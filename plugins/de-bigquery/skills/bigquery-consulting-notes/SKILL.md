---
name: bigquery-consulting-notes
description: BigQuery consulting delta - bytes-scanned cost model and on-demand vs capacity pricing, partition pruning failures, clustering limits, MERGE cost on big tables, streaming inserts vs Storage Write API, load quotas, slot contention, time travel window. Use when optimizing cost, designing loads, or diagnosing expensive queries on BigQuery in a data engineering engagement.
---

# BigQuery consulting notes

Consulting DELTA only — query/analytics mechanics come from Google's official
`bigquery-data-analytics` plugin (install per the pack README). This skill carries the
cost model and the pruning/loading traps that decide engagement outcomes.

## The cost model IS the engagement

- **On-demand bills bytes SCANNED, not returned** (~$6.25/TiB). `LIMIT 10` does not
  reduce scan; `SELECT *` on a wide table pays for every column. The first audit query
  is always `INFORMATION_SCHEMA.JOBS` ordered by `total_bytes_billed`
  (`practice-cost-optimization` cost map).
- **On-demand vs capacity (Editions autoscaling slots) crossover** is a standard
  deliverable: steady heavy workloads → capacity; spiky/light → on-demand. Show the
  math from 30-90 days of `JOBS` history, not intuition.
- Always run with `maximum_bytes_billed` set (the pack's MCP config exposes it as an
  env var) — a runaway query should fail, not bill.

## Partition pruning — where the money leaks

- **Pruning silently fails when the partition column is wrapped in a function**
  (`WHERE DATE(ts) = ...`), compared against a subquery result, or joined dynamically —
  full scan at full price with zero warnings. Predicates must be constant filters on
  the bare partition column. Verify with a dry run (`--dry_run` bytes estimate) before
  and after — this is `method-safe-operations` rule 8 in BigQuery form.
- Set `require_partition_filter` on big partitioned tables so unpruned queries fail
  loudly instead of billing quietly.
- **Clustering** only helps filters/aggregations on the clustered columns in declared
  order, and gives no hard cost cap up front (the estimator shows an upper bound).
  Partitioning gives the guarantee; clustering gives the discount.

## Loading and mutation

- **Storage Write API over legacy streaming inserts** (~half the price, first 2TiB/month
  free, exactly-once semantics available). Rows in the streaming buffer have DML
  restrictions — recently-streamed data can't be immediately updated/deleted.
- **MERGE on large tables rescans the full target unless the merge condition contains
  literal partition predicates** — CDC upserts without partition pruning in the ON/WHEN
  clauses are the classic silent cost explosion (`practice-incremental-processing`).
- **Quotas are pipeline design constraints**: 1,500 load jobs (and table-modification
  operations) per table per day — micro-batching every minute hits it by mid-afternoon.
  Batch accordingly or use the Write API.

## Diagnosis quick map

- Slow + expensive → pruning failure (check bytes processed vs table size).
- Slow + cheap → slot contention (on-demand fair-shares ~2,000 slots/project; check
  `JOBS` slot_ms and concurrent load) or a skewed join stage.
- "Same query, different cost" → query cache miss: cache is 24h, per-user, and disabled
  by non-deterministic functions (`CURRENT_TIMESTAMP`), destination tables, or
  streaming-buffered source tables.
- Recovery window: time travel is 2-7 days per dataset (default 7) + 7-day fail-safe
  (admin recovery only). Shortening it cuts storage cost AND recovery options — that
  trade-off is a client decision to document (`practice-data-lifecycle`).
