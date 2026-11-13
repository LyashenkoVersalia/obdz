-- Лабораторна робота №2.
-- Зміна й видалення даних.
-- Кожен дослід виконується окремо.
-- ROLLBACK повертає початкові дані після перевірки.

-- 1. UPDATE: пробна знижка 10% на мініатюри.
-- Відбір за форматом, а не за первинним ключем.
-- Очікується зміна двох товарів: 4 і 9.

BEGIN;

SELECT id, format_id, price
FROM products
WHERE format_id = 2
ORDER BY id;

UPDATE products
SET price = round(price * 0.90, 2)
WHERE format_id = 2;

SELECT id, format_id, price
FROM products
WHERE format_id = 2
ORDER BY id;

ROLLBACK;

SELECT id, format_id, price
FROM products
WHERE format_id = 2
ORDER BY id;


-- 2. UPDATE: додавання відсутнього опису Wood Rain.
-- Очікується зміна одного аромату.

BEGIN;

SELECT id, name, description
FROM fragrances
WHERE name = 'Wood Rain'
ORDER BY id;

UPDATE fragrances
SET description = 'Деревний аромат із нотами дощу'
WHERE name = 'Wood Rain'
  AND description IS NULL;

SELECT id, name, description
FROM fragrances
WHERE name = 'Wood Rain'
ORDER BY id;

ROLLBACK;

SELECT id, name, description
FROM fragrances
WHERE name = 'Wood Rain'
ORDER BY id;


-- 3. DELETE: видалення квітневих замовлень-чернеток.
-- Очікується видалення одного замовлення: 10.
-- Воно не має позицій, оплати та доставки.

BEGIN;

SELECT id, order_number, ordered_at, status
FROM orders
WHERE status = 'draft'
  AND ordered_at >= '2026-04-01 00:00:00+03'
  AND ordered_at < '2026-05-01 00:00:00+03'
ORDER BY id;

DELETE FROM orders
WHERE status = 'draft'
  AND ordered_at >= '2026-04-01 00:00:00+03'
  AND ordered_at < '2026-05-01 00:00:00+03';

SELECT id, order_number, ordered_at, status
FROM orders
WHERE status = 'draft'
  AND ordered_at >= '2026-04-01 00:00:00+03'
  AND ordered_at < '2026-05-01 00:00:00+03'
ORDER BY id;

ROLLBACK;

SELECT id, order_number, ordered_at, status
FROM orders
WHERE status = 'draft'
  AND ordered_at >= '2026-04-01 00:00:00+03'
  AND ordered_at < '2026-05-01 00:00:00+03'
ORDER BY id;

-- 4. RESTRICT: заборона видалення покупця,
-- на якого посилаються замовлення.
-- Команди виконуються окремо.
-- Після очікуваної помилки DELETE виконується ROLLBACK.

BEGIN;

SELECT id, email
FROM customers
WHERE id = 1;

SELECT id, customer_id, order_number
FROM orders
WHERE customer_id = 1
ORDER BY id;

DELETE FROM customers
WHERE id = 1;

ROLLBACK;

SELECT id, email
FROM customers
WHERE id = 1;

SELECT id, customer_id, order_number
FROM orders
WHERE customer_id = 1
ORDER BY id;


-- 5. CASCADE: видалення замовлення автоматично
-- видаляє його позиції.
-- Замовлення 9 має дві позиції, але не має оплати й доставки.
-- ROLLBACK відновлює замовлення та його позиції.

BEGIN;

SELECT id, order_number
FROM orders
WHERE id = 9;

SELECT order_id, product_id, quantity, unit_price
FROM order_items
WHERE order_id = 9
ORDER BY product_id;

DELETE FROM orders
WHERE id = 9;

SELECT id, order_number
FROM orders
WHERE id = 9;

SELECT order_id, product_id, quantity, unit_price
FROM order_items
WHERE order_id = 9
ORDER BY product_id;

ROLLBACK;

SELECT id, order_number
FROM orders
WHERE id = 9;

SELECT order_id, product_id, quantity, unit_price
FROM order_items
WHERE order_id = 9
ORDER BY product_id;