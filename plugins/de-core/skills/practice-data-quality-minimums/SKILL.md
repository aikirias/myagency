---
name: practice-data-quality-minimums
description: Minimum data quality bar for production datasets - the four mandatory checks (freshness, volume, duplicates, nulls), severity levels, automated execution, threshold calibration, reconciliation. Use when designing, reviewing, or generating data quality checks for any dataset or pipeline.
---

# Practice: data quality minimums

A dataset without quality checks is not production-ready. Checks that only run when someone
remembers to run them do not count.

## The four mandatory checks

| Check | Minimum requirement |
| --- | --- |
| Freshness | Alert when the latest reliable data signal is older than SLA + buffer |
| Volume | Alert when record count deviates beyond a calibrated threshold vs baseline |
| Duplicates | Alert when the declared uniqueness definition is violated |
| Nulls | Alert when null rate on required fields exceeds threshold |

Every production dataset has all four. Additional checks (reconciliation, distribution,
referential integrity) are added by risk, not by default.

## Severity — every check has one

- **critical**: data is wrong or missing in a way that affects decisions → page/alert the
  owner, block downstream where possible. A count of 0 on a never-empty dataset is always
  critical.
- **warning**: unusual but not confirmed broken → team-channel alert, same-day look.
- **info**: expected variance worth tracking → log only.

## Calibration

- Generic thresholds (±20%) are placeholders, acceptable only at day one; calibrate per
  dataset against observed variance and seasonality, then remove the placeholder.
- Null threshold on required business fields is 0% unless a documented exception exists.
- Noisy checks are worse than no checks — an ignored alert channel silently disables the
  entire quality system. Tune or delete checks that cry wolf.

## Automated execution — non-negotiable

A SQL file of checks is a reference, not an implementation. Every check suite runs
automatically, in one of two patterns:

- **In-pipeline**: check tasks appended after the load, failing the run on critical FAIL.
  Use when checks should gate the pipeline's own output.
- **Independent schedule**: a separate job running after the load is expected, logging
  results. Use when monitoring data produced by someone else, or when check results must be
  independent of pipeline success.

Either way: every result (check, status, observed value, timestamp) is logged to a results
table; critical failures raise loudly; the executor itself has retries, a timeout, and an
alert with an owner.

## Metadata — a check is not complete without

`dataset`, `check name`, `severity`, `owner`, `alert channel`, `threshold`.

## Reconciliation

Required for financial data, customer-facing metrics, and regulatory outputs: compare row
counts, key metric totals, and distinct entity counts against the source, with an exact or
explicitly justified tolerance.
