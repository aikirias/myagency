# Data Quality Standards

## Every production dataset must have

| Check | Minimum requirement |
|---|---|
| Freshness | Alert if the latest successful data signal is older than SLA + buffer |
| Volume | Alert if record count deviates beyond calibrated threshold versus baseline |
| Duplicates | Alert if the uniqueness definition is violated |
| Nulls | Alert if null rate on required fields exceeds threshold |

These four checks are the minimum bar. Datasets missing any of them are not production-ready.

## Severity levels

| Level | Meaning | Action |
|---|---|---|
| `critical` | Data is wrong or missing in a way that affects business decisions | Page on-call, block downstream if possible |
| `warning` | Something is unusual but not confirmed broken | Alert in the team channel, investigate same day |
| `info` | Informational trend or expected variance | Log only, review periodically |

## Freshness checks

- Threshold = expected availability time + SLA buffer
- Use the most reliable freshness signal available: `loaded_at`, successful interval marker, watermark, or partition timestamp
- Hourly and sub-hourly workflows need tighter freshness windows than daily ones

```sql
SELECT
    MAX(loaded_at) AS last_load,
    CASE
        WHEN MAX(loaded_at) < CURRENT_TIMESTAMP - INTERVAL 26 HOUR THEN 'FAIL'
        ELSE 'PASS'
    END AS status
FROM schema.table_name;
```

## Volume checks

- Compare against the previous interval, rolling baseline, or an absolute floor
- `+/-20%` is only a temporary default; calibrate per dataset after observing variance
- A count of `0` is always `critical` for datasets that should never be empty

## Duplicate checks

- Check the declared business key or uniqueness definition after every load
- For datasets without a single-column key, validate the composite uniqueness definition explicitly

## Null checks

- List all required business-critical fields explicitly
- Null threshold for required fields is `0%` unless there is a documented exception
- Optional fields still need an acceptable null-rate expectation when they matter analytically

## Reconciliation

- Required for financial data, customer-facing metrics, regulatory reporting, and any dataset where silent drift is unacceptable
- Compare row count, key metric totals, and distinct entity counts where appropriate
- Threshold should be exact match or a justified tolerance based on source reliability

## Check metadata requirements

Every data quality check must have:

- `dataset_name`
- `check_name`
- `severity`
- `owner`
- `alert_channel`
- `threshold`

No check is complete without all six.

## Automated execution requirement

A SQL check file alone is not a production-ready DQ implementation. Every check suite must have two layers:

### Layer 1 — Check definitions (SQL file)
The SQL file in `local-stack/starrocks/migrations/` defines what is checked, the threshold, and the expected output. Each query must return a `status` column (`'PASS'` or `'FAIL'`) and a `detail` column with the observed value.

This layer is for: ad-hoc manual runs, debugging, and reference.

### Layer 2 — Automated executor (Airflow DAG or task)
Every check suite must be executed automatically on a schedule or as part of the pipeline that produces the data. Without automation, checks only run when someone remembers to run them.

**Two execution patterns — choose one per dataset:**

#### Pattern A: DQ tasks appended to the load DAG
Add DQ check tasks at the end of the pipeline DAG, after the final load and inline validation. Checks run as part of every scheduled load.

```
start → fetch_and_load → transform_to_model → validate_load → dq_freshness → dq_volume → dq_duplicates → dq_nulls → end
```

Use when: the checks are tightly coupled to the load and should block the run from completing if they fail.

#### Pattern B: Separate scheduled DQ DAG
Create a dedicated DAG (e.g. `dq_crypto_price_daily`) that runs all checks independently on its own schedule — typically after the load DAG is expected to have completed.

```
start → run_dq_checks → log_results → end
```

Use when: checks need to run independently of the load (e.g. to monitor a dataset produced by an external team), or when you want DQ results independent of pipeline success/failure.

### Automated executor requirements

Regardless of pattern, the automated executor must:

- Execute each check query and read the `status` column
- Log every check result (check name, status, detail, run timestamp) to `db_report.pipeline_run_log` or equivalent
- Fail the task (raise an exception) if any `critical` check returns `'FAIL'`
- Emit a warning log for `warning` severity failures without blocking
- Have retries, timeout, and failure alerting configured like any other production task

### Check result log table

Results should be written to `db_report.pipeline_run_log` with:

```sql
INSERT INTO db_report.pipeline_run_log (pipeline_name, run_id, status, event_time, details)
VALUES (
    '<check_name>',
    '<dag_run_id>',
    '<PASS|FAIL>',
    NOW(),
    '<detail string from check query>'
);
```

### Execution spec — required documentation per check suite

Every automated DQ implementation must document:

```text
dataset:          <db.table>
execution pattern: DAG task (Pattern A) | Separate DAG (Pattern B)
dag_id:           <dag_id>
schedule:         <cron or "after <parent_dag>">
on critical FAIL: task fails, pipeline blocked
on warning FAIL:  log only, pipeline continues
results logged to: db_report.pipeline_run_log
owner:            <team>
```
