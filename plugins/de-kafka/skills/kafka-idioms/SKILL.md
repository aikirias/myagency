---
name: kafka-idioms
description: Apache Kafka semantics for pipelines - durability matrix (acks, min.insync.replicas, unclean election), exactly-once reality vs marketing, consumer offset and rebalance semantics, compacted topic behavior, retention and timestamp types, partitioning and key skew. Use when designing, configuring, or reviewing Kafka producers, consumers, or topics.
---

# Kafka idioms (verified against Kafka 4.x docs)

## Durability — the matrix, not a single flag

- Producer defaults are good now: `acks=all`, `enable.idempotence=true`,
  `retries=MAX_INT`. The broker side is where durability silently dies:
  **`min.insync.replicas` defaults to 1** — with RF=3/min.isr=1, once followers drop
  out of ISR, `acks=all` is satisfied by the leader ALONE. The false-comfort config.
- The real durability floor: **RF=3 + `min.insync.replicas=2` + `acks=all`** (the
  pairing the official Streams docs recommend for EOS) +
  `unclean.leader.election.enable=false` (default — verify nobody flipped it; the docs
  say enabling it "may result in data loss").
- **`auto.create.topics.enable=true` (default) creates RF=1, 1-partition topics** — a
  typo'd topic name becomes an undurable topic in production. Audit for auto-created
  topics on every engagement.

## Exactly-once — what it actually covers

- Idempotent producer (default on) = no duplicates from RETRIES on one session. Not
  transactions.
- Transactions (`transactional.id` set) add cross-partition atomicity + zombie fencing —
  but **consumers default to `isolation.level=read_uncommitted`**: uncommitted
  transactional data IS visible to default consumers. EOS requires the consumer side to
  opt in (`read_committed`).
- Kafka Streams: `processing.guarantee` defaults to **at_least_once**;
  `exactly_once_v2` needs brokers >= 2.5 and drops commit interval to 100ms.
- Scope honesty (say this in design reviews): EOS covers Kafka -> process -> Kafka. The
  moment a side effect leaves Kafka (DB write, HTTP call), you're back to at-least-once
  + idempotent sink design (`practice-idempotency-and-reruns`). Connect has EOS for
  SOURCE connectors only (see `kafka-connect-debezium`).

## Consumer semantics — the two silent data-eaters

- **`auto.offset.reset=latest` (default)**: a new group — or one whose offsets expired —
  starts at the log END. Deploy gap = silently skipped data.
- **Committed offsets expire after 7 days** (`offsets.retention.minutes=10080`) once
  the group is empty. A pipeline paused for 8 days doesn't resume where it stopped —
  it jumps to `auto.offset.reset`. Set the topic's consumers to `earliest` +
  idempotent processing, or shorten pause windows.
- Auto-commit (default, every 5s) commits positions from poll() — crash = up to 5s of
  processed-but-uncommitted work redelivered. Commit AFTER processing, manually, for
  anything that matters.
- Rebalance protocol state (2026): classic protocol default on clients
  (`group.protocol=classic`, assignors Range + CooperativeSticky); KIP-848
  (`group.protocol=consumer`) is GA server-side since 4.0 and eliminates
  stop-the-world rebalances — opt-in per consumer. Static membership
  (`group.instance.id`) remains the restart-churn fix on classic.

## Compacted topics — eventual, not immediate

- Compaction never touches the ACTIVE segment, triggers at dirty ratio >= 0.5
  (`min.cleanable.dirty.ratio`), and segments roll as slowly as `segment.ms` (7 days
  default) — **duplicates per key are EXPECTED**; consumers must be idempotent by key.
- Tombstones live `delete.retention.ms` = **1 day**: a consumer that takes longer than
  that from segment start can MISS deletes entirely — the compacted-topic-as-table
  pattern needs consumers faster than the tombstone window.
- `cleanup.policy=compact,delete` = compacted AND time-bounded — verify which semantics
  the client actually wanted; it deletes old keys too.

## Retention and timestamps

- `retention.ms` default 7 days; retention runs on **`message.timestamp.type=CreateTime`
  (default)** — producer-supplied timestamps. Replaying historical data with original
  timestamps into a CreateTime topic can be deleted on arrival; broken producer clocks
  distort retention. LogAppendTime fixes retention but breaks event-time reprocessing —
  choose per topic, deliberately.

## Partitioning

- Default partitioner: hash(key) → partition; no key → sticky batching. Low-cardinality
  hot keys = hot partitions (one consumer pegged, the rest idle — diagnose in
  `kafka-diagnosis`).
- **Adding partitions shuffles key→partition mapping** (doc-verbatim: Kafka "will not
  attempt to automatically redistribute data") — key ordering breaks at the boundary,
  and compacted topics end up with stale values stranded in old partitions. Partition
  count is a day-one design decision (`practice-architecture-selection` discipline).
