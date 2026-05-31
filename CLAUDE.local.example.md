# CLAUDE.local.md — Local Personal Context

Copy this file to `CLAUDE.local.md` and fill in only the local or personal context that helps Claude work better for you.
This file is gitignored and should never be committed.

`CLAUDE.md` is for shared repo rules.
`CLAUDE.local.md` is for personal workflow, local environment, and temporary priorities.

## Best Practices

- Keep it short and operational.
- Add only context that changes Claude's decisions in your local workflow.
- Prefer concrete facts over generic preferences.
- Update it when your current focus changes.
- Do not repeat rules already defined in `CLAUDE.md` or `.claude/rules/`.
- Do not put secrets here unless you are comfortable storing them in a local plaintext file.

Good:

- "My local analytical database runs on `localhost:9030`."
- "I am currently migrating `customer_orders` from full load to incremental."
- "When reviewing workflows, show operational risk before style comments."

Avoid:

- Long personal notes or general documentation
- Rewriting team-wide SQL or orchestration rules
- Vague statements like "write better code"

## My Role

<!-- Good: one short line with your responsibility -->
<!-- Example: Senior Data Engineer focused on ingestion and backfills -->

## My Current Focus

<!-- Good: active work that should influence prioritization -->
<!-- Example: Migrating MSSQL ingestion from full loads to incremental -->
<!-- Example: Stabilizing late-arriving events in customer activity pipelines -->

## Review Preferences

<!-- Good: how you want findings presented -->
<!-- Example: Show blockers first, then performance risks, then style issues -->
<!-- Example: For risky SQL, call out data duplication scenarios explicitly -->

## Local Environment Notes

<!-- Good: machine-specific or local-cluster context -->
<!-- Example: My dev analytical database is at localhost:9030 -->
<!-- Example: I use the local orchestration stack from local-stack/ -->
<!-- Example: My usual schema for testing is db_stage -->

## Active Projects

<!-- Good: short list of current pipelines, tables, or initiatives -->
<!-- Example: - customer_orders ingestion from MSSQL -->
<!-- Example: - btc_price_daily workflow reliability cleanup -->
<!-- Example: - data quality rollout for db_business_model.daily_sales -->

## Team Or Runtime Context

<!-- Good: temporary context not worth promoting to shared CLAUDE.md yet -->
<!-- Example: My orchestration platform in this environment is version 2.7 -->
<!-- Example: We have a deploy freeze every Friday after 16:00 -->
<!-- Example: Current incident focus is delayed partner settlements -->

## Personal Constraints

<!-- Good: constraints that change implementation choices -->
<!-- Example: Avoid adding new Python dependencies unless I ask explicitly -->
<!-- Example: Prefer changes that I can validate locally with docker compose -->
<!-- Example: If MCP context conflicts with local files, ask me before changing behavior -->
