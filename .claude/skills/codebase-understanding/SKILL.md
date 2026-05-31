---
name: codebase-understanding
description: Uses Understand Anything to explore, map, and explain codebases, pipeline logic, and transformation dependencies. Use when onboarding to a new codebase, mapping pipeline dependencies, understanding legacy SQL, or when the user asks to explore or document how a codebase works.
---

When using this skill:

1. Identify the goal from the table below and route to the appropriate command.
2. Confirm that Understand Anything is installed in Claude Code.
3. If the knowledge graph has not been built yet, start with `/understand`.
4. Interpret the output in the context of data engineering patterns.
5. Use `.claude/rules/engineering-workflow.md` to decide whether the next step is proposal work, diagramming, implementation, or publication.

## Command routing

| Goal | Command |
|---|---|
| First-time exploration of a codebase | `/understand` |
| Map business domains and data flows | `/understand-domain` |
| Understand impact of a pending change | `/understand-diff` |
| Ask questions about specific logic or a table | `/understand-chat` |
| Deep dive into a specific file or SQL model | `/understand-explain` |
| Generate onboarding guide for new team members | `/understand-onboard` |

## Data engineering use cases

**Before deploying a change:**
Run `/understand-diff` to map which pipelines and downstream consumers are affected before merging. Cross-reference with the downstream consumer list.

**Understanding legacy transformations:**
Use `/understand-explain` on a specific DAG or SQL file to get a structured explanation of inputs, outputs, and business logic.

**Onboarding a new team member:**
Run `/understand-onboard` to generate a structured guide covering pipeline families, data flow, and ownership.

**Mapping domain ownership:**
Run `/understand-domain` to extract which business domains each pipeline serves, then align with SLA tiers and team ownership.

**Ad-hoc questions:**
Use `/understand-chat` to ask:
- "Which pipelines write to `db_data_model.fact_orders`?"
- "What are the upstream dependencies of the `btc_price_daily` DAG?"
- "Which tables have no data quality checks?"

## Config files

- `.understand-anything/knowledge-graph.json` — commit to git (source of truth)
- `.understand-anything/intermediate/` — do not commit (scratch files)
- `.understand-anything/diff-overlay.json` — do not commit (local only)

## Notes

- Run `/understand` once after cloning the repo before using other commands.
- Re-run `/understand` after major refactors to keep the knowledge graph current.
- The `--auto-update` flag keeps the graph updated incrementally via git hooks.
- This skill is usually the first step of the "existing system discovery" workflow.
