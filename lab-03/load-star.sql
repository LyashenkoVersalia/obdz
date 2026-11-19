-- Завантаження зірки в базі dbsa.
-- Порядок: товари, календарні дати, факти позицій.
-- Повторний запуск оновлює описи та показники без дублювання.

-- 1. Вимір товарів.
-- Завантажуються всі товари, включно з товарами без позицій.
INSERT INTO dim_products (
    source_product_id,
    fragrance_name,
    brand_name,
    format_name,
    volume_ml
)
SELECT
    p.id,
    f.name,
    b.name,
    pf.name,
    p.volume_ml
FROM products AS p
JOIN fragrances AS f ON f.id = p.fragrance_id
JOIN brands AS b ON b.id = f.brand_id
JOIN product_formats AS pf ON pf.id = p.format_id
WHERE true
ON CONFLICT (source_product_id) DO UPDATE
SET fragrance_name = EXCLUDED.fragrance_name,
    brand_name = EXCLUDED.brand_name,
    format_name = EXCLUDED.format_name,
    volume_ml = EXCLUDED.volume_ml;

-- 2. Вимір дат.
-- Кожен календарний день від першої до останньої дати позицій.
INSERT INTO dim_dates (
    date_key,
    year_number,
    month_label,
    day_of_week,
    is_weekend
)
SELECT
    CAST(d.day_value AS date),
    CAST(EXTRACT(year FROM d.day_value) AS integer),
    to_char(d.day_value, 'YYYY-MM'),
    CAST(EXTRACT(isodow FROM d.day_value) AS integer),
    EXTRACT(isodow FROM d.day_value) >= 6
FROM generate_series(
    (
        SELECT CAST(min(CAST(o.ordered_at AS date)) AS timestamp)
        FROM orders AS o
        JOIN order_items AS oi ON oi.order_id = o.id
    ),
    (
        SELECT CAST(max(CAST(o.ordered_at AS date)) AS timestamp)
        FROM orders AS o
        JOIN order_items AS oi ON oi.order_id = o.id
    ),
    interval '1 day'
) AS d(day_value)
WHERE true
ON CONFLICT (date_key) DO NOTHING;

-- 3. Факти позицій замовлень.
-- Усі статуси; вартість за ціною позиції на момент замовлення.
INSERT INTO fact_order_items (
    order_id,
    product_id,
    product_key,
    date_key,
    quantity,
    unit_price,
    line_amount
)
SELECT
    oi.order_id,
    oi.product_id,
    dp.product_key,
    CAST(o.ordered_at AS date),
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price
FROM order_items AS oi
JOIN orders AS o ON o.id = oi.order_id
JOIN dim_products AS dp ON dp.source_product_id = oi.product_id
WHERE true
ON CONFLICT (order_id, product_id) DO UPDATE
SET product_key = EXCLUDED.product_key,
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    line_amount = EXCLUDED.line_amount;