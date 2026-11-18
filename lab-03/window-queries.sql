-- Лабораторна робота №3. Віконні функції.
-- Виконувати в базі dbsa на початковому наповненні роботи №2.
-- Суми позицій охоплюють усі статуси замовлень,
-- включно зі скасованими; це не сума отриманих оплат.

-- Запит 1. Яке місце має кожен покупець за кількістю замовлень?
-- Рядків: 5, включно з покупцем без замовлень.
-- Покупці customer01 та customer02 мають по 3 замовлення:
-- rank = 1, dense_rank = 1, row_number = 1 та 2.
-- Покупці customer03 та customer04 мають по 2 замовлення:
-- rank = 3, dense_rank = 2, row_number = 3 та 4.
-- Покупець customer05 має 0 замовлень:
-- rank = 5, dense_rank = 3, row_number = 5.
-- Для рейтингу обрано rank: однакові результати ділять місце,
-- а наступне місце враховує кількість попередніх учасників.
SELECT
    c.email,
    count(o.id) AS orders_count,
    rank() OVER (
        ORDER BY count(o.id) DESC
    ) AS rank_place,
    dense_rank() OVER (
        ORDER BY count(o.id) DESC
    ) AS dense_rank_place,
    row_number() OVER (
        ORDER BY count(o.id) DESC, c.email
    ) AS row_number_place
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.id
GROUP BY c.id, c.email
ORDER BY orders_count DESC, c.email;

-- Запит 2. Як за днями накопичувалася вартість позицій замовлень?
-- Рядків: 9.
-- День       | Сума дня | Накопичувальна сума
-- 2026-03-05 | 2740.00  | 2740.00
-- 2026-03-12 | 650.00   | 3390.00
-- 2026-03-20 | 2920.00  | 6310.00
-- 2026-03-31 | 5200.00  | 11510.00
-- 2026-04-01 | 3100.00  | 14610.00
-- 2026-04-05 | 1600.00  | 16210.00
-- 2026-04-10 | 4300.00  | 20510.00
-- 2026-04-15 | 540.00   | 21050.00
-- 2026-04-30 | 3150.00  | 24200.00
SELECT
    d.order_day,
    d.day_value,
    sum(d.day_value) OVER (
        ORDER BY d.order_day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM (
    SELECT
        CAST(o.ordered_at AS date) AS order_day,
        sum(oi.quantity * oi.unit_price) AS day_value
    FROM orders AS o
    JOIN order_items AS oi
        ON oi.order_id = o.id
    GROUP BY CAST(o.ordered_at AS date)
) AS d
ORDER BY d.order_day;

-- Запит 3. Яка середня денна вартість позицій
-- за поточним і двома попередніми рядками днів із позиціями?
-- Рядків: 9.
-- День       | Ковзне середнє
-- 2026-03-05 | 2740.00
-- 2026-03-12 | 1695.00
-- 2026-03-20 | 2103.33
-- 2026-03-31 | 2923.33
-- 2026-04-01 | 3740.00
-- 2026-04-05 | 3300.00
-- 2026-04-10 | 3000.00
-- 2026-04-15 | 2146.67
-- 2026-04-30 | 2663.33
-- ROWS рахує рядки результату, а не календарні дні.
-- Наприклад, для 20 березня рамка містить 5, 12 та 20 березня.
SELECT
    d.order_day,
    d.day_value,
    round(
        avg(d.day_value) OVER (
            ORDER BY d.order_day
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_average
FROM (
    SELECT
        CAST(o.ordered_at AS date) AS order_day,
        sum(oi.quantity * oi.unit_price) AS day_value
    FROM orders AS o
    JOIN order_items AS oi
        ON oi.order_id = o.id
    GROUP BY CAST(o.ordered_at AS date)
) AS d
ORDER BY d.order_day;