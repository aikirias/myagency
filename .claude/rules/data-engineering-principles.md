# Data Engineering Principles

These principles apply to all pipelines, queries, workflows, and data models in this project.

## Idempotency

Every pipeline must be safe to re-run for the same execution date without producing incorrect results.

- Bounded replace or upsert patterns are preferred over blind append
- Deduplication logic must be explicit, not assumed
- Partial run failures must leave the target in a clean state (no partial loads)

## Business date clarity

Every pipeline must have a clear definition of:

- **Event time**: when the business event occurred (e.g., `order_created_at`)
- **Processing time**: when the record was processed
- **Partition date**: which partition the record belongs to

These must not be silently interchanged. If the partition date differs from the event time, document it explicitly.

## Observability

Every production pipeline must have:

- A freshness check
- A row count check
- An alert on failure with a named owner
- A runbook link or documented escalation path

Pipelines without these are not production-ready.

## Ownership

Every table and pipeline must have a named owner. Ownerless data is unmaintainable data.

- Owner = the team or person responsible for incidents and changes
- Ownership must be documented in the pipeline, the data quality checks, and the table metadata

## Data quality first

Data quality checks are not optional. Every new table or pipeline must have:

- At minimum: freshness, row count, and duplicate check
- Severity levels assigned to every check
- An alert channel defined

## Backfill safety

Before running any backfill:

- Confirm the pipeline is idempotent
- Define the batch size and execution order
- Confirm source data availability
- Notify downstream consumers

Running a backfill on a non-idempotent pipeline is a production risk.

## Downstream awareness

Every schema or logic change must consider:

- Which tables depend on this table?
- Which dashboards or consumers read from this table?
- Will this change break or alter anything downstream?

Document downstream dependencies before deploying breaking changes.

## Safe deployment

Prefer:
- Additive DDL changes (new columns, new tables) over destructive ones
- Feature flags or parallel loads for risky logic changes
- Staging environment validation before production deployment
- Off-peak deployment windows for large table changes

Avoid:
- `DROP TABLE` or `TRUNCATE` in production without explicit approval
- `ALTER TABLE` that changes column types or removes columns without migration
- Deploying workflow logic changes without reviewing backfill safety
