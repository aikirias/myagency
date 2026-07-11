# Client project overlay — template

Copy the block below into the CLIENT repo's `CLAUDE.md` (or `CLAUDE.local.md` if it must
stay out of their git) at the start of an engagement, and fill it in. This is the
per-project configuration every de-core skill reads: deliverable conventions, stack,
safety boundaries. When a skill says "the overlay defines it", it means this block.

---

```markdown
# Engagement: <client> — <short engagement name>

## Toolkit

- Marketplace: `myagency` (add once: `claude plugin marketplace add aikirias/myagency`)
- Installed plugins: `de-core`, <`de-<stack>` packs that apply>, `research`
- Vendor marketplaces added: <e.g. astronomer/agents, timescale/pg-aiguide, ClickHouse/agent-skills>

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
- Approval boundaries: <who approves prod DDL, deploys, backfills>
- Deploy / freeze windows: <...>
- Data boundary: <what may not leave client systems; PII classification owner>

## Out of scope for this engagement

- <explicit exclusions — the scope fence>
```
