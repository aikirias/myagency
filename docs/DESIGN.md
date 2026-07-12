# myagency — Design Document

Source of truth for the rebuild of this repo as a personal Data Engineering consulting toolkit,
distributed as a Claude Code plugin marketplace.

Status: **in progress**. The previous scaffold is preserved on the `legacy-scaffold` branch and is
treated as a quarry of ideas, **not** as a source of truth.

## Goal

Abstract the practices, tools, and deliverable formats used across DE consulting engagements into
reusable, installable Claude Code plugins:

- A **core** plugin with the working method, engineering practices, and deliverable contracts —
  stack-agnostic by design.
- One **stack pack** plugin per technology, carrying idioms, gotchas, snippets, and tool/MCP config
  for that stack only.
- Per-client projects install `de-core` + only the stack packs that apply.

## Decision log

| # | Decision | Choice | Notes |
| --- | --- | --- | --- |
| 1 | Distribution | Claude Code plugin marketplace (this repo) | Install per client repo: `/plugin marketplace add <this repo>` then `/plugin install de-core@myagency --scope project` |
| 2 | Rebuild approach | From scratch; legacy on `legacy-scaffold` branch | Demo stack kept as testbed (to be moved under `examples/`) |
| 3 | Plugin granularity | Modular: `de-core` + one plugin per stack | Keeps client context free of irrelevant stacks |
| 4 | Language | All content in English | Deliverable language may be overridden per client later if needed |
| 5 | Naming | Marketplace `myagency`, plugins `de-*` | Skills invoke as `/de-core:<skill>` |
| 6 | First deliverable contract | `broken-report-fix` | Serves as the pattern for the other contracts |
| 7 | Commands directory | Not used — deprecated in favor of skills | Skills are the single entry point |
| 8 | Stack packs are reuse-first | Survey existing community/vendor plugins, skills, and MCP servers per stack BEFORE authoring | Where good assets exist: reference/install them, and our pack ships only the consulting delta (gotchas, safety integration, contract hooks). Own content stays at the abstract level (medallion, idempotency, method) |
| 9 | Vendor plugins as formal dependencies | Thin packs declare cross-marketplace `dependencies` in plugin.json (Claude Code v2.1.110+) | `de-airflow` → `astronomer-data@astronomer`; `de-postgres` → `pg@aiguide`; `de-clickhouse` → `clickhouse-best-practices` + `clickhouse-architecture-advisor` @ `clickhouse-agent-skills`. External marketplace names whitelisted via `allowCrossMarketplaceDependenciesOn`. One manual step remains per vendor: `claude plugin marketplace add <org/repo>` (dependencies cannot auto-add marketplaces) |
| 10 | Layer-naming convention | Medallion = conceptual vocabulary (design notes, audits); physical naming follows the transformation tool's ecosystem (dbt: staging/intermediate/marts) | Equivalence declared once in `practice-architecture-selection` (Decision 3); client overlay states which naming the repo uses; never mix within one artifact. User-approved 2026-07-12 |
| 11 | SCD2 implementation default | dbt snapshots where dbt is in the stack; platform-native change tracking otherwise | Selection rule ("no SCD2 without a named point-in-time query") unchanged — this fixes the HOW. Deviations are documented design-note decisions. User-approved 2026-07-12 |

## Architecture

```text
myagency/                          # marketplace repo (this repo)
├── .claude-plugin/marketplace.json
├── plugins/
│   ├── de-core/                   # installed in EVERY engagement
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/                # flat dirs, prefixed by family (plugin discovery is
│   │   │   │                      # skills/<name>/SKILL.md — no nested grouping)
│   │   │   ├── method-*/          # how I work: discovery → diagnosis → solution → delivery
│   │   │   ├── practice-*/        # engineering standards, loaded on demand per task
│   │   │   └── deliverable-*/     # output contracts per engagement type
│   │   ├── agents/                # slim role definitions (judgment, not personas)
│   │   └── hooks/                 # safety hooks (SQL/DDL/py validation)
│   ├── de-airflow/ de-starrocks/ de-clickhouse/ de-postgres/   # wave 1
│   ├── de-spark/ de-flink/ de-pulsar/ de-mssql/                # wave 1 full
│   ├── de-kafka/ de-snowflake/ de-lakehouse/                   # wave 2 full
│   ├── de-dbt/ de-mysql/ de-mongodb/ de-elasticsearch/         # wave 2 thin
│   ├── de-redis/ de-rabbitmq/ de-bigquery/ de-databricks/      # wave 2 thin
│   └── research/                                               # domain-agnostic
├── examples/                      # testbed (ex local-stack demo), NOT part of the product
└── docs/                          # this design doc + usage docs
```

Stack plugins are added to `marketplace.json` only once they have real content — the marketplace
never lists empty plugins.

## Layering rules

1. **`de-core` must stay stack-agnostic.** No references to a specific engine, orchestrator,
   catalog, port, table name, or vendor SQL inside core skills. If a rule only makes sense on one
   technology, it belongs in that stack pack.
2. **Stack packs particularize, never redefine.** A stack pack says *how* a core practice applies
   on that technology (e.g. how idempotent upserts work on ClickHouse `ReplacingMergeTree`); it
   never contradicts core practices.
