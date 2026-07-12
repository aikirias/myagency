---
name: kafka-diagnosis
description: Kafka failure modes by symptom - rebalance loops, lag that resets or lies, lost messages by layer (producer, broker, consumer), duplicates downstream, KRaft migration state and quorum health. Use when diagnosing consumer groups, data loss, duplicates, or cluster issues on Kafka.
---

# Kafka diagnosis (verified against Kafka 4.x docs)

## "Consumer group keeps rebalancing"

Causal tree, most common first:

1. **Processing exceeds `max.poll.interval.ms`** (default 5 min) between polls →
   member evicted. Signature: rebalance follows slow batches. Fix: smaller
   `max.poll.records` (default 500), async processing, or raise the interval —
   knowingly trading detection latency.
2. **Missed heartbeats** (`session.timeout.ms` 45s, heartbeats every 3s) → GC pauses,
   network, or a dying pod. Look at the client host before the cluster.
3. **Restart churn**: rolling deploys without static membership re-shuffle everything
   each pod restart. Fix: `group.instance.id` per instance, or migrate to the KIP-848
   protocol (`group.protocol=consumer`, GA since 4.0) which removes stop-the-world
   rebalances.
4. **Connect amplification**: a flapping worker redistributes ALL its
   connectors/tasks; departures only settle after `scheduled.rebalance.max.delay.ms`
   (5 min default) — a crash-looping worker keeps the whole Connect cluster in
   rebalance purgatory.

## "Lag reset / reprocessed old data / lag looks wrong"

- **Lag vanished + data skipped**: offsets expired (group empty > 7 days,
  `offsets.retention.minutes`) + `auto.offset.reset=latest`. The incident happened at
  restart, not when noticed.
- **Lag exploded suddenly**: same expiry with `reset=earliest` = mass reprocessing —
  duplicates downstream if sinks aren't idempotent.
- **Lag high but data flows**: lag is a derivative (end-offset moves too); with
  `read_committed`, lag is measured against the Last Stable Offset, so an open/hung
  transaction inflates apparent lag. Check for stuck transactional producers before
  scaling consumers.
- Lag on compacted topics is structurally misleading (offsets are sparse after
  compaction) — don't alert on absolute lag there.

## "Messages lost" — walk the layers in order

1. **Producer**: acks=0/1 in some legacy config? `delivery.timeout.ms` expiries logged
   and swallowed? Fire-and-forget sends without callbacks are the most common "Kafka
   lost it" that Kafka never saw.
2. **Broker**: `unclean.leader.election.enable=true` anywhere (topic overrides
   included)? min.isr=1 with a follower outage window? Auto-created RF=1 topics?
3. **Consumer**: `auto.offset.reset=latest` skips; commit-before-process drops
   in-flight records on crash. Read the consumer code's commit placement — it's a
   5-minute check that closes half these tickets.

Evidence: broker logs for leader elections, `kafka-topics --describe` for ISR/RF
reality vs assumption, consumer group describe for offset gaps.

## "Duplicates downstream"

At-least-once redelivery points, in likelihood order: consumer redelivery after
rebalance/crash (gap between processing and commit), Connect sink task restarts
(sinks are at-least-once — dedup by (topic,partition,offset) or natural key in the
sink), producer retries with idempotence disabled (non-default), replays after offset
expiry. The fix ladder ends at an idempotent sink — it always ends there
(`practice-idempotency-and-reruns`).

## KRaft / migration state (2026 reality)

- **Kafka 4.0+ is KRaft-only; ZooKeeper mode is removed.** Migration path is fixed:
  ZK cluster → **3.9 (the last bridge release)** → KRaft migration → then 4.x. Clients
  (incl. Streams/Connect) must be >= 2.1 before brokers hit 4.0. A client on 3.x ZK has
  a mandatory migration project in their future — surface it in audits with this exact
  path.
- Quorum health: `kafka-metadata-quorum.sh describe --status` (leader, epoch,
  high-watermark, follower lag) and `--replication` — the KRaft equivalents of the old
  ZK checks. Controller quorum followers lagging = metadata operations slow before
  data does.
