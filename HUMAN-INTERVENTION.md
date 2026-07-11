# Human intervention needed

Running list of items that require Aikirias's review, decision, or input. Claude adds items
here as they appear; mark done (or answer inline) and Claude picks them up next session.

Format: unchecked = pending. Add answers/notes directly under the item.

## Pending

- [ ] **ClickHouse: rerun validation pattern** — in
  [clickhouse-consulting-notes](plugins/de-clickhouse/skills/clickhouse-consulting-notes/SKILL.md)
  (`[REVIEW]` marker): when validating a rerun on `ReplacingMergeTree`, is your preferred
  pattern `count()` with `FINAL`, an `argMax` comparison by version column, or something
  else? (added 2026-07-11)

- [ ] **ClickHouse: personal gotchas dump** — the consulting-notes skill is a drafted
  baseline; add your recurring gotchas from real ClickHouse engagements so the pack
  reflects your field experience, not just docs. Free-text is fine; Claude will structure
  it. (added 2026-07-11)

- [ ] **Review the deliverable contracts** — especially
  [deliverable-broken-report-fix](plugins/de-core/skills/deliverable-broken-report-fix/SKILL.md)
  (it is the pattern the other two follow): does the package shape and the 9 mandatory
  README sections match what you actually hand to clients? (added 2026-07-11)

- [ ] **StarRocks: field-experience review** — the three `de-starrocks` skills
  ([idioms](plugins/de-starrocks/skills/starrocks-idioms/SKILL.md),
  [diagnosis](plugins/de-starrocks/skills/starrocks-diagnosis/SKILL.md),
  [operations](plugins/de-starrocks/skills/starrocks-operations/SKILL.md)) are drafted from
  verified official docs. Add your engagement gotchas and correct anything that clashes
  with what you've seen in the field. (added 2026-07-11)

- [ ] **Architecture-selection frameworks review** — new skill
  [practice-architecture-selection](plugins/de-core/skills/practice-architecture-selection/SKILL.md)
  (warehouse vs lakehouse, when medallion applies, SCD1/SCD2/events/snapshots decision
  tree, processing cadence). Check the defaults match how you actually decide — especially
  the "no SCD2 without a named point-in-time query" rule and the hybrid-platform default.
  Extended per your request with: OLTP/OLAP/engine-class selection (now Decision 1 of that
  skill), plus two new skills to review —
  [practice-data-lifecycle](plugins/de-core/skills/practice-data-lifecycle/SKILL.md)
  (retention/archiving, raw hot-window default of 1-3 months: confirm) and
  [practice-governance-and-catalog](plugins/de-core/skills/practice-governance-and-catalog/SKILL.md)
  (catalog threshold ~50-100 datasets: confirm it matches your experience).
  (added 2026-07-11)

## Answered / done

<!-- move completed items here, keep the answer for traceability -->

- [x] **Commit checkpoint** — pushed to `origin/main` on 2026-07-11 (`f46ae35` marketplace
  rebuild + `ddb17a0` gitignore fix for plugin MCP configs); `legacy-scaffold` branch also
  pushed to origin.
