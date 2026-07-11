"""
eth_price_daily — Daily ETH/USD price ingestion from CoinGecko.

Flow:
  fetch_and_load_eth_price  →  transform_to_model  →  validate_load

Ingests the daily price snapshot from the CoinGecko simple-price endpoint,
writes to db_stage.eth_price_daily, transforms into
db_data_model.fact_eth_daily_price, and validates a row exists.
"""

import json
import logging
import urllib.request
from datetime import date, datetime, timedelta

import pymysql
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

log = logging.getLogger(__name__)

COINGECKO_URL = (
    "https://api.coingecko.com/api/v3/simple/price"
    "?ids=ethereum"
    "&vs_currencies=usd"
    "&include_market_cap=true"
    "&include_24hr_vol=true"
    "&include_24hr_change=true"
)
STAGE_TABLE = "db_stage.eth_price_daily"
MODEL_TABLE = "db_data_model.fact_eth_daily_price"
SOURCE_SYSTEM = "coingecko"


def _get_price_date(context):
    logical_date = context.get("logical_date") or context.get("data_interval_start")
    if logical_date:
        return logical_date.strftime("%Y-%m-%d")
    # Manual trigger without logical_date: use yesterday
    return (date.today() - timedelta(days=1)).isoformat()


def _get_starrocks_conn(database="db_stage"):
    conn_meta = BaseHook.get_connection("starrocks_local")
    return pymysql.connect(
        host=conn_meta.host,
        port=int(conn_meta.port or 9030),
        user=conn_meta.login,
        password=conn_meta.password or "",
        database=database,
        connect_timeout=10,
    )


def _on_failure_callback(context):
    log.error(
        "Task failed | dag=%s | task=%s | logical_date=%s | exception=%s",
        context["dag"].dag_id,
        context["task_instance"].task_id,
        context.get("logical_date"),
        context.get("exception"),
    )


def _fetch_and_load_eth_price(**context):
    price_date = _get_price_date(context)
    log.info("Fetching ETH price from CoinGecko for price_date=%s", price_date)
    context["ti"].xcom_push(key="price_date", value=price_date)

    with urllib.request.urlopen(COINGECKO_URL, timeout=30) as response:
        raw = response.read()

    payload = json.loads(raw)

    if "ethereum" not in payload or "usd" not in payload["ethereum"]:
        raise ValueError(
            f"CoinGecko response missing required key 'ethereum.usd'. Raw: {raw!r}"
        )

    eth = payload["ethereum"]
    price_usd = float(eth["usd"])
    market_cap_usd = eth.get("usd_market_cap")
    volume_24h_usd = eth.get("usd_24h_vol")
    price_change_24h = eth.get("usd_24h_change")

    log.info(
        "CoinGecko data: price_usd=%.2f market_cap_usd=%s volume_24h_usd=%s",
        price_usd,
        market_cap_usd,
        volume_24h_usd,
    )

    conn = _get_starrocks_conn("db_stage")
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO db_stage.eth_price_daily (
                    price_date,
                    price_usd,
                    market_cap_usd,
                    volume_24h_usd,
                    price_change_24h_usd,
                    price_change_percentage_24h,
                    source_system,
                    api_request_date,
                    ingested_date,
                    loaded_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, CURDATE(), CURDATE(), NOW())
                """,
                (
                    price_date,
                    price_usd,
                    market_cap_usd,
                    volume_24h_usd,
                    None,
                    price_change_24h,
                    SOURCE_SYSTEM,
                ),
            )
            conn.commit()
            log.info(
                "Inserted %d row(s) into %s for price_date=%s",
                cursor.rowcount,
                STAGE_TABLE,
                price_date,
            )
    finally:
        conn.close()


def _transform_to_model(**context):
    price_date = context["ti"].xcom_pull(
        task_ids="fetch_and_load_eth_price", key="price_date"
    )
    log.info("Transforming staging data to model for price_date=%s", price_date)

    conn = _get_starrocks_conn("db_stage")
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO db_data_model.fact_eth_daily_price (
                    price_date,
                    price_usd,
                    market_cap_usd,
                    volume_24h_usd,
                    price_change_pct_24h,
                    price_source,
                    loaded_at
                )
                SELECT
                    price_date,
                    CAST(price_usd AS DECIMAL(18, 2)),
                    CAST(market_cap_usd AS DECIMAL(24, 2)),
                    CAST(volume_24h_usd AS DECIMAL(24, 2)),
                    CAST(price_change_percentage_24h AS DECIMAL(10, 4)),
                    source_system,
                    NOW()
                FROM db_stage.eth_price_daily
                WHERE price_date = %s
                """,
                (price_date,),
            )
            conn.commit()
            log.info(
                "Inserted %d row(s) into %s for price_date=%s",
                cursor.rowcount,
                MODEL_TABLE,
                price_date,
            )
    finally:
        conn.close()


def _validate_load(**context):
    price_date = context["ti"].xcom_pull(
        task_ids="fetch_and_load_eth_price", key="price_date"
    )

    conn = _get_starrocks_conn("db_data_model")
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT COUNT(*) FROM db_data_model.fact_eth_daily_price WHERE price_date = %s",
                (price_date,),
            )
            (count,) = cursor.fetchone()
    finally:
        conn.close()

    log.info("validate_load: row_count=%d for price_date=%s", count, price_date)
    if count == 0:
        raise ValueError(
            f"No rows found in fact_eth_daily_price for price_date={price_date}. "
            "Transform step may have silently failed."
        )


default_args = {
    "owner": "data-engineering",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "execution_timeout": timedelta(minutes=30),
    "on_failure_callback": _on_failure_callback,
}

with DAG(
    dag_id="eth_price_daily",
    start_date=datetime(2024, 1, 1),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    dagrun_timeout=timedelta(hours=1),
    default_args=default_args,
    tags=["ingestion", "crypto", "starrocks"],
) as dag:

    start = EmptyOperator(task_id="start")

    fetch_and_load_eth_price = PythonOperator(
        task_id="fetch_and_load_eth_price",
        python_callable=_fetch_and_load_eth_price,
    )

    transform_to_model = PythonOperator(
        task_id="transform_to_model",
        python_callable=_transform_to_model,
    )

    validate_load = PythonOperator(
        task_id="validate_load",
        python_callable=_validate_load,
    )

    end = EmptyOperator(task_id="end")

    start >> fetch_and_load_eth_price >> transform_to_model >> validate_load >> end
