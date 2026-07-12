---
name: mssql-diagnosis
description: SQL Server failure modes by symptom - blocking chains during extraction, transaction log growth (CDC trap), tempdb pressure, CDC pipeline failures, slow queries via Query Store, and numbers-dont-match extraction bugs. Use when diagnosing blocking, disk growth, failed CDC, or wrong extracted data on SQL Server.
---

# SQL Server diagnosis

By symptom, extending `method-diagnosis` steps 4-5. Evidence sources are DMVs and Query
Store — capture outputs as you go (before-evidence rule).

## Blocking during extraction

- Chain walk: `sys.dm_exec_requests.blocking_session_id` (0 = not blocked) joined to
  `sys.dm_exec_sessions` / `sys.dm_exec_sql_text`; task-level waits in
  `sys.dm_os_waiting_tasks`; lock inventory in `sys.dm_tran_locks`. Find the HEAD
  blocker (its own blocking_session_id is 0/NULL) — everything else is victims.
- Long-open transactions: `sys.dm_tran_database_transactions` +
  `sys.dm_tran_session_transactions` (`database_transaction_begin_time`).
- If the blocker is YOUR extract taking shared locks: switch to RCSI/snapshot
  (`mssql-extraction-idioms`), don't sprinkle NOLOCK.

## Transaction log grows without bound

First read `sys.databases.log_reuse_wait_desc` — it names the reason:

- `LOG_BACKUP`: full/bulk-logged recovery with no log backups running.
- `ACTIVE_TRANSACTION`: a long/open transaction (any recovery model).
- `REPLICATION`: undelivered replicated transactions — **and the CDC trap**: with CDC
  enabled, **even under SIMPLE recovery the log cannot truncate until the capture job
  reads the pending changes; a stopped Agent or capture job = unbounded log growth.**
  This is the MSSQL twin of the Postgres abandoned-replication-slot incident: a DE
  artifact taking down the client's source. Top audit check on any CDC-enabled source.
- Also: ADR's aggressive truncation is disabled with CDC (CDC+ADR unsupported on 2019;
  OK from 2022 CU18).

## tempdb pressure

Three consumers — identify which via `sys.dm_db_file_space_usage`
(`version_store_reserved_page_count` vs `internal_object_reserved_page_count` vs
`user_object_reserved_page_count`):

- **Version store**: RCSI/snapshot row versions — a long-running snapshot extract
  prevents version-store cleanup (your own extract can be the cause).
- **Internal objects**: sort/hash spills from big queries.
- Per-culprit: `sys.dm_db_session_space_usage` / `sys.dm_db_task_space_usage`.

## CDC pipeline stopped / lagging

1. `sys.dm_cdc_errors` FIRST — unresolved errors block the capture process (and grow
   the log, see above). Scan health: `sys.dm_cdc_log_scan_sessions`.
2. Capture/cleanup are **Agent jobs** — check them like any ETL job (msdb, below).
3. Consumer behind the retention window → min-LSN failures, unrecoverable gap.
4. Schema drift: ALTER COLUMN type/size on CDC tables throws conversion errors
   (241/245/8114/8169; 2628/8115 on size reduction) — consume pending changes, then
   disable/re-enable the capture instance.

## Slow queries — evidence via Query Store

- Query Store is the durable evidence source (plan cache is volatile): top queries by
  duration/CPU/reads, plan history, regressions, per-query wait categories (2017+).
  High `LCK_M_*` waits on a query → find the writer blocking it.
- Missing-index DMVs are hints, not designs: no column ordering, no
  clustered/filtered/columnstore suggestions, capped at 600 groups, RESET on
  restart/failover and on `ALTER INDEX` — never paste them into a deliverable verbatim.

## "Numbers don't match" extraction bugs — check in order

1. **NOLOCK artifacts** anywhere in the extract path (double/missed rows).
2. **datetime rounding**: .999 boundaries rounding into the next day; datetime2→datetime
   conversions rounding the same way.
3. **Collation**: case-insensitive collations merge "distinct" keys in joins/dedup;
   CDC can fail to persist non-ASCII data when column collation differs from the
   database's (use nvarchar or align collations).
4. **Implicit conversions** on join/filter columns — kill sargability AND can change
   matching semantics; check the plan for CONVERT_IMPLICIT.
5. **Watermark skips**: identity/datetime watermarks vs late-committing transactions
   (`mssql-extraction-idioms`).
