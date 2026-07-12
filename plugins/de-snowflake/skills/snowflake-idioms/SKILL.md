---
name: snowflake-idioms
description: Snowflake loading and pipeline idioms - COPY INTO load metadata and silent skips, Snowpipe vs Snowpipe Streaming, Streams offset and staleness semantics, Tasks and DAGs, Dynamic Tables, MERGE determinism, transient tables, zero-copy clone. Use when building or reviewing loading, CDC, or transformation pipelines on Snowflake.
---

# Snowflake idioms (doc-verified)

## Loading — three mechanisms, three semantics

- **COPY INTO** tracks load metadata for **64 days** and silently SKIPS already-loaded
  files. This is the rerun-safety mechanism (`practice-idempotency-and-reruns`) AND a
  trap: files older than the 64-day metadata horizon get "unknown" status and are
  skipped by default (`LOAD_UNCERTAIN_FILES=FALSE`). `FORCE=TRUE` reloads everything —
  and duplicates everything. To reload one file legitimately: re-stage it (new
  checksum).
- **Snowpipe** (classic): file-based, serverless, dedup by file path+name for only
  **14 days** (not 64); a modified file with the same name is NOT reloaded. Error
  notifications only fire with `ON_ERROR = SKIP_FILE` (the default) — a pipe on
  CONTINUE fails silently; check `NOTIFICATION_HISTORY` and `COPY_HISTORY` (the
  INFORMATION_SCHEMA function covers both COPY and Snowpipe, 14-day window).
- **Snowpipe Streaming**: rows via channels with offset tokens ("exactly-once through
  built-in offset token tracking") — the Kafka-partition-shaped option. Billing is
  throughput-based per uncompressed GB. (Note: Snowpipe's old per-file billing model is
  obsolete — don't quote credits-per-1000-files figures.)
- Batch loads on a warehouse pay warehouse runtime with the 60s resume minimum —
  singleton INSERT patterns burn minimums; batch through COPY or Snowpipe.

## Streams + Tasks — the CDC pair and its two silent killers

- Stream offset advances **only when consumed inside a committed DML transaction**
  (CTAS and COPY INTO location count; a plain SELECT never advances it).
- **Staleness**: Snowflake extends the source's retention up to
  `MAX_DATA_EXTENSION_TIME_IN_DAYS` (default **14**) for an unconsumed stream; past
  that the stream goes stale and the missed interval is unrecoverable through it.
  Monitor `SHOW STREAMS` → `STALE_AFTER`; gate tasks with
  `SYSTEM$STREAM_HAS_DATA()` (skipped runs still count as consumption opportunities
  only if they consume). The `CHANGES` clause (requires `CHANGE_TRACKING=TRUE`) is the
  offset-free fallback, bounded by Time Travel.
- **Tasks auto-suspend after 10 consecutive failures** (`SUSPEND_TASK_AFTER_NUM_FAILURES`
  default 10 → `FAILED_AND_AUTO_SUSPENDED` in TASK_HISTORY) — the #1 cause of "CDC
  quietly stopped last month". A suspended ROOT cancels the whole graph; resume trees
  with `SYSTEM$TASK_DEPENDENTS_ENABLE`. Overlap: `OVERLAP_POLICY` default NO_OVERLAP
  (one graph instance at a time; `ALLOW_OVERLAPPING_EXECUTION` is deprecated).
- Serverless tasks (`USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE`, mutually exclusive with
  `WAREHOUSE`) avoid the per-run 60s warehouse minimum — the right shape for frequent
  small tasks.

## Dynamic Tables — when they replace Streams+Tasks

Declarative materialization with `TARGET_LAG` (minimum **60 seconds**; `DOWNSTREAM` =
refresh only when dependents need it). `REFRESH_MODE=AUTO` resolves incremental-vs-full
**once at creation and never re-evaluates** — check `SHOW DYNAMIC TABLES` for what you
actually got; EXCEPT/INTERSECT and exact percentiles force full refresh. Stay on
Streams+Tasks when you need procedural logic, external calls, or sub-60s freshness.

## Modeling idioms

- Micro-partitions hold 50-500MB of UNCOMPRESSED data, clustered naturally by insertion
  order. Clustering keys pay off only on large (typically multi-TB), frequently
  filtered, infrequently changed tables — Automatic Clustering bills serverless credits
  forever on churny tables, and reclustered-away partitions linger in Time
  Travel/Fail-safe storage.
- **MERGE**: multiple source rows hitting one target row errors by default
  (`ERROR_ON_NONDETERMINISTIC_MERGE=TRUE`). Never "fix" that error by setting it FALSE
  (undefined row wins, silently) — fix the source with QUALIFY/dedup.
- **Transient tables for staging/ETL**: Time Travel max 1 day, NO Fail-safe — the
  documented idiom for work tables, cutting churn storage several-fold.
- **Zero-copy clone**: metadata-only, bills only divergence; unconsumed stream records
  inside a clone are inaccessible, and clones own no pre-clone Time Travel. Clone is
  the dry-run substrate: test destructive changes on a clone first
  (`method-safe-operations` rule 8).
