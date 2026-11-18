-- Лабораторна робота №3.
-- Генерація даних для досліду з індексом.
-- Виконувати лише в окремій базі dbsa_big після міграцій 001-003.
-- Перед першим запуском робочі таблиці порожні,
-- крім трьох форматів, доданих міграцією 002.
--
-- Тестові ідентифікатори та номери замовлень відрізняються
-- від початкового наповнення роботи №2.
-- Дати замовлень належать 2025 року.
--
-- OVERRIDING SYSTEM VALUE дозволяє явно задати тестові id
-- у стовпцях GENERATED ALWAYS AS IDENTITY.
--
-- Скрипт призначений для одного запуску.
-- Повторний запуск порушить первинні ключі.

BEGIN;

-- 1. Тестовий бренд.
INSERT INTO brands (id, name)
OVERRIDING SYSTEM VALUE
VALUES (10001, 'Benchmark Brand');

-- 2. Тестовий аромат.
INSERT INTO fragrances (id, brand_id, name, description)
OVERRIDING SYSTEM VALUE
VALUES (
    10001,
    10001,
    'Benchmark Fragrance',
    'Штучні дані для вимірювання продуктивності'
);

-- 3. Десять товарних варіантів.
-- Обсяги: 10, 20, ..., 100 мл.
-- Ціни: 500, 600, ..., 1400 грн.
INSERT INTO products (
    id,
    fragrance_id,
    volume_ml,
    price,
    format_id
)
OVERRIDING SYSTEM VALUE
SELECT
    10000 + n,
    10001,
    10 * n,
    500 + 100 * (n - 1),
    (SELECT id FROM product_formats WHERE name = 'флакон')
FROM generate_series(1, 10) AS n;

-- 4. Десять тисяч вигаданих покупців.
-- Ідентифікатори: 10001-20000.
INSERT INTO customers (id, last_name, email, phone)
OVERRIDING SYSTEM VALUE
SELECT
    10000 + n,
    'Тестовий покупець ' || n,
    'benchmark-' || n || '@example.com',
    NULL
FROM generate_series(1, 10000) AS n;

-- 5. Сто тисяч замовлень.
-- Ідентифікатори: 100001-200000.
-- На кожного покупця припадає 10 замовлень.
-- Крок між замовленнями: 5 хвилин.
INSERT INTO orders (
    id,
    customer_id,
    ordered_at,
    status,
    order_number
)
OVERRIDING SYSTEM VALUE
SELECT
    100000 + n,
    10001 + n % 10000,
    timestamptz '2025-01-01 08:00:00+02'
        + n * interval '5 minutes',
    'new',
    'BIG-2025-' || n
FROM generate_series(1, 100000) AS n;

-- 6. По одній позиції в кожному замовленні.
-- Кількість товару: від 1 до 3 одиниць.
-- Ціна відповідає обраному тестовому товару.
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    100000 + n,
    10001 + n % 10,
    1 + n % 3,
    500 + 100 * (n % 10)
FROM generate_series(1, 100000) AS n;

COMMIT;

-- Контроль результату.
SELECT 'database_name' AS check_name,
       current_database()::text AS check_value
UNION ALL
SELECT 'brands_count', count(*)::text FROM brands
UNION ALL
SELECT 'fragrances_count', count(*)::text FROM fragrances
UNION ALL
SELECT 'products_count', count(*)::text FROM products
UNION ALL
SELECT 'customers_count', count(*)::text FROM customers
UNION ALL
SELECT 'orders_count', count(*)::text FROM orders
UNION ALL
SELECT 'order_items_count', count(*)::text FROM order_items
UNION ALL
SELECT 'unit_count', sum(quantity)::text FROM order_items
UNION ALL
SELECT 'order_value', sum(quantity * unit_price)::text
FROM order_items
UNION ALL
SELECT 'first_order_date',
       min(CAST(ordered_at AS date))::text
FROM orders
UNION ALL
SELECT 'last_order_date',
       max(CAST(ordered_at AS date))::text
FROM orders;