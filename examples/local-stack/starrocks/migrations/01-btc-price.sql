-- Migration: 01-btc-price
-- Creates the curated BTC daily price fact table in db_data_model.
-- Prerequisites: db_data_model schema must exist (created in 00-bootstrap.sql).
-- The staging source table db_stage.btc_price_daily is NOT recreated here.

CREATE TABLE IF NOT EXISTS db_data_model.fact_btc_daily_price (
    price_date          DATE,
    price_usd           DECIMAL(18, 2),
    market_cap_usd      DECIMAL(24, 2),
    volume_24h_usd      DECIMAL(24, 2),
    price_change_pct_24h DECIMAL(10, 4),
    price_source        VARCHAR(64),
    loaded_at           DATETIME
)
ENGINE = OLAP
UNIQUE KEY(price_date)
DISTRIBUTED BY HASH(price_date) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);
