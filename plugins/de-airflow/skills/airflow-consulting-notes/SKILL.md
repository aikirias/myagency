---
name: airflow-consulting-notes
description: Airflow consulting delta - interval semantics confusion, catchup and backfill discipline, parse-time traps, sensor deadlocks, idempotency under scheduler retries. Use when diagnosing, designing, reviewing, or fixing anything involving Airflow DAGs, scheduling, or orchestration.
---

# Airflow consulting notes

Consulting DELTA only — general DAG authoring and platform knowledge comes from
Astronomer's maintained skills (install per the pack README). This covers the failure
patterns that generate engagements, mapped to the de-core method.

## Interval semantics — the #1 source of "wrong data" tickets

Airflow schedules a run AFTER its data interval closes: the run "for Monday" executes on
Tuesday. Three business-date bugs come from this (`practice-incremental-processing`):

- Tasks using "today"/wall-clock instead of the interval boundaries (`data_interval_start`
  / `data_interval_end`; `execution_date` in legacy 2.x code) — loads shift by one period,
  or drift when a run executes late/retried.
- Off-by-one filters: mixing `ds` (interval start) with "the day the run happened".
- Re-runs of old intervals computing "now"-relative logic — deterministic-schedule rule
  broken; every rerun writes different data.

Diagnosis shortcut: if numbers are "shifted by one day" or change when a task is retried,
check interval vs wall-clock usage FIRST.

## Catchup and backfill discipline

- `catchup=True` on a DAG whose tasks are not interval-idempotent = a storm of duplicate
  loads the moment the DAG is unpaused or its `start_date` moved. Default to
  `catchup=False`; enable catch-up only after proving interval idempotency
  (`practice-idempotency-and-reruns`).
- Backfills run isolated from the production schedule (`practice-backfill-safety`):
  cap concurrency (`max_active_runs`), validate the first interval, and never let a
  backfill and the daily schedule fight over the same intervals.

## Parse-time traps

DAG files are re-parsed continuously by the scheduler. Anything at module top level runs
on every parse:

- DB/API calls, heavy imports, or credential fetches at top level → scheduler degradation
  that presents as "the UI is slow / DAGs appear late" (a platform-audit finding, not a
  DAG bug).
- Dynamic `start_date=datetime.now()` → runs never fire or fire unpredictably; always a
  fixed date. (The pack hook warns on this.)

## Idempotency under the scheduler

The scheduler WILL re-run tasks: retries, cleared states, catchup, backfills. Per
`practice-idempotency-and-reruns`, every task must be safe for its interval; additionally
Airflow-specific:

- XCom is for small metadata, not data payloads — data through XCom couples idempotency
  to scheduler DB state and blows up the metadata DB (audit finding).
- Task-level `retries` + `retry_delay` + `execution_timeout` on EVERY production task;
  a task without a timeout can silently occupy a worker slot forever.
- Keep business logic OUT of the orchestration layer: operators should call idempotent
  jobs (SQL, containers, jobs), not implement transformations inline — orchestration
  stays lightweight and replays stay safe.

## Sensors and cross-DAG waits

- Long-poking sensors in `poke` mode hold worker slots — the classic "workers are full
  but nothing is running" incident; use `reschedule` mode or deferrable operators for
  waits over ~1 minute.
- Cross-DAG dependencies must state HOW intervals match (same day? previous hour?) —
  undocumented interval mapping is where cross-DAG deadlocks and silent gaps live.

## Silent-failure surface (practice-observability-and-ownership)

Audit checks: DAGs with no `on_failure_callback`/alerting; SLAs unused; paused DAGs
nobody remembers pausing; `email_on_failure` pointing at a dead inbox; import errors in
the UI ignored for weeks (the DAG silently stopped updating).

## Secrets

Connections/Variables (or a secrets backend), never literals in DAG files
(`method-safe-operations` rule 12; the core python hook flags obvious cases).
