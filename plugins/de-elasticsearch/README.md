# de-elasticsearch

Thin stack pack for Elasticsearch / OpenSearch engagements (search stores as pipeline
sinks, occasionally sources). ES|QL/ingestion/security knowledge comes from Elastic's
official plugin ([survey](../../docs/stack-packs.md)) — this pack ships the MCP routing
decision (there is no single server) and the pipeline-consulting delta.

## What this pack provides

- **MCP routing** (no single `.mcp.json` — pick per cluster, see the skill):

  | Cluster | Server | Read-only mechanism |
  | --- | --- | --- |
  | Elastic >= 9.2 / Serverless | Agent Builder endpoint in Kibana (`{KIBANA_URL}/api/agent_builder/mcp` via `npx mcp-remote` + `Authorization: ApiKey ...` header) | Scope the API key (`feature_agentBuilder.read`) |
  | Elastic < 9.2 (very common) | `@elastic/mcp-server-elasticsearch` (npm) — **deprecated upstream but read-only by construction** (search/mappings/ES|QL tools only) | No write tools exist |
  | OpenSearch | `uvx opensearch-mcp-server-py` | **Read-only by default**; writes gated behind `OPENSEARCH_SETTINGS_ALLOW_WRITE=true` (never set) |

- **Skill** `elasticsearch-consulting-notes`: refresh/mapping/pagination/ILM traps and
  the ES-vs-OpenSearch divergence map.

## Per-project setup

1. Add the vendor marketplace once (Elastic clients):

   ```bash
   claude plugin marketplace add elastic/agent-skills
   ```

2. `/plugin install de-elasticsearch@myagency --scope project` — auto-installs
   `elastic-elasticsearch@elastic-agent-skills`.
3. OpenSearch clients: the vendor skills live in a skills-standard repo (no first-party
   marketplace): `npx skills add opensearch-project/opensearch-agent-skills -a claude-code`.
4. Configure the MCP row that matches the cluster; credentials in the environment, never
   in files. Ask for a read-scoped API key / read-only user.
