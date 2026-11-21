-- Лабораторна робота №4. Звірка агрегації з PostgreSQL.
-- Виконувати в базі dbsa після початкового наповнення роботи №2.
-- orders_count — показник запиту 6 analytic-queries.sql роботи №3.
-- Додаткова сума: вартість позицій усіх статусів, а не сума оплат.
-- Позиції спочатку згортаємо до одного рядка на замовлення, щоб JOIN
-- не помножив кількість замовлень з кількома позиціями.
-- Фактично отримано 5 покупців; customer05 має 0 замовлень і суму 0.
WITH order_values AS (
    SELECT
        order_id,
        sum(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT
    c.email,
    count(o.id) AS orders_count,
    coalesce(sum(v.order_value), 0) AS order_value
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.id
LEFT JOIN order_values AS v
    ON v.order_id = o.id
GROUP BY c.id, c.email
ORDER BY orders_count DESC, c.email;
