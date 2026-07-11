---
name: starrocks-operations
description: StarRocks operations knowledge - FE/BE and shared-data architecture essentials, monitoring surface, async materialized views, resource groups and query queues for workload isolation, configuration pitfalls. Use when operating, auditing, right-sizing, or designing workload isolation on a StarRocks cluster.
---

# StarRocks operations (3.x)

## Architecture essentials

- **FE** (metadata + planning): Leader / Follower (quorum elects leader) / Observer (read
  scaling, no vote). Metadata fully replicated per FE.
- **Shared-nothing**: BE nodes own storage + compute; `replication_num` (typically 3).
- **Shared-data (3.x)**: stateless **CN** nodes; data on object storage (S3/GCS/Azure/
  MinIO/HDFS) via `CREATE STORAGE VOLUME`; local disk acts as data cache; single copy in
  the object store; compaction is FE-scheduled (`lake_compaction_*`, CN `compact_threads`
  ≈ 25% of cores). PK persistent index on object storage needs v3.3.2+.
- Which mode the client runs changes the audit questions: replica health matters in
  shared-nothing; compaction score and cache sizing matter in shared-data.

## Monitoring surface (maps to practice-observability-and-ownership)

| Concern | Where to look |
| --- | --- |
| Compaction pressure | `partitions_meta.Max_CS` (thresholds 10/100/500/2000), `SHOW PROC '/compactions'` |
| Tablet health | `SHOW PROC '/statistic'`, `/backends`, `/cluster_balance` |
| Memory | BE `/mem_tracker` endpoints; `?type=update` for PK index |
| Loads | `information_schema.loads`, `SHOW LOAD`, `SHOW ROUTINE LOAD` |
| MV refreshes | `information_schema.task_runs`, `materialized_views` |

Documented stack: Prometheus + Grafana. An audit finding of "no dashboard on compaction
score or routine-load state" is a detection-gap finding, not cosmetic.

## Async materialized views (v2.4+)

The engine's native answer to `practice-cost-optimization` pre-aggregation:

- Refresh modes: `ASYNC` (on base-table change), `ASYNC START ... EVERY (INTERVAL ...)`,
  `MANUAL`.
- **Partition-level incremental refresh** (v2.5+): align MV partitioning with the base
  table so only changed partitions refresh — otherwise every refresh is a full rebuild.
- Automatic **query rewrite** for aggregate/join shapes: dashboards get faster without
  changing their SQL.
- Also work over external catalogs (Hive/Iceberg v2.5+, JDBC v3.0+) — lake acceleration.
- Audit check: repeated expensive dashboard aggregations with no MV = quick win; MVs
  refreshing hourly for daily dashboards = cost finding.

## Workload isolation

- **Resource groups**: `cpu_weight` (soft), `exclusive_cpu_cores` (hard, v3.3.5+),
  `mem_limit`, `concurrency_limit`, and big-query killers
  (`big_query_scan_rows_limit`, `big_query_cpu_second_limit`, `big_query_mem_limit`).
  Classifiers by user/role/query type/source IP/db. Use them to keep ad-hoc analysts from
  starving pipelines — the consulting default for shared clusters.
- **Query queues**: cluster-level triggers (`query_queue_concurrency_limit`,
  `..._mem_used_pct_limit`, `..._cpu_used_permille_limit`), per-class enablement
  (`enable_query_queue_select/load`). Slot-based v2 exists from v3.3 (default only v4.1+).

## Configuration pitfalls checklist (audit dimension: architecture + cost)

1. High-frequency tiny loads (per-row INSERTs, per-second Stream Loads) — versions/txn
   errors; batch instead.
2. Manual bucket counts on small partitions — tablet explosion; auto bucketing is default
   since v2.5.7 for a reason.
3. PK tables with `enable_persistent_index=false` — BE memory blowups.
4. `INSERT OVERWRITE` without PARTITION clause in pipeline code — replaces the whole
   table on what looks like an interval load.
5. Label-based idempotency assumed beyond the 3-day retention window.
6. Functions/implicit casts on partition columns — pruning dead.
7. New tables built on legacy range partitioning or Unique Key model instead of
   expression partitioning + Primary Key.
8. Shared-data: `compact_threads` undersized; compaction score ignored until throttling
   at 100.
9. Routine Load with default `max_error_number=0` and no alert on PAUSED state.

Sources: docs.starrocks.io — introduction/Architecture, administration/management/
compaction, resource_group, query_queues, using_starrocks/async_mv, monitoring/metrics.
Least-verified area: shared-data deployment specifics (docs reorganization during survey);
re-verify CREATE STORAGE VOLUME syntax against current docs before using in a deliverable.
