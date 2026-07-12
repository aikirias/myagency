---
name: mssql-extraction-idioms
description: SQL Server extraction idioms - Change Tracking vs CDC selection, why NOLOCK corrupts extracts and what to use instead (RCSI/snapshot), bulk export, rowversion/datetime watermark semantics, columnstore for analytics. Use when designing incremental extraction, CDC, bulk reads, or analytical workloads on SQL Server.
---

# SQL Server extraction idioms

Verified against learn.microsoft.com (2019/2022/2025; gates flagged). MSSQL in DE
engagements is usually the SOURCE — the goal is correct, safe extraction that doesn't
hurt the client's OLTP workload.

## Change Tracking vs CDC — the incremental-extraction decision

| | Change Tracking (CT) | Change Data Capture (CDC) |
| --- | --- | --- |
| Captures | THAT a row changed: PK + DML type | The changed VALUES (full history, before/after) |
| Mechanism | Synchronous, in-transaction | Async log reader (needs **SQL Server Agent**) |
| Deletes | Yes (PK only) | Yes, with values |
| Overhead | Low, storage-light | Change tables + capture/cleanup jobs |
| Editions | ALL (incl. Express) | **Enterprise + Standard only** (Standard since 2016 SP1; never Web/Express) |

- **CT** fits "which rows changed since version N" syncs where you re-read current values
  by PK. Wrap sync queries in snapshot isolation (docs' own recommendation) to avoid
  torn reads between the version query and the data query.
- **CDC** fits warehouse/lake ETL needing every intermediate change and delete values.
  Reading pattern: `cdc.fn_cdc_get_all_changes_<instance>` / `..._net_changes_...`
  between `sys.fn_cdc_get_min_lsn` and `sys.fn_cdc_get_max_lsn`; `__$operation`
  (1=del, 2=ins, 3=upd-before, 4=upd-after).
- **CDC retention race**: cleanup defaults to 3 days (4320 min, daily 2 AM job). If your
  consumer falls behind past the low LSN, the query functions FAIL and the window is
  unrecoverable — size retention above worst-case consumer downtime, always.
- CDC ignores columns added after enablement (fixed change-table shape; max 2 capture
  instances per table — use the second one to migrate schema).

## NOLOCK gives wrong numbers — never in extractions

Documented failure modes, not folklore: dirty reads of data later rolled back; rows read
**twice or not at all** under page splits (allocation-order scans); error 601 "data
movement". And it still blocks behind DDL (takes Sch-S). NOLOCK on an extract = a
`numbers-don't-match` engagement waiting to happen.

**Use instead**: RCSI (`READ_COMMITTED_SNAPSHOT ON`, statement-level snapshot — default
on Azure SQL, OFF on-prem) or **SNAPSHOT isolation** for multi-query consistent extracts
(transaction-level view). Both cost tempdb version store — see `mssql-diagnosis`.

## Safe big reads

- **Lock escalation**: ~5,000 locks in one statement escalates row→TABLE lock. Under
  RCSI/snapshot reads take no shared locks, which sidesteps it; otherwise batch reads.
- **Keyset pagination** on the clustered key (`WHERE key > @last ORDER BY key`) — the
  standard chunked-extract pattern (practitioner convention; docs only formalize
  OFFSET/FETCH, which degrades linearly).
- **Bulk export**: `bcp` is the only tool that exports (and generates format files);
  BULK INSERT / OPENROWSET(BULK) are import-side. Minimal logging needs simple or
  bulk-logged recovery + TABLOCK on heaps.

## Watermarks (practice-incremental-processing on MSSQL)

- **rowversion**: 8-byte DB-wide monotonic counter, bumps on EVERY insert/update in the
  database (even no-op updates) — excellent change watermark, NOT a timestamp and not
  a key. High-water mark: `@@DBTS`; race-free floor: `MIN_ACTIVE_ROWVERSION()` (excludes
  in-flight transactions — without it, long transactions make `> @last` watermarks skip
  rows).
- **datetime rounds to .000/.003/.007s** — `23:59:59.999` rounds to the NEXT DAY. Never
  build day boundaries with `.999` on datetime; use `>= start AND < next_start`, and
  prefer datetime2 (docs: "avoid datetime for new work").
- Identity-based watermarks (`WHERE id > @max`) skip rows from transactions that commit
  late/out of order — same class of problem, use rowversion or CT/CDC instead.

## Columnstore — analytics duties on MSSQL

- Nonclustered columnstore (NCCI) on an OLTP table = real-time operational analytics
  without a copy; clustered (CCI) = the fact-table storage format.
- Bulk loads ≥102,400 rows bypass the deltastore — batch your loads; trickle inserts pile
  up in delta rowgroups until the tuple mover compacts.
- **Standard edition gates that change advice**: 32 GB columnstore segment cache,
  batch-mode DOP capped at 2, no batch mode on rowstore, no aggregate pushdown — the
  same query can be several times slower than the Enterprise demo the client saw.
