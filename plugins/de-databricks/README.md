# de-databricks

Thin stack pack for Databricks engagements. Platform mechanics (UC, jobs, DABs, DBSQL,
pipelines) come from Databricks' official 28-skill plugin
([survey](../../docs/stack-packs.md)) — this pack ships the managed-MCP access recipe and
the consulting delta the vendor will never write: cost judgment and lock-in review.

**Layering**: Spark ENGINE content (joins, skew, AQE, streaming semantics, OSS Delta
mechanics) lives in `de-spark` — install both on Databricks engagements. This pack covers
only platform behavior.

## What this pack provides

- **Managed MCP recipe** (no `.mcp.json` — endpoints are per-workspace, Streamable HTTP):
  - Endpoints: `https://<ws>/api/2.0/mcp/sql` (SQL), `/api/2.0/mcp/functions/{cat}/{schema}`
    (UC functions), `/api/2.0/mcp/genie/{space_id}` (Genie, read-only by design).
  - **OAuth requires an ACCOUNT admin** to register the app — consultants usually can't.
    Practical fallbacks, in order: PAT `Authorization: Bearer` header (works for managed
    MCP only), or the official `databricks-mcp` PyPI local proxy
    (`uvx databricks-mcp serve`) riding Databricks CLI credentials.
  - Read-only posture = UC grants (SELECT-only principal), NOT a server flag. Ask for a
    SELECT-only service principal + `USE CATALOG/SCHEMA` and nothing else.
  - Do not use `databrickslabs/mcp` — deprecated upstream.
- **Skill** `databricks-consulting-notes`: cost model, UC migration, portability review.

## Per-project setup

1. Add the vendor marketplace once:

   ```bash
   claude plugin marketplace add databricks/databricks-agent-skills
   ```

2. `/plugin install de-databricks@myagency --scope project` — auto-installs
   `databricks@databricks-agent-skills` (includes `/databricks:setup` and
   `/databricks:doctor` for connection debugging).
3. Also `/plugin install de-spark@myagency` for engine-level work.
4. Request early: SELECT on `system.billing.usage` + `system.access.audit` (system
   tables are the evidence base for cost/audit work and need an admin grant).
