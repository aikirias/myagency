---
name: elasticsearch-consulting-notes
description: Elasticsearch/OpenSearch as a pipeline sink or source - refresh interval visibility, dynamic mapping traps and immutable mappings, deep pagination with search_after and PIT, shard sizing, ILM/ISM delete phases, approximate aggregations, version conflicts on concurrent upserts. Use when loading into, extracting from, or auditing an Elasticsearch or OpenSearch cluster in a data engineering engagement.
---

# Elasticsearch / OpenSearch consulting notes

Consulting DELTA only — ES|QL, ingestion mechanics, and security come from Elastic's
official plugin (install per the pack README). This skill carries the pipeline-facing
failure modes plus the ES/OpenSearch divergence map.

## Sink-side traps (loading INTO the cluster)

- **"Where's my document?" = refresh interval.** Indexing is near-real-time: documents
  are invisible to search until the next refresh (default 1s; commonly raised to 30s+
  for ingest throughput). Never validate a load with an immediate search-by-query;
  `?refresh=wait_for` works but taxes throughput — validation queries belong AFTER the
  refresh horizon (`practice-data-quality-minimums` timing note).
- **First document wins the mapping.** Dynamic mapping types a field from its first
  value — a numeric-looking string maps the field as text forever. Unbounded keys (user
  IDs as field names) blow `index.mapping.total_fields.limit` (default 1000) and bloat
  cluster state. Pipelines write through explicit index templates with
  `dynamic: strict` (or `flattened` for genuinely open maps) — dynamic mapping in a
  pipeline sink is an audit finding.
- **Mappings are immutable** — every field-type change is an alias-and-reindex
  (`_reindex` + index alias swap, or a data stream rollover). Plan it as a standing
  operational pattern with a rollback point (`method-improvement-plan`), not an
  exception.
- **Idempotent upserts need explicit concurrency handling**: concurrent writers throw
  `version_conflict_engine_exception` (`_seq_no`/`_primary_term` optimistic control).
  Sinks need retry-on-conflict or external versioning (`version_type=external`) —
  this is the `practice-idempotency-and-reruns` contract on ES.

## Source-side traps (extracting FROM the cluster)

- **Deep pagination caps at 10,000** (`index.max_result_window`) — naive from/size
  full-exports fail. Use `search_after` + Point-In-Time (PIT) for consistent deep
  scrolls; the scroll API is legacy. OpenSearch has the same PIT mechanism.
- **Aggregations are approximate**: `terms` counts merge per-shard top-Ns — check
  `doc_count_error_upper_bound` / `sum_other_doc_count`, tune `shard_size`;
  `cardinality` is HyperLogLog++. Never reconcile pipeline counts against aggregation
  output — reconcile against `_count` with the same filter.
- **ILM/ISM delete phases destroy source data on schedule.** A pipeline reading "all
  data" from an ES source reads a retention window. Audit lifecycle policies before
  promising replays or backfills (`practice-backfill-safety`,
  `practice-data-lifecycle`).

## Cluster-health findings (for `deliverable-platform-audit`)

- **Oversharding is the #1 field finding**: target roughly 10-50GB per shard; thousands
  of tiny shards burn heap and cluster-state overhead. Shard count is fixed at index
  creation — remediation is shrink/split/reindex, an engagement-sized task.
- Cost lever ordering: shard hygiene → tiering (hot/warm/cold) → replica count → node
  sizing (`practice-cost-optimization`).

## ES vs OpenSearch divergence map (post-fork)

Same skeleton, diverging surfaces — check which one the client actually runs:

| Area | Elasticsearch | OpenSearch |
| --- | --- | --- |
| Query language push | ES\|QL | PPL (+ SQL plugin) |
| Lifecycle | ILM | ISM (different policy JSON) |
| MCP | Agent Builder endpoint (9.2+) / deprecated npm server | `opensearch-mcp-server-py` (RO default) |
| Licensing | Elastic License / SSPL | Apache-2.0 |

Feature parity claims from either side belong in a RES record with sources, not in a
design note as assumptions (`research` plugin precedence rules).
