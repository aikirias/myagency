---
name: flink-diagnosis
description: Apache Flink failure modes by symptom - backpressure localization, checkpoint failure causal mapping, state size explosion, restart loops and poison pills, stalled watermarks, streaming wrong-results causes. Use when diagnosing slow, failing, looping, or wrong-result Flink jobs.
---

# Flink diagnosis (1.20 / 2.3)

Evidence surfaces: Flink UI (job graph colors, Back Pressure tab, Checkpoints tabs) and
the REST API mirroring it.

## Backpressure — localize before tuning

- Per-subtask triple summing to ~1000 ms/s: `busyTimeMsPerSecond` /
  `backPressuredTimeMsPerSecond` / `idleTimeMsPerSecond`. UI: blue idle, red busy,
  black backpressured; tab thresholds OK ≤10%, LOW 10-50%, HIGH >50%.
- **Localization rule: the first operator down the chain that is BUSY (red) while its
  upstreams are backpressured is the culprit.** Everything upstream is a victim.
- `checkpointStartDelayNanos` high on ONE specific subtask → data skew (docs' own
  reading).

## Checkpoints failing or timing out — causal map

Read the per-subtask stats and map:

| Signal | Cause | Direction |
| --- | --- | --- |
| High start delay / alignment time | Backpressure | Fix the slow operator; buffer debloat; unaligned checkpoints |
| High async duration | Large state or slow durable storage | Incremental checkpoints; storage; state diet |
| High sync duration | Serialization / synchronous snapshot parts | Serializer/state-structure review |

Remember `tolerable-failed-checkpoints` defaults to 0 — a "job keeps restarting" ticket
is often one slow checkpoint tripping failover. Checkpointed Data Size is the DELTA when
incremental is on (`lastCheckpointFullSize` for the truth).

## State size explosion

Causes, most common first: unbounded-keyspace SQL update-queries (state per emitted row,
forever, unless TTL); TTL missing or configured without a working cleanup strategy;
stalled watermarks holding windows open (they never fire = never purge); fast-source
skew buffering in joins (watermark alignment is the fix); `allowedLateness` keeping
window state alive. Detect via checkpoint-size trend and async-duration growth; RocksDB
native metrics are opt-in and costly — enable temporarily.

## Restart loops

- Check `restart-strategy.type` first — **default with checkpointing enabled is
  `exponential-delay`** (1.19+; older material claiming fixed-delay is stale). Keep
  jitter nonzero in prod.
- **Poison pill**: a record that deterministically throws burns attempts forever. The
  official primitive for routing bad records is **side outputs**; the "DLQ topic" is
  side output + Kafka sink (standard practice, not a named doc feature) — which is
  exactly the de-core streaming rule (`practice-observability-and-ownership`: preserve
  failed payloads, never drop silently). Deserialization guards belong in the
  connector's DeserializationSchema.
- Metrics: `numRestarts` trending up with `uptime` sawtooth = the loop.

## Stalled watermarks ("windows never fire")

Walk upstream comparing `currentInputWatermark` to wall clock until it stops advancing:

1. Idle partitions/splits (min-of-inputs rule) → `withIdleness`
2. Parallelism > Kafka partitions (doc-explicit: source never idles those subtasks)
3. One source far behind/ahead → watermark alignment (`watermarkAlignmentDrift`)
4. Timestamps/bounded-out-of-orderness mis-tuned vs real disorder

## Streaming wrong-results checklist

1. **Silently dropped late data** (the default!) — check `numLateRecordsDropped` before
   anything else.
2. Sink guarantee NONE / at-least-once → duplicates after restarts (Kafka sink default
   is NONE — `flink-idioms`).
3. `allowedLateness` re-firings → multiple results per window; downstream must upsert.
4. Unaligned checkpoints change watermark-per-record behavior on recovery
   (doc-explicit) — relevant when results differ only after failovers.
5. Non-determinism on reprocessing: processing-time logic, non-deterministic SQL
   (RANK/OVER), intermediate-savepoint side-effect anomalies.
