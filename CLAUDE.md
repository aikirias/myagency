# Data Engineering Workspace

Persistent onboarding for Claude Code in this repo. Keep responses and changes aligned with the project's data engineering workflows, not with generic software defaults.
This file is operational guidance for Claude Code, not general project documentation.

## Project Context

Reusable workspace for Data Engineering teams using Claude Code with:

- Airflow orchestration
- StarRocks as the primary analytical database
- Python for workflow automation
- SQL for transformations, modeling, and data quality
- Batch and near-real-time pipeline workflows
- LikeC4 for architecture-as-code diagrams
- OpenSpec for spec-driven development proposals
- Understand Anything for codebase exploration and impact analysis

Primary goals:

- Reliable, idempotent pipelines
- Low operational risk
- Incremental-first processing
- Reusable review and delivery workflows

## Commands

- `claude` from the repo root -> load this workspace with `.claude/` config
- `cp .env.example .env` -> create local credentials and MCP config
- `make install` -> install LikeC4, OpenSpec, and Understand Anything
- `cd local-stack && docker compose up -d --build` -> start local Airflow + StarRocks + CloudBeaver + Backstage
- `cd local-stack && ./bootstrap-starrocks.sh` -> create demo StarRocks schemas and tables
- `cd local-stack && docker compose logs -f airflow` -> inspect Airflow locally
- `cd local-stack && docker compose down` -> stop the local stack

Useful slash commands:

- `/project:review-sql`
- `/project:review-orchestration-workflow`
- `/project:generate-backfill-plan`
- `/project:generate-data-quality-checks`
- `/project:review-data-pr`
- `/project:investigate-pipeline-incident`
- `/project:architecture-diagram` -> create or update a LikeC4 architecture diagram
- `/project:spec-proposal` -> write an OpenSpec proposal before implementing
- `/project:codebase-understanding` -> explore codebase with Understand Anything

## Repository Structure

- `.claude/agents/` -> specialist agent definitions
- `.claude/skills/` -> checklist-driven workflows
- `.claude/commands/` -> `/project:*` entry points
- `.claude/rules/` -> persistent engineering standards
- `.claude/hooks/` -> validation and safety hooks
- `examples/` -> sample SQL, workflow, incident, and ticket inputs
- `local-stack/` -> local Airflow + StarRocks + Backstage environment

## Rules

### SQL

- Prefer ANSI SQL whenever possible.
- Never use `SELECT *` unless explicitly justified.
- Always explicitly name columns.
- Prefer CTEs over deeply nested subqueries.
- Avoid vendor-specific SQL unless the task requires it.
- Use StarRocks-specific syntax only when it provides a clear performance or modeling benefit.
- Filter partitions when querying large partitioned tables.
- Avoid `DISTINCT` as a deduplication shortcut.
- Avoid functions on partition or filter columns.
- Explicitly cast types when joining different data types.
- Large joins must document expected cardinality.

### Data Modeling

- Treat the curated model layer as the reusable source of truth for business entities and metrics.
- Serving or business-facing layers must only consume curated models, not raw ingestion outputs.
- Prefer immutable raw layers and append-only patterns when possible.
- Avoid duplicating business logic across models.
- Partition large transactional tables by time unless a different strategy is justified.
- Every table must define an owner and expected freshness SLA.

### Orchestration And Pipelines

- All pipelines must be idempotent and safe to retry.
- Prefer incremental loads over full refreshes unless explicitly requested.
- Avoid full-table rewrites unless explicitly required.
- Pipelines must fail loudly on schema mismatches.
- Always distinguish event time, processing time, and partition date.
- Always validate source row counts or equivalent ingestion sanity checks.
- Avoid hardcoded dates; use UTC internally unless business logic requires otherwise.
- Backfills must be isolated from production schedules.
- Workflow definitions must be deterministic and keep business logic out of orchestration layers when possible.
- Keep orchestration definitions lightweight and prefer reusable helpers.
- Every workflow step must have retries and timeout boundaries configured.
- Long-running consumers should run in isolated execution environments when possible.
- Cross-workflow waits must be designed carefully to avoid deadlocks.
- For streaming or consumer workflows, require idempotency, DLQs for malformed events, and versioned schemas.

### Reliability And Engineering

- Prefer explicit failures over silent corruption.
- Never ignore failed records silently; preserve original payloads in failure logs when applicable.
- Never suggest dropping, truncating, or destructive production DDL without explicit instruction.
- Never remove retries, alerts, or safety checks without explicit instruction.
- Flag hardcoded credentials, schema names, and environment-specific values.
- Schema-breaking changes require contract versioning.
- Prefer solutions with predictable operational cost.
- Avoid repartitioning large datasets without clear justification.
- Do not modify unrelated files.
- Prefer minimal diffs.
- Reuse existing rules, skills, and patterns before creating new abstractions.
- Prefer simple and maintainable solutions over unnecessary complexity.
- Do not invent schemas or APIs.
- Do not introduce new dependencies unless necessary.
- Prefer additive and backward-compatible changes when production impact is possible.

## Work Style

- Before changing code, inspect existing patterns.
- Documentation first: before implementing a new integration, provider feature, external API, or unfamiliar tool, review the official documentation first and base the implementation on that source.
- For risky changes, explain assumptions and impact.
- Prefer review or checklist outputs before implementation.
- When information is missing, state assumptions explicitly.
- **Agent and skill routing is mandatory**: before executing any Data Engineering task, identify which agents (`.claude/agents/`) and skills (`.claude/skills/`) apply. Route each track to the appropriate specialist — do not generate SQL, DDL, backfill plans, data quality checks, or technical documentation directly when a skill or agent covers it. If multiple tracks are involved (e.g., design + backfill + data quality), spawn the corresponding agents in parallel.

## Architecture Notes

- StarRocks is the primary modeling target in this workspace.
- The expected medallion flow is `raw/landing -> refined/curated -> serving/consumption`.
- Use bronze/silver/gold or equivalent layer names only as implementation details; keep design reasoning at the medallion-pattern level.
- Reporting, logs, and audit datasets are downstream consumption artifacts, not the canonical curated model layer.
- Local MCP usage is backed by `.mcp.json`; the local stack provides the `starrocks` and `airflow` endpoints.
- Treat prod, backfills, and large-table changes as high-risk operations.

## Additional Documentation

Use progressive disclosure. Read deeper docs only when the task needs them.

- `.claude/rules/data-engineering-principles.md`
- `.claude/rules/sql-style-guide.md`
- `.claude/rules/orchestration-workflow-guide.md`
- `.claude/rules/analytical-modeling-guide.md`
- `.claude/rules/data-quality-standards.md`
- `.claude/rules/backfill-standards.md`
- `.claude/rules/plane-integration.md`
- `.claude/rules/likec4-guide.md` -> LikeC4 DSL conventions and CLI usage
- `.claude/rules/openspec-guide.md` -> OpenSpec proposal workflow and templates
- `.claude/rules/understand-anything-guide.md` -> Understand Anything commands and data engineering use cases
- `.claude/README.md`
- `README.md`
- `local-stack/README.md`
