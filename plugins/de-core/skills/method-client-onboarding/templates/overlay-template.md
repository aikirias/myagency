# Client project overlay — canonical template

Filled by `method-client-onboarding` into the CLIENT repo's `CLAUDE.md` (or
`CLAUDE.local.md` if it must stay out of their git). This is the per-project
configuration every de-core skill reads. Unknowns stay as `OPEN:` markers — never
assumptions.

---

```markdown
# Engagement: <client> — <short engagement name>

## Engagement scope (agreed <date>, approved by <who>)

- Problem: <what hurts, who is affected, cadence/deadline, audience>
- Must do (engagement fails without these):
  - <...>
- Can do (only if time/access allows — never displaces a must-do without re-agreement):
  - <...>
- Out of scope (the fence):
  - <explicit exclusions>
- Deliverable: <broken-report-fix | new-pipeline | platform-audit | custom: package
  defined as ...>
- Acceptance criteria (verifiable):
  - <...>
- Scope changes: re-agreed and appended here with date — never absorbed silently.

## Toolkit

- Marketplace: `myagency` (add once: `claude plugin marketplace add aikirias/myagency`)
- Installed plugins: `de-core`, <`de-<stack>` packs that apply>, `research`
- Vendor marketplaces added: <e.g. astronomer/agents, dbt-labs/dbt-agent-skills>
- Day-one access requests sent (<date>): <list from the stack packs' READMEs — status>

## Stack and environments

- Engines / orchestrators: <e.g. ClickHouse 24.x, Airflow 2.9>
- Environments: <prod / staging / replica endpoints — hosts only, never credentials>
- Credentials: via project env vars (<e.g. CLICKHOUSE_*, DATABASE_URI, AIRFLOW_*>) —
  read-only users confirmed with <who> on <date>
- Production-looking schemas for the DDL hook: `DE_PROD_SCHEMAS="<prod dw ...>"`

## Deliverable conventions (read by the deliverable-* contracts)

- Language: <English | Spanish | ...>
- Delivery channel: <folder `deliverables/` in this repo | PR | wiki export | zip>
- Prevention mode (broken-report-fix contract): <implement | recommend-only>
- Diagram style: <Mermaid embedded (default) | client's tool>

## Record systems

- Research records: `research/` (RES-NNN) — decision registry for this engagement
- Improvement plans: `plans/` (PLAN-NNN)
- Pending human decisions: `HUMAN-INTERVENTION.md` (every item carries a Review focus line)

## Client conventions and constraints

- Naming / modeling conventions that bind: <...>
- Layer naming in THIS repo: <medallion bronze/silver/gold | dbt staging/intermediate/marts>
  (conceptual vocabulary in design notes stays medallion — de-core Decision 3 house rule)
- Approval boundaries: <who approves prod DDL, deploys, backfills>
- Deploy / freeze windows: <...>
- Data boundary: <what may not leave client systems; PII classification owner>
- Client git conventions binding our PRs: <...>
```
