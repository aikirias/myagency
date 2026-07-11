---
name: practice-data-modeling
description: Analytical data modeling standards - explicit grain, layered flow (raw to curated to serving), history strategy selection, keys and uniqueness, physical layout. Use when designing or reviewing tables, models, serving datasets, or layer placement decisions.
---

# Practice: data modeling

Every modeling decision is answerable in one sentence: what is the grain, which layer does
it live in, and how does history behave. If any of the three is fuzzy, the model is not
ready.

## Grain

- Every dataset declares its grain in one sentence ("one row per order per day").
- Every uniqueness strategy is documented; composite keys carry an explicit dedup /
  conflict-resolution rule.
- Time semantics distinguish event, processing, and reporting time
  (see `practice-incremental-processing`).

## Layers

Flow: **raw/landing → curated → serving**.

- **Raw**: ingestion fidelity — preserve source shape, capture lineage, no business logic.
  Prefer immutable / append-only.
- **Curated**: typing, validation, deduplication, conformance. The reusable source of truth
  for business entities and metrics. Business logic lives here, once — never duplicated
  across models.
- **Serving**: business-facing shapes (facts, aggregates, wide tables) that consume ONLY
  curated models, never raw. Reporting/audit side-tables are downstream artifacts, not a
  substitute for curated models.
- Skipping a layer requires explicit justification.

## History strategy — pick the simplest that meets the need

(Selection logic — the ordered questions that lead to each strategy — lives in
`practice-architecture-selection`; this table is the reference.)

| Strategy | Use when |
| --- | --- |
| Current-state only | Point-in-time reconstruction is not needed |
| Append-only events | The events themselves are the source of truth |
| SCD1 (overwrite) | Latest value is sufficient |
| SCD2 (versioned rows) | Consumers truly need point-in-time attribute history — verify they do; SCD2 by default is years of avoidable complexity |
| Snapshots | Full dataset state at points in time matters more than attribute-level change |

## Serving shape — match the access pattern

Normalized model, star schema, wide table, aggregate table, or a hybrid — chosen by how
consumers actually query, not by doctrine. Repeated grouped metrics → aggregate; fixed
fast lookups → wide table; reusable dimensional analytics → star.

## Physical layout

- Time-partition large transactional tables unless a different strategy is clearly better;
  partition column names say what they mean (`event_date`, `business_date`).
- Avoid layouts that skew on low-cardinality keys.
- Define retention/archival for large or historical datasets.
- Every table has a named owner and an expected freshness SLA.
- `snake_case` names; stable, explicit keys.
