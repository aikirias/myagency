---
name: clickhouse-consulting-notes
description: ClickHouse consulting delta - engagement gotchas (eventual dedup, real-time misuse, parts pressure, mutation traps), how de-core practices map to ClickHouse mechanics, and safe-operations specifics. Use when diagnosing, designing, fixing, or auditing anything on a ClickHouse cluster.
---

# ClickHouse consulting notes

This is the consulting DELTA only. General best practices (schema design, query
optimization, ingestion) come from ClickHouse's own maintained skills — install them per
the pack README. This skill covers what those don't: the failure patterns that generate
consulting engagements, mapped to the de-core method.

## Requirement-fit checks (method-diagnosis step 3)

The single most common ClickHouse engagement: **the client treats it as a real-time or
OLTP database.** Check for these mismatches first:

- **"Real-time" dashboards over `ReplacingMergeTree`**: deduplication happens at merge
  time, not insert time. Reads shortly after insert see duplicates BY DESIGN. If the
  symptom is "numbers jump around / duplicates appear and disappear", this is the first
  hypothesis. Fixes are design-level: query-time dedup (`argMax` by version column, or
  `FINAL` accepting its cost), or accept merge lag and set expectations.
- **Frequent small inserts** (per-event, per-request): produces parts explosion, insert
  errors (`too many parts`), and merge pressure. Look for batch size in the ingestion
  path; the fix is batching or `async_insert`, not a bigger cluster.
- **Point updates/deletes as workflow**: `ALTER TABLE ... UPDATE/DELETE` are asynchronous
  heavyweight mutations that rewrite parts — using them routinely means the workload is
  OLTP-shaped and ClickHouse is the wrong tool for that slice, or the model needs
  rethinking (versioned rows + ReplacingMergeTree).

## Storage-fit checks (method-diagnosis step 4)

- **Over-granular `PARTITION BY`**: partitioning by day on low volume, or by a
  high-cardinality key, creates thousands of parts and kills insert/merge performance.
  Partition for pruning and TTL/retention (typically by month); use `ORDER BY` — not more
  partitions — for query locality. Check `system.parts` for part counts per partition.
- **`ORDER BY` vs actual filters**: the sorting key is the primary index. If dashboard
  queries filter on columns not prefixing the `ORDER BY`, scans are near-full despite
  "having an index".
- **JOIN memory**: the right-hand table of a hash join loads into memory. Large-right-side
  joins cause OOM kills that present as "the query randomly fails". Check join order and
  dictionary/`JOIN` engine alternatives.

## Idempotency on ClickHouse (practice-idempotency-and-reruns)

- **Bounded replace** maps to `ALTER TABLE ... DROP PARTITION` + `INSERT` for the interval
  — atomic per partition, the cleanest rerun-safe pattern. This is also the standard
  rollback mechanism for fixes (drop the bad partition, re-insert).
- **`ReplacingMergeTree` is NOT a rerun guarantee by itself**: dedup is eventual and
  intra-partition. A rerun is only clean after merges settle (or with query-time dedup).
  Never validate a rerun by `SELECT count(*)` right after insert. [REVIEW: confirm your
  preferred validation pattern — `count()` with `FINAL`, or argMax comparison?]
- `OPTIMIZE TABLE ... FINAL` forces merges but is expensive and blocking on large tables —
  a diagnostic/repair tool, not a pipeline step.

## Safe operations specifics (method-safe-operations)

- `EXPLAIN` variants: `EXPLAIN indexes = 1` shows partition pruning and primary-key usage
  — the rule-1 check before running anything. `EXPLAIN ESTIMATE` gives rows/parts to read.
- Bound probes with partition-key filters AND `LIMIT`; on shared clusters set
  `max_execution_time` and consider `max_threads` for heavy diagnostics.
- The pack's MCP server is read-only by default; keep it that way on client systems. Ask
  for a read-only user as well (defense in depth).
- Dropped data is recoverable short-term (`system.dropped_tables`, backups) but treat
  `DROP PARTITION` as destructive: it is the fix mechanism AND the rollback mechanism, so
  always snapshot the partition (e.g. `INSERT INTO backup_table SELECT ...` with client
  permission, or rely on their backup) before replacing it.

## Audit shortcuts (deliverable-platform-audit)

High-signal system tables for the audit dimensions:

- Cost/efficiency: `system.query_log` (top queries by `read_bytes`/`memory_usage`),
  `system.parts` (storage per table, part counts)
- Architecture: tables with default/no TTL, partition schemes vs query filters
- Quality/consistency: duplicate rates via business-key `GROUP BY ... HAVING count() > 1`
  sampled per partition

[REVIEW: add your recurring ClickHouse gotchas from real engagements — the list above is
the draft baseline; your field experience should extend or correct it.]
