# de-clickhouse

Thin stack pack for ClickHouse engagements. Per the reuse-first strategy
([docs/stack-packs.md](../../docs/stack-packs.md)), general ClickHouse best practices come
from the vendor's maintained assets — this pack ships connectivity, pointers, and the
consulting-specific delta only.

## What this pack provides

- **MCP access** (`.mcp.json`): the official [mcp-clickhouse](https://github.com/ClickHouse/mcp-clickhouse)
  server. **Read-only by default** — writes would require `CLICKHOUSE_ALLOW_WRITE_ACCESS=true`
  and DROP additionally `CLICKHOUSE_ALLOW_DROP=true`; do NOT set these on client engagements
  (see `method-safe-operations`).
- **Skill** `clickhouse-consulting-notes`: engagement gotchas mapped to the de-core method.

## Per-project setup

1. Install this pack: `/plugin install de-clickhouse@myagency --scope project`
2. Install the vendor knowledge (maintained by ClickHouse Inc., do not duplicate it here):

   ```bash
   claude plugin marketplace add ClickHouse/clickhouse-claude-code-plugin
   # or the skills repo directly: https://github.com/ClickHouse/agent-skills
   ```

3. Set credentials in the project environment (never in files):
   `CLICKHOUSE_HOST`, `CLICKHOUSE_PORT`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`,
   `CLICKHOUSE_SECURE`. Request a **read-only user** from the client.

Requires `uv` (Python) on the machine running Claude Code.
