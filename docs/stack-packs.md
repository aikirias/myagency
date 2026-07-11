# Stack packs — reuse-first strategy

Survey date: 2026-07-11. Per decision #8 in [DESIGN.md](DESIGN.md): before authoring stack
content, we surveyed existing plugins, skills, and MCP servers. Result: two pack tiers.

- **Thin pack**: good vendor/community knowledge exists → our pack ships the MCP config,
  points to the external plugin(s) to install, and adds ONLY our consulting delta
  (gotchas, safety integration, contract hooks).
- **Full pack**: no curated knowledge exists → our pack carries the idioms/diagnosis/
  operations content ourselves (this is also where the toolkit differentiates).

## Survey matrix

| Stack | Existing knowledge | MCP server | Pack tier |
| --- | --- | --- | --- |
| ClickHouse | **REUSE**: [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (official, 7 skills incl. 28-rule best practices) + [official plugin](https://github.com/ClickHouse/clickhouse-claude-code-plugin) | **SHIP**: [mcp-clickhouse](https://github.com/ClickHouse/mcp-clickhouse) (official; **read-only by default**; env `CLICKHOUSE_HOST/PORT/USER/PASSWORD`) | Thin |
| Airflow | **REUSE**: [astronomer/agents](https://github.com/astronomer/agents) (~30 skills, on the official Anthropic marketplace as `data-engineering`) | **SHIP**: `astro-airflow-mcp` (PyPI; `AF_READ_ONLY=true`; env `AIRFLOW_API_URL` + auth) | Thin |
| PostgreSQL | **REUSE**: [timescale/pg-aiguide](https://github.com/timescale/pg-aiguide) (1.8k★, most mature of the survey) | **SHIP**: [Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp) (`--access-mode=restricted` = enforced read-only + time limits; env `DATABASE_URI`). Do NOT use the archived Anthropic reference server (read-only bypass issues) | Thin |
| StarRocks | **BUILD**: nothing curated exists anywhere | **SHIP with caveat**: [official MCP](https://github.com/StarRocks/mcp-server-starrocks) has no global read-only flag — always connect with a read-only DB user on client engagements | Full |
| Spark (OSS) | **BUILD**: only Databricks-platform skills exist ([databricks/databricks-agent-skills](https://github.com/databricks/databricks-agent-skills) — reuse when the client is on Databricks); OSS tuning/skew/shuffle knowledge is an open lane | **SHIP scoped**: [Kubeflow Spark History Server MCP](https://github.com/kubeflow/mcp-apache-spark-history-server) (inherently read-only; job/perf analysis only, no query execution) | Full |
| Flink | **WRAP**: one community SKILL.md ([gordonmurray/data-engineering-skills](https://github.com/gordonmurray/data-engineering-skills)); Confluent's is Confluent-Cloud-only | **DOCUMENT**: nothing shippable (community servers are run-from-source, single-digit stars) | Full |
| Pulsar | **BUILD**: zero skills found | **SHIP**: [streamnative-mcp-server](https://github.com/streamnative/streamnative-mcp-server) (vendor-official; `--read-only` + `--features` allowlist; works with self-hosted Pulsar) | Full |
| SQL Server | **BUILD**: no real knowledge pack exists (marketplace listings are auto-generated pages) | **DOCUMENT/bootstrap**: Microsoft's official SQL MCP Server (Data API builder v1.7+, per-entity RBAC read-only) needs a per-client `dab-config.json` — not drop-in; the older Azure-Samples MssqlMcp was removed | Full |

## Consequences

1. **Open lanes = our differentiation**: StarRocks, Pulsar, SQL Server, OSS Spark ops, and
   Flink have no curated knowledge anywhere. Full packs there are worth real authoring
   effort.
2. **Never re-write what ClickHouse/Astronomer/Timescale already maintain.** Thin packs
   point at them; our delta stays small and personal (consulting gotchas, safety posture,
   contract integration).
3. **Read-only posture per engagement** (extends `method-safe-operations`): prefer servers
   with enforced read-only (ClickHouse default, Postgres restricted mode, `AF_READ_ONLY`,
   `snmcp --read-only`); where the server can't enforce it (StarRocks), the pack README
   mandates a read-only DB user.
4. **No npx assumption**: 6 of 8 SHIP picks run via Python/uvx, Pulsar is a Go
   binary/Docker, MSSQL is .NET — pack install docs state the runtime per stack.
5. External plugins install via `claude plugin marketplace add <org/repo>`; our packs
   document the exact commands per stack.
