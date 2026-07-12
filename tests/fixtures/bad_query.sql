-- FIXTURE: intentionally bad SQL for TC-12 (practice-sql-quality) and TC-23 (check-sql hook).
-- Planted defects: SELECT *, implicit cartesian join, positional GROUP BY,
-- function on partition column, DELETE without WHERE, = NULL comparison.

SELECT *
FROM db_data_model.fact_orders o, db_data_model.dim_customers c
WHERE toDate(o.partition_date) >= '2026-01-01'
  AND o.discount = NULL
GROUP BY 1, 2;

DELETE FROM db_data_model.fact_orders;
