# de-snowflake

Full stack pack for Snowflake engagements. No reusable consulting content exists — the
official `snowflake-cortex-code` plugin is a router to the proprietary Cortex Code CLI
([survey](../../docs/stack-packs.md)) — so this pack carries first-party, doc-verified
content: idioms, diagnosis, and the cost/audit judgment layer.

## Skills

- `snowflake-idioms` — COPY/Snowpipe/Streaming loading semantics, Streams+Tasks CDC,
  Dynamic Tables, clone/transient/modeling idioms.
- `snowflake-diagnosis` — query-slow tree (pruning/spilling/joins/queuing), stale
  streams, tasks that didn't run, numbers-don't-match causes.
- `snowflake-operations` — credit model, warehouse defaults, storage/Time-Travel
  economics, the ACCOUNT_USAGE audit backbone, RBAC minimums.

## MCP routing (no `.mcp.json` shipped — pick per account access)

| Situation | Option | Read-only mechanism |
| --- | --- | --- |
| You can CREATE in the account | Snowflake-managed MCP server (`CREATE MCP SERVER` with a `SYSTEM_EXECUTE_SQL` tool) | `read_only: true` in the tool spec + RBAC |
| No create rights (common for consultants) | [Snowflake-Labs/mcp](https://github.com/Snowflake-Labs/mcp) — **deprecated upstream but functional** (`uvx snowflake-labs-mcp`) | `sql_statement_permissions` config: `Select: true`, everything else false |
| Minimal fallback | Google MCP Toolbox `--prebuilt snowflake` (execute_sql + list_tables only) | None in-server — read-only ROLE is the only guarantee |

In every case: connect with a dedicated read-only role (USAGE on warehouse/db/schema +
SELECT and nothing else). The role is the durable guarantee, not the server flag.

## Setup

`/plugin install de-snowflake@myagency --scope project`. Request early: a read-only
role, and SELECT on `SNOWFLAKE.ACCOUNT_USAGE` (IMPORTED PRIVILEGES) — it gates all
cost/audit work.
