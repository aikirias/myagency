---
name: data-quality-review
description: Designs or reviews data quality checks for datasets and pipelines. Use when adding quality checks, validating coverage, investigating false positives, or when the user asks to review or generate data quality checks.
---

When using this skill:

1. Read the dataset, pipeline, SLA, uniqueness definition, and any existing checks.
2. Map coverage across the core categories:
   - freshness
   - volume or drift
   - duplicates
   - nulls on critical fields
   - source-to-target reconciliation
   - business-rule validation
3. Require a threshold, severity, owner, and alert path for each meaningful check.
4. Generate missing checks when needed.
5. Flag checks that are too loose, too strict, noisy, or operationally unclear.
6. **Design the automated execution layer** — SQL check definitions alone are not a complete DQ implementation. Specify the executor (Pattern A or Pattern B) and produce the Airflow DAG or task code.

Prefer checks that are:

- actionable
- calibrated to the SLA
- easy to operate
- specific to the dataset grain and business rules

For detailed standards, use:

- `.claude/rules/data-quality-standards.md`
- `.claude/rules/data-engineering-principles.md`

## Two-layer delivery model

Every DQ implementation has two mandatory layers. Delivering only Layer 1 is incomplete.

### Layer 1 — SQL check definitions
A `.sql` file in `local-stack/starrocks/migrations/` with:
- One query per check
- Metadata comments: `check_name`, `dataset_name`, `severity`, `owner`, `alert_channel`, `threshold`
- Each query returns `status VARCHAR ('PASS'|'FAIL')` and `detail VARCHAR`

### Layer 2 — Automated executor (Airflow)
An Airflow DAG or task set that:
- Executes each check query against StarRocks
- Reads the `status` column
- Logs every result to `db_report.pipeline_run_log`
- Raises an exception (fails the task) if any `critical` check returns `'FAIL'`
- Logs a warning for `warning` severity failures without blocking

**Choose the execution pattern:**

| Pattern | When to use | DAG structure |
|---|---|---|
| A — tasks appended to load DAG | Checks are tightly coupled to the load; failure should block completion | `... → validate_load → dq_freshness → dq_volume → dq_duplicates → dq_nulls → end` |
| B — separate DQ DAG | Checks run independently, or dataset is owned by an external team | `start → run_dq_checks → log_results → end` |

## Automated executor template (Pattern B — separate DAG)

```python
"""
dq_<dataset>  — Automated data quality checks for <dataset>.

Executes SQL checks from migrations/<xx>-<dataset>-dq.sql against StarRocks.
Logs results to db_report.pipeline_run_log.
Fails on any critical check returning FAIL.
"""

import logging
import pymysql
from datetime import datetime, timedelta
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator

log = logging.getLogger(__name__)

CHECKS = [
    {
        "check_name": "freshness_loaded_at",
        "severity": "critical",
        "sql": """
            SELECT
                CASE WHEN MAX(loaded_at) >= NOW() - INTERVAL 26 HOUR THEN 'PASS' ELSE 'FAIL' END AS status,
                CONCAT('last_loaded_at=', CAST(MAX(loaded_at) AS VARCHAR)) AS detail
            FROM db_data_model.<table_name>
        """,
    },
    # add remaining checks here
]


def _get_conn(database="db_data_model"):
    meta = BaseHook.get_connection("starrocks_local")
    return pymysql.connect(
        host=meta.host, port=int(meta.port or 9030),
        user=meta.login, password=meta.password or "",
        database=database, connect_timeout=10,
    )


def _run_dq_checks(**context):
    conn = _get_conn()
    failures = []
    run_id = context["run_id"]
    try:
        for check in CHECKS:
            with conn.cursor() as cur:
                cur.execute(check["sql"])
                row = cur.fetchone()
                status, detail = row[0], row[1]
                log.info("check=%s status=%s detail=%s", check["check_name"], status, detail)
                with conn.cursor() as log_cur:
                    log_cur.execute(
                        "INSERT INTO db_report.pipeline_run_log "
                        "(pipeline_name, run_id, status, event_time, details) "
                        "VALUES (%s, %s, %s, NOW(), %s)",
                        (check["check_name"], run_id, status, detail),
                    )
                conn.commit()
                if status == "FAIL" and check["severity"] == "critical":
                    failures.append(check["check_name"])
                elif status == "FAIL":
                    log.warning("DQ warning: check=%s detail=%s", check["check_name"], detail)
    finally:
        conn.close()
    if failures:
        raise ValueError(f"Critical DQ checks FAILED: {failures}")


default_args = {
    "owner": "data-engineering",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "execution_timeout": timedelta(minutes=15),
}

with DAG(
    dag_id="dq_<dataset>",
    start_date=datetime(2024, 1, 1),
    schedule="30 6 * * *",   # 30 min after load DAG at 06:00
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["dq", "<domain>", "starrocks"],
) as dag:
    start = EmptyOperator(task_id="start")
    run_checks = PythonOperator(task_id="run_dq_checks", python_callable=_run_dq_checks)
    end = EmptyOperator(task_id="end")
    start >> run_checks >> end
```

## Execution spec — required per check suite

Document this before closing the DQ review:

```text
dataset:           <db.schema.table>
execution pattern: Pattern A (load DAG tasks) | Pattern B (separate DAG)
dag_id:            <dag_id>
schedule:          <cron expression + timezone>
on critical FAIL:  task fails, pipeline/DAG blocked
on warning FAIL:   log only, continues
results logged to: db_report.pipeline_run_log
owner:             <team>
alert_channel:     <channel>
```

## Output format

```markdown
## Data Quality Review: [dataset_name]

### Coverage Summary
- Freshness: COVERED | MISSING
- Volume: COVERED | MISSING
- Duplicates: COVERED | MISSING
- Nulls: COVERED | MISSING
- Reconciliation: COVERED | MISSING | NOT REQUIRED

### Findings
[BLOCKER] ...
[WARNING] ...
[SUGGESTION] ...

### Layer 1 — SQL Check Definitions
File: local-stack/starrocks/migrations/<xx>-<dataset>-dq.sql
```sql
-- check here
```

### Layer 2 — Automated Executor
Pattern: A (load DAG tasks) | B (separate DAG)
File: local-stack/airflow/dags/dq_<dataset>.py

Execution spec:
- dag_id: ...
- schedule: ...
- on critical FAIL: task fails
- results logged to: db_report.pipeline_run_log

### Release Readiness
GO | NO-GO — [specific blockers if NO-GO]
```
