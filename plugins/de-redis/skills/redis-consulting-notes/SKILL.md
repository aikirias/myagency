---
name: redis-consulting-notes
description: Redis in data pipelines - persistence loss windows (RDB vs AOF), eviction policies silently deleting data, cache vs store-of-record separation, dedup-store idioms with SET NX EX, Redis-as-queue anti-pattern vs Streams, big keys and KEYS in prod, cluster slot constraints. Use when assessing, integrating, or debugging Redis in a data engineering engagement.
---

# Redis consulting notes — the pipeline delta

Consulting DELTA only — data structures, connections, clustering, and security mechanics
come from Redis Inc's official plugin (install per the pack README). This skill frames
Redis as pipeline infrastructure, where the vendor skills (developer-oriented) don't.

## The first audit question: cache or store of record?

- **Default persistence is RDB snapshots — minutes of acknowledged writes vanish on
  crash.** Clients who say "we have persistence" usually have RDB-only and don't know
  their loss window. AOF `everysec` bounds loss to ~1s at rewrite-I/O cost. State the
  actual loss window in the audit (`deliverable-platform-audit`).
- **Eviction silently deletes data at `maxmemory`**: `allkeys-*` policies evict
  feature-store or dedup keys with no error to the writer; `noeviction` fails writes
  instead. A cache and a store-of-record sharing one instance is the endemic
  anti-pattern — they need separate instances with different policies. This is the
  Redis form of "one tool forced into two engine classes"
  (`practice-architecture-selection` Decision 1).

## Pipeline idioms

- **Dedup store** (the RabbitMQ/Kafka at-least-once companion):
  `SET dedup:<key> 1 NX EX <ttl>` is the atomic claim — NX gives first-writer-wins,
  EX bounds memory. TTL must exceed the maximum redelivery horizon or duplicates leak
  through after expiry (`practice-idempotency-and-reruns`).
- **Plain `SET` on an existing key CLEARS its TTL** (use `KEEPTTL`) — the classic way a
  dedup or session store quietly becomes immortal and eats the instance.
- **Redis-as-queue via LPUSH/BRPOP is an anti-pattern for pipelines**: no ack, no
  redelivery — consumer crash = message lost. If Redis must queue, Redis Streams
  (XADD/XREADGROUP/XACK, consumer groups, pending-entries list) is the correct
  primitive; otherwise that's what a broker is for.

## Operational traps (assessment checklist)

- **`KEYS` in prod blocks the single-threaded event loop** — O(N) over the whole
  keyspace. Audit app code AND dashboards for `KEYS`, `SMEMBERS` on huge sets,
  `FLUSHALL` reachability. Use `SCAN` cursors.
- **Big keys stall every tenant**: multi-MB hashes/sets make O(N) ops and even `DEL`
  block (use `UNLINK`). `redis-cli --bigkeys` is the standard assessment move.
- **Cluster mode is not transparent sharding**: 16384 slots; multi-key ops across slots
  throw CROSSSLOT. Hash tags (`{user123}.profile`) must be designed in from day one —
  retrofitting a key schema is a migration project, price it as one.

## Engagement posture

- The official MCP has NO read-only mode — the ACL recipe in the pack README is
  mandatory, not optional (`method-safe-operations`). The DB-side ACL is the only
  guarantee.
- Memory is the budget: `INFO memory`, eviction counters, and big-key census are the
  cost-review evidence base (`practice-cost-optimization`).
