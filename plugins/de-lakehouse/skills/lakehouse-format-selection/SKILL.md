---
name: lakehouse-format-selection
description: Vendor-neutral table format selection - Iceberg vs Delta Lake vs plain Parquet decision inputs, engine ecosystem constraints, catalog strategy, interop bridges and their limits. Use when choosing or reviewing the table format and catalog for a lakehouse architecture.
---

# Lakehouse format selection

Particularizes `practice-architecture-selection` (Decision 2, warehouse vs lakehouse)
one level down: once "lakehouse" won, which format — and the answer is constraints, not
fashion. Record the decision as a RES record when it's contested (`research` plugin).

## Decision inputs (doc-sourced strengths)

**Iceberg** — pick when engine neutrality is the requirement:

- Hidden partitioning + partition/schema evolution without rewrites (old data keeps the
  old spec — metadata-only evolution).
- REST catalog spec = one client protocol against any catalog backend; this is where
  the ecosystem is converging (Polaris, Lakekeeper, Glue REST, Unity all speak it).
- First-party docs for Spark, Flink, AND Trino — genuinely multi-engine.

**Delta** — pick when Spark is the center of gravity:

- Deepest Spark-native feature set: schema enforcement, generated columns, CHECK
  constraints, CDF, native idempotent writes (txnAppId/txnVersion).
- Deletion vectors mature (default-on for DML since 3.1) — best-in-class for
  update-heavy Spark pipelines.
- UniForm bridges to Iceberg readers — but read-only, no DVs, feature-gated
  (see `delta-discipline`). A bridge is not neutrality.

**Plain Parquet + Hive-style layout** — still legitimate when ALL hold: append-only,
single engine, no row-level ops, no time travel/ACID needs. (Consulting judgment, not a
doc quote — the doc-sourced part is that every format benefit is the delta over Parquet:
ACID commits, deletes, evolution, travel.) Don't sell table-format migration to a client
whose workload never uses the delta.

## Constraint questions that decide it (ask in discovery)

1. **Which engines MUST read these tables in 3 years?** More than Spark → Iceberg lane.
   Spark-only + Databricks trajectory → Delta lane (and `de-databricks` lock-in review).
2. **Who writes?** Flink upsert CDC → Iceberg equality-delete + compaction story
   (`iceberg-discipline`); Spark MERGE-heavy → Delta DV story (`delta-discipline`).
3. **Catalog**: Hive Metastore is the legacy default, Glue is AWS lock-in with IAM
   semantics, REST-based is the neutral future. Catalog choice is harder to reverse
   than format choice — treat it as the bigger decision.
4. **Update/delete rate**: CDC-heavy → merge-on-read variants + mandatory compaction
   budget (someone must own the maintenance schedule — name them,
   `practice-observability-and-ownership`).
5. **Compliance erasure**: both formats soft-delete by default (Iceberg delete files,
   Delta DVs) — physical erasure needs explicit purge steps (`practice-pii-handling`).

## Anti-patterns (audit findings)

- Format chosen ≠ maintenance owned: a lakehouse with no compaction/expiration schedule
  is a slow-motion incident in both formats.
- Dual-format "we'll keep both in sync" without UniForm/one-way declared — two sources
  of truth (`deliverable-platform-audit` consistency dimension).
- Migrating append-only Parquet to a table format "for modernization" with zero
  row-level or time-travel requirements — cost without the benefit.
