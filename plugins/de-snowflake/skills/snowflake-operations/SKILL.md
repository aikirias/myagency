---
name: snowflake-operations
description: Snowflake operations and cost - credit model per warehouse size, auto-suspend cache trade-off, serverless billing meters, Time Travel and Fail-safe storage economics, ACCOUNT_USAGE audit backbone with latencies, resource monitors, read-only RBAC pattern. Use when auditing cost, operating, or setting up governance on a Snowflake account.
---

# Snowflake operations (doc-verified)

## Compute cost model

- Credits/hour double per size: XS=1, S=2, M=4, L=8, XL=16 ... 6XL=512 (Gen1 standard).
  Per-second billing with a **60-second minimum on every resume** — a warehouse that
  resumes every 2 minutes for a 5-second query bills 12x its work.
- `CREATE WAREHOUSE` defaults: `AUTO_SUSPEND=600` (10 min), `AUTO_RESUME=TRUE`,
  size XSMALL. The suspend trade-off is documented: suspending drops the warehouse
  data cache → slower first queries after resume; docs suggest 5-10 minutes or less as
  the balance. Aggressive suspend on repeated-scan workloads can RAISE cost.
- **Serverless is a separate meter**: Snowpipe, serverless tasks, automatic clustering,
  materialized-view maintenance, search optimization, replication — each a distinct
  `SERVICE_TYPE` in `METERING_HISTORY`. A cost review that only looks at warehouses
  misses these; automatic clustering on a churny table is the classic invisible line
  item.
- Cloud services bill only above 10% of daily warehouse usage — metadata-heavy
  patterns (thousands of SHOW/DESCRIBE, tiny queries) can breach it.

## Storage economics

- Time Travel: `DATA_RETENTION_TIME_IN_DAYS` default **1**; Standard Edition caps at 1,
  Enterprise+ up to **90**. Fail-safe: fixed **7 days**, Snowflake-recoverable only.
- **High-churn tables amplify storage**: changed micro-partitions are retained per
  24-hour period through Time Travel + Fail-safe; drops/truncates retain FULL copies.
  The documented fix: **transient tables** (no Fail-safe, TT <= 1 day) for ETL/staging.
  Evidence: `TABLE_STORAGE_METRICS` (active vs TT vs Fail-safe vs clone-retained
  bytes) — the audit query for "why is storage 5x the data".

## Audit backbone (request access on day one)

| Surface | Latency | Retention |
| --- | --- | --- |
| ACCOUNT_USAGE.QUERY_HISTORY | 45 min | 365 days |
| ACCOUNT_USAGE.ACCESS_HISTORY (Enterprise+; column-level reads/writes + lineage) | 3 h | 365 days |
| ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY | 3 h | 365 days |
| ACCOUNT_USAGE.QUERY_ATTRIBUTION_HISTORY (`CREDITS_ATTRIBUTED_COMPUTE` per query) | up to 8 h | 365 days |
| INFORMATION_SCHEMA table functions (QUERY_HISTORY, TASK_HISTORY) | real-time | 7 days |
| INFORMATION_SCHEMA.COPY_HISTORY (COPY + Snowpipe) | real-time | 14 days |

- QUERY_ATTRIBUTION_HISTORY excludes idle time, storage, cloud services, serverless —
  attributed credits UNDERSTATE total cost; reconcile against WAREHOUSE_METERING.
- **Resource monitors**: credit quota + up to 5 NOTIFY / 1 SUSPEND / 1
  SUSPEND_IMMEDIATE actions; **do NOT control serverless credits** — a monitor-covered
  account can still bleed via auto-clustering/Snowpipe. ACCOUNTADMIN-only to create.

## RBAC minimums for engagements

- Read-only role pattern: USAGE on warehouse + database + schema, SELECT on objects —
  every layer required, a missing schema USAGE looks like "table doesn't exist".
- Ask for IMPORTED PRIVILEGES on the SNOWFLAKE database (ACCOUNT_USAGE access) for
  audit work; ACCESS_HISTORY needs Enterprise+.
- Role hygiene findings: custom roles not rooted under SYSADMIN (become
  ACCOUNTADMIN-only manageable), humans running as ACCOUNTADMIN, missing future grants
  (`GRANT ... ON FUTURE TABLES`) causing per-object grant drift. Schema-level future
  grants OVERRIDE database-level ones — a subtle source of "why does the new table have
  no grants".

## Upgrade/change discipline

Zero-copy clone + Time Travel are the rollback substrate: clone before destructive
change, `AT`/`BEFORE` reads to compare, `UNDROP` within retention
(`method-safe-operations` rules 8-9; `method-improvement-plan` checkpoints map to
clones).
