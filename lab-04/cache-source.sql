-- Лабораторна робота №4. Джерело показника для кеша Redis.
-- База dbsa, зірка роботи №3 після stage-load.sql.
-- Вартість позицій за березень; включено всі статуси й прийняте нове джерело.
-- Фактично підтверджено 14250 грн; це не сума отриманих оплат.
SELECT
    '2026-03' AS report_month,
    coalesce(sum(f.line_amount), 0) AS order_value
FROM fact_order_items AS f
JOIN dim_dates AS d
    ON d.date_key = f.date_key
WHERE d.date_key >= DATE '2026-03-01'
  AND d.date_key < DATE '2026-04-01';
