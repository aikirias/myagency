# data-eng-claude-workspace

Reusable workspace for Data Engineering teams using Claude Code with structured workflows, team rules, and a local test stack.

## Purpose

This project standardizes how a Data Engineering team works with Claude Code. Instead of ad-hoc prompting, it defines agents, skills, commands, rules, and hooks that turn team knowledge into repeatable workflows.

The goal is straightforward: more consistent reviews, less repeated context in each prompt, and lower operational risk for data changes.

## Who should use it

- Data Engineers writing or reviewing pipelines, DAGs, SQL, and backfills
- Data Architects designing source-to-target flows and data models
- Tech leads doing PR reviews or incident investigations
- Anyone generating technical documentation (tickets, ADRs, runbooks)

## What problems it solves

| Problem | Solution |
| --- | --- |
| Inconsistent SQL reviews | `/project:review-sql` skill with a shared checklist |
| Risky backfills with no plan | `/project:generate-backfill-plan` skill |
| Workflows missing retries or idempotency checks | `/project:review-orchestration-workflow` skill |
| Incident investigation without structure | `/project:investigate-pipeline-incident` skill |
| Ticket quality varies by author | `/project:generate-technical-ticket` command |
| Vague business requests with no structure | `/project:discover-requirements` skill |
| New team members don't know standards | Rules, skills, and agents encode them |

## Agent structure

The current repository structure is consolidated into 6 base agents:

- `business-intake-manager`
- `data-architect`
- `data-engineer`
- `data-analyst`
- `data-quality-engineer`
- `incident-analyst`

The idea is that agents define specialization and judgment, while concrete workflows live in `skills` and are exposed through `/project:*`.

## Main workflows

### Technical review

```text
/project:review-data-eng-plan          → Review a pipeline plan before implementation
/project:review-sql                    → Review a SQL query
/project:review-orchestration-workflow → Review an orchestration workflow
/project:generate-data-quality-checks  → Generate data quality checks
/project:generate-backfill-plan        → Design a safe backfill plan
/project:review-data-pr                → Review a Data Engineering PR
/project:investigate-pipeline-incident → Investigate a pipeline incident
/project:generate-technical-ticket     → Generate a Plane-ready technical ticket
```

### Requirements and prioritization

```text
/project:discover-requirements  → Turn business requests into a functional specification
/project:generate-technical-use-cases → Convert a functional specification into technical use cases
/project:refine-ticket          → Refine vague or oversized tickets
/project:assess-priority        → Prioritize a backlog with explicit criteria
```

## Repository structure

```text
data-eng-claude-workspace/
├── CLAUDE.md                        # Global Claude behavior for this project
├── local-stack/                     # Airflow + StarRocks + CloudBeaver + Backstage for local testing
├── .claude/
│   ├── settings.json                # Permissions and hooks config
│   ├── agents/                      # 6 base specialists for the workspace
│   ├── skills/                      # Structured checklist-driven workflows
│   ├── commands/                    # Slash commands /project:*
│   ├── rules/                       # Modeling, SQL, orchestration, and prioritization standards
│   └── hooks/                       # Pre/post tool validation scripts
└── examples/                        # Realistic examples for demos and testing
```

## Setup

Claude Code resolves commands, agents, skills, and rules **relative to the root of the opened workspace**. If you open a parent directory instead, Claude Code will not find this project's `.claude/` folder and the commands will not appear.

**VS Code / Cursor**: open this folder as the workspace root:

```text
File → Open Folder → data-eng-claude-workspace/
```

**Claude Code CLI**: start from this folder:

```bash
cd data-eng-claude-workspace
cp .env.example .env   # one time only, if you need local tokens or credentials
# load variables if your shell does not export them automatically
# set -a; source .env; set +a
claude
```

Once the root is correct, `/project:*` commands appear in autocomplete when you type `/`.

## Demo flow

