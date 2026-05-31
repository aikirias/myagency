# Understand Anything Guide

## What it is

Understand Anything is a Claude Code native plugin that builds a knowledge graph from a codebase using Tree-sitter and LLM analysis. It exposes slash commands for exploration, impact analysis, and onboarding.

- Repo: https://github.com/Lum1104/Understand-Anything
- Install: run inside Claude Code → `/plugin marketplace add Lum1104/Understand-Anything` then `/plugin install understand-anything`

## Setup

After installing, run `/understand` once in Claude Code to build the initial knowledge graph.

```
.understand-anything/
  knowledge-graph.json    # commit to git — source of truth
  intermediate/           # do not commit — scratch files
  diff-overlay.json       # do not commit — local only
```

Add to `.gitignore`:
```
.understand-anything/intermediate/
.understand-anything/diff-overlay.json
```

## Command reference

| Command | Purpose |
|---|---|
| `/understand` | Build or update the knowledge graph for the codebase |
| `/understand-domain` | Extract business domains and data flows from the codebase |
| `/understand-diff` | Analyze the impact of staged or uncommitted changes |
| `/understand-chat` | Interactive Q&A about the codebase |
| `/understand-explain` | Deep-dive explanation of a specific file or function |
| `/understand-onboard` | Generate a structured onboarding guide |
| `/understand-knowledge` | Analyze wiki-pattern knowledge bases |
| `/understand-dashboard` | Open interactive knowledge graph visualization |

## Data engineering use cases

### Before deploying a change
Run `/understand-diff` to map which pipelines and downstream consumers are affected. Cross-reference with the downstream consumer list before merging.

### Understanding legacy SQL
Use `/understand-explain <file>` to get a structured breakdown of inputs, outputs, business rules, and dependencies.

### Domain and ownership mapping
Run `/understand-domain` to extract which business domains each pipeline serves. Align results with SLA tiers and team ownership records.

### Onboarding
Run `/understand-onboard` to generate a guide covering pipeline families, data flow, key tables, and owners.

### Ad-hoc questions via `/understand-chat`

Useful questions for data engineering:
- "Which pipelines write to `db_data_model.fact_orders`?"
- "What are the upstream dependencies of this DAG?"
- "Which tables have no data quality checks?"
- "What does this CTE in `transform_orders.sql` do?"
- "Which pipelines would be affected if I change the schema of `db_stage.raw_crm_events`?"

## Maintenance

- Re-run `/understand` after major refactors to keep the graph current.
- Use `--auto-update` flag to keep the graph updated incrementally via git hooks.
- The knowledge graph is cumulative — it does not reset on re-run unless explicitly cleared.
