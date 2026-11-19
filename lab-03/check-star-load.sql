-- Контроль завантаження: виконувати до та після запусків load-star.sql.
SELECT 'database_name' AS check_name,
       current_database()::text AS check_value
UNION ALL
SELECT 'dim_products_count', count(*)::text FROM dim_products
UNION ALL
SELECT 'dim_dates_count', count(*)::text FROM dim_dates
UNION ALL
SELECT 'fact_count', count(*)::text FROM fact_order_items
UNION ALL
SELECT 'unit_count', coalesce(sum(quantity), 0)::text
FROM fact_order_items
UNION ALL
SELECT 'line_amount_total', coalesce(sum(line_amount), 0)::text
FROM fact_order_items
UNION ALL
SELECT 'first_date', min(date_key)::text FROM dim_dates
UNION ALL
SELECT 'last_date', max(date_key)::text FROM dim_dates;