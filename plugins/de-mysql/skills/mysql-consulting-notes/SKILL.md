---
name: mysql-consulting-notes
description: MySQL as a CDC/extraction source - binlog format and retention prerequisites, GTID vs position offsets, consistent snapshots, replica lag that lies, online DDL interaction with CDC, charset and type-mapping traps. Use when extracting from, replicating, or setting up CDC against a MySQL database in a data engineering engagement.
---

# MySQL consulting notes — the source-system delta

Consulting DELTA only — schema/indexing/isolation/online-DDL knowledge comes from
PlanetScale's official `mysql` skill (install per the pack README). In DE engagements
MySQL is almost always the SOURCE; this skill is the CDC/extraction posture no vendor
skill covers.

## CDC prerequisites — check these BEFORE promising binlog-based CDC

- **`binlog_format=ROW` + `binlog_row_image=FULL`** are hard prerequisites for Debezium
  and friends. STATEMENT/MIXED silently break downstream consumers. On RDS/Aurora these
  live in parameter groups, not `my.cnf` — verify the actual running values
  (`SHOW VARIABLES LIKE 'binlog%'`), not the config file.
- **Binlog retention is THE CDC failure mode**: `binlog_expire_logs_seconds` (8.0+),
  or on RDS `binlog retention hours` — whose default is NULL, meaning binlogs are purged
  almost immediately. A connector paused longer than retention forces a full re-snapshot.
  Size retention against worst-case downstream downtime, and say the number in the design
  note (`deliverable-new-pipeline`).
- **GTID mode (`gtid_mode=ON`) vs file+position offsets**: position-based offsets do not
  survive failover; GTID-based ones do. Legacy clients still run position-based — flag it
  as a resilience finding, not a nitpick.
- **Online DDL tools interact with CDC**: gh-ost (binlog-based) floods the binlog with
  shadow-table traffic and confuses connectors unless its tables are filtered; pt-osc
  (trigger-based) multiplies write load. Coordinate schema migrations with the CDC owner.

## Consistent extraction

- Initial loads: `START TRANSACTION WITH CONSISTENT SNAPSHOT` (or `mysqldump
  --single-transaction`) gives a nonblocking consistent read under InnoDB's default
  `REPEATABLE READ` — note this default differs from Postgres (`READ COMMITTED`) and gap
  locks make long extraction transactions more intrusive than PG consultants expect.
- **`Seconds_Behind_Source` lies**: it reads 0-or-spike under relay-log stalls and NULL
  when the IO thread is dead. Use a heartbeat table or `performance_schema` replication
  tables to measure real replica lag; extracting "up to now" from a lagging replica
  silently loses the lag window (`practice-incremental-processing` watermark integrity).
- Keyset pagination for bulk pulls (`WHERE id > last ORDER BY id LIMIT n`) — `OFFSET`
  rescans from zero. Same rule as every source pack; it dies faster on MySQL because
  `OFFSET` cannot use the clustered index efficiently.

## Type-mapping traps (MySQL → warehouse)

- **`utf8` is NOT UTF-8** — it is 3-byte `utf8mb3`; emoji and some CJK break. Columns and
  the connector handshake must both be `utf8mb4`; mojibake findings usually live in the
  handshake, not the data.
- **Implicit coercion kills indexes AND corrupts predicates**: comparing a VARCHAR column
  to a number makes `'1abc' = 1` true and forces full scans. Audit extraction predicates
  for type mismatches on both sides.
- Zero-dates (`0000-00-00`) crash strict-mode consumers; `TIMESTAMP` converts through the
  session timezone while `DATETIME` is naive — mixed usage is a classic
  "numbers shift by N hours" root cause; unsigned BIGINT overflows signed 64-bit readers.

## Engagement posture

- MCP server is read-only by default (pack `.mcp.json`); the durable guarantee is a
  `SELECT`-only DB user — ask for it on day one (`method-safe-operations`).
- Heavy analytics running ON the MySQL primary is the finding, not the workload to tune
  (`practice-architecture-selection` Decision 1).
