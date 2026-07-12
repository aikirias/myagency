---
name: delta-discipline
description: Delta Lake (OSS) table discipline - VACUUM vs time travel data-loss trap, log vs file retention, deletion vectors as soft deletes, optimistic concurrency conflict matrix, schema enforcement and column mapping one-way doors, Change Data Feed, UniForm interop limits. Use when designing, maintaining, or diagnosing Delta Lake tables.
---

# Delta discipline (verified against Delta OSS docs; Databricks-platform deltas live in de-databricks)

## VACUUM — the classic data-loss trap

- Default retention **7 days** (`delta.deletedFileRetentionDuration` = `interval 1 week`).
  **VACUUM permanently destroys time travel beyond the window** — and old snapshots may
  still be in use by concurrent readers/writers, which is why the docs recommend >= 7
  days and why the safety check (`retentionDurationCheck`) exists. Anyone disabling that
  check gets a finding, not a pass.
- **Time travel needs BOTH the log entry AND the data files** (doc-verbatim). Two
  separate dials: `delta.logRetentionDuration` (default **30 days**) and file retention
  (7 days) — effective time travel = the shorter of the two. State the real recovery
  window in the design note (`practice-data-lifecycle`).

## Deletion vectors — soft deletes with two traps

- DVs mark rows deleted without rewriting files (default-on for UPDATE since Delta 3.1).
  Trap 1: **enabling DVs upgrades the table protocol one-way** — clients without DV
  support can no longer read the table (external OSS readers, older connectors). Trap 2:
  **"deleted" data physically remains** until `REORG TABLE ... APPLY (PURGE)` + VACUUM —
  a GDPR/PII landmine (`practice-pii-handling`): a DELETE is not an erasure.
- Delta 3.0+ can drop the DV table feature after purge to restore reader compatibility.

## Concurrency — optimistic, and conflicts are real

- UPDATE/DELETE/MERGE vs each other **can conflict** (ConcurrentAppend/Delete
  exceptions); compaction (`dataChange=false`) vs UPDATE/DELETE/MERGE also conflicts;
  INSERT vs INSERT does not. Design answer: partition/clustering-key isolation between
  concurrent writers + retry logic — not hope. A nightly OPTIMIZE colliding with a
  streaming MERGE is the canonical incident.
- Idempotent writes exist natively: `txnAppId` + monotonic `txnVersion` options — the
  `practice-idempotency-and-reruns` primitive on Delta; use them in every retriable
  batch writer.

## Schema — enforcement and one-way doors

- Enforcement rejects: missing columns in target, type mismatches, and names differing
  only by case. `mergeSchema` adds columns; `overwriteSchema` replaces schema (only with
  full overwrite). Silent schema drift is not a Delta failure mode — silent COLUMN LOSS
  via a sloppy `overwriteSchema` is.
- **Column mapping (`delta.columnMapping.mode=name`) enables RENAME/DROP COLUMN but is
  irreversible** ("cannot turn off after you enable it") and lifts reader/writer
  protocol versions. Another one-way door to flag before flipping.
- CHECK constraints validate existing rows on ADD and upgrade the writer protocol;
  they're the cheap in-engine DQ layer (`practice-data-quality-minimums`).

## Change Data Feed

- `delta.enableChangeDataFeed=true` (default false); read via `table_changes()` or
  streaming `readChangeFeed`. `_change_type`: insert / update_preimage /
  update_postimage / delete. **CDF retention rides table retention** — change records
  are VACUUMed away with old versions, so a CDC consumer that pauses longer than the
  retention window loses history (same class of failure as binlog/oplog retention).

## Maintenance and interop

- OPTIMIZE (bin-packing, idempotent) + Z-ORDER (not idempotent) in OSS since 1.2/2.0;
  liquid clustering OSS since Delta 3.1 (`CLUSTER BY`, incompatible with partitioning
  and ZORDER, max 4 columns). Checkpoints roughly every 10 commits (OSS docs gap;
  corroborated by Trino's writer default) keep log reads viable.
- **UniForm is read-only interop**: Iceberg clients read, never write; requires column
  mapping; **incompatible with deletion vectors**; CDF invisible to Iceberg readers. If
  the client's strategy slide says "open lakehouse" over UniForm, verify the feature
  matrix actually permits it — contradiction goes through the `research` conflict gate.
