CREATE DATABASE IF NOT EXISTS db_stage;
CREATE DATABASE IF NOT EXISTS db_data_model;
CREATE DATABASE IF NOT EXISTS db_business_model;
CREATE DATABASE IF NOT EXISTS db_report;

CREATE TABLE IF NOT EXISTS db_stage.orders_raw (
    order_id STRING,
    customer_id STRING,
    order_date STRING,
    amount STRING,
    _source_system STRING,
    _ingested_at STRING
)
ENGINE=OLAP
DUPLICATE KEY(order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

INSERT INTO db_stage.orders_raw VALUES
    ("1001", "1", "2026-05-01", "1200.00", "erp_demo", "2026-05-14 00:00:00"),
    ("1002", "1", "2026-05-02", "950.50", "erp_demo", "2026-05-14 00:00:00"),
    ("1003", "2", "2026-05-04", "450.00", "erp_demo", "2026-05-14 00:00:00"),
    ("1004", "3", "2026-05-05", "300.00", "erp_demo", "2026-05-14 00:00:00");

CREATE TABLE IF NOT EXISTS db_data_model.orders_curated (
    order_id BIGINT,
    customer_id BIGINT,
    order_date DATE,
    amount DECIMAL(10, 2),
    source_system VARCHAR(64),
    ingested_at DATETIME
)
ENGINE=OLAP
DUPLICATE KEY(order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

INSERT INTO db_data_model.orders_curated VALUES
    (1001, 1, "2026-05-01", 1200.00, "erp_demo", "2026-05-14 00:00:00"),
    (1002, 1, "2026-05-02", 950.50, "erp_demo", "2026-05-14 00:00:00"),
    (1003, 2, "2026-05-04", 450.00, "erp_demo", "2026-05-14 00:00:00"),
    (1004, 3, "2026-05-05", 300.00, "erp_demo", "2026-05-14 00:00:00");

CREATE TABLE IF NOT EXISTS db_business_model.daily_sales (
    order_date DATE,
    order_count BIGINT,
    total_amount DECIMAL(18, 2)
)
ENGINE=OLAP
DUPLICATE KEY(order_date)
DISTRIBUTED BY HASH(order_date) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

INSERT INTO db_business_model.daily_sales VALUES
    ("2026-05-01", 1, 1200.00),
    ("2026-05-02", 1, 950.50),
    ("2026-05-04", 1, 450.00),
    ("2026-05-05", 1, 300.00);

CREATE TABLE IF NOT EXISTS db_stage.btc_price_daily (
    price_date DATE,
    price_usd DOUBLE,
    market_cap_usd DOUBLE,
    volume_24h_usd DOUBLE,
    price_change_24h_usd DOUBLE,
    price_change_percentage_24h DOUBLE,
    source_system VARCHAR(64),
    api_request_date DATE,
    ingested_date DATE,
    loaded_at DATETIME
)
ENGINE=OLAP
UNIQUE KEY(price_date)
DISTRIBUTED BY HASH(price_date) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

CREATE TABLE IF NOT EXISTS db_report.pipeline_run_log (
    pipeline_name VARCHAR(128),
    run_id VARCHAR(128),
    status VARCHAR(32),
    event_time DATETIME,
    details STRING
)
ENGINE=OLAP
DUPLICATE KEY(pipeline_name, run_id, status)
DISTRIBUTED BY HASH(pipeline_name) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

INSERT INTO db_report.pipeline_run_log VALUES
    ("customer_orders_daily", "manual__2026-05-14T00:00:00", "success", "2026-05-14 00:00:00", "demo bootstrap row");
