---
name: mongodb-consulting-notes
description: MongoDB as a pipeline source - change-stream CDC and oplog window sizing, schema drift contracts, ObjectId time semantics, read preference and consistency for extraction, sharded-cluster extraction pitfalls, TTL index silent deletes. Use when extracting from, running CDC against, or auditing a MongoDB deployment in a data engineering engagement.
---

# MongoDB consulting notes — the pipeline delta

Consulting DELTA only — schema design, query optimization, and Atlas mechanics come from
MongoDB's official plugin (install per the pack README). This skill covers MongoDB as a
SOURCE feeding pipelines, where the vendor skills are silent.

## Change-stream CDC — the oplog window is the SLA

- **Resume tokens die when they age out of the oplog.** A change-stream consumer can only
  resume while its token's operation is still in the oplog window; past that, it's a full
  resync. Size the oplog against worst-case downstream downtime
  (`replSetResizeOplog`, `storage.oplogMinRetentionHours`) and write the number into the
  design note — same discipline as binlog/WAL retention on MySQL/Postgres sources.
- Change streams require replica sets (standalone = no CDC) and emit deletes as bare
  `_id`s — downstream needs the key-only-delete pattern, not full-document diffs.
  `fullDocument: updateLookup` costs a read per update and races concurrent writes.
- **TTL indexes silently delete data** (~60s background cycle). Batch extractors lose
  rows between snapshot and read; deletes from TTL look identical to app deletes in the
  change stream. Inventory TTL indexes during discovery (`method-discovery`).

## Extraction consistency

- **Read preference decides stale-or-not**: `secondaryPreferred` extraction reads lagging
  replicas with no warning. For consistent batch pulls use `readConcern: majority` (+
  causal consistency or snapshot reads); bound incremental pulls by a watermark the
  target has confirmed (`practice-incremental-processing`).
- **ObjectId timestamps are not event time**: the embedded seconds are client-generated
  at creation — clock skew, custom `_id`s, and bulk imports make `_id`-based incremental
  extraction unsafe without a real, maintained `updated_at` field. Verify the field is
  actually maintained before trusting it (same trap as dbt's timestamp snapshots).
- Aggregation extractions hit the **100MB per-stage memory limit** — long `$group`/
  `$sort` need `allowDiskUse: true`; single documents cap at 16MB (use cursor output).

## Schema drift — flexible schema meets fixed warehouse

- Producers add/retype fields without ceremony; ingestion breaks later and silently.
  Contract at the pipeline boundary: land raw, validate with `$jsonSchema` or an explicit
  field allowlist, and route unknown shapes to a quarantine collection/dead-letter path
  (`practice-data-quality-minimums`, `practice-observability-and-ownership`).
- Mixed types in one field (`"42"` and `42`) are legal in MongoDB and fatal in most
  warehouses — the type census (`$type` aggregation per field) is a standard discovery
  artifact for `deliverable-platform-audit`.

## Sharded clusters

- **Never read shards directly**: bypassing `mongos` returns orphaned documents and
  duplicates from in-flight chunk migrations. All extraction goes through `mongos`.
- Non-shard-key queries broadcast to every shard (scatter-gather) — bulk extraction
  without the shard key is a cluster-wide load event; schedule it, and consider pausing
  the balancer for large consistent extracts.

## Engagement posture

- MCP pinned `--readOnly` (pack `.mcp.json`); durable guarantee = read-only DB user.
- Analytics aggregations hammering the production replica set is the finding, not the
  workload to tune (`practice-architecture-selection` Decision 1).
