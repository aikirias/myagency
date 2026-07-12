---
name: iceberg-discipline
description: Apache Iceberg table discipline - compaction and snapshot expiration defaults, orphan file safety, metadata hygiene, copy-on-write vs merge-on-read, hidden partitioning and partition evolution, WAP branches, changelog CDC reads, Flink upsert equality deletes. Use when designing, maintaining, or diagnosing Iceberg tables.
---

# Iceberg discipline (verified against Iceberg 1.11 docs)

Iceberg tables do not maintain themselves. Every production table needs a scheduled
maintenance contract — writers create the mess, maintenance pays it down, and the query
engine's speed is the difference.

## The maintenance contract (schedule all four)

| Procedure | Key defaults | Why it matters |
| --- | --- | --- |
| `rewrite_data_files` (compaction) | binpack strategy; target file size = `write.target-file-size-bytes` default **512MB**; `min-input-files=5` | Streaming/CDC writers produce small files that silently kill scan performance |
| `expire_snapshots` | table props: max snapshot age **5 days**, min snapshots to keep **1** | Data files are NOT deleted while any snapshot references them — no expiration = unbounded storage |
| `rewrite_manifests` | — | When write pattern misaligns with query pattern, planning slows even after compaction |
| `remove_orphan_files` | `older_than` default **3 days** — official docs: shortening it "might corrupt the table" by deleting in-progress writes | Failed jobs leak untracked files; run periodically but infrequently, never with short retention |

- **Metadata hygiene is OFF by default**: `write.metadata.delete-after-commit.enabled`
  defaults to **false** (keeps `write.metadata.previous-versions-max`=100 old
  metadata.json files, forever, until enabled). Files orphaned before enabling still
  need `remove_orphan_files`.
- Expiration vs time travel is one dial: retention window = rollback capability = storage
  cost. Put the number in the design note (`practice-data-lifecycle`).

## Row-level operations — CoW vs MoR

- `write.delete.mode` / `write.update.mode` / `write.merge.mode` all default to
  **copy-on-write**: updates rewrite whole files (write amplification on CDC-heavy
  tables). Merge-on-read defers cost to readers via delete files — and then compaction
  discipline is MANDATORY, not optional.
- Delete encodings: position deletes (v2) become **deletion vectors in v3**; equality
  deletes exist in both and are written mainly by **Flink upsert mode**
  (`write.upsert.enabled=true`, requires identifier fields; partition source columns
  must be part of the equality fields). Flink post-commit maintenance can convert
  equality deletes to DVs — an unconverted equality-delete backlog is a classic
  "reads got slow" root cause.
- v3 (spec complete; adopted per-engine at different speeds) adds deletion vectors, row
  lineage, variant type. Engine support is uneven — verify per engine before promising
  v3 features (`research` plugin territory, not assumption).

## Hidden partitioning — decisions are still decisions

- Transforms (`bucket[N]`, `truncate[W]`, `year/month/day/hour`, identity) are invisible
  to queries — no more wrong-format partition literals silently returning wrong results
  (the documented Hive failure). But transform choice still decides scan cost.
- **Partition evolution is metadata-only: old data keeps the old layout.** "We evolved
  the partition spec" does NOT fix historical scan patterns — each partition layout
  plans separately. Fixing history means rewriting it (a `practice-backfill-safety`
  operation).

## Write-audit-publish (WAP) — the validation gate

`write.wap.enabled=true` (default false) + write to an audit branch
(`SET spark.wap.branch = audit_branch`) → run DQ checks → publish via
`fast_forward`. This is `practice-data-quality-minimums` implemented at the table
layer: bad loads never become visible. Branches/tags default to forever retention —
give them retention clauses or they pin snapshots indefinitely.

## Concurrency and CDC

- Optimistic concurrency: commit = atomic metadata swap; losers retry
  (`commit.retry.num-retries` default **4**). High-frequency concurrent writers to the
  same table → commit contention, visible as retry storms; partition-aligned writers or
  a single writer per table is the design answer.
- CDC reads: `create_changelog_view` gives `_change_type`
  (INSERT/DELETE/UPDATE_BEFORE/UPDATE_AFTER) between snapshots; `net_changes` collapses
  intermediate states. Downstream consumers must handle the before/after pair shape
  (`practice-incremental-processing`).
