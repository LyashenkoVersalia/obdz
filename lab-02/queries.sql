-- Лабораторна робота №2.
-- Запити виконуються окремо після початкового наповнення,
-- до виконання змін із data-changes.sql.

-- Запит 1.
-- Які флакони або мініатюри коштують не більше 3000 грн?
-- Формати: 1 — флакон, 2 — мініатюра.
-- Конструкції: AND, OR, дужки, порівняння.
-- Очікується 4 рядки: товари 1, 4, 5, 9.
SELECT id, fragrance_id, volume_ml, format_id, price
FROM products
WHERE (format_id = 1 OR format_id = 2)
  AND price <= 3000
ORDER BY id;

-- Запит 2.
-- Які товари коштують від 650 до 2700 грн включно?
-- Конструкція: BETWEEN.
-- Очікується 4 рядки: товари 1, 4, 5, 9.
SELECT id, volume_ml, price
FROM products
WHERE price BETWEEN 650 AND 2700
ORDER BY price, id;

-- Запит 3.
-- Які нові замовлення або чернетки оформлено у квітні 2026 року?
-- Конструкції: IN, AND, напівінтервал для дати й часу.
-- Очікується 5 рядків: замовлення 5, 6, 8, 9, 10.
SELECT id, order_number, ordered_at, status
FROM orders
WHERE status IN ('new', 'draft')
  AND ordered_at >= '2026-04-01 00:00:00+03'
  AND ordered_at < '2026-05-01 00:00:00+03'
ORDER BY ordered_at, id;

-- Запит 4.
-- Які аромати містять у назві слово Night?
-- Конструкція: LIKE.
-- Очікується 1 рядок: Amber Night.
SELECT id, name, description
FROM fragrances
WHERE name LIKE '%Night%'
ORDER BY name, id;

-- Запит 5.
-- У яких покупців не вказано телефон?
-- Конструкція: IS NULL.
-- Очікується 2 рядки: покупці 2, 4.
SELECT id, last_name, email, phone
FROM customers
WHERE phone IS NULL
ORDER BY id;

-- Запит 6.
-- Які три найдорожчі товари серед тих, що дорожчі за 1000 грн?
-- Конструкції: порівняння, ORDER BY, LIMIT.
-- Очікується 3 рядки: товари 6, 2, 10.
SELECT id, fragrance_id, volume_ml, price
FROM products
WHERE price > 1000
ORDER BY price DESC, id
LIMIT 3;

-- NULL, приклад 1.
-- Які покупці мають телефон, відмінний від +380000000001?
-- Цей варіант не включає покупців без телефону.
-- Очікується 2 рядки: покупці 3, 5.
SELECT id, last_name, phone
FROM customers
WHERE phone <> '+380000000001'
ORDER BY id;

-- NULL, приклад 2.
-- Які покупці мають інший телефон або не вказали його?
-- Виправлення: явно включено рядки з NULL.
-- Очікується 4 рядки: покупці 2, 3, 4, 5.
SELECT id, last_name, phone
FROM customers
WHERE phone <> '+380000000001'
   OR phone IS NULL
ORDER BY id;

-- З’єднання 1. Внутрішнє з’єднання двох таблиць.
-- Які аромати належать кожному бренду?
-- Очікується 6 рядків — по одному на кожен аромат.
-- fragrances.brand_id NOT NULL REFERENCES brands(id),
-- а brands.id є первинним ключем:
-- кожен аромат знаходить рівно один бренд.
SELECT
    f.id AS fragrance_id,
    f.name AS fragrance_name,
    b.name AS brand_name
FROM fragrances AS f
JOIN brands AS b
    ON f.brand_id = b.id
ORDER BY f.id;

-- З’єднання 2. Відновлення структури таблиці «Продажі»
-- з розділу 5 лабораторної роботи №1.
-- Усі 26 стовпців наведено в початковому порядку.
-- Один рядок відповідає одній позиції замовлення.
-- Очікується 12 рядків.
-- Оплата й доставка необов’язкові, тому для них LEFT JOIN.

SELECT
    o.id AS order_id,
    o.ordered_at AS ordered_at,
    o.status AS order_status,
    c.id AS customer_id,
    c.last_name AS last_name,
    c.email AS email,
    c.phone AS phone,
    p.id AS product_id,
    p.volume_ml AS volume_ml,
    pf.name AS format_name,
    p.price AS price,
    f.id AS fragrance_id,
    f.name AS fragrance_name,
    f.description AS description,
    b.id AS brand_id,
    b.name AS brand_name,
    oi.quantity AS quantity,
    oi.unit_price AS unit_price,
    pay.id AS payment_id,
    pay.amount AS amount,
    pay.paid_at AS paid_at,
    pay.status AS payment_status,
    s.id AS shipment_id,
    s.address AS address,
    s.shipped_at AS shipped_at,
    s.status AS shipment_status
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.id
JOIN customers AS c
    ON o.customer_id = c.id
JOIN products AS p
    ON oi.product_id = p.id
JOIN product_formats AS pf
    ON p.format_id = pf.id
JOIN fragrances AS f
    ON p.fragrance_id = f.id
JOIN brands AS b
    ON f.brand_id = b.id
LEFT JOIN payments AS pay
    ON pay.order_id = o.id
LEFT JOIN shipments AS s
    ON s.order_id = o.id
ORDER BY o.id, p.id;

-- З’єднання 3. Рядки без пари.
-- Які покупці ще не мають жодного замовлення?
-- Очікується 1 рядок — покупець 5.
-- LEFT JOIN зберігає покупців без замовлень.
-- Для них o.id дорівнює NULL.
SELECT
    c.id AS customer_id,
    c.last_name,
    c.email
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.id
WHERE o.id IS NULL
ORDER BY c.id;