-- Завантаження шести навчальних рядків нового підрозділу.
-- Перед виконанням мають бути заповнені dim_dates і stage_order_items.

-- 1. Відбракування до перетворення типів.
INSERT INTO stage_rejects (source_row, reject_reason)
SELECT
    s.source_row,
    CASE
        WHEN nullif(trim(s.quantity_raw), '') IS NULL
            THEN 'До перетворення: кількість не заповнена'
        WHEN nullif(trim(replace(s.unit_price_raw, ' грн', '')), '') IS NULL
            THEN 'До перетворення: ціна не заповнена'
        WHEN nullif(trim(replace(s.line_amount_raw, ' грн', '')), '') IS NULL
            THEN 'До перетворення: сума не заповнена'
        ELSE 'До перетворення: дата відсутня в календарі або має неправильний формат'
    END
FROM stage_order_items AS s
LEFT JOIN dim_dates AS d
    ON to_char(d.date_key, 'DD.MM.YYYY') = trim(s.ordered_on_raw)
WHERE nullif(trim(s.quantity_raw), '') IS NULL
   OR nullif(trim(replace(s.unit_price_raw, ' грн', '')), '') IS NULL
   OR nullif(trim(replace(s.line_amount_raw, ' грн', '')), '') IS NULL
   OR d.date_key IS NULL
ON CONFLICT (source_row) DO NOTHING;

-- 2. Перевірка числових значень після перетворення.
INSERT INTO stage_rejects (source_row, reject_reason)
SELECT
    t.source_row,
    CASE
        WHEN t.quantity <= 0
            THEN 'Після перетворення: кількість має бути додатною'
        WHEN t.unit_price <= 0
            THEN 'Після перетворення: ціна має бути додатною'
        WHEN t.line_amount <= 0
            THEN 'Після перетворення: сума має бути додатною'
        ELSE 'Після перетворення: сума не дорівнює кількості, помноженій на ціну'
    END
FROM (
    SELECT
        s.source_row,
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
    LEFT JOIN stage_rejects AS r ON r.source_row = s.source_row
    WHERE r.source_row IS NULL
) AS t
WHERE t.quantity <= 0
   OR t.unit_price <= 0
   OR t.line_amount <= 0
   OR t.line_amount <> t.quantity * t.unit_price
ON CONFLICT (source_row) DO NOTHING;

-- 3. Додавання нових товарів джерела у вимір.
INSERT INTO dim_products (
    source_product_id,
    fragrance_name,
    brand_name,
    format_name,
    volume_ml
)
SELECT DISTINCT
    CAST(trim(s.product_id_raw) AS bigint),
    trim(s.fragrance_name_raw),
    trim(s.brand_name_raw),
    trim(s.format_name_raw),
    CAST(trim(s.volume_ml_raw) AS numeric(8,2))
FROM stage_order_items AS s
LEFT JOIN stage_rejects AS r ON r.source_row = s.source_row
WHERE r.source_row IS NULL
ON CONFLICT (source_product_id) DO NOTHING;

-- 4. Перетворення типів у підзапиті та DISTINCT перед завантаженням фактів.
-- Дату беремо з календаря після точного зіставлення текстового запису.
INSERT INTO fact_order_items (
    order_id,
    product_id,
    product_key,
    date_key,
    quantity,
    unit_price,
    line_amount
)
SELECT DISTINCT
    t.order_id,
    t.product_id,
    p.product_key,
    t.date_key,
    t.quantity,
    t.unit_price,
    t.line_amount
FROM (
    SELECT
        CAST(trim(s.order_id_raw) AS bigint) AS order_id,
        CAST(trim(s.product_id_raw) AS bigint) AS product_id,
        d.date_key,
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
    LEFT JOIN stage_rejects AS r ON r.source_row = s.source_row
    WHERE r.source_row IS NULL
) AS t
JOIN dim_products AS p ON p.source_product_id = t.product_id
WHERE t.quantity > 0
  AND t.unit_price > 0
  AND t.line_amount = t.quantity * t.unit_price
ON CONFLICT (order_id, product_id) DO UPDATE
SET product_key = EXCLUDED.product_key,
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    line_amount = EXCLUDED.line_amount;
