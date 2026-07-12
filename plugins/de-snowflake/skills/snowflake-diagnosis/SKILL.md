---
name: snowflake-diagnosis
description: Snowflake failure modes by symptom - slow query tree (pruning, spilling, exploding joins, queuing), result cache miss reasons, stale streams, tasks that silently stopped, numbers-dont-match causes including timezone defaults, warehouse sizing decisions. Use when diagnosing slow, failing, or wrong-result workloads on Snowflake.
---

# Snowflake diagnosis (doc-verified)

Evidence surfaces: Query Profile (Snowsight) and `ACCOUNT_USAGE.QUERY_HISTORY` columns —
every branch below names its metric.

## "Query is slow" — walk the tree in this order

1. **Pruning failure**: Query Profile "Partitions scanned" ≈ "Partitions total"
   (`PARTITIONS_SCANNED` vs `PARTITIONS_TOTAL`) — data organization doesn't match the
   filter. Fixes: filter on natural-order columns, clustering key (only if multi-TB +
   stable), or restructure the predicate. A function wrapping the filter column kills
   pruning here just like everywhere else.
2. **Spilling**: `BYTES_SPILLED_TO_LOCAL_STORAGE` (bad) vs `_REMOTE_STORAGE`
   (severe — docs: "profound effect"). Fixes per docs: bigger warehouse (more memory +
   local disk) or smaller batches. This is the ONE case where "bigger warehouse" is the
   documented answer.
3. **Exploding join**: join operator produces "significantly (often by orders of
   magnitude) more tuples than it consumes" — missing/insufficient join condition or
   fanout duplicates. Fix the data/condition, not the warehouse.
4. **Queuing**: `QUEUED_OVERLOAD_TIME` — the warehouse is busy, not slow. More
   clusters (multi-cluster, Enterprise+) fixes concurrency; bigger size does NOT
   ("larger is not necessarily faster for smaller, more basic queries").

## Result cache — why "the same query" re-billed

Reuse requires ALL of: byte-identical text (case and aliases included), no
non-deterministic functions (RANDOM, UUID_STRING), no external functions, unchanged
underlying data AND micro-partitions (reclustering invalidates even when data is
logically identical), privileges intact. Retention 24h (extends on reuse, max 31 days).
`RESULT_SCAN()` reuses a prior result explicitly.

## "CDC broke" — streams and tasks fail silently

- **Stale stream**: `SHOW STREAMS` → `STALE_AFTER` in the past. Cause: not consumed in
  a committed DML within the extension window (default 14 days). Recovery: recreate the
  stream (the missed interval is lost through the stream) + backfill via `CHANGES`
  clause or source reload (`practice-backfill-safety`).
- **Task stopped**: TASK_HISTORY status `FAILED_AND_AUTO_SUSPENDED` (10 consecutive
  failures — default), `SKIPPED` (WHEN predicate false — normal), or root suspended
  (cancels all future graph runs). INFORMATION_SCHEMA.TASK_HISTORY covers 7 days;
  ACCOUNT_USAGE for older history. Alert on task state, not just data freshness
  (`practice-observability-and-ownership`).

## "Numbers don't match" — ordered checklist

1. **Timezones first**: bare TIMESTAMP maps to **TIMESTAMP_NTZ** (no timezone) by
   default, while the session `TIMEZONE` defaults to **America/Los_Angeles** — mixed
   NTZ/LTZ arithmetic and non-UTC sessions are the classic off-by-hours cause. TZ
   stores an offset, not a zone (no DST retro-application).
2. Time Travel reads (`AT`/`BEFORE`) pinned to a past point legitimately disagree with
   current data — check the query text before the data.
3. Clone divergence: source and clone silently diverge from the clone point; verify
   which object the report actually reads.
4. Nondeterministic MERGE with `ERROR_ON_NONDETERMINISTIC_MERGE=FALSE` — undefined row
   selection; treat the setting itself as the finding.
5. Result cache serving a pre-fix result within 24h of a data correction — rerun with
   `USE_CACHED_RESULT=FALSE` when validating fixes (`deliverable-broken-report-fix`
   validation step).

## Warehouse sizing — what actually helps

| Symptom | Lever |
| --- | --- |
| Spilling (local/remote bytes > 0) | Bigger warehouse |
| Queuing (`QUEUED_OVERLOAD_TIME`) | More clusters (multi-cluster) or workload split |
| Row-by-row UDFs, single-thread logic | Nothing — fix the code |
| Small queries slow | Not size — check caching, pruning, cloud-services latency |

Complex queries "scale linearly with warehouse size" (docs) — but only the ones that
were parallelizable in the first place.
