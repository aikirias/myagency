---
name: practice-sql-quality
description: SQL correctness and quality standards - join/grain safety, null and date handling, incremental filters, scan discipline, destructive-statement safety. Use when writing, reviewing, or fixing any SQL query or transformation.
---

# Practice: SQL quality

Correctness first, performance second, style third. A query that returns wrong results is
always a blocker regardless of how fast it runs.

## Correctness

- **Grain awareness.** Before joining, know the grain of each table. Any join that can
  multiply rows (1:N, N:M) must be intentional and documented; duplicate amplification is
  the most common silent wrong-result bug.
- **Explicit join types and keys.** `INNER/LEFT/FULL OUTER JOIN ... ON` with table aliases;
  no implicit joins. Cast join keys explicitly when types differ — implicit casts hide
  mismatches and break pruning.
- **No `DISTINCT` as a dedup shortcut.** If duplicates appear, find why. `DISTINCT` is only
  valid when deduplication is the actual intent.
- **Null discipline.** `IS NULL` / `IS NOT NULL`, never `= NULL`. `COALESCE` only as a
  deliberate business decision, not to silence unexpected nulls. Remember NULL join keys
  never match.
- **Date logic.** Cast dates explicitly; be explicit about which time you filter on
  (event vs processing vs partition — see `practice-incremental-processing`). Document
  timezone assumptions when mixing sources.
- **Aggregations.** GROUP BY lists all non-aggregated columns by name (no positional
  grouping in production code). Validate SUM/COUNT against source on first run of a new
  query.

## Scan discipline

- Filter on partition/pruning-compatible columns; never wrap partition or filter columns in
  functions (kills pruning).
- No `SELECT *` in production queries or transformations — name columns explicitly.
- Incremental filters apply to EVERY dated input in the query, not just the main table.
- Large joins document expected cardinality (rows in × rows in → rows out).

## Safety

- `DELETE` and `UPDATE` always carry a `WHERE` (and a partition bound on partitioned
  tables). `DROP`/`TRUNCATE` never appear in pipeline logic — migrations only, with
  approval.
- No side effects inside CTEs.
- Prefer ANSI SQL; use vendor-specific constructs only for a clear performance or modeling
  benefit (the applicable stack pack defines the idioms worth using).

## Review order

When reviewing SQL: (1) does it return the right rows at the right grain, (2) does it
handle nulls/dates/dupes safely, (3) does it scan sanely (`EXPLAIN`), (4) style.
