# de-starrocks

Full stack pack for StarRocks engagements. No curated StarRocks knowledge exists in the
plugin ecosystem ([survey](../../docs/stack-packs.md)) — the skills here are first-party
content covering engine idioms, diagnosis, and operations.

## What this pack provides

- **MCP access** (`.mcp.json`): the official
  [mcp-server-starrocks](https://github.com/StarRocks/mcp-server-starrocks).
  **Warning: this server has NO global read-only flag** — it always exposes a write-capable
  tool. On client engagements, `STARROCKS_USER` MUST be a read-only database user
  (SELECT-only grants). This is mandatory, not a suggestion (`method-safe-operations`).
- **Skills**: `starrocks-idioms` (table models, load patterns, idempotency mapping),
  `starrocks-diagnosis` (failure modes by symptom), `starrocks-operations` (ops and
  monitoring surface).

## Per-project setup

1. `/plugin install de-starrocks@myagency --scope project`
2. Ask the client for a **read-only user**; set `STARROCKS_HOST`, `STARROCKS_PORT`
   (MySQL protocol, default 9030), `STARROCKS_USER`, `STARROCKS_PASSWORD` in the project
   environment — never in files.

Requires `uv` (Python) on the machine running Claude Code.

## Testbed

The `examples/` local stack in this repo runs StarRocks — use it to validate pack content
end-to-end without touching any client system.
