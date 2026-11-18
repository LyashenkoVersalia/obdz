-- Лабораторна робота №3. Аналітичні запити.
-- Предметна область: інтернет-магазин нішевої парфумерії.
-- Виконувати в базі dbsa після початкового наповнення роботи №2.
-- Суми позицій охоплюють усі замовлення, включно зі скасованими.
-- Це вартість записаних позицій, а не сума отриманих оплат.

-- Запит 1.
-- Скільки позицій, одиниць товару та на яку суму є в усіх замовленнях?
-- Рядків: 1.
-- Результат: line_count = 12, unit_count = 16, order_value = 24200.00.
SELECT
    count(*) AS line_count,
    sum(oi.quantity) AS unit_count,
    sum(oi.quantity * oi.unit_price) AS order_value
FROM order_items AS oi;

-- Запит 2.
-- Які покупці оформили в березні замовлення
-- із загальною вартістю позицій понад 3000 грн?
-- Конструкції: WHERE, GROUP BY, HAVING.
-- Рядків: 1.
-- Результат: customer01@example.com, 2 замовлення, 7940.00 грн.
SELECT
    c.email,
    count(DISTINCT o.id) AS orders_count,
    sum(oi.quantity * oi.unit_price) AS order_value
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.id
JOIN order_items AS oi
    ON oi.order_id = o.id
WHERE o.ordered_at >= '2026-03-01 00:00:00+02'
  AND o.ordered_at < '2026-04-01 00:00:00+03'
GROUP BY c.id, c.email
HAVING sum(oi.quantity * oi.unit_price) > 3000
ORDER BY order_value DESC, c.email;

-- Запит 3.
-- Скільки замовлень має кожен покупець із замовленнями
-- і скільки з них перебувають у стані new?
-- Конструкції: GROUP BY, CASE усередині count.
-- Рядків: 4.
-- Результати orders_count / new_count:
-- customer01@example.com: 3 / 1.
-- customer02@example.com: 3 / 1.
-- customer03@example.com: 2 / 0.
-- customer04@example.com: 2 / 2.
SELECT
    c.email,
    count(*) AS orders_count,
    count(CASE WHEN o.status = 'new' THEN 1 END) AS new_count
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.id
GROUP BY c.id, c.email
ORDER BY c.email;

-- Запит 4.
-- Скільки товарів коштують дорожче за середню ціну всіх товарів?
-- Конструкція: підзапит у WHERE.
-- Рядків: 1.
-- Середня ціна: 2355.00 грн. Результат: 6 товарів.
SELECT
    count(*) AS products_above_average
FROM products AS p
WHERE p.price > (
    SELECT avg(price)
    FROM products
);

-- Запит 5.
-- Яка середня вартість замовлень, що мають хоча б одну позицію?
-- Конструкція: підзапит у FROM.
-- Рядків: 1. Результат: 2688.89 грн.
-- У підзапиті 9 замовлень із позиціями на загальну суму 24200.00.
-- Замовлення-чернетка без позицій до середнього не входить.
SELECT
    round(avg(t.order_value), 2) AS average_order_value
FROM (
    SELECT
        oi.order_id,
        sum(oi.quantity * oi.unit_price) AS order_value
    FROM order_items AS oi
    GROUP BY oi.order_id
) AS t;

-- Запит 6.
-- Скільки замовлень має кожен покупець, включно з покупцями без замовлень?
-- Конструкції: LEFT JOIN, GROUP BY, count стовпця правої таблиці.
-- Рядків: 5.
-- Результати:
-- customer01@example.com: 3.
-- customer02@example.com: 3.
-- customer03@example.com: 2.
-- customer04@example.com: 2.
-- customer05@example.com: 0.
SELECT
    c.email,
    count(o.id) AS orders_count
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.id
GROUP BY c.id, c.email
ORDER BY c.email;