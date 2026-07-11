---
name: postgres-consulting-notes
description: PostgreSQL consulting delta - PG as a source system (CDC slots, extraction safety, replica lag), MVCC bloat and vacuum signals, lock-safe DDL, EXPLAIN ANALYZE cautions. Use when extracting from, diagnosing, or operating against a PostgreSQL database in a data engineering engagement.
---

# PostgreSQL consulting notes

Consulting DELTA only — general PG schema/indexing/tuning knowledge comes from Timescale's
`pg-aiguide` (install per the pack README). In DE engagements PG is usually the SOURCE
(an OLTP system you extract from) or a small serving DB — and the engine-class rule
applies (`practice-architecture-selection` Decision 1): heavy analytics on the production
OLTP database is the finding, not the workload to tune.

## PG as a source system — the gotchas that cause incidents

- **Logical replication slots (CDC) retain WAL until consumed.** An abandoned or lagging
  slot (a CDC pipeline that stopped, a POC someone forgot) makes WAL grow until the disk
  fills and the PRIMARY goes down — a data-engineering artifact taking down the client's
  production app. Audit check on every PG source:
  `SELECT slot_name, active, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) FROM pg_replication_slots;`
- **Long-running extraction queries on the primary** hold back vacuum (xmin horizon) →
  bloat and eventual autovacuum storms. Extract from a **read replica** when one exists;
  if on the primary, keep extraction transactions short and set `statement_timeout` on
  your own session (`method-safe-operations` rule 2's PG form).
- **Replica lag vs incremental extraction**: extracting "up to now" from a lagging
  replica silently loses the lag window. Bound extractions by a watermark the replica has
  confirmed (`practice-incremental-processing` watermark integrity), not by wall-clock.
- **Bulk export**: `COPY` outperforms row-by-row SELECT dramatically; paginate with
  keyset (`WHERE id > last_id ORDER BY id LIMIT n`), never `OFFSET` (re-scans from zero,
  degrades linearly).

## MVCC realities

- UPDATE/DELETE do not reclaim space — they create dead tuples; mass updates (a
  "harmless" backfill UPDATE on a big table) generate bloat + WAL surges + replication
  lag downstream. For interval rewrites prefer partition-level operations (`DROP/ATTACH
  PARTITION`) or staged copy-and-swap.
- Bloat signals for audits: `pg_stat_user_tables.n_dead_tup` vs `n_live_tup`, autovacuum
  falling behind on the hottest tables, index bloat after mass churn (`REINDEX
  CONCURRENTLY` as remediation).

## Diagnosis toolkit cautions

- **`EXPLAIN ANALYZE` EXECUTES the statement** — on SELECT it costs the read; on
  INSERT/UPDATE/DELETE it PERFORMS the writes. For DML plans, wrap in
  `BEGIN; EXPLAIN ANALYZE ...; ROLLBACK;` — this is the `method-safe-operations` rule-8
  dry-run, verbatim, on PG. Plain `EXPLAIN` (no ANALYZE) is always safe.
- `EXPLAIN (ANALYZE, BUFFERS)` shows real I/O — the difference between "slow query" and
  "cold cache" findings.
- High-signal views for audits: `pg_stat_statements` (top queries by total time — THE
  cost-map source), `pg_stat_activity` (long transactions, idle-in-transaction),
  `pg_locks` (blocking chains), `pg_stat_user_tables`/`indexes` (dead tuples, unused
  indexes).

## Lock-safe changes

- DDL takes `ACCESS EXCLUSIVE`: an innocent `ALTER TABLE` queues behind a long query and
  then blocks EVERYTHING behind it — on busy tables always set `lock_timeout` before DDL
  and use `CREATE INDEX CONCURRENTLY` (and `DROP ... CONCURRENTLY`).
- Adding a column with a volatile default, or changing a column type, rewrites the table;
  additive nullable columns are the safe path (`practice-observability-and-ownership`
  safe-deployment posture).

## Serving-layer notes

PG is a fine small serving DB (single-node dashboards, app-facing aggregates). The audit
signal that it stopped being fine: analytical queries dominating `pg_stat_statements` on
an OTLP instance, BI tools hitting the primary, work_mem tuning wars — that is Decision 1
territory, propose the analytical store instead of tuning harder.
