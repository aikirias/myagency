---
name: pulsar-idioms
description: Apache Pulsar engine idioms - subscription type selection, ack/redelivery/DLQ semantics, effectively-once via broker dedup, schema compatibility, and the exact retention vs TTL vs backlog-quota semantics. Use when designing producers, consumers, topics, or delivery guarantees on Pulsar.
---

# Pulsar idioms (4.0.x LTS; 3.x differences flagged)

Verified against official docs and the actual 4.0 `broker.conf` defaults — the defaults
are where most Pulsar surprises live.

## Architecture facts that drive design

- **Brokers are stateless; storage lives in BookKeeper bookies** (topic = sequence of
  immutable ledgers spread across bookies). Consequences vs Kafka: brokers scale without
  data rebalancing; sealed segments enable transparent tiered offload; a ledger is only
  deletable when ALL subscription cursors have passed it.
- Metadata: ZooKeeper (3.x practical default), Oxia available from 4.0.

## Subscription types — pick by ordering vs parallelism

| Type | Parallelism | Ordering | Notes |
| --- | --- | --- | --- |
| Exclusive (default) | 1 consumer | Full | |
| Failover | 1 active/partition | Preserved | Warm standby |
| Shared | Per-message round-robin | **None** | No cumulative ack; DLQ works here |
| Key_Shared | Per-key | Per-key only | See producer requirement below |

**Key_Shared trap**: producers MUST use key-based batching (`BatcherBuilder.KEY_BASED`)
or disable batching — default batching mixes keys per batch and silently breaks routing.
4.0 (PIP-379, use ≥4.0.3) fixed the 3.x problem where one consumer's unacked messages
blocked whole hash ranges.

## Delivery semantics

- Acks: individual vs cumulative (cumulative NOT allowed on Shared/Key_Shared).
- Negative ack: default redelivery delay 1 min; **nack/redelivery counters are in-memory
  only** — they reset on broker restart or consumer reconnect. Retry counts that must
  survive restarts need the **retry topic** pattern (`enableRetry(true)` +
  `reconsumeLater`), whose counter travels in message properties.
- Ack timeout: **disabled by default** — a consumer that receives and never acks holds
  messages forever unless you enable it.
- **DLQ is built-in but only on Shared / Key_Shared** subscriptions
  (`DeadLetterPolicy.maxRedeliverCount`); pair with `initialSubscriptionName` so DLQ data
  isn't immediately deletable. This maps directly to the de-core streaming rule
  (`practice-observability-and-ownership`: no silent record dropping).

## Effectively-once (practice-idempotency-and-reruns)

- Broker dedup is **off by default** (`brokerDeduplicationEnabled=false`). Enabled, it
  dedups by producer name + sequence ID — **per producer, per partition only**. It does
  NOT cover: multiple producers, cross-partition, or consumer-side redeliveries.
- Producer requirements for it to work: explicit stable producer name + infinite send
  timeout (`sendTimeout(0)`).
- Transactions (atomic consume-process-produce) exist and are documented, but are far
  less battle-tested: recommend broker dedup + idempotent consumers as the default;
  transactions only when true multi-topic atomicity is a hard requirement.

## Retention vs TTL vs backlog quota — exact semantics (the classic confusion)

Baseline: the broker keeps only messages some subscription still needs. **Once acked by
all subscriptions (or if no subscription exists), messages are deletable immediately.**

| Mechanism | Applies to | Default | Effect |
| --- | --- | --- | --- |
| **Retention** | ACKED messages | **0/0 = none** | Keep acked data around (replays, new subs) |
| **TTL** | UNACKED messages | 0 = disabled | Auto-acks old unacked messages (data skipped!) |
| **Backlog quota** | Unacked backlog size | **-1 = unlimited** | On breach: hold/except producers, or silently EVICT backlog |

- Documented constraint: retention must be ≥ backlog quota.
- All three are **namespace-level policies** (topic overrides possible).
- Consulting framing: "Pulsar lost my data" is almost always one of these three defaults
  doing exactly what it says.

## Schema

- Schemas are per-topic, broker-stored. Compatibility default: **FULL for Avro/JSON,
  ALWAYS_INCOMPATIBLE for others**. BACKWARD-family → upgrade consumers first;
  FORWARD-family → producers first.
- `AUTO_CONSUME`/`AUTO_PRODUCE` are the idiom for generic bridges/sinks.
- Producers without schema are allowed by default (`isSchemaValidationEnforced=false`) —
  turn enforcement on for governed topics (`practice-governance-and-catalog`).
