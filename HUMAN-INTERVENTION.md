# Human intervention needed

Running list of items that require Aikirias's review, decision, or input. Claude adds items
here as they appear; mark done (or answer inline) and Claude picks them up next session.

Format: unchecked = pending. Add answers/notes directly under the item.
**Convention (mandatory): every item ends with a `Review focus:` line** — the one or two
things worth your attention when reviewing, so you never have to re-derive what matters.

## Pending

- [ ] **ClickHouse: personal gotchas dump** — the 5 doc-derived candidates are now
  confirmed and folded into the
  [consulting-notes skill](plugins/de-clickhouse/skills/clickhouse-consulting-notes/SKILL.md).
  This item now just holds space for YOUR field gotchas: free-text me the recurring
  ClickHouse incidents you've seen and I'll structure + fold them into the "Field-captured
  gotchas" section. (added 2026-07-11)
  **Review focus:** the incidents you've seen MORE than once — those are what's worth
  encoding; drop me whatever comes to mind, no format needed.

- [ ] **Review the deliverable contracts** — especially
  [deliverable-broken-report-fix](plugins/de-core/skills/deliverable-broken-report-fix/SKILL.md)
  (it is the pattern the other two follow). (added 2026-07-11)
  **Review focus:** (1) the package folder shape — is `fix-<date>-<slug>/` with numbered
  `sql/` how you'd actually hand it over? (2) the 9 mandatory README sections — is any
  missing or superfluous vs what your clients expect? Errors here propagate to the other
  two contracts.

- [ ] **StarRocks: field-experience review** — the three `de-starrocks` skills
  ([idioms](plugins/de-starrocks/skills/starrocks-idioms/SKILL.md),
  [diagnosis](plugins/de-starrocks/skills/starrocks-diagnosis/SKILL.md),
  [operations](plugins/de-starrocks/skills/starrocks-operations/SKILL.md)) are drafted from
  verified official docs. (added 2026-07-11)
  **Review focus:** the "duplicates despite Primary Key — 5 mechanics" list in diagnosis
  (it will drive real fixes, wrong entries cost client time) and whether the
  "too many versions → batch, not bigger cluster" framing matches your field experience.

- [ ] **Architecture-selection frameworks review** —
  [practice-architecture-selection](plugins/de-core/skills/practice-architecture-selection/SKILL.md)
  (engine class OLTP/OLAP, warehouse vs lakehouse, medallion, history strategy, cadence),
  plus [practice-data-lifecycle](plugins/de-core/skills/practice-data-lifecycle/SKILL.md)
  and [practice-governance-and-catalog](plugins/de-core/skills/practice-governance-and-catalog/SKILL.md).
  (added 2026-07-11)
  **Review focus:** the defaults that will bind future designs: (1) "no SCD2 without a
  named point-in-time query", (2) hybrid lake+warehouse as the usual mid-size answer,
  (3) raw hot-window of 1-3 months before cold tiering, (4) catalog-product threshold at
  ~50-100 datasets. Each is a judgment call I made for you — confirm or correct the number.

- [ ] **Airflow + Postgres packs review** — new thin packs
  [de-airflow](plugins/de-airflow/) and [de-postgres](plugins/de-postgres/).
  (added 2026-07-11)
  **Review focus:** de-airflow — the interval-semantics section (it claims "shifted by one
  day" bugs are the #1 ticket source; adjust if your experience differs). de-postgres —
  the CDC/replication-slot WAL warning is written as THE top audit check on PG sources;
  confirm it deserves that rank.

- [ ] **Research plugin review** — domain-agnostic plugin
  [research](plugins/research/): [investigate](plugins/research/skills/investigate/SKILL.md) +
  [review](plugins/research/skills/review/SKILL.md) skills and the
  [RES record template](plugins/research/skills/investigate/templates/RES-template.md).
  (added 2026-07-11)
  **Review focus:** (1) the practice-precedence order (project decisions > toolkit
  practices > official docs > industry) and the blocking escalation gate — this decides
  when you get interrupted vs when things self-resolve; (2) staleness thresholds (30d
  journal-silent, 90d concluded-unimplemented); (3) whether the RES template sections are
  ones you'd genuinely fill or dead weight.

- [ ] **Improvement-plan method review** — de-core skill
  [method-improvement-plan](plugins/de-core/skills/method-improvement-plan/SKILL.md) +
  [PLAN template](plugins/de-core/skills/method-improvement-plan/templates/PLAN-template.md).
  (added 2026-07-11)
  **Review focus:** the drift thresholds — auto-correct requires acceptance criteria intact
  AND no scope/risk/safety change; 3 consecutive minor drifts escalate as major. This sets
  the balance between the plan nagging you and running away on its own; tune it here.

- [ ] **Commit checkpoint** — uncommitted on top of what's pushed: research plugin,
  method-improvement-plan, method-field-capture, cross-marketplace dependencies, ClickHouse
  gotcha promotions, and the REPO CLOSURE (demo moved to `examples/`, legacy `.claude/`
  removed except hooks+settings, new README/CLAUDE.md/Makefile/validator, client overlay
  template). Plus one unpushed local revert commit. (added 2026-07-11)
  **Review focus:** the deletions — 57 legacy files removed from main (all preserved on
  `legacy-scaffold`); confirm nothing you still use daily got removed, then say when to
  commit+push. `make validate` passes on the new structure.

## Answered / done

<!-- move completed items here, keep the answer for traceability -->

- [x] **Field-capture mechanism review** (approved 2026-07-11, as-is) —
  [method-field-capture](plugins/de-core/skills/method-field-capture/SKILL.md) accepted:
  recurrence gate (candidate on 1 sighting, confirmed on ≥2) and the two boundaries
  (no editing installed packs in client repos; de-identify before promoting) approved
  unchanged. Hooks into `method-delivery`.

- [x] **ClickHouse: rerun validation pattern** (resolved 2026-07-11) — set two
  non-negotiable rules + a pattern in
  [clickhouse-consulting-notes](plugins/de-clickhouse/skills/clickhouse-consulting-notes/SKILL.md):
  (1) always partition-scope, never whole table; (2) validate content not cardinality.
  Primary pattern = `argMax(col, version)` by business key, partition-scoped;
  `count() FINAL` demoted to a spot-check for small partitions; reconcile against source
  when available (preferred for fix deliverables).
