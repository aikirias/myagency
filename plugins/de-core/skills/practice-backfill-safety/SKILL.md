---
name: practice-backfill-safety
description: Safe backfill standards - preconditions, batch sizing, execution order, QA checkpoints, rollback, communication. Use when planning, reviewing, or executing any backfill, historical reprocessing, or recovery load.
---

# Practice: backfill safety

A backfill is a production intervention, not a bigger scheduled run. Running a backfill on
a non-idempotent pipeline is how one bad day becomes a corrupted history.

## Preconditions — all five, or no backfill

1. **Idempotency verified** — actually re-run one interval and compare results
2. **Source availability confirmed** — history exists for the full range
3. **Target state understood** — what is currently in the target for the range
4. **Downstream notified** — consumers know data will move under them
5. **Rollback defined** — snapshot, partition-delete list, or upstream replay path, written
   down before batch one

## Execution

- **Batch by volume**: small daily volumes → large batches (weeks); large volumes → one day
  or less per batch. The first batch is a canary: validate it fully before continuing.
- **Order**: oldest → newest by default (preserves downstream dependency order); newest →
  oldest only when the business needs recent data first, stated explicitly.
- **Isolation**: backfills run separately from the production schedule — never let a
  catch-up storm and the daily run fight over the same intervals or resources.
- **Throttle**: reduce concurrency if the source is sensitive; prefer off-peak windows.

## QA checkpoints

- After every batch: row counts vs source, duplicate check on the business key, spot-check
  a handful of rows.
- After the full range: complete quality suite, key metric totals (SUM / COUNT DISTINCT)
  vs source for the whole range, downstream consumers notified of completion.

## Communication

Announce before starting (range, expected duration, affected tables) and confirm after
finishing. A silent backfill that changes numbers under a dashboard destroys more trust
than the gap it fixed.
