---
name: flink-operations
description: Apache Flink operations - deployment modes and HA, must-watch metrics, rescaling and the fixed max-parallelism limit, savepoint-based upgrade discipline, the 1.x to 2.x break, TaskManager memory troubleshooting, config pitfalls. Use when operating, scaling, upgrading, or auditing Flink deployments.
---

# Flink operations (1.20 LTS / 2.3)

## Deployment and HA

- **Application Mode** (cluster per app) is the recommended isolation; Session Mode for
  shared clusters. **Per-job mode was removed in 2.0.**
- JobManager is a SPOF without HA (ZooKeeper or Kubernetes HA) — production-readiness
  checklist item. On K8s, the **Flink Kubernetes Operator** (separate active project,
  with autoscaler) is the practical default.

## Must-watch metrics (practice-observability-and-ownership)

| Concern | Metrics |
| --- | --- |
| Checkpointing | `lastCheckpointDuration`, `lastCheckpointFullSize`, `numberOfFailedCheckpoints`, `checkpointStartDelayNanos` |
| Load | `busyTimeMsPerSecond` / `backPressuredTimeMsPerSecond` / `idleTimeMsPerSecond` |
| Progress | `numRecordsIn/OutPerSecond`, **`numLateRecordsDropped`** |
| Event time | `currentInputWatermark` vs wall clock (watermark lag) |
| Availability | `numRestarts`, `uptime` |

UI checkpoint stats don't survive JobManager failover — scrape to Prometheus for
history. Minimum alert set: checkpoint failures, watermark lag, numRestarts, late-drops.

## Scaling — know the hard limit FIRST

- **Max parallelism (key-group count) is fixed at first start and cannot change without
  discarding state.** Implicit default 128; set explicitly with headroom at design time
  — discovering this limit during an incident is a classic consulting moment.
- Classic rescale: stop-with-savepoint → resume with new parallelism.
- **Adaptive Scheduler** (`jobmanager.scheduler: adaptive`, streaming only): scales to
  available slots, rescales from the latest checkpoint; REST
  `PUT /jobs/<id>/resource-requirements` for external autoscalers (pairs with the K8s
  Operator autoscaler). Reactive Mode remains experimental and standalone-only.

## Upgrade discipline

- Job upgrades: stop-with-savepoint → `run -s`. Prerequisites: `uid()` everywhere;
  state datatypes frozen; removed stateful operators need `-n` on restore.
- Framework upgrades: canonical savepoints are the most portable format; savepoint must
  be reachable at the same absolute path.
- **1.x → 2.x: state compatibility is NOT guaranteed** (official release notes) — plan
  as a migration (fresh state or dual-run + cutover), never a routine upgrade. 2.0 also
  removed: DataSet API, Scala APIs, SourceFunction/SinkFunction (incl.
  TwoPhaseCommitSinkFunction), per-job mode, Java 8, and legacy `flink-conf.yaml`
  (2.x requires standard-YAML `config.yaml`).
- Table/SQL jobs: even MINOR version upgrades may break state (planner owns the
  topology) — factor into architecture selection for stateful SQL.

## TaskManager memory troubleshooting

Total process = task heap + **managed** (RocksDB lives here; ~0 for hashmap backend) +
network + framework + metaspace + JVM overhead. Symptom map (docs'):

- "Insufficient number of network buffers" → network memory
- Container OOM-kill with RocksDB → managed memory / `MALLOC_ARENA_MAX=1` / JVM overhead
- Metaspace OOM → `taskmanager.memory.jvm-metaspace.size`

## Config pitfalls checklist (verified keys)

1. Checkpoint storage on JobManager heap (default) → `filesystem` + durable dir.
2. `tolerable-failed-checkpoints=0` default → one slow checkpoint = failover loop.
3. Checkpoint interval drives exactly-once sink visibility — pick from the SLA, with
   `min-pause` for progress.
4. Kafka EXACTLY_ONCE without raising `transaction.timeout.ms` → documented data-loss
   risk; unique transactional prefix per app.
5. Managed memory misfit: RocksDB starving or hashmap wasting it.
6. Max parallelism unset → 128 forever.
7. Missing `uid()` → savepoints die at the first refactor.
8. Kafka sink guarantee NONE / source starting at `earliest` — check both defaults.
9. Restart strategy: exponential-delay is the modern default; nonzero jitter.
10. 2.x: `config.yaml` (standard YAML) — `flink-conf.yaml` is unsupported.
