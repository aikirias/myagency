# Stack packs — reuse-first strategy

Survey dates: wave 1 2026-07-11 (8 stacks), wave 2 2026-07-12 (11 stacks/areas). Per
decision #8 in [DESIGN.md](DESIGN.md): before authoring stack content, we survey existing
plugins, skills, and MCP servers. Result: two pack tiers.

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

## Survey matrix — wave 2 (surveyed and built 2026-07-12)

Verdicts from the wave-2 survey (all claims doc-verified by research agents with URLs;
full reports archived in the session transcript). All 11 packs are built; full-pack
content additionally verified against official docs (Kafka 4.x generated configs,
Debezium 3.6 stable, docs.snowflake.com, Iceberg 1.11 / Delta OSS / Trino 482).

| Stack | Existing knowledge | MCP server | Pack tier |
| --- | --- | --- | --- |
| dbt | **REUSE**: [dbt-labs/dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills) — first-party marketplace `dbt-agent-marketplace`, plugin `dbt` (9 skills: modeling, unit tests, semantic layer, mesh, troubleshooting) | **SHIP**: [dbt-mcp](https://github.com/dbt-labs/dbt-mcp) (official; `uvx dbt-mcp`; granular toolset gating — read-only posture = enable Discovery + Semantic Layer only; SQL/codegen disabled by default) | Thin |
| MySQL | **REUSE**: [planetscale/database-skills](https://github.com/planetscale/database-skills) `mysql` skill (MIT, in Anthropic official directory; covers schema/indexing/isolation/online-DDL) — but ZERO CDC/binlog-as-source content anywhere | **SHIP**: [benborla/mcp-server-mysql](https://github.com/benborla/mcp-server-mysql) (**read-only by default**, writes need explicit `ALLOW_*_OPERATION` env). AWS clients: `uvx awslabs.mysql-mcp-server` (also RO by default) | Thin (+1 authored skill: MySQL-as-CDC-source) |
| MongoDB | **REUSE**: [mongodb/agent-skills](https://github.com/mongodb/agent-skills) — marketplace `mongodb-plugins`, plugin `mongodb` (official, bundles MCP + 7 skills) | **SHIP**: [mongodb-mcp-server](https://github.com/mongodb-js/mongodb-mcp-server) (`npx`; **`--readOnly`** / `MDB_MCP_READ_ONLY=true`) | Thin (delta: change-stream CDC, extraction consistency, sharded-cluster pitfalls) |
| Elasticsearch / OpenSearch | **REUSE**: [elastic/agent-skills](https://github.com/elastic/agent-skills) — marketplace `elastic-agent-skills`, plugin `elastic-elasticsearch`. OpenSearch: skills-standard repo only (no first-party marketplace) | **ROUTE**: Elastic ≥9.2 = Agent Builder MCP endpoint in Kibana (scoped ApiKey); older clusters = deprecated-but-read-only `@elastic/mcp-server-elasticsearch`; OpenSearch = `opensearch-mcp-server-py` (RO by default, writes gated) | Thin (delta: MCP routing matrix, ES/OS divergence, source/sink gotchas) |
| Redis | **REUSE**: [redis/agent-skills](https://github.com/redis/agent-skills) — marketplace `redis`, plugin `redis-development` (official, Anthropic-listed, 8 skills) | **SHIP with caveat**: [redis/mcp-redis](https://github.com/redis/mcp-redis) (official) has **no read-only flag** — pack mandates the ACL recipe (`+@read -@write` user) | Thin (delta: ACL recipe, cache-vs-store-of-record, dedup-store idioms) |
| RabbitMQ | **BUILD (small)**: zero vendor AI assets | **SHIP**: [amazon-mq/mcp-server-rabbitmq](https://github.com/amazon-mq/mcp-server-rabbitmq) (`uvx amq-mcp-server-rabbitmq`; **read-only by default**, mutations need `--allow-mutative-tools`) | Thin (delta: one skill — 4.x quorum migration, memory alarms, DLX, streams-vs-queues) |
| BigQuery | **REUSE**: `bigquery-data-analytics` @ `claude-plugins-official` (Google-official, dual-listed in `data-agent-kit`) | **SHIP with caveat**: [MCP Toolbox](https://github.com/googleapis/mcp-toolbox) (`--prebuilt bigquery` has NO read-only env) — ship custom `tools.yaml` with `writeMode: blocked` + `BIGQUERY_MAXIMUM_BYTES_BILLED` cost guardrail | Thin (delta: the tools.yaml + cost-audit method) |
| Kafka (+ Connect/Debezium) | **BUILD**: Confluent's plugin is Cloud-provisioning-only (and `commands/`-based); Aiven's is niche; nothing carries operational judgment; Debezium has zero assets | **SHIP scoped**: [mcp-confluent](https://github.com/confluentinc/mcp-confluent) (official, works self-hosted; no RO flag → ship curated `--allow-tools-file`). Watch: KIP-1318 (upstream Apache Kafka MCP, under discussion) | Full |
| Snowflake | **BUILD**: `snowflake-cortex-code` is a router to the proprietary Cortex CLI (heavy prereqs), not reusable content | **ROUTE**: [Snowflake-Labs/mcp is DEPRECATED](https://github.com/Snowflake-Labs/mcp); successor = in-account managed MCP (`CREATE MCP SERVER`, `read_only: true`) which consultants may not be able to create; fallback = deprecated server with Select-only `sql_statement_permissions`, or MCP Toolbox `--prebuilt snowflake` + read-only ROLE | Full |
| Lakehouse (Iceberg + Delta + Trino) | **BUILD**: nothing official from apache/iceberg, delta-io, trinodb; Databricks plugin covers only Databricks-flavored Delta/UniForm (declare as dep for those clients) | **SHIP scoped**: [tuannvm/mcp-trino](https://github.com/tuannvm/mcp-trino) (**read-only by default**, writes need `TRINO_ALLOW_WRITE_QUERIES=true`); Starburst clients = built-in coordinator MCP (hard read-only); AWS = awslabs S3 Tables MCP (RO default). Engine-MCP-first; catalog MCPs are situational | Full — ONE combined `de-lakehouse` pack (the consulting delta IS the format×engine interaction) |
| Databricks | **REUSE**: [databricks/databricks-agent-skills](https://github.com/databricks/databricks-agent-skills) — marketplace `databricks-agent-skills`, plugin `databricks` (28 skills, hooks, `/databricks:doctor`) | **ROUTE**: managed MCP servers in-workspace (OAuth needs account admin → PAT Bearer fallback; `databricks-mcp` PyPI local proxy as escape hatch); RO via UC SELECT-only grants, not a flag. `databrickslabs/mcp` deprecated | Thin (delta: DBU cost model, UC migration judgment, DBR↔OSS lock-in review; engine content stays in `de-spark`) |

Wave-2 whitelist additions needed in `marketplace.json` `allowCrossMarketplaceDependenciesOn`
when each pack is built: `planetscale`, `mongodb-plugins`, `elastic-agent-skills`, `redis`,
`dbt-agent-marketplace`, `databricks-agent-skills`, `claude-plugins-official` (BigQuery).

## Consequences

1. **Open lanes = our differentiation**: StarRocks, Pulsar, SQL Server, OSS Spark ops, and
   Flink have no curated knowledge anywhere. Full packs there are worth real authoring
   effort. Wave 2 adds three more open lanes: **Kafka operational judgment, Snowflake
   consulting substance, and the lakehouse layer** (Iceberg/Delta/Trino interaction).
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
