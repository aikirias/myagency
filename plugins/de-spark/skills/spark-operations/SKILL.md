---
name: spark-operations
description: Apache Spark operations - unified memory model and sizing, dynamic allocation requirements and cost pitfalls, speculative execution caveats, monitoring surface (event logs, History Server, MCP), config pitfalls checklist, deployment-mode deltas, 3.5 to 4.x migration. Use when operating, right-sizing, auditing, or migrating Spark workloads.
---

# Spark operations (OSS 3.5.x / 4.x)

## Memory model in five numbers

Usable memory M = (heap − 300MiB) × `spark.memory.fraction` (0.6); within M,
`spark.memory.storageFraction` (0.5) reserves the cache region R. Execution can evict
storage down to R; **storage never evicts execution**. Off-heap needs both
`offHeap.enabled` and `offHeap.size`. Sizing heuristics from docs: 2-3 tasks per core;
estimate cache footprint via the Storage tab or `SizeEstimator`.

## Dynamic allocation — cost lever with teeth

- Default OFF. Needs one of: external shuffle service (YARN), shuffle tracking
  (`shuffleTracking.enabled` — default true since 3.4, so enabling DA alone works), or
  decommissioning. **K8s has NO external shuffle service** — tracking/decommissioning
  only.
- The cost pitfalls: `cachedExecutorIdleTimeout` defaults to **infinity** — executors
  holding cached data never scale down (the classic "we enabled autoscaling and the bill
  didn't move"); shuffle tracking pins executors while their shuffle files are alive.
- Helps bursty/multi-tenant; hurts shuffle-heavy and cache-heavy jobs; amplifies the
  small-files problem on wide writes (community-verified).

## Speculative execution

Default off (`spark.speculation`; 3× median, 0.9 quantile). Helps genuine stragglers
(bad node, throttled disk). Two caveats: at-least-once duplication against
non-transactional/`foreach` sinks (idempotency rules apply), and it does NOT fix skew —
the duplicate of a skewed task is just as slow.

## Monitoring surface (practice-observability-and-ownership)

- **`spark.eventLog.enabled` defaults to FALSE** — a cluster without event logs has no
  post-mortem capability; enabling it (+ `eventLog.rolling.*` for streaming apps) is a
  standard audit recommendation.
- History Server REST `/api/v1`: applications, stages with task distributions,
  executors, SQL executions. Peak executor memory metrics with
  `eventLog.logStageExecutorMetrics=true`; python RSS via
  `executor.processTreeMetrics.enabled`.
- The pack's MCP (Kubeflow SHS) exposes this read-only: `get_job_bottlenecks`,
  `get_stage` distributions, `compare_job_performance` / `compare_job_environments`
  (config diff between a good and a bad run — gold for "it got slow last week"),
  `list_sql_executions`.

## Config pitfalls checklist (verified defaults; audit dimensions cost + architecture)

1. `spark.sql.shuffle.partitions=200` static — with AQE: high `initialPartitionNum`,
   coalesce down, `parallelismFirst=false` on busy clusters (docs' own advice).
2. `spark.eventLog.enabled=false` — no evidence, no audits.
3. `cachedExecutorIdleTimeout=∞` — autoscaling that never scales down.
4. `memoryOverheadFactor=0.10` — undersized for PySpark/native libs.
5. `driver.maxResultSize=1g` — see OOM taxonomy before touching it.
6. `autoBroadcastJoinThreshold=10MB` on stale stats — wrong broadcasts both ways.
7. `session.timeZone` = JVM default — pin UTC.
8. FileOutputCommitter v1 on S3 (cripplingly slow) or v2 (unsafe) — S3A committers.
9. Dynamic partition overwrite + S3A committers — unsupported combination.
10. Small files: no auto-compaction in OSS — needs an explicit strategy.

## Deployment deltas (only what changes advice)

- **YARN**: external shuffle service available — best DA story; container limits enforce
  the overhead math.
- **K8s**: no ESS; pod memory limit = the 4-component sum; size `spark.local.dir`
  volumes for spill.
- **Standalone**: set `spark.executor.cores` explicitly with DA (over-acquisition bug
  otherwise).
- Client vs cluster mode decides WHERE collect/maxResultSize pressure lands.

## 3.5 → 4.x migration headline

`spark.sql.ansi.enabled` flips to true (errors instead of silent NULL/overflow — audit
data pipelines for reliance on the old behavior), JDK 17 + G1GC default (revisit GC
tuning), docs restructured. Treat the ANSI flip as a correctness audit, not a config
tweak.
