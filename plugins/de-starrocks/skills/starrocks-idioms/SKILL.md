---
name: starrocks-idioms
description: StarRocks engine idioms - table model selection (Primary Key vs Duplicate vs Aggregate), expression partitioning, bucketing, load-method idempotency via labels, safe interval-rerun patterns, partial/conditional updates. Use when designing tables, choosing load patterns, or implementing pipelines on StarRocks.
---

# StarRocks idioms (3.x)

How de-core practices map to StarRocks mechanics. Verified against docs.starrocks.io
(2026); version-gated features are flagged.

## Table model selection

| Model | Duplicate handling | Use when |
| --- | --- | --- |
| **Primary Key** | Replaces row by key (delete+insert at WRITE time) | Upserts/CDC, frequently updated tables — the default choice for curated layers |
| **Duplicate Key** | None — "key" is just a sort key | Logs, immutable events, raw/landing layers |
| **Aggregate** | Merges rows by key (SUM/MAX/REPLACE/...) | Pre-aggregated metrics where detail is not needed |
| Unique Key (legacy) | Replaces row via merge-on-READ | Do not use for new tables — Primary Key is its successor |

Key insight vs eventual-dedup engines: **Primary Key tables are read-consistent** —
dedup happens at write time (DelVector + new file), so reads never see duplicate versions
and never pay a merge penalty. This makes PK upserts a true idempotent write pattern.

PK constraints that bite in design: the key is immutable, ≤128 bytes encoded, no DECIMAL,
and **must include all partition and bucket columns** (see the duplicate trap in
`starrocks-diagnosis`). Always keep `enable_persistent_index=true` (default) — without it
large key sets blow up BE memory.

## Partitioning and bucketing

- **Expression partitioning (v3.0+, recommended)**: `PARTITION BY date_trunc('day', event_day)`
  — partitions auto-created at load. Docs position it to replace range partitioning
  (range + `dynamic_partition.*` remains valid on existing tables). Retention:
  `partition_live_number`, or `partition_retention_condition` (v3.5+).
- **Bucketing**: leave **auto bucket count** on (default since v2.5.7); size manually only
  when a partition exceeds ~100 GB. Rule: **~10 GB per tablet**. Random bucketing (v3.1+,
  Duplicate Key only) avoids skew when there is no natural key.
- Never partition finer than the data justifies: tiny partitions × buckets = tablet
  explosion (see diagnosis).

## Load methods and idempotency

All load methods are **atomic** per job and deduplicated by **label** — but labels are
per-database and expire (`label_keep_max_second`, **default 3 days**). Labels are
idempotency within that window only.

| Method | Idempotency property |
| --- | --- |
| Stream Load (HTTP, sync) | Caller-set label → retry returns "Label Already Exists" = dedup worked |
| Stream Load transaction API | 2PC begin/prepare/commit → exactly-once across systems (what the Flink connector uses) |
| Routine Load (Kafka) | Exactly-once: each task is a transaction + FE-tracked offsets |
| Broker Load | Async, labeled, atomic |
| INSERT INTO SELECT | Atomic, labeled |

## Safe interval-rerun patterns (practice-idempotency-and-reruns)

1. **PK table + upsert** — naturally idempotent, preferred for curated layers.
2. **Non-PK table + `INSERT OVERWRITE ... PARTITION (...)`** — atomically replaces exactly
   those partitions; the canonical bounded replace. **Trap**: `INSERT OVERWRITE` WITHOUT a
   partition clause replaces the whole table. v3.4+ `dynamic_overwrite=true` replaces only
   partitions receiving data.
3. **Deterministic label per interval** (e.g. `load_<table>_<interval>`) — dedups retries,
   but only within the 3-day label window; not a substitute for patterns 1-2 on backfills.
4. **Transaction interface** when an external system needs 2PC.

## Updates on Primary Key tables

- `__op` field: 0=UPSERT (default) / 1=DELETE in Stream/Broker/Routine Load.
- **Partial updates** (`partial_update:true`): row mode for small real-time batches across
  many columns; column mode for few columns × many rows (batch).
- **Conditional updates** (v2.5+): apply only when the source value ≥ a designated
  condition column (e.g. greater `event_time` wins) — the built-in guard against
  out-of-order upserts. Compatible with partial updates from v3.1.3.

Sources: docs.starrocks.io — table_types/table_capabilities, primary_key_table,
best_practices/primarykey_table, data_distribution/, loading_concepts, INSERT,
Load_to_Primary_Key_tables, Stream_Load_transaction_interface, RoutineLoad.
