-- Перевірка 1. Причини відбракування.
SELECT source_row, reject_reason
FROM stage_rejects
ORDER BY source_row;

-- Перевірка 2. Результат DISTINCT і перевірки суперечностей.
-- Тут виключаємо лише відбракування ДО перетворення,
-- щоб окремо порахувати суперечність після перетворення.
SELECT
    count(*) AS rows_after_distinct,
    sum(
        CASE
            WHEN t.quantity > 0
             AND t.unit_price > 0
             AND t.line_amount = t.quantity * t.unit_price
            THEN 1 ELSE 0
        END
    ) AS accepted_rows,
    sum(
        CASE
            WHEN t.quantity <= 0
              OR t.unit_price <= 0
              OR t.line_amount <= 0
              OR t.line_amount <> t.quantity * t.unit_price
            THEN 1 ELSE 0
        END
    ) AS rejected_after_conversion
FROM (
    SELECT DISTINCT
        CAST(trim(s.order_id_raw) AS bigint) AS order_id,
        CAST(trim(s.product_id_raw) AS bigint) AS product_id,
        d.date_key,
        trim(s.fragrance_name_raw) AS fragrance_name,
        trim(s.brand_name_raw) AS brand_name,
        trim(s.format_name_raw) AS format_name,
        CAST(trim(s.volume_ml_raw) AS numeric(8,2)) AS volume_ml,
        CAST(nullif(trim(s.quantity_raw), '') AS integer) AS quantity,
        CAST(
            nullif(trim(replace(s.unit_price_raw, ' грн', '')), '')
            AS numeric(12,2)
        ) AS unit_price,
        CAST(
            nullif(trim(replace(s.line_amount_raw, ' грн', '')), '')
            AS numeric(24,2)
        ) AS line_amount
    FROM stage_order_items AS s
    JOIN dim_dates AS d
        ON to_char(d.date_key, 'DD.MM.YYYY') = trim(s.ordered_on_raw)
    LEFT JOIN stage_rejects AS r
        ON r.source_row = s.source_row
       AND r.reject_reason LIKE 'До перетворення:%'
    WHERE r.source_row IS NULL
) AS t;

-- Перевірка 3. Підсумки сховища та нового джерела.
SELECT 'database_name' AS check_name,
       current_database()::text AS check_value
UNION ALL
SELECT 'stage_rows', count(*)::text FROM stage_order_items
UNION ALL
SELECT 'stage_rejects', count(*)::text FROM stage_rejects
UNION ALL
SELECT 'dim_products_count', count(*)::text FROM dim_products
UNION ALL
SELECT 'dim_dates_count', count(*)::text FROM dim_dates
UNION ALL
SELECT 'fact_count', count(*)::text FROM fact_order_items
UNION ALL
SELECT 'unit_count', sum(quantity)::text FROM fact_order_items
UNION ALL
SELECT 'fact_total', sum(line_amount)::text FROM fact_order_items
UNION ALL
SELECT 'new_source_fact_count', count(*)::text
FROM fact_order_items
WHERE order_id BETWEEN 900001 AND 900004
UNION ALL
SELECT 'new_source_total', coalesce(sum(line_amount), 0)::text
FROM fact_order_items
WHERE order_id BETWEEN 900001 AND 900004;
