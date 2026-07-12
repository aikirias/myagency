---
name: dbt-consulting-notes
description: dbt consulting delta - incremental strategy traps per adapter, on_schema_change silent default, snapshot SCD2 pitfalls, tests that pass vacuously, slim CI with state and defer, source freshness discipline. Use when building, auditing, or debugging dbt projects in a data engineering engagement.
---

# dbt consulting notes

Consulting DELTA only — modeling/testing/semantic-layer mechanics come from dbt Labs'
official `dbt` plugin (install per the pack README). This skill carries the failure modes
that produce "CI is green but the data is wrong" — the thing clients actually hire for.

## Incremental models — where data silently disappears

- **Strategy is adapter-specific**: `merge` vs `insert_overwrite` vs `delete+insert` vs
  `microbatch` differ per adapter. On BigQuery, `insert_overwrite` replaces WHOLE
  partitions — a wrong `partition_by`/`partitions` config drops data with a green run.
  Always state the strategy + adapter pair explicitly in the design note
  (`deliverable-new-pipeline`).
- **`on_schema_change` defaults to `ignore`**: new source columns are silently absent
  from incremental models until someone notices downstream. Even
  `append_new_columns`/`sync_all_columns` never backfill existing rows — schema changes
  on incrementals need an explicit backfill decision (`practice-backfill-safety`).
- **`--full-refresh` is a cost/SLA event, not a flag**: it rebuilds the table. Protect
  expensive models with `full_refresh: false` and treat any full refresh as a
  `practice-backfill-safety` operation (scoped, costed, approved).
- The rerun question (`practice-idempotency-and-reruns`): an incremental model is only
  rerun-safe if its predicate re-selects the same interval deterministically — lookback
  windows (`where updated_at > max(this)`) with late-arriving data need an explicit
  lookback margin, and that margin is a documented judgment call.

## House conventions (from de-core, Decisions 3-4)

- **Layer naming**: in dbt repos, physical naming is `staging`/`intermediate`/`marts`;
  medallion terms stay in design notes and client conversations
  (`practice-architecture-selection` layer-naming house rule — don't mix vocabularies
  in one artifact).
- **SCD2 default**: where dbt is present, SCD2 = dbt snapshots (house rule); the
  strategy caveats below are the reason this section exists.

## Snapshots (SCD2) — both strategies lie differently

- `timestamp` strategy trusts `updated_at`: rows changed without touching it are missed
  forever. Verify the column is trigger/app-maintained before choosing it.
- `check` strategy compares `check_cols` between runs: a value that changes and reverts
  BETWEEN runs is invisible; hard deletes need `hard_deletes: invalidate` (or the legacy
  `invalidate_hard_deletes`) or deleted rows stay "current" forever.
- de-core rule applies: no SCD2 without a named point-in-time query
  (`practice-architecture-selection` Decision 4).

## Tests — green is not the same as right

- **Generic tests pass vacuously on empty models**: `unique`, `not_null`,
  `accepted_values` all pass on zero rows, so a broken upstream filter yields a fully
  green build. Pair every critical model with a volume/recency check (row-count
  threshold, `dbt_utils.recency`, or source freshness) — this is
  `practice-data-quality-minimums` applied to dbt.
- **Source freshness is the cheap guard**: `loaded_at_field` + warn/error thresholds on
  every source actually loaded on a schedule. A project with tests but no freshness
  checks tests yesterday's data.
- Singular tests for business rules; store failures (`store_failures`) when the client
  needs evidence trails for the fix deliverable.

## CI and state — the slim-CI pattern

- `dbt build --select state:modified+ --defer --state <prod-artifacts>` is the correct
  CI shape (build only what changed + downstream, read the rest from prod). Two traps:
  stale prod manifests cause false diffs, and env-var/macro changes mark everything
  modified. Regenerate the state artifact on every prod deploy.
- `target/compiled/` + `dbt compile` is the debugging path for macro/Jinja issues; code
  inside `{% if execute %}` guards does not run at parse time — `run_query` in macros
  confuses everyone the first time.

## Project hygiene findings (for `deliverable-platform-audit`)

- **Seeds misuse**: seeds are for small static mappings. Real datasets (or PII) loaded as
  seeds = data in git, no lineage, slow runs — a recurring audit finding
  (`practice-pii-handling`).
- Sources without freshness, models without owners/descriptions, and warehouse-side
  objects created outside dbt (breaking `dbt docs` lineage) round out the standard
  finding set (`practice-observability-and-ownership`, `practice-governance-and-catalog`).
