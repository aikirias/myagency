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

- [ ] **Four new full packs: field review** — [de-spark](plugins/de-spark/),
  [de-flink](plugins/de-flink/), [de-pulsar](plugins/de-pulsar/),
  [de-mssql](plugins/de-mssql/), all doc-verified (Spark defaults checked against
  SQLConf source; Pulsar against 4.0 broker.conf; Flink against 1.20/2.3 doc source;
  MSSQL against learn.microsoft.com). (added 2026-07-11)
  **Review focus:** per pack, the ONE claim that drives real engagements — Spark: the
  documented "dynamic partition overwrite + S3A committers unsupported" trap; Flink:
  "1.x→2.x state compatibility NOT guaranteed" (migration, not upgrade); Pulsar:
  retention=0 / quota=unlimited / subs-never-expire defaults tree; MSSQL: the CDC
  log-truncation trap (stopped capture job = unbounded log even in simple recovery).
  Confirm these match your field experience and add your own gotchas.

- [ ] **Test suite review** — [tests/TESTPLAN.md](tests/TESTPLAN.md): 38 scenario cases
  (install 5, methods 6, practices 8, deliverables e2e 3, hooks 4, research 4, stack
  packs 8) + fixtures with planted defects. Execution deferred until you approve the
  suite. (added 2026-07-11)
  **Review focus:** (1) coverage — is anything you care about untested? (2) the Expected
  checklists of TC-20/21/22 (the deliverable e2e cases) — they encode what "the system
  works" means; (3) the run protocol (fresh session per case, sandbox outside the repo).

- [ ] **Wave-2 packs (11): field review** — surveyed AND built on your go-ahead
  (2026-07-12). Verdict matrix in [docs/stack-packs.md](docs/stack-packs.md).
  Thin (8, vendor deps + consulting delta): [de-dbt](plugins/de-dbt/),
  [de-mysql](plugins/de-mysql/), [de-mongodb](plugins/de-mongodb/),
  [de-elasticsearch](plugins/de-elasticsearch/), [de-redis](plugins/de-redis/),
  [de-rabbitmq](plugins/de-rabbitmq/), [de-bigquery](plugins/de-bigquery/),
  [de-databricks](plugins/de-databricks/). Full (3, doc-verified):
  [de-kafka](plugins/de-kafka/) (Kafka 4.x + Debezium 3.6),
  [de-snowflake](plugins/de-snowflake/), [de-lakehouse](plugins/de-lakehouse/)
  (Iceberg 1.11 + Delta OSS + Trino 482, ONE combined pack). Marketplace now 21
  plugins, `make validate` green. Test cases TC-39..47 added. (added 2026-07-12)
  **Review focus:** per full pack, the ONE claim that drives engagements — Kafka:
  min.insync.replicas=1 default makes acks=all leader-only (the false-comfort matrix)
  and offsets expire in 7 days; Snowflake: tasks auto-suspend after 10 failures and
  streams go stale at 14 days (the silent CDC killers); Lakehouse: VACUUM/expiration
  vs time-travel as ONE dial + DV/protocol one-way doors. Plus two judgment calls:
  (1) `de-lakehouse` combined instead of per-tech packs; (2) de-mysql does NOT
  formally depend on the PlanetScale plugin (its hosted MCP is PlanetScale-cloud-only)
  — skill pulled via `npx skills add` instead. Veto or confirm.

- [ ] **Client onboarding skill review** — new de-core skill
  [method-client-onboarding](plugins/de-core/skills/method-client-onboarding/SKILL.md):
  repo inspection first, then problem/scope interview (must-do / can-do / out-of-scope,
  deliverable mapped to a contract, verifiable acceptance criteria), a scope APPROVAL
  GATE before technical work, then generates the overlay from its
  [canonical template](plugins/de-core/skills/method-client-onboarding/templates/overlay-template.md)
  (moved into the skill so it ships to client repos; root `templates/` is now a
  pointer) + day-one access list from pack READMEs. Test case TC-48 added.
  (added 2026-07-12)
  **Review focus:** (1) the scope gate — is "no technical work before scope approval"
  how you actually want to operate, or too rigid for quick fixes? (2) the must-do /
  can-do / out-of-scope split and the "can-do never displaces a must-do without
  re-agreement" rule; (3) the overlay's new Engagement scope section — fields you'd
  add or drop.

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
