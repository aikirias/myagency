---
name: pulsar-operations
description: Apache Pulsar operations - tiered storage offload, multi-tenancy and namespace policies, monitoring surface, geo-replication caveats, and the config-pitfalls checklist of surprising defaults. Use when operating, auditing, or setting policies on a Pulsar cluster.
---

# Pulsar operations (4.0.x; 3.x flagged)

## Multi-tenancy — namespaces are the policy unit

Hierarchy: `persistent://tenant/namespace/topic`. Retention, TTL, backlog quota, dedup,
schema compatibility, offload threshold, and replication clusters are ALL namespace-level
policies (topic-level overrides exist, default-enabled). Audit implication: reading
`pulsar-admin namespaces policies <t/ns>` for every namespace is the single
highest-signal step — the dangerous defaults (below) live here.

## Tiered storage (practice-data-lifecycle on Pulsar)

- Offloads sealed ledger segments to object storage (S3/GCS/Azure/filesystem) with reads
  staying transparent — this is raw-layer archiving with the replay guarantee retained.
- **Disabled by default** (auto-trigger threshold -1). Enable per namespace:
  `pulsar-admin namespaces set-offload-threshold --size 10G <t/ns>`; manual offload +
  `topics offload-status` for verification.
- Audit finding pattern: bookies sized for the full history because nobody configured
  offload, while retention is infinite "just in case" — cost dimension.

## Monitoring surface (practice-observability-and-ownership)

| Concern | Where |
| --- | --- |
| Backlog per subscription | `topics stats` (`msgBacklog`, `unackedMessages`); Prometheus `pulsar_subscription_back_log`, `pulsar_subscription_unacked_messages` |
| Storage | `pulsar_storage_size`, `pulsar_storage_backlog_size`; `topics stats-internal` (cursors, ack holes) |
| Throughput | `pulsar_rate_in` / `pulsar_rate_out` |
| Bookie health | `bookie_journal_JOURNAL_SYNC` (fsync latency), `bookkeeper_server_ADD_ENTRY_REQUEST` on `:8000/metrics` |
| Broker | `pulsar-admin brokers healthcheck` |

Minimum alert set for a production Pulsar: backlog growth per subscription, storage
growth, journal sync latency, and consumer disconnects on critical subscriptions — a
leaked subscription with no alert is the silent-failure pattern.

## Geo-replication

- Async, per-producer ordering preserved; enabled per namespace
  (`set-clusters --clusters us-west,us-east`).
- **Replicated subscriptions caveat**: only periodic mark-delete snapshots replicate,
  individual acks do NOT — expect re-consumption after a failover (consumers must be
  idempotent), and state is inconsistent if consumers are active in both clusters at
  once.

## Config pitfalls checklist (verified 4.0 defaults — audit dimension: architecture + cost)

1. `defaultRetentionTimeInMinutes=0` / `SizeInMB=0` → acked data deleted immediately;
   no replay for new subscriptions unless retention is set.
2. `backlogQuotaDefaultLimitGB/Bytes/Second=-1` → unbounded backlog; one leaked
   subscription can fill the bookies.
3. `subscriptionExpirationTimeMinutes=0` → inactive subscriptions never expire (the leak
   in #2 never self-heals).
4. `ttlDurationDefaultInSeconds=0` → no TTL; but adding TTL later silently auto-acks slow
   consumers — both directions surprise someone.
5. `brokerDeduplicationEnabled=false` + `transactionCoordinatorEnabled=false` →
   at-least-once out of the box; "we thought it was exactly-once" is a finding, not a bug.
6. `allowAutoTopicCreation=true` (non-partitioned type) → typos create real topics;
   partitioned topics are N internal `-partition-N` topics (use `partitioned-stats`).
7. `brokerDeleteInactiveTopicsEnabled=true` → pre-created topics with no
   subscription/producer get garbage-collected — surprises "we'll create topics upfront"
   plans.
8. Retention must be ≥ backlog quota (documented constraint) — violating it makes quota
   behavior incoherent.

## Admin access for agents

StreamNative's `snmcp` (vendor OSS, not Apache) exposes admin + read/write tools over
MCP for self-hosted Pulsar. On client clusters: `--read-only` always, plus a
`--features` allowlist — full admin surface via an agent violates
`method-safe-operations` rule 7.