1. Open `examples/pipeline-plan-example.md` → run `/project:review-data-eng-plan`
2. Open `examples/bad-query-example.sql` → run `/project:review-sql`
3. Open `examples/airflow-dag-example.py` → run `/project:review-orchestration-workflow`
4. Open `examples/incident-example.md` → run `/project:investigate-pipeline-incident`

This sequence shows agents, skills, commands, and rules all working together in a concrete Data Engineering context.

## Local stack

The repo includes a minimal local stack in [local-stack/README.md](/home/akwiek/doc/claudio/data-eng-claude-workspace/local-stack/README.md:1) for end-to-end workflow testing with:

- Airflow standalone
- local StarRocks with `1 FE + 1 BE`
- CloudBeaver as a web SQL editor
- Backstage for local portal exploration

Endpoints:

- Airflow: `http://localhost:8080`
- StarRocks FE: `http://localhost:8030`
- StarRocks MySQL: `localhost:9030`
- CloudBeaver: `http://localhost:8978`
- Backstage frontend: `http://localhost:3000`
- Backstage backend: `http://localhost:7007`

## Project MCPs

The repo includes MCP configuration in [`.mcp.json`](/home/akwiek/doc/claudio/data-eng-claude-workspace/.mcp.json:1). The goal is to let Claude Code query real tools and systems instead of relying only on textual context.

MCP servers currently configured:

- `starrocks`: read-only MySQL connection to StarRocks for exploring schemas, tables, and data
- `airflow`: access to the Airflow API to list DAGs, runs, and operational state
- `postgres`: optional generic connector for environments that still use Postgres outside the local stack
- `mattermost`: optional integration for reading or using team operational context

Relation to the local stack:

- `starrocks` points to the local StarRocks instance started by `local-stack`
- `airflow` points to the local Airflow instance at `http://localhost:8080`
- `postgres` is not part of the current `local-stack`
- `mattermost` depends on an external instance

Relevant environment variables:

- `AIRFLOW_USERNAME`
- `AIRFLOW_PASSWORD`
- `STARROCKS_HOST`
- `STARROCKS_PORT`
- `STARROCKS_USER`
- `STARROCKS_PASS`
- `STARROCKS_DB`
- `POSTGRES_URL`
- `MATTERMOST_URL`
- `MATTERMOST_TOKEN`
- `MATTERMOST_TEAM_ID`

Quick reference:

- copy [`.env.example`](/home/akwiek/doc/claudio/data-eng-claude-workspace/.env.example:1) to `.env`
- fill in only the variables you need for your active MCPs
- in this repo, Plane integration is not modeled as an MCP: it is used through API credentials (`PLANE_TOKEN`) and the rules in `.claude/rules/plane-integration.md`

## Medallion in StarRocks

The local and repository modeling convention follows a medallion architecture:

- `db_stage` = Bronze, pure raw data with source fields as strings
- `db_data_model` = Silver, curated and typed data
- `db_business_model` = Gold, modeled data ready for business consumption
- `db_report` = reporting, logs, and audit data

The expected flow is `db_stage -> db_data_model -> db_business_model`, with `db_report` used as an auxiliary layer rather than the canonical model.

## How to extend it

- **Add a new agent**: create `.claude/agents/your-agent.md` following the existing template
- **Add a new skill**: create `.claude/skills/your-skill/SKILL.md`
- **Add a new command**: create `.claude/commands/your-command.md`
- **Add team rules**: add `.md` files to `.claude/rules/`
- **Add hooks**: add shell scripts to `.claude/hooks/` and register them in `.claude/settings.json`
- **Override locally**: copy `CLAUDE.local.example.md` to `CLAUDE.local.md` and add personal context

## Stack context

This workspace is designed for teams using:

- Apache Airflow for orchestration
- StarRocks or similar analytical databases
- SQL-heavy transformations
- Batch and near-real-time pipelines
- Data quality frameworks
- Standard SDLC with PRs, tickets, and ADRs
