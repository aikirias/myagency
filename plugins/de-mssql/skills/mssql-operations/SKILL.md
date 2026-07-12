---
name: mssql-operations
description: SQL Server operations for DE consulting - Query Store setup for audits, the DMV cheat sheet, Agent jobs as the incumbent ETL scheduler, edition/licensing gates that change advice, official SQL MCP Server model. Use when auditing, monitoring, or planning work on a SQL Server estate.
---

# SQL Server operations

## Query Store — the audit evidence engine

- **On by default only from SQL Server 2022**; enable elsewhere:
  `ALTER DATABASE <db> SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE)`; add
  `WAIT_STATS_CAPTURE_MODE = ON` (2017+). All editions.
- For the audit cost/efficiency dimension: top-N by CPU/duration/logical reads over the
  audit window IS the platform cost map on MSSQL (`sys.query_store_runtime_stats` +
  `_plan` + `_query_text`), and regressed-plan history answers "it got slow last month"
  with evidence.
- Plan forcing (`sp_query_store_force_plan`) exists — a mitigation to recommend, with the
  client executing (method-safe-operations rule 7).

## DMV cheat sheet for audits

| Concern | DMV / source |
| --- | --- |
| Blocking now | `sys.dm_exec_requests`, `sys.dm_os_waiting_tasks`, `sys.dm_tran_locks` |
| Cumulative waits | `sys.dm_os_wait_stats` (since restart — note the caveat) |
| Index usage / dead indexes | `sys.dm_db_index_usage_stats` |
| Missing indexes (hints only) | `sys.dm_db_missing_index_*` (600-group cap, resets, no ordering) |
| Log health | `sys.databases.log_reuse_wait_desc` |
| tempdb | `sys.dm_db_file_space_usage`, `sys.dm_tran_version_store_space_usage` |
| CDC health | `sys.dm_cdc_errors`, `sys.dm_cdc_log_scan_sessions` |

## Agent jobs — the incumbent scheduler

Client ETL usually lives in SQL Server Agent. Read it from msdb: `dbo.sysjobs`,
`sysjobsteps`, `sysjobhistory`. Gotchas that corrupt naive job-history queries:

- `run_status`: 0=Failed, 1=Succeeded, 2=Retry, 3=Canceled, 4=In Progress
- `run_date`/`run_time` are **ints** (yyyyMMdd / HHmmss); `run_duration` is int
  **HHMMSS**, not seconds — convert before doing math
- History rows appear only AFTER a step completes — a hung step has NO row (the classic
  "the job didn't fail" while it's been stuck for hours). Freshness checks on the data,
  not on job history, catch this (`practice-data-quality-minimums`).
- CDC capture/cleanup are Agent jobs too — alert on them like production pipelines.

## Edition and version gates that change consulting advice

- **Standard**: 128 GB buffer pool cap, 32 GB columnstore cache, batch-mode DOP 2, no
  batch mode on rowstore, no automatic tuning / memory-grant feedback. A plan built on
  Enterprise numbers will disappoint on Standard — ask the edition FIRST
  (`SELECT SERVERPROPERTY('Edition')`).
- **CDC**: Enterprise + Standard (2016 SP1+) only; needs Agent → no Express.
- **2022+**: Query Store default-on, PSP optimization (all editions), ordered CCI.
- Web edition discontinued in SQL Server 2025.

## Official SQL MCP Server (agent access model)

Ships in Data API builder v1.7+ (2.0 current). Model: NO arbitrary SQL by design —
entities declared in `dab-config.json` with per-role RBAC; seven deterministic tools
(`describe_entities`, `read_records`, `aggregate_records`, CRUD, `execute_entity`).
Consulting posture: register only the tables the engagement needs, reader role with
`read` action only, connection string via `@env()`, run `dab start --mcp-stdio`. The
per-client bootstrap is scriptable (`dab init` + `dab add` loop) — do it at engagement
setup, not ad hoc.
