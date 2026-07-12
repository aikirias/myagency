---
name: kafka-connect-debezium
description: Kafka Connect and Debezium CDC consulting - error tolerance and DLQ scope, internal topic compaction requirements, source EOS, Debezium snapshot modes and incremental snapshots, schema history topic rules, tombstone handling SMT trap, binlog and WAL retention failure modes. Use when building, configuring, or diagnosing Kafka Connect pipelines or Debezium CDC connectors.
---

# Kafka Connect + Debezium (verified: Kafka 4.x, Debezium 3.6)

## Connect — the framework rules that bite

- **`errors.tolerance` defaults to `none`**: one bad record fails the whole task. The
  common flip to `all` without a DLQ silently SKIPS bad records — worse. The correct
  trio for sinks: `errors.tolerance=all` + `errors.deadletterqueue.topic.name=...` +
  `errors.deadletterqueue.context.headers.enable=true`.
- **DLQ is SINK-only.** Source connectors (i.e., all of Debezium) have no DLQ — a
  poison source record needs connector-level handling. Never promise "we'll DLQ it" on
  the source side.
- **Internal topics must be compacted** (doc-verbatim requirement): config topic =
  single partition + compacted; offset and status topics = replicated + compacted. A
  cluster where someone let auto-creation make these with `cleanup.policy=delete` will
  eventually lose connector offsets — check all three on every Connect audit.
- Converter vs SMT confusion: converters (de)serialize, SMTs transform. The classic
  failure — JsonConverter with `schemas.enable=true` expects a `{schema, payload}`
  envelope and fails on plain JSON (flagged Confluent-documented). Match
  `schemas.enable` to what's actually in the topic, per converter, key and value
  separately.
- **Source EOS exists**: worker `exactly.once.source.support` (default `disabled`;
  rolling enable via `preparing` → `enabled`, distributed mode only). Debezium +
  source EOS removes the classic "duplicates after connector restart" — but sinks stay
  at-least-once regardless.

## Debezium — snapshot vs streaming

- `snapshot.mode` default `initial` (snapshot then stream). The two useful non-defaults:
  `no_data` (stream only — ONLY safe if all needed history is still in the log) and
  `when_needed` (auto re-snapshot when offsets are unrecoverable — self-healing but can
  surprise with a full-table re-read at 3am; decide which failure you prefer).
  MySQL `recovery` mode carries a doc WARNING: never use it if schema changed since
  the last shutdown.
- **Incremental snapshots** (signal table + `signal.data.collection`) re-snapshot
  chosen tables WITHOUT stopping streaming — the answer to "we need to re-sync one
  table" that doesn't cost a full re-snapshot. Requires the signal table writable by
  the connector user; set it up on day one, not during the incident.
- Snapshot vs streaming phase is visible in JMX: `SnapshotRunning`/`SnapshotCompleted`
  and `MilliSecondsBehindSource` — "is it still snapshotting or is it lagging" is a
  metrics read, not a guess.

## The retention failure modes (both directions)

- **MySQL: connector paused > binlog retention** (`binlog_expire_logs_seconds`, MySQL
  default 30 days but often lowered; RDS default effectively hours) → position lost →
  forced full re-snapshot, or hard failure if snapshots disabled. Size retention
  against worst-case downtime.
- **Postgres: the INVERSE** — the replication slot RETAINS WAL while the connector is
  down; a paused connector fills the source disk (see `de-postgres` audit query). And
  on LOW-traffic databases, set `heartbeat.interval.ms` > 0 (default 0 = no
  heartbeats) or the slot never advances and WAL grows even while "working".
- Prerequisites checklist (MySQL): `binlog_format=ROW`, `binlog_row_image=FULL`,
  unique server-id, GTID recommended — verify running values, not config files
  (`de-mysql` pack has the source-side detail).

## Schema history topic (MySQL/SQL Server connectors)

Doc-verbatim rules: **single partition, NO compaction, infinite (or very long)
retention**, RF >= 3. It is internal-only (consumers use schema *change* topics, a
different thing). Corrupted/lost history topic = `snapshot.mode=recovery` (schema-only
rebuild) — with the schema-change warning above. Postgres connectors have no history
topic at all.

## The tombstone SMT trap

`ExtractNewRecordState` (unwrap) — current option `delete.tombstone.handling.mode`,
default `tombstone` (keeps tombstones). Setting `rewrite` (adds `__deleted=true`)
**removes tombstones** → downstream compacted topics NEVER physically delete those
keys, and sink connectors doing delete-on-tombstone stop deleting. If downstream needs
both a soft-delete flag and real deletes: `rewrite-with-tombstone`. The legacy options
(`drop.tombstones`, `delete.handling.mode`) are deprecated/renamed — audit old
connector configs for them.

Compacted CDC data topics: tune `delete.retention.ms` up so slow consumers still see
tombstones (`kafka-idioms` tombstone window).
