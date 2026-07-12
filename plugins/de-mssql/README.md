# de-mssql

Full stack pack for SQL Server engagements, angled at MSSQL as a **source system** for
data platforms (extraction, CDC) plus its analytics duties. No curated MSSQL knowledge
pack exists in the ecosystem ([survey](../../docs/stack-packs.md)) — these skills are
first-party, verified against learn.microsoft.com (SQL Server 2019/2022/2025;
version/edition gates flagged inline).

## What this pack provides

- **Skills**: `mssql-extraction-idioms` (CT vs CDC, NOLOCK vs RCSI/snapshot, bulk export,
  watermarks, columnstore), `mssql-diagnosis` (blocking, log growth, tempdb, CDC pipeline
  failures, numbers-don't-match bugs), `mssql-operations` (Query Store, DMV cheat sheet,
  Agent jobs, edition gates).
- **MCP (documented, not shipped)**: Microsoft's official **SQL MCP Server** ships inside
  Data API builder v1.7+ — deliberately NO arbitrary SQL: every table the agent may see
  must be registered as an entity in a per-client `dab-config.json` with per-role RBAC
  (`dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')"`,
  then `dab add <entity> --permissions "reader:read"`; run `dab start --mcp-stdio`).
  For consulting that is a feature (deterministic read-only surface) but it requires a
  bootstrap step per client, so no drop-in `.mcp.json` is shipped here — script the
  `dab` bootstrap during engagement setup instead.

## Per-project setup

1. `/plugin install de-mssql@myagency --scope project`
2. Ask the client for a read-only login; for agent access, bootstrap DAB as above with a
   read-only role, or work through their approved SQL client.
