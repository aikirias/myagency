# de-spark

Full stack pack for OSS Apache Spark engagements (3.5.x / 4.x — version gates flagged in
the skills). The ecosystem only has Databricks-platform skills
([survey](../../docs/stack-packs.md)); OSS Spark tuning/ops knowledge is first-party here.

## What this pack provides

- **Skills**: `spark-idioms` (idempotent writes, object-storage committers, AQE, joins,
  streaming sink guarantees), `spark-diagnosis` (OOM taxonomy, shuffle/skew, UI reading
  order, wrong-results causes), `spark-operations` (memory model, dynamic allocation,
  monitoring, config pitfalls, 3.5→4.x migration headline).
- **MCP** (`.mcp.json`): the [Kubeflow Spark History Server MCP](https://github.com/kubeflow/mcp-apache-spark-history-server)
  — **inherently read-only** (monitoring API only, no job submission): job bottlenecks,
  stage task distributions, executor summaries, run/config comparisons. Set
  `SPARK_HISTORY_SERVER_URL` in the project env.

## When the client is on Databricks

Do NOT duplicate platform knowledge: add their vendor marketplace and use
[databricks/databricks-agent-skills](https://github.com/databricks/databricks-agent-skills)
for Lakeflow/Unity Catalog/DABs specifics. This pack still applies for engine-level work
(joins, skew, memory, streaming semantics).

## Per-project setup

1. `/plugin install de-spark@myagency --scope project`
2. `SPARK_HISTORY_SERVER_URL` pointing at the client's History Server (read-only by
   nature). Requires `uv` on the machine running Claude Code.
