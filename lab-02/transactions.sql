-- Лабораторна робота №2.
-- Явні транзакції.
-- Операція: реєстрація оплати замовлення
-- та переведення замовлення у стан paid.
-- Команди виконуються окремо.

-- Частина 1. COMMIT.
-- Замовлення 6 містить дві одиниці товару
-- за ціною 800 грн: сума оплати 1600 грн.
-- До досліду замовлення має стан new та не має оплати.

SELECT
    o.id AS order_id,
    o.order_number,
    o.status AS order_status,
    pay.id AS payment_id,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 6;

BEGIN;

INSERT INTO payments (order_id, amount, paid_at, status)
VALUES (6, 1600, '2026-04-05 11:10:00+03', 'paid');

UPDATE orders
SET status = 'paid'
WHERE id = 6;

SELECT
    o.id AS order_id,
    o.order_number,
    o.status AS order_status,
    pay.id AS payment_id,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 6;

COMMIT;

SELECT
    o.id AS order_id,
    o.order_number,
    o.status AS order_status,
    pay.id AS payment_id,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 6;

-- Частина 2. ROLLBACK.
-- Пробна реєстрація оплати замовлення 8.
-- У замовленні три одиниці товару по 180 грн:
-- сума оплати 540 грн.
-- Після ROLLBACK оплата має зникнути,
-- а стан замовлення має повернутися до new.

SELECT
    o.id AS order_id,
    o.status AS order_status,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 8;

BEGIN;

INSERT INTO payments (order_id, amount, paid_at, status)
VALUES (8, 540, '2026-04-15 16:10:00+03', 'paid');

UPDATE orders
SET status = 'paid'
WHERE id = 8;

SELECT
    o.id AS order_id,
    o.status AS order_status,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 8;

ROLLBACK;

SELECT
    o.id AS order_id,
    o.status AS order_status,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 8;

-- Частина 3. Помилка всередині транзакції.
-- Спочатку змінюється стан замовлення 9.
-- Потім виконується помилкова вставка оплати:
-- amount = NULL порушує NOT NULL.
-- Після помилки SELECT має бути відхилено.
-- COMMIT у перерваній транзакції спричиняє її відкат.

SELECT
    o.id AS order_id,
    o.status AS order_status,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 9;

BEGIN;

UPDATE orders
SET status = 'paid'
WHERE id = 9;

SELECT id, status
FROM orders
WHERE id = 9;

INSERT INTO payments (order_id, amount, paid_at, status)
VALUES (9, NULL, '2026-04-30 19:55:00+03', 'paid');

SELECT id, status
FROM orders
WHERE id = 9;

COMMIT;

SELECT
    o.id AS order_id,
    o.status AS order_status,
    pay.amount,
    pay.status AS payment_status
FROM orders AS o
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
WHERE o.id = 9;