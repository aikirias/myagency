# FIXTURE: intentionally flawed Airflow DAG for TC-13 (practice-idempotency-and-reruns)
# and TC-26 (de-airflow check-dag hook).
# Planted defects: blind INSERT append (duplicates on retry), catchup=True without
# idempotency, dynamic start_date, wall-clock date instead of the data interval,
# print() instead of logging, no retries/timeout on the task.

from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator


def load_sales():
    today = datetime.now().strftime("%Y-%m-%d")  # wall-clock, not data interval
    print(f"loading sales for {today}")
    # blind append: re-running this task duplicates rows
    run_sql(f"INSERT INTO db_stage.raw_sales SELECT * FROM src.sales WHERE d = '{today}'")


def run_sql(query):
    print(query)


with DAG(
    dag_id="sales_daily",
    start_date=datetime.now(),
    schedule="@daily",
    catchup=True,
) as dag:
    PythonOperator(task_id="load", python_callable=load_sales)
