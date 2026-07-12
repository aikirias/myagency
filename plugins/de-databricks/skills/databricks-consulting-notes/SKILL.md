---
name: databricks-consulting-notes
description: Databricks platform consulting delta - DBU cost model across compute types, Photon silent fallback, Unity Catalog migration judgment, DBR defaults that lock out external readers, jobs vs declarative pipelines, system tables for cost audits. Use when auditing cost, reviewing architecture, or assessing lock-in on a Databricks platform engagement.
---

# Databricks consulting notes — the platform delta

Consulting DELTA only — UC/jobs/DABs/DBSQL mechanics come from the official `databricks`
plugin; Spark ENGINE content lives in `de-spark`. This skill is the judgment layer the
vendor won't ship: what things cost, what locks you in, and what to check.

## Cost model — the four-way compute decision

- Cost per DBU differs by compute type: **all-purpose clusters (most expensive) >
  SQL warehouses > job clusters > (serverless: different meter entirely)**. The most
  common cost finding: ETL and BI running on all-purpose clusters. Move scheduled work
  to job clusters, BI to SQL warehouses, then evaluate serverless per workload.
- **Photon bills a DBU premium but coverage is partial**: no UDFs, no RDD API, stateless
  streaming only — and fallback to JVM Spark is **silent per-operator** (check the Spark
  UI operator coloring). Paying Photon prices for non-Photon execution is a standard
  audit finding.
- Multi-task jobs should **share one job cluster across tasks** — per-task clusters
  multiply spin-up time and DBUs.
- Spot-heavy job clusters get mid-job evictions → recompute/shuffle-fetch failures that
  look like flakiness. Driver on-demand, executors spot, is the sane default.
- Evidence base: `system.billing.usage` joined to job/warehouse IDs — request SELECT on
  the `system` catalog on day one (`practice-cost-optimization`).

## Lock-in / portability review (the vendor won't frame this)

- **DBR writer defaults upgrade table protocols one-way**: new tables get deletion
  vectors (and increasingly liquid clustering / predictive optimization) by default —
  external OSS readers without DV support lose read access to "their own" lake. For
  tables that must stay engine-neutral, disable DVs explicitly or plan
  `REORG TABLE ... APPLY (PURGE)` before external consumers connect.
- UniForm gives Iceberg readers read-only access with feature caveats — it is a bridge,
  not neutrality. If the client's strategy says "open lakehouse", verify the table
  features actually allow it (`practice-architecture-selection`; escalate contradictions
  per the `research` plugin conflict gate).
- Predictive optimization auto-runs OPTIMIZE/VACUUM on UC **managed** tables only —
  external tables silently rot with small files; a classic audit split.

## Unity Catalog — migration is judgment, not mechanics

- hive_metastore → UC is an engagement-sized workstream: three-level namespace rewrite,
  GRANT model change, mounts → external locations/volumes. Mixed-mode workspaces (both
  catalogs live) produce permission surprises — inventory which workloads still read
  `hive_metastore` before declaring victory.
- Secrets: hardcoded creds in notebooks are the #1 quick-win finding; secret scopes (or
  UC service credentials) are the fix (`practice-pii-handling` adjacent).

## Pipelines: declarative vs jobs

- Lakeflow Spark Declarative Pipelines (ex-DLT; core donated to Apache Spark 4.1 as
  `pyspark.pipelines`) for dependency-managed multi-stage datasets with expectations;
  Lakeflow Jobs for procedural orchestration and external integrations. The naming churn
  confuses clients — the decision inputs don't: declarative when the product is tables,
  procedural when it is a process.

## Audit evidence quick list

`system.billing.usage` (cost), `system.access.audit` (who touched what), query history
system tables (SQL spend), cluster event logs (eviction/restart churn), UC lineage.
All need admin-granted SELECT on `system` — ask early, it gates the whole audit
(`deliverable-platform-audit`).
