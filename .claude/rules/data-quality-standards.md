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
