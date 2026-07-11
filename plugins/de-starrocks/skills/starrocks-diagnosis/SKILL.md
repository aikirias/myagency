---
name: starrocks-diagnosis
description: StarRocks failure modes by symptom - too many versions / compaction lag, duplicate data despite Primary Key, label and transaction errors, BE memory, tablet skew, pruning failures, and the query analysis toolkit. Use when diagnosing errors, wrong results, duplicates, or slow queries on StarRocks.
---

# StarRocks diagnosis (3.x)

Engine-specific extension of `method-diagnosis` steps 4-5. Organized by symptom.

## "too many tablet versions" / loads failing, queries degrading

The classic StarRocks incident: load frequency outpacing compaction (limit: BE
`tablet_max_versions`, default 1000). Root cause is almost always **high-frequency tiny
loads** — StarRocks is not an OLTP sink; the fix is batching, not a bigger cluster.

- Shared-data clusters: check compaction score —
  `SELECT * FROM information_schema.partitions_meta ORDER BY Max_CS DESC` or
  `SHOW PROC '/dbs/<db>/<table>/partitions'`. Thresholds: **<10 healthy, >100 load
  throttling begins, >500 manual intervention (`ALTER TABLE t COMPACT`), >2000 load
  transactions rejected**.
- Shared-nothing: BE compaction thread configs per table type (Primary Key:
  `update_compaction_*`; others: `cumulative/base_compaction_*`).
- Profile smell: `SegmentsReadCount / TabletCount` in the tens = unmerged accumulation.
- Related symptom: "current running txns on db X is 100" (`max_running_txn_num_per_db`) —
  same root cause, too many small loads.

## Duplicates despite "we have a Primary Key" — the 5 real mechanics

When the client swears the key is unique but duplicates exist, check in order:

1. **The table is actually Duplicate Key** — no constraint at all; retries without label
   discipline duplicate rows. `SHOW CREATE TABLE` first, always.
2. **Label expiry**: labels dedup for `label_keep_max_second` (default **3 days**);
   re-runs after that reload into non-PK tables.
3. **Labels are per-database**: the same data loaded under different labels or into
   another DB is not deduplicated.
4. **Partition column inside the PK**: the key must include partition/bucket columns, so
   if a mutable attribute (e.g. an event date that gets corrected) is part of the key, the
   "same" business entity becomes a second row in another partition.
5. **At-least-once writers**: external loaders using fresh random labels per retry get
   at-least-once, not exactly-once — deterministic labels or the transaction API fix it.

## "Label Already Exists"

Usually idempotency WORKING, not a bug: an HTTP retry re-submitted the label. Verify with
`SHOW LOAD WHERE LABEL = '...'` — if the original is FINISHED, the retry was correctly
deduplicated. Only investigate if the original failed.

## Routine Load stopped silently

Default `max_error_number=0` pauses the job (`PAUSED`) on the first bad row. Check
`SHOW ROUTINE LOAD` → `ReasonOfStateChanged`, `ErrorLogUrls`. Map to
`practice-observability-and-ownership`: a paused job with no alert is the "silent
corruption" pattern — freshness checks catch it.

## BE memory errors

"Memory of process exceed limit": BE `mem_limit` (soft limit ~90%, community-verified via
GitHub issues, not docs), per-query `query_mem_limit`. On PK tables, "index exceeds limit"
→ verify `enable_persistent_index=true`; inspect
`http://<be>:<http_port>/mem_tracker?type=update`.

## Slow queries

- `EXPLAIN` for the plan; **`EXPLAIN ANALYZE` (v3.1+) executes the query** — for INSERT it
  aborts the transaction so nothing is written (safe for diagnosis, still costs the read).
  This is the `method-safe-operations` rule-1 tool on StarRocks.
- Query profiles: `SET enable_profile=true` per session; in production prefer
  `SET GLOBAL big_query_profile_threshold='30s'` to capture only slow queries.
  `show profilelist` + `ANALYZE PROFILE` to inspect.
- Pruning killers: functions or implicit casts on partition columns (the
  `practice-sql-quality` rule, enforced by the engine's planner); check scanned partitions
  vs total in the plan.
- Tablet skew: manual bucket counts + low-cardinality bucket keys; check
  `information_schema.be_tablets`, target ~10 GB/tablet.

## Cluster health surfaces

- `SHOW PROC '/statistic'` — UnhealthyTabletNum, InconsistentTabletNum
- `SHOW PROC '/backends'` — node liveness, disk %, tablet counts
- `SHOW PROC '/cluster_balance'` — repair/clone queues
- `information_schema.loads`, `be_compactions`, `be_txns`, `routine_load_jobs`,
  `task_runs` (MV refreshes)

Sources: docs.starrocks.io — faq/loading/Loading_faq, administration/management/compaction,
EXPLAIN_ANALYZE, best_practices/query_tuning/query_profile_overview, SHOW_PROC,
information_schema; BE soft-limit: StarRocks/starrocks#35175, #32058.
