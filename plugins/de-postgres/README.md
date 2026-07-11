# de-postgres

Thin stack pack for PostgreSQL engagements. General PG knowledge comes from Timescale's
`pg-aiguide` ([survey](../../docs/stack-packs.md)) — this pack ships connectivity, pointers,
and the consulting delta for PG in data-engineering engagements (usually as a SOURCE
system).

## What this pack provides

- **MCP access** (`.mcp.json`): [Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp)
  pinned to `--access-mode=restricted` — parser-enforced read-only transactions with
  execution time limits. Do NOT switch to unrestricted mode on client engagements.
  Note: the archived Anthropic reference Postgres server has known read-only bypass
  issues — never use it as a fallback.
- **Skill** `postgres-consulting-notes`: gotchas for PG as a source/serving system,
  mapped to the de-core method.

## Per-project setup

1. Add the vendor marketplace once:

   ```bash
   claude plugin marketplace add timescale/pg-aiguide
   ```

2. `/plugin install de-postgres@myagency --scope project` — this **auto-installs
   `pg@aiguide`** (Timescale's curated PG skills + docs MCP) as a declared dependency.
3. Set `DATABASE_URI` (e.g. `postgresql://user:pass@host:5432/db`) in the project
   environment — never in files. Ask the client for a read-only role and, when available,
   point at a **read replica** rather than the primary.

Requires `uv` (Python) on the machine running Claude Code.
