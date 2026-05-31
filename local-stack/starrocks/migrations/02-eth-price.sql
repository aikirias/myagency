-- Migration: 02-eth-price
-- Creates the raw landing table db_stage.eth_price_daily and the curated ETH
-- daily price fact table db_data_model.fact_eth_daily_price.
-- Prerequisites: db_stage and db_data_model schemas must exist (created in 00-bootstrap.sql).

CREATE TABLE IF NOT EXISTS db_stage.eth_price_daily (
    price_date                    DATE,
    price_usd                     DOUBLE,
    market_cap_usd                DOUBLE,
    volume_24h_usd                DOUBLE,
    price_change_24h_usd          DOUBLE,
    price_change_percentage_24h   DOUBLE,
    source_system                 VARCHAR(64),
    api_request_date              DATE,
    ingested_date                 DATE,
    loaded_at                     DATETIME
)
ENGINE = OLAP
UNIQUE KEY(price_date)
DISTRIBUTED BY HASH(price_date) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);

CREATE TABLE IF NOT EXISTS db_data_model.fact_eth_daily_price (
    price_date            DATE,
    price_usd             DECIMAL(18, 2),
    market_cap_usd        DECIMAL(24, 2),
    volume_24h_usd        DECIMAL(24, 2),
    price_change_pct_24h  DECIMAL(10, 4),
    price_source          VARCHAR(64),
    loaded_at             DATETIME
)
ENGINE = OLAP
UNIQUE KEY(price_date)
DISTRIBUTED BY HASH(price_date) BUCKETS 1
PROPERTIES (
    "replication_num" = "1"
);
