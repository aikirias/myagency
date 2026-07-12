---
name: trino-engine
description: Trino engine semantics and tuning - fault-tolerant execution off by default, per-query memory kills, cost-based optimizer and stats discipline, pushdown variance per connector, timestamp semantics across catalogs, Iceberg and Delta connector maintenance commands. Use when tuning, diagnosing, or designing queries and maintenance on a Trino cluster.
---

# Trino engine (verified against Trino 482 docs)

## What Trino is NOT (set expectations in discovery)

- **Not fault-tolerant by default**: `retry-policy` defaults to NONE — a worker dying
  mid-query kills the query. FTE is opt-in: `QUERY` retry (small queries; results
  buffer capped at 32MB without an exchange manager) or `TASK` retry (large batch;
  REQUIRES an external exchange manager, adds latency, best on a dedicated cluster).
  A client running 4-hour ETL on non-FTE Trino has a reliability finding.
- **Single coordinator**: all results funnel through it. `SELECT *` exports and
  agent/MCP access need result caps — read-only + limits is the posture (the pack
  README's MCP table).
- Memory limits are guillotines, not backpressure: `query.max-memory-per-node`
  (default 30% of heap) and `query.max-memory` (default 20GB) KILL the query on breach.
  Spill-to-disk is legacy/discouraged — the modern answer to memory-heavy batch is FTE
  task retry, not spill tuning.

## CBO — stats are a prerequisite, not an optimization

- `join-distribution-type` and `join-reordering-strategy` default AUTOMATIC = cost-based
  — **without table stats the CBO is blind**, falls back to hash-distributed arbitrary
  join order, and "Trino is slow" tickets follow. Hive: run `ANALYZE`. Iceberg: stats
  collect on write by default (`iceberg.extended-statistics.collect-on-write=true`) but
  ANALYZE after large non-Trino writes.
- Broadcast joins capped by `join-max-broadcast-table-size` (default 100MB) — a
  dimension table just over the cap silently switches to partitioned join; check
  `EXPLAIN` when a join regresses after growth.

## Pushdown varies per connector — always EXPLAIN

Predicate/projection/dereference pushdown is broad; **aggregate and join pushdown are
documented for JDBC connectors** (PostgreSQL etc.), while lake connectors rely on
predicate/projection + stats pruning. The same query shape can be fast on one catalog
and a full scan on another — `EXPLAIN` before promising anything cross-catalog.

## Timestamps — the cross-connector trap

- `TIMESTAMP(P)` is a wall-clock value: Trino does NOT adjust it to the session
  timezone (post-341 semantics). `TIMESTAMP WITH TIME ZONE` is a point in time.
- Mappings differ: Iceberg `timestamp` → TIMESTAMP(6), `timestamptz` → TIMESTAMP(6) WITH
  TIME ZONE; Delta `TIMESTAMP` → TIMESTAMP(3) **WITH TIME ZONE**, `TimestampNTZ` →
  TIMESTAMP(6). Joining "the same" timestamp across catalogs can silently shift hours.
- Legacy Hive files: `parquet.time-zone` / `orc.time-zone` (set UTC for Hive 3.1+);
  `hive.timestamp-precision` default MILLISECONDS truncates micros. Property prefixes
  changed across versions — verify against the deployed Trino before shipping configs.

## Table maintenance FROM Trino (often the only engine the client gives you)

| Format | Commands | Guardrails |
| --- | --- | --- |
| Iceberg | `ALTER TABLE ... EXECUTE optimize` (file_size_threshold 100MB), `expire_snapshots(retention_threshold => '7d')`, `remove_orphan_files`, `optimize_manifests` | `iceberg.expire-snapshots.min-retention` / `remove-orphan-files.min-retention` default **7d** — the connector refuses shorter (good; don't tune it down) |
| Delta | `ALTER TABLE ... EXECUTE optimize` (compaction only — NO zorder/clustering from Trino), `CALL system.vacuum(schema, table, '7d')` | `delta.vacuum.min-retention` default 7 DAYS |

Time travel from Trino: `FOR VERSION AS OF` / `FOR TIMESTAMP AS OF` on both connectors —
the reconciliation tool for "numbers changed since yesterday" diagnosis.

## Quick diagnosis map

- Query killed with memory error → per-query limit hit: reduce shape (join order,
  pre-aggregation) or move the workload to FTE-task cluster; resist the "raise the
  limit" reflex — it starves neighbors.
- Fast yesterday, slow today → stats staleness or broadcast→partitioned flip.
- Wrong timestamps → mapping table above, then legacy file TZ properties.
- Cluster-wide slowness → coordinator saturation (huge result pulls, too many small
  queries) before blaming workers.
