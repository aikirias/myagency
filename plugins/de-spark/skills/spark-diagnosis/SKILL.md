---
name: spark-diagnosis
description: Apache Spark failure modes by symptom - OOM taxonomy (driver vs executor vs container kill), shuffle spills and fetch failures, skew detection and fix ladder, Spark UI reading order, wrong-results causes (non-deterministic UDFs, timezones, ANSI flip, schema merge). Use when diagnosing OOMs, slow jobs, task failures, or wrong results on Spark.
---

# Spark diagnosis (OSS 3.5.x / 4.x)

Engine-specific extension of `method-diagnosis`. Primary evidence: Spark UI / History
Server (REST `/api/v1`; the pack's MCP exposes it read-only).

## OOM taxonomy — identify WHICH memory died first

1. **Driver OOM**: `collect()`-shaped results and broadcast builds land on the driver.
   Guard is `spark.driver.maxResultSize` (1g default) — raising it without raising
   driver memory just trades the abort for an OOM (docs say exactly this).
2. **Executor heap OOM**: usually one task's working set (groupByKey/aggregation hash
   tables), not "data doesn't fit". **Docs' first fix is more parallelism**, not more
   memory — tasks as short as 200ms are fine.
3. **Container kill** ("exit 137", "killed by YARN for exceeding memory limits" —
   community phrasing, official math): native/off-heap use exceeded
   `spark.executor.memoryOverhead` (default max(10% of executor memory, 384m)).
   **PySpark routinely needs well above 10%** (python memory counts against overhead
   unless `spark.executor.pyspark.memory` is set). Container total = executor.memory +
   memoryOverhead + offHeap.size + pyspark.memory.

Blind "increase executor memory" without classifying which of the three = the
anti-pattern this skill exists to prevent.

## Shuffle problems

- **Spills**: `memoryBytesSpilled` / `diskBytesSpilled` per task in the UI — persistent
  spill means too few partitions or too little memory per task; parallelism first.
- **FetchFailedException**: stage reattempts; root cause is usually a DEAD serving
  executor (often the container kill above) or long GC pauses — chase the executor
  death, not the fetch (`spark.shuffle.io.maxRetries`=3, `spark.network.timeout`=120s
  only paper over it).
- Wide-transformation explosions: shuffle-write ≫ input on a stage = join fanout or
  grain mistake — cross-check expected cardinality (`practice-sql-quality`).

## Skew

- Detect: stage task summary quantiles (min/median/max duration and input) — max ≫
  median with most tasks fast = skew, not under-provisioning. The MCP's `get_stage`
  returns exactly these distributions.
- Fix ladder, in order: AQE skew join already covers SMJ cases (check it's on and
  thresholds fit) → `forceOptimizeSkewedJoin` → broadcast the small side → **salting /
  hot-key isolation** (community pattern — needed for aggregations and single hot keys,
  which AQE cannot split).

## Slow-job UI reading order

1. Longest jobs/stages in the History Server
2. Stage task-time distribution → skew vs uniformly-slow
3. GC time per executor (`jvmGcTime`; persist per-stage metrics with
   `spark.eventLog.logStageExecutorMetrics=true`)
4. Shuffle read/write + spill volumes
5. Input-size imbalance across tasks
6. Scheduler noise: locality waits, dynamic-allocation churn

## Wrong results — the usual suspects, in order

1. **Non-deterministic UDFs**: the optimizer may invoke a UDF more or fewer times than
   written; combined with task retries/speculation against non-transactional sinks →
   divergent or duplicated rows. Mark with `asNondeterministic()`; treat any UDF with
   side effects or randomness as a correctness bug under retry.
2. **Timezone**: `spark.sql.session.timeZone` defaults to the JVM's zone —
   cluster-dependent results unless pinned (pin UTC, per core practice).
3. **ANSI flip (3.5 → 4.x)**: `spark.sql.ansi.enabled` false→true. 3.5 silently NULLs
   invalid casts and wraps overflow; 4.x throws. Pipelines that "worked" on 3.5 may have
   been eating bad casts silently for years — audit finding when migrating, and the
   single biggest 3.5→4.0 migration item.
4. **Schema surprises**: Parquet `mergeSchema` defaults false (columns present in only
   some files silently dropped); CSV/JSON `inferSchema` samples — types can flip between
   runs. Explicit schemas in production paths.
