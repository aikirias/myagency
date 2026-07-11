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
│   ├── de-airflow/
│   ├── de-starrocks/
│   ├── de-clickhouse/
│   ├── de-spark/
│   ├── de-flink/
│   ├── de-pulsar/
│   ├── de-postgres/
│   └── de-mssql/
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
- [x] Method skills: `method-discovery`, `method-diagnosis`, `method-safe-operations`, `method-delivery`
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
- [ ] Remaining stack packs per the tier matrix in stack-packs.md
- [ ] Client-project overlay template (`CLAUDE.md` snippet for client repos)
- [ ] Move demo to `examples/`, retire legacy `.claude/` surface from `main`
- [ ] Rewrite root `README.md` + install/usage docs
- [ ] End-to-end test: install plugins into the testbed and run one deliverable per contract

## Pending cleanup

The legacy `.claude/` directory is still present on `main` because its hooks are active in the
current session and the content is still being mined. It is removed in the "retire legacy" roadmap
step once `de-core` covers its useful parts.
