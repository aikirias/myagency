---
name: method-diagnosis
description: Layered diagnosis method for broken, wrong, or slow reports, queries, and datasets - from reproducing the symptom through data, model/storage fit, tool fit, query logic, and consumption path, to a confirmed root cause. Use when investigating why a report or dataset does not run, returns wrong results, or performs badly.
---

# Method: diagnosis

Diagnose in layers, cheapest and most-frequent causes first. Do not touch query logic until
the data and the structural fit have been checked. Capture evidence at every step — the
"before" evidence for the deliverable can only be captured now, not reconstructed later.

Prerequisite: discovery is done (see `method-discovery`) — you know the audience, cadence,
timeline, and acceptance criteria. All probing follows `method-safe-operations`.

## Step 0 — Reproduce and classify the symptom

Reproduce the failure yourself (or capture the exact failing output) and classify it:

- **Does not run** (errors, timeouts, never finishes) → suspect resources, structure, locks, upstream availability
- **Runs but wrong results** (missing rows, duplicates, bad numbers) → suspect data, grain, logic, write semantics
- **Runs but too slow / degrading** → suspect volume growth, partitioning, scan patterns, consumption load

The branch determines which layers below get the most attention. Record the exact
reproduction (query, parameters, timestamp, output) as evidence.

## Step 1 — Timeline

When did it last work, and what changed around the break: deploys, schema changes, upstream
source changes, volume shifts, new consumers. A working system that broke has a cause in the
delta; find the delta before theorizing.

## Step 2 — Data before code

Before assuming the query is wrong, check the inputs:

- Freshness: did the upstream data actually arrive for the affected period?
- Completeness: row counts vs expected baseline for the period
- Duplicates: business-key uniqueness on the involved tables
- Contract drift: did an upstream schema or semantic change silently?

A large share of "the report is broken" turns out to be late, missing, or duplicated
upstream data.

## Step 3 — Requirement fit (are they forcing the tools?)

Compare what the report is being asked to do against what the platform was built for:

- Latency expectations vs the engine's consistency and ingestion model (e.g. near-real-time
  reads on an eventually-consistent engine can surface duplicates or partial data by design)
- Serving-layer queries hitting raw/ingestion tables directly
- Interactive dashboards aggregating over data that should be pre-aggregated

A mismatch here means the "bug" is architectural: the fix must say so, and quick-fix vs
redesign becomes an explicit recommendation in the deliverable.

## Step 4 — Storage and model fit

For every table involved in the report:

- Structure and grain: does the table's grain match how the query uses it?
- Partitioning: does the partition scheme match the query's filters? Is pruning happening?
- Volume: current size and growth vs what the layout was designed for
- Engine/table type: is the engine and table type (merge/dedup semantics, key strategy)
  appropriate for the write and read pattern it serves?

Stack packs (`de-clickhouse`, `de-starrocks`, …) carry the engine-specific checks for this
step; apply the matching pack when the engine is known.

## Step 5 — Query fit

Only now, the queries themselves:

- Join logic, grain preservation, duplicate amplification
- Filter and date logic (event time vs processing time confusion)
- Scan behavior: run `EXPLAIN` (mandatory before executing anything — see
  `method-safe-operations`) and look for full scans, missing partition pruning, exploding joins

## Step 6 — Consumption path

How the report is read can be the problem or hide one:

- The BI tool's generated queries, caching, and refresh schedule
- Dashboards firing many concurrent queries at peak times
- Timeouts or limits imposed by the consuming tool, not the database

This step also yields improvement recommendations beyond the immediate fix.

## Step 7 — Converge on root cause

- Rank remaining hypotheses by supporting evidence; verify cheapest-first.
- Root cause is CONFIRMED when you can reproduce the failure mechanism and predict its
  behavior (e.g. "duplicates appear exactly when a retry overlaps a merge window").
  Anything less is a hypothesis and must be labeled as one in the deliverable.
- Write the causal chain symptom → mechanism → root cause with the evidence for each link.

## Output

Diagnosis notes containing: symptom classification, timeline, evidence per layer checked
(including layers ruled out), confirmed root cause with causal chain, and captured "before"
evidence. This feeds directly into the matching `deliverable-*` contract.
