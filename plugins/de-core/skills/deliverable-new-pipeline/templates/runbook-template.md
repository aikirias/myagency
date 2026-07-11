# Runbook: <pipeline name>

**Owner**: <team/person>
**Alert channel**: <channel>
**Freshness SLA**: <e.g. data available by 07:00 UTC daily>
**Escalation**: <who, when the runbook does not resolve it>

## Normal operation

- Schedule: <cadence, timezone, expected duration>
- Healthy looks like: <the signals — last run status, freshness check green, expected volume range>

## When it fails

| Symptom | Likely cause | Action |
| --- | --- | --- |
| <run failed with X> | <cause> | <numbered steps or link to section below> |
| <freshness alert> | <upstream late / run stuck> | <check A, then B> |
| <volume alert> | <source issue / partial load> | <check A, then B> |

## How to re-run an interval

Safe because: <idempotency mechanism — what makes re-running not duplicate data>.

1. <exact command / UI steps to re-run interval Y>
2. <what to verify after: counts, DQ checks>

## How to backfill a range

<Reference to the backfill plan, or the steps + batch size + validation checkpoints.
Follows practice-backfill-safety: never run wide ranges without validating the first batch.>

## Rollback

<How to undo a bad load: partition delete list / snapshot restore / upstream replay.
Exact steps, not intentions.>

## Do NOT

- <Actions that look helpful but are dangerous for this pipeline — e.g. do not re-run
  with overlapping intervals while a merge is in progress>
