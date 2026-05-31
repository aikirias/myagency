# Backfill Standards

## Before any backfill

These must be confirmed before starting:

1. **Idempotency verified** — re-running the same date produces the same result
2. **Source data available** — historical data exists in the source for the full range
3. **Target state understood** — what exists in the target for the backfill range?
4. **Downstream notified** — consumers know data is being reprocessed
5. **Rollback defined** — there is a clear way to undo the backfill if it goes wrong

If any of these is not confirmed: do not start the backfill.

## Idempotency patterns

| Pattern | Safe for backfill |
|---|---|
| Interval-bounded replace | Yes — replaces only the targeted interval |
| `DELETE + INSERT` in a transaction | Yes — atomically replaces the partition |
| `MERGE / UPSERT` by PK | Yes — idempotent by definition |
| Plain `INSERT` | No — will duplicate rows on re-run |
| Append to a file | No — will duplicate on re-run |

## Batch size guidelines

| Volume per day | Recommended batch size |
|---|---|
| < 100k rows | 30 days |
| 100k – 1M rows | 7 days |
| 1M – 10M rows | 1–3 days |
| > 10M rows | 1 day or less |

Always validate the first batch before proceeding to the rest.

## Execution order

- Default: oldest to newest (preserves dependency order for downstream pipelines)
- Exception: newest to oldest if the business needs the most recent data first

## Concurrency during backfill

- Reduce workflow concurrency during the backfill window unless there is a documented reason not to
- Reduce scheduler or worker concurrency if the source system is sensitive to load
- Run backfills during off-peak hours (typically 20:00–06:00 local time)

## QA checkpoints

After every batch:
- Check row count matches source
- Check no duplicates were introduced
- Spot-check 5–10 rows for correctness

After the full backfill:
- Run the full data quality suite for the dataset
- Compare key metrics (SUM, COUNT DISTINCT) against source for the full range
- Notify downstream consumers that the backfill is complete

## Communication

Before starting:
- Announce in the team channel: date range, expected duration, affected tables
- Notify downstream consumers (BI, analysts, dependent pipelines)

After completing:
- Confirm the backfill is complete and data is correct
- Update any dashboards or reports that were paused

## Rollback procedure

Define this before starting. Typical options:

1. **Restore from snapshot**: if the target was snapshotted before the backfill started
2. **Truncate + reload from source**: if source data is still available
3. **Delete affected partitions**: if clean partitions can be identified
4. **Replay from upstream**: if the upstream pipeline can re-deliver the data

Never start a backfill without a defined rollback procedure.