3. **Deliverable contracts define the output, not the technique.** Each engagement type
   (broken report fix, new pipeline, audit, …) has a contract skill defining exactly what files
   are handed to the client, in what order and format. Practices define how the work is done;
   contracts define what leaves the building.
4. **Progressive disclosure.** Nothing is always-loaded except each skill's one-line description.
   No monolithic rules files. A skill body is read only when the task matches.
5. **Per-client overlay lives in the client repo**, not here: the client's `CLAUDE.md` /
   `CLAUDE.local.md` declares stack, conventions, and deliverable preferences. This repo may ship
   a template for that overlay.

## Content sources

When porting material from the legacy branch, apply this filter:

- Keep: distilled practices (idempotency, backfill safety, DQ minimums, business-date clarity).
- Strip: demo-stack contamination (StarRocks table names, Airflow DAG shapes, Backstage/Plane
  endpoints, localhost ports) — move anything worth keeping into the matching stack pack.
- Drop: persona filler in agents, 1:1 command wrappers, always-loaded rule bloat.

## Roadmap

- [x] Decide distribution, granularity, language, naming
- [x] Marketplace + `de-core` manifest scaffold
- [x] Deliverable contract: `broken-report-fix` (v1 — see `plugins/de-core/skills/deliverable-broken-report-fix/`)
- [x] Method skills: `method-discovery`, `method-diagnosis`, `method-safe-operations`,
      `method-delivery`, `method-improvement-plan` (checkpointed plans + drift protocol),
      `method-field-capture` (capture→promote loop that grows skills from field experience)
- [x] Practices skills: sql-quality, idempotency-and-reruns, incremental-processing,
      data-quality-minimums, backfill-safety, data-modeling, observability-and-ownership,
      cost-optimization, pii-handling, architecture-selection (incl. OLTP/OLAP/engine-class),
      data-lifecycle, governance-and-catalog
- [x] Agents (slim rewrite): data-architect, data-engineer, data-quality-engineer, incident-analyst
- [x] Hooks: check-sql, check-prod-ddl (DE_PROD_SCHEMAS-configurable), check-python — rewritten
      as PostToolUse on Write|Edit; Airflow-specific python checks deferred to `de-airflow`
- [x] Deliverable contract: `new-pipeline` (approval-gated design note w/ Mermaid, runbook,
      deployed DQ suite, idempotency-proof validation evidence)
- [x] Deliverable contract: `platform-audit` (6 dimensions incl. consistency/source-of-truth and
      efficiency/effectiveness; severity × effort findings; dual-audience report)
- [x] Ecosystem survey: existing plugins/skills/MCP per stack → [stack-packs.md](stack-packs.md)
- [x] First thin pack: `de-clickhouse` (draft — pending user review of consulting notes)
- [x] First full pack: `de-starrocks` (idioms / diagnosis / operations, doc-verified — pending
      user review + testbed validation)
- [x] Thin packs: `de-airflow` (incl. DAG hooks ported from legacy), `de-postgres`
- [x] `research` plugin (domain-agnostic): `investigate` skill + RES-NNN record system with
      implementation-tracking lifecycle
- [x] Remaining stack packs (full tier, doc-verified research per pack): `de-spark`,
      `de-flink`, `de-pulsar`, `de-mssql` — pending user field review
- [x] Wave-2 stack packs (surveyed and built 2026-07-12): thin — `de-dbt`, `de-mysql`,
      `de-mongodb`, `de-elasticsearch`, `de-redis`, `de-rabbitmq`, `de-bigquery`,
      `de-databricks` (vendor deps + consulting delta); full, doc-verified — `de-kafka`
      (+Connect/Debezium), `de-snowflake`, `de-lakehouse` (Iceberg+Delta+Trino
      combined) — pending user field review
- [x] Test suite prepared: `tests/TESTPLAN.md` + 47 cases across 7 areas + fixtures
      (execution deferred until suite approved; TC-39..47 cover wave-2 packs)
- [x] Client-project overlay template — canonical copy now ships inside
      `method-client-onboarding` (root `templates/` file is a pointer)
- [x] `method-client-onboarding` (de-core): repo inspection → problem/scope interview
      (must-do / can-do / out-of-scope + deliverable + acceptance criteria, approval
      gate) → generated overlay + day-one access list (added 2026-07-12)
- [x] Demo moved to `examples/` (local-stack, architecture, catalog-info, openspec); legacy
      `.claude/` retired except hooks/ + settings.json (session-active — removed next session)
- [x] Root `README.md` + `CLAUDE.md` rewritten for the marketplace; new `make validate`
      (scripts/validate_marketplace.py) replaces the legacy structure validator
- [ ] Execute the test suite (tests/TESTPLAN.md) — install/unit/integration, one case per
      fresh session; failures feed back as skill fixes or HUMAN-INTERVENTION items

## Pending cleanup

Only `.claude/hooks/` + `.claude/settings.json` remain from the legacy surface — their
PreToolUse hooks are loaded in the working session, so deleting them mid-session breaks
Write calls. Remove both (plus the note in `CLAUDE.md`) in a fresh session; de-core's
plugin hooks replace them.
