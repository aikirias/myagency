---
name: practice-incremental-processing
description: Incremental-first processing standards - event vs processing vs partition time, watermarks and late data, bounded intervals, when full refresh is acceptable. Use when designing or reviewing pipeline load strategies, incremental filters, or date/time semantics.
---

# Practice: incremental processing

Prefer bounded incremental processing over full refresh. Full refreshes hide cost growth,
punish source systems, and turn every run into a potential full outage.

## The three times — never silently interchanged

- **Event time**: when the business event happened (`order_created_at`)
- **Processing time**: when the record arrived / was processed
- **Partition date**: which physical partition the record lives in

Every pipeline states which of the three drives its incremental filter and its partition
strategy. If partition date differs from event time, that mapping is documented — this is
where late data either gets handled or silently lost.

## Rules

- **Bounded intervals.** Each run processes an explicit logical interval passed as a
  parameter — never "everything since whenever", never derived from wall-clock "now"
  inside the logic. UTC internally unless business logic requires otherwise; no hardcoded
  dates.
- **Incremental filter on every dated input.** Filtering only the main table while joining
  full history from others is the classic hidden full scan.
- **Late data is a decision, not a surprise.** Define the lateness window (how far back a
  run re-reads or re-opens intervals) based on observed source behavior, and document what
  happens to records later than that.
- **Watermark integrity.** Whatever signal marks "processed up to here" (watermark, interval
  marker, max loaded_at) must only advance after the interval is fully and successfully
  loaded.
- **Reprocessing behavior documented before production.** How do you re-run one day? One
  month? See `practice-backfill-safety` for execution.

## When full refresh is acceptable

- Small reference/dimension data where full reload is cheaper than change tracking
- Sources with no reliable change signal AND small volume
- Explicit rebuilds (schema migration, logic change) — as a planned event, not a schedule

In all cases the choice is stated and justified, with the volume at which it stops being
acceptable noted.
