# de-dbt

Thin stack pack for dbt engagements. General dbt knowledge comes from dbt Labs' own
first-party plugin ([survey](../../docs/stack-packs.md)) — this pack ships the MCP safety
posture per engagement type and the consulting delta (the failure modes that produce
"green CI, wrong data").

## What this pack provides

- **MCP access** (`.mcp.json`): the official [dbt-mcp](https://github.com/dbt-labs/dbt-mcp)
  server via `uvx dbt-mcp`, with SQL execution and the Admin API disabled by default
  (`DISABLE_SQL=true`, `DISABLE_ADMIN_API=true`). Toolsets auto-disable when their env
  vars are missing, so a local-Core-only setup exposes only CLI/discovery surfaces.
- **Skill** `dbt-consulting-notes`: incremental/snapshot/test traps mapped to the de-core
  method.

## Per-project setup

1. Add the vendor marketplace once:

   ```bash
   claude plugin marketplace add dbt-labs/dbt-agent-skills
   ```

2. `/plugin install de-dbt@myagency --scope project` — auto-installs
   `dbt@dbt-agent-marketplace` (dbt Labs' 9 official skills) as a declared dependency.
3. Set `DBT_PROJECT_DIR` (absolute path to the dbt project) and `DBT_PATH` (path to the
   dbt executable, e.g. `~/.local/bin/dbt`).

## Safety posture per engagement type

| Engagement | Recipe |
| --- | --- |
| Audit / discovery (read-only) | Keep the shipped defaults; if dbt Cloud creds exist, add `DBT_MCP_ENABLE_DISCOVERY=true` + `DBT_MCP_ENABLE_SEMANTIC_LAYER=true` and nothing else |
| Build engagement | CLI toolset active (default when `DBT_PROJECT_DIR` is set) — dbt CLI tools run `build/run/test` and DO modify warehouse data; target dev, never prod profiles |

Requires `uv` (Python) on the machine running Claude Code.
