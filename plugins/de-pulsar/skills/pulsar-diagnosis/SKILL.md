---
name: pulsar-diagnosis
description: Apache Pulsar failure modes by symptom - backlog growth and subscription leaks, disappearing messages, duplicates, bookie storage filling, latency spikes, Key_Shared stuck consumers. Use when diagnosing message loss, duplicates, growing backlogs, or storage/latency issues on Pulsar.
---

# Pulsar diagnosis (4.0.x; 3.x flagged)

Engine-specific extension of `method-diagnosis`. Primary evidence tools:
`pulsar-admin topics stats <topic>` (add `--get-precise-backlog`), `topics stats-internal`,
`pulsar-admin namespaces policies`, Prometheus metrics on broker `:8080/metrics`.

## Backlog keeps growing

- Read `topics stats`: per-subscription `msgBacklog`, `unackedMessages`, `msgRateOut`.
  A subscription with backlog and `msgRateOut ≈ 0` is dead or absent.
- **#1 cause: subscription leaks.** A durable subscription with no consumer retains
  everything forever — `subscriptionExpirationTimeMinutes=0` (never expire) is the
  DEFAULT. Old POCs, renamed services, and one-off debug subscriptions are the usual
  suspects. Fix: `pulsar-admin topics unsubscribe`, or set subscription expiration.
- `blockedSubscriptionOnUnackedMsgs=true` → the app receives but never acks (hit the
  max-unacked limit). Check ack logic, not the broker.

## "Messages disappeared"

Walk this tree in order — three of the four are defaults working as designed:

1. **No retention configured** (default 0/0): all subscriptions acked → immediate
   deletion is CORRECT behavior, not loss.
2. **Consumer created after produce**: `subscriptionInitialPosition` defaults to
   `Latest` — a new subscription sees nothing old. The most common false alarm.
3. **TTL set on the namespace**: TTL auto-ACKS unacked messages — slow consumers get
   data silently skipped.
4. **Backlog quota with `consumer_backlog_eviction`**: broker discards backlog silently
   on quota breach. Check the namespace policy.

## Duplicates

At-least-once is the default posture; duplicates come from real mechanics:

- Redelivery: nack, ack-timeout, or consumer crash before ack. Nack counters are
  in-memory — restarts reset them, so "maxRedeliverCount" style logic based on nacks
  alone under-counts.
- Producer retries with dedup disabled (default): the broker stores the retry as a new
  message. Enable broker dedup (see `pulsar-idioms` for its exact scope) or make
  consumers idempotent.

## Bookie storage filling

- Ledgers delete only when ALL cursors pass them: check `topics stats-internal` for
  `markDeletePosition` per cursor and `individuallyDeletedMessages` — **ack holes**
  (individual acks with gaps) pin ledgers.
- Subscription leaks (above) are the same disease seen from the storage side.
- Infinite retention (-1/-1) set "temporarily" and forgotten.
- Offload configured but never triggering: auto-offload threshold defaults to disabled
  (`managedLedgerOffloadAutoTriggerSizeThresholdBytes=-1`).

## Latency spikes

- Writes: every entry fsyncs to the bookie **journal** before ack — journal disk speed
  IS write latency. Official guidance: separate physical disks for journal vs ledger
  storage, SSD for journal. Metrics: `bookie_journal_JOURNAL_SYNC`,
  `bookkeeper_server_ADD_ENTRY_REQUEST`.
- Reads of old data (catch-up consumers, backlog drains) hit ledger disks instead of the
  broker cache — on shared disks they contend with live writes. A "random latency"
  complaint that correlates with a consumer catching up is this.

## Key_Shared stuck consumers

- 3.x: one consumer holding unacked messages can block entire hash ranges (whole keys
  stall). 4.0 PIP-379 limits blocking to affected keys and exposes `drainingHashesCount`
  / `drainingHashes` in `topics stats`; use ≥4.0.3 (ordering race fixed).
- Also check the producer batching requirement (`pulsar-idioms`) — mixed-key batches
  masquerade as ordering bugs.
