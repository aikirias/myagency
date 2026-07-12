---
name: rabbitmq-consulting-notes
description: RabbitMQ feeding data pipelines - quorum vs classic queues and the 4.x mirroring removal, prefetch tuning, memory alarms blocking all publishers, dead-letter discipline, publisher confirms, streams vs queues, at-least-once duplicates. Use when assessing, consuming from, or diagnosing RabbitMQ in a data engineering engagement.
---

# RabbitMQ consulting notes

RabbitMQ appears in DE engagements as the buffer between producers and pipelines. These
are the assessment/consumption gotchas; broker development is out of scope.

## Version cliff first (discovery checklist)

- **Classic queue mirroring is GONE in RabbitMQ 4.x** (deprecated since 2021). Quorum
  queues are the only replicated type now, and the default queue type on 4.x. A client
  on 3.13 with mirrored queues needs a migration plan, not a policy tweak — mirroring
  policy keys silently no-op after upgrade. This is the first thing to check
  (`method-discovery`).

## Reliability semantics (what the pipeline inherits)

- **At-least-once means duplicates, period.** Redelivery after consumer failure is
  guaranteed behavior. Every pipeline consumer must be idempotent — dedup key downstream
  (`practice-idempotency-and-reruns`; the `de-redis` pack's `SET NX EX` dedup store is
  the standard companion).
- **Publisher confirms, not AMQP transactions**: transactions are slow and effectively
  deprecated; confirms are the supported publish-safety mechanism. Fire-and-forget
  publishing without confirms is the default failure mode found in client producers —
  messages lost before the broker ever saw them look like "RabbitMQ lost data".
- **No DLX = poison messages requeue-loop forever** (or vanish, depending on consumer
  code). Dead-letter exchanges are opt-in; quorum queues additionally support
  at-least-once dead-lettering (classic DLX delivery can itself drop). Preserve failed
  payloads, never drop silently (`practice-observability-and-ownership`).

## Capacity and flow control

- **RabbitMQ is not a database**: one unbounded backlogged queue trips the memory
  high-watermark alarm and **blocks ALL publishers cluster-wide** — a single slow
  pipeline consumer freezes every producer in the company. Mandate `max-length`/TTL
  policies per queue and backlog monitoring with alerts.
- **Prefetch (QoS) is the #1 consumer-throughput knob and both extremes hurt**:
  unlimited prefetch = one fast consumer hoards + unbounded unacked memory; prefetch=1 =
  round-trip-bound throughput. Tune per consumer workload; document the value.

## Streams vs queues — a routing decision clients get wrong

- Queues = destructive competing consumers. **Streams** = replayable append-only log
  (non-destructive reads, fan-out, replay, large backlogs). Teams emulate Kafka with
  fanout exchanges + per-consumer queues when a stream is the right tool — or adopt
  streams where competing consumers were fine. If requirements are genuinely log-shaped
  (replay, multiple independent readers, retention), compare against an actual log
  system before building on streams (`practice-architecture-selection`).

## Engagement posture

- MCP read-only by default (mutations need an explicit flag we never pass); management
  API access via a `monitoring`-tagged user (`method-safe-operations`).
- Queue backlog age, redelivery rate, and alarm history are the audit evidence base
  (`deliverable-platform-audit`).
