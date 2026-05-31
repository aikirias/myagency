# SQL Style Guide

## Formatting

- Keywords in UPPERCASE: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`, `ORDER BY`
- One clause per line for queries with more than 3 columns or conditions
- Indent column lists and JOIN conditions with 4 spaces
- Aliases are lowercase with underscores: `order_id AS order_id`
- Always use explicit aliases on derived columns

```sql
-- Good
SELECT
    o.order_id,
    o.customer_id,
    SUM(oi.amount) AS total_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2024-01-01'
GROUP BY
    o.order_id,
    o.customer_id

-- Bad
select order_id,customer_id,sum(amount) from orders join order_items using(order_id) where order_date>='2024-01-01' group by 1,2
```

## SELECT rules

- Never use `SELECT *` in production queries or transformations
- Always explicitly list columns
- Use `DISTINCT` only when deduplication is the intent, not a workaround for bad joins

## JOINs

- Specify JOIN type explicitly: `INNER JOIN`, `LEFT JOIN`, `FULL OUTER JOIN`
- Join conditions use `ON` with explicit table aliases
- Avoid implicit joins (`FROM a, b WHERE a.id = b.id`)
- Verify that a LEFT JOIN is appropriate — a missing match may indicate a data issue

## NULL handling

- Use `COALESCE(col, default)` for explicit null replacement
- Use `IS NULL` / `IS NOT NULL`, not `= NULL`
- In aggregations: `SUM(COALESCE(amount, 0))` when nulls should be treated as zero
- In joins: be aware that NULL keys do not match — handle them if they are expected

## Date and time

- Always cast dates explicitly: `CAST(event_ts AS DATE)`
- Do not rely on implicit date casting
- Use `DATE_TRUNC('day', ts)` for truncation, not string formatting
- Document timezone assumptions in a comment when mixing timezones

## Incremental patterns

- The incremental filter must appear on all tables that have a date column, not just the main table
- Use `>=` with a parameter, never hardcode dates in production queries
- Document the incremental key in a comment at the top of the query

## Aggregations

- Ensure GROUP BY includes all non-aggregated SELECT columns
- Avoid grouping by column position (`GROUP BY 1, 2`) in production code
- Use `COUNT(DISTINCT col)` only when necessary — it is expensive on large tables
- Validate SUM and COUNT results against source for the first run of a new query

## Safety

- DELETE and UPDATE must always have a WHERE clause
- DROP TABLE and TRUNCATE are only allowed in migration scripts, never in pipeline logic
- Avoid side effects in CTEs (no DML in CTEs)
