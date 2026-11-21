-- Дашборд вартості позицій замовлень.
-- База dbsa після load-star.sql і stage-load.sql.
-- Період: 2026-03-05 — 2026-04-30.
-- Включено всі статуси замовлень і прийняті позиції нового джерела.
-- Показник описує вартість позицій, а не отримані оплати.

-- 1. Підсумок за місяцями для картки.
-- 2 рядки: 2026-03 = 14250.00; 2026-04 = 12690.00.
-- Картка підсумовує order_value: 26940.00.
SELECT
    d.month_label,
    sum(f.line_amount) AS order_value
FROM fact_order_items AS f
JOIN dim_dates AS d ON d.date_key = f.date_key
WHERE d.date_key BETWEEN DATE '2026-03-05' AND DATE '2026-04-30'
GROUP BY d.month_label
ORDER BY d.month_label;

-- 2. Вартість за товарами, включно з товарами без позицій.
-- 11 рядків; товар source_product_id = 10 має нуль.
-- Сума order_value за всіма товарами: 26940.00.
SELECT
    p.source_product_id,
    p.fragrance_name || ' / ' ||
        p.volume_ml::text || ' мл / ' ||
        p.format_name AS product_name,
    coalesce(sum(f.line_amount), 0) AS order_value
FROM dim_products AS p
LEFT JOIN fact_order_items AS f
    ON f.product_key = p.product_key
   AND f.date_key BETWEEN DATE '2026-03-05' AND DATE '2026-04-30'
GROUP BY
    p.source_product_id,
    p.fragrance_name,
    p.volume_ml,
    p.format_name
ORDER BY order_value DESC, p.source_product_id;

-- 3. Вартість день за днем.
-- 57 рядків, з них 48 із нульовою вартістю.
-- За 2026-03-05: 5480.00. Загальна сума: 26940.00.
-- Дата виводиться у форматі ISO для експорту в CSV.
SELECT
    to_char(d.date_key, 'YYYY-MM-DD') AS order_day,
    coalesce(sum(f.line_amount), 0) AS order_value
FROM dim_dates AS d
LEFT JOIN fact_order_items AS f ON f.date_key = d.date_key
WHERE d.date_key BETWEEN DATE '2026-03-05' AND DATE '2026-04-30'
GROUP BY d.date_key
ORDER BY d.date_key;
