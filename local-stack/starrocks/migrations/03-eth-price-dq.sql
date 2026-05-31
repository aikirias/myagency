-- Migration: 03-eth-price-dq
-- Data quality verification checks for db_data_model.fact_eth_daily_price.
-- Source: CoinGecko public API (no upstream SLA).
-- Schedule: DAG runs daily at 06:00 UTC; expected load completion by ~07:00 UTC.
-- Run each SELECT independently to evaluate the check status.
-- Every check returns:
--   status  VARCHAR  'PASS' | 'FAIL'
--   detail  VARCHAR  current observed value vs threshold for triage context
--
-- Coverage summary:
--   freshness     : COVERED  (check 1)
--   volume        : COVERED  (check 2)
--   duplicates    : COVERED  (check 3)
--   nulls         : COVERED  (check 4 — price_usd, threshold 0%)
--   reconciliation: NOT COVERED — stage-to-curated reconciliation via
--                   db_stage.eth_price_daily is recommended as a follow-up
--                   (deferred: no upstream SLA; explicit waiver required if omitted)
-- -----------------------------------------------------------------------


-- -----------------------------------------------------------------------
-- CHECK 1: Freshness
-- -----------------------------------------------------------------------
-- check_name: freshness_loaded_at
-- dataset_name: db_data_model.fact_eth_daily_price
-- severity: critical
-- owner: data-engineering
-- alert_channel: #data-alerts
-- threshold: MAX(loaded_at) must be within the last 26 hours
--   Rationale: DAG runs at 06:00 UTC daily. 26 hours = one full daily cycle
--   plus a 2-hour buffer that absorbs normal CoinGecko API latency without
--   producing false positives on weekends or minor delays. A tighter window
--   (e.g., 6 hours) would fire on every weekend morning before the next run.
SELECT
    CASE
        WHEN MAX(loaded_at) >= NOW() - INTERVAL 26 HOUR THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'last_loaded_at=', CAST(MAX(loaded_at) AS VARCHAR),
        ' | threshold=now-26h (',
        CAST(NOW() - INTERVAL 26 HOUR AS VARCHAR),
        ')'
    ) AS detail
FROM db_data_model.fact_eth_daily_price;


-- -----------------------------------------------------------------------
-- CHECK 2: Volume
-- -----------------------------------------------------------------------
-- check_name: volume_latest_date_row_count
-- dataset_name: db_data_model.fact_eth_daily_price
-- severity: critical
-- owner: data-engineering
-- alert_channel: #data-alerts
-- threshold: COUNT(*) for MAX(price_date) must be >= 1
--   Rationale: grain is one row per price_date. A count of 0 for the most
--   recent date means the load produced no output — always critical for a
--   dataset that must never be empty after a successful run.
SELECT
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'row_count_for_latest_date=', CAST(COUNT(*) AS VARCHAR),
        ' | latest_date=', CAST(MAX(price_date) AS VARCHAR),
        ' | threshold=>=1'
    ) AS detail
FROM db_data_model.fact_eth_daily_price
WHERE price_date = (
    SELECT MAX(price_date)
    FROM db_data_model.fact_eth_daily_price
);


-- -----------------------------------------------------------------------
-- CHECK 3: Duplicates
-- -----------------------------------------------------------------------
-- check_name: duplicate_price_date_key
-- dataset_name: db_data_model.fact_eth_daily_price
-- severity: critical
-- owner: data-engineering
-- alert_channel: #data-alerts
-- threshold: zero rows where COUNT(price_date) per group > 1
--   Rationale: price_date is the declared business key (UNIQUE KEY in DDL).
--   The StarRocks engine UNIQUE KEY model enforces deduplication at write
--   time, but an explicit observable check is required — engine constraints
--   are not a substitute for a monitored quality signal. Any duplicate
--   indicates an upstream or load logic defect.
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'duplicate_dates_found=', CAST(COUNT(*) AS VARCHAR),
        ' | threshold=0_duplicate_dates'
    ) AS detail
FROM (
    SELECT price_date
    FROM db_data_model.fact_eth_daily_price
    GROUP BY price_date
    HAVING COUNT(price_date) > 1
) AS duplicates;


-- -----------------------------------------------------------------------
-- CHECK 4: Null check — price_usd (required field)
-- -----------------------------------------------------------------------
-- check_name: null_price_usd
-- dataset_name: db_data_model.fact_eth_daily_price
-- severity: critical
-- owner: data-engineering
-- alert_channel: #data-alerts
-- threshold: NULL count on price_usd must be 0 (0% null rate, no tolerance)
--   Rationale: price_usd is the primary analytical metric for this dataset.
--   A NULL value makes the row analytically useless and indicates a failed
--   extraction or transformation. No tolerance is permitted; even one NULL
--   must block downstream use until investigated.
SELECT
    CASE
        WHEN SUM(CASE WHEN price_usd IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    CONCAT(
        'null_price_usd_count=',
        CAST(SUM(CASE WHEN price_usd IS NULL THEN 1 ELSE 0 END) AS VARCHAR),
        ' | total_rows=', CAST(COUNT(*) AS VARCHAR),
        ' | threshold=0_nulls_allowed'
    ) AS detail
FROM db_data_model.fact_eth_daily_price;
