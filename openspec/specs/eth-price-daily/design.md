# Design: ETH Price Daily Ingestion

## Source

- System: CoinGecko public REST API (no auth required for free tier)
- Endpoint: `GET /api/v3/simple/price?ids=ethereum&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true`
- Ingestion pattern: full snapshot per execution interval (single-row daily price snapshot)
- Rate limits: CoinGecko free tier allows ~30 req/min; this pipeline makes 1 request/day — well within limits

## Target

### Stage layer

- Layer: `db_stage`
- Table: `db_stage.eth_price_daily`
- Grain: one row per `price_date`
- Key: `UNIQUE KEY(price_date)` — idempotent upsert on re-run, consistent with `btc_price_daily`

### Curated model layer

- Layer: `db_data_model`
- Table: `db_data_model.fact_eth_daily_price`
- Grain: one row per `price_date`
- Key: `UNIQUE KEY(price_date)`

## Transformation logic

Stage → curated transformation applies explicit type casts. No business rules beyond casting and renaming to align with the BTC fact table schema conventions:

```sql
SELECT
    price_date,
    CAST(price_usd                   AS DECIMAL(18, 2))  AS price_usd,
    CAST(market_cap_usd              AS DECIMAL(24, 2))  AS market_cap_usd,
    CAST(volume_24h_usd              AS DECIMAL(24, 2))  AS volume_24h_usd,
    CAST(price_change_percentage_24h AS DECIMAL(10, 4))  AS price_change_pct_24h,
    source_system                                         AS price_source,
    NOW()                                                 AS loaded_at
FROM db_stage.eth_price_daily
WHERE price_date = %(price_date)s
```

## Load pattern

- Idempotency: `UNIQUE KEY(price_date)` in both tables — StarRocks upserts on duplicate key, making re-runs safe
- Partition key: `price_date`
- Frequency: daily at 06:00 UTC
- Backfill strategy: not in scope for this delivery; pipeline is `catchup=False`

## Trade-offs

| Option | Pros | Cons |
|---|---|---|
| Mirror BTC pattern exactly (chosen) | Zero new abstractions, proven pattern, fast delivery | If BTC pattern has a bug it is replicated |
| Shared generic crypto DAG parameterized by coin | DRY, easier to add new coins later | More complexity now, over-engineering for 2 coins |
| Streaming / sub-daily price | Real-time price visibility | Not needed, significant infrastructure overhead |

## Dependencies

- Upstream: CoinGecko public API (external, no SLA)
- Upstream: `db_stage` and `db_data_model` databases in StarRocks (exist, created in bootstrap)
- Downstream: no committed consumers at proposal time

## Schema

### `db_stage.eth_price_daily`

| Column | Type | Notes |
|---|---|---|
| `price_date` | `DATE` | UNIQUE KEY — logical date of the price snapshot |
| `price_usd` | `DOUBLE` | Raw price from API |
| `market_cap_usd` | `DOUBLE` | |
| `volume_24h_usd` | `DOUBLE` | |
| `price_change_24h_usd` | `DOUBLE` | Absolute change (nullable, not returned by simple/price) |
| `price_change_percentage_24h` | `DOUBLE` | % change from API |
| `source_system` | `VARCHAR(64)` | Always `coingecko` |
| `api_request_date` | `DATE` | Date the API was called |
| `ingested_date` | `DATE` | |
| `loaded_at` | `DATETIME` | |

### `db_data_model.fact_eth_daily_price`

| Column | Type | Notes |
|---|---|---|
| `price_date` | `DATE` | UNIQUE KEY |
| `price_usd` | `DECIMAL(18,2)` | |
| `market_cap_usd` | `DECIMAL(24,2)` | |
| `volume_24h_usd` | `DECIMAL(24,2)` | |
| `price_change_pct_24h` | `DECIMAL(10,4)` | |
| `price_source` | `VARCHAR(64)` | |
| `loaded_at` | `DATETIME` | |

## Open decisions

- [TODO: Confirm whether `price_change_24h_usd` should be dropped from stage (CoinGecko simple/price does not return it — matches BTC pattern where it is always NULL)]
