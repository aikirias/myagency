# Analytical Data Modeling Guide

## Modeling layers

Every new dataset should be placed intentionally in a layer with a clear purpose:

| Layer | Purpose |
|---|---|
| Raw | Landing zone close to the source representation |
| Standardized | Cleaned, typed, conformed data ready for safe modeling |
| Business | Business-facing facts, dimensions, aggregates, and serving datasets |
| Reporting / Audit | Reporting support, logs, audit outputs, and operational side tables |

## Layer rules

- Raw is for ingestion fidelity first: preserve source shape, capture lineage, avoid business logic
- Standardized is where typing, validation, deduplication, and conformance happen
- Business is the canonical consumer-facing layer for reusable analytical datasets
- Reporting and audit artifacts must not become a substitute for canonical business models
- Data should usually flow forward across layers; skipping a layer requires explicit justification

## Serving pattern selection

Choose the simplest pattern that satisfies the access pattern:

| Pattern | Use when |
|---|---|
| Normalized model | Write complexity is lower than read complexity and relationships matter |
| Star schema | Dimensional analytics and reusable facts/dimensions are required |
| Wide serving table | Consumers need fast, repeated access to a fixed shape |
| Aggregate table | Repeated grouped metrics dominate the workload |
| Hybrid | Different consumer classes need different serving shapes |

## History strategy

- Use current-state only when point-in-time reconstruction is not needed
- Use append-only history when events themselves are the source of truth
- Use SCD1 when latest-value overwrite is sufficient
- Use SCD2 only when consumers truly need point-in-time attribute history
- Use snapshots when full point-in-time dataset state matters more than attribute-level change tracking

## Grain and keys

- Every dataset must have an explicit grain stated in one sentence
- Every uniqueness strategy must be documented
- Composite keys require an explicit deduplication or conflict-resolution rule
- Time semantics must distinguish event time, processing time, and reporting time

## Physical layout

- Partition, clustering, sharding, or sorting choices must follow actual access patterns
- Use time-based partitioning for large time-series data unless another strategy is clearly better
- Avoid layouts that create skew on low-cardinality keys
- Retention and archival strategy must be defined for large or historical datasets

## Incremental loading

- Prefer bounded incremental processing over full refresh where feasible
- Incremental filters must apply to every relevant input, not only the primary dataset
- Reprocessing behavior must be documented before production use

## Scan avoidance

- Large queries must filter on pruning-compatible columns where possible
- Avoid implicit casts that disable pruning or pushdown
- Benchmark major model changes before production deployment if they affect large datasets

## Naming conventions

- Use `snake_case` for dataset and column names
- Keys should be explicit and stable
- Date partition columns should indicate their meaning clearly, such as `event_date` or `business_date`
