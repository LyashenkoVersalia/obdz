-- Наповнення бази інтернет-магазину нішевої парфумерії.
-- Дані навчальні та вигадані.
-- Перший запуск: після застосування міграцій 001, 002, 003
-- до порожніх таблиць зі стандартними форматами id 1, 2, 3.
-- Повторний запуск не додає дублікатів.
-- Після зміни цього скрипта схему потрібно відтворити
-- міграціями down - up перед новим першим наповненням.

-- 1. Бренди. Четвертий бренд поки не має ароматів.
INSERT INTO brands (name)
VALUES
    ('Aroma North'),
    ('Velvet Lab'),
    ('Serein Atelier'),
    ('Amber Studio')
ON CONFLICT (name) DO NOTHING;

-- 2. Формати вже додані міграцією 002.
INSERT INTO product_formats (name)
VALUES
    ('флакон'),
    ('мініатюра'),
    ('пробник')
ON CONFLICT (name) DO NOTHING;

-- 3. Аромати. Для частини опис не заповнено.
INSERT INTO fragrances (brand_id, name, description)
VALUES
    (1, 'Rose Mist', 'Квітковий аромат із нотами троянди'),
    (1, 'Citrus Dawn', 'Свіжий цитрусовий аромат'),
    (2, 'Amber Night', 'Теплий амбровий аромат'),
    (2, 'Wood Rain', NULL),
    (3, 'Vanilla Cloud', 'М’який ванільний аромат'),
    (3, 'Iris Light', NULL)
ON CONFLICT (brand_id, name) DO NOTHING;

-- 4. Десять товарних варіантів.
-- Товар 10 поки не входить до жодного замовлення.
INSERT INTO products (
    fragrance_id, volume_ml, format_id, price
)
VALUES
    (1, 50, 1, 2500.00),
    (1, 100, 1, 4300.00),
    (1, 2, 3, 180.00),
    (2, 10, 2, 650.00),
    (2, 50, 1, 2700.00),
    (3, 100, 1, 5200.00),
    (3, 2, 3, 220.00),
    (4, 50, 1, 3100.00),
    (4, 10, 2, 800.00),
    (5, 100, 1, 3900.00)
ON CONFLICT (fragrance_id, volume_ml, format_id)
DO NOTHING;

-- 5. Навчальні покупці.
-- Телефони умовні; покупець 5 не має замовлень.
INSERT INTO customers (last_name, email, phone)
VALUES
    ('Тестовий-А', 'customer01@example.com', '+380000000001'),
    ('Тестовий-Б', 'customer02@example.com', NULL),
    ('Тестовий-В', 'customer03@example.com', '+380000000003'),
    ('Тестовий-Г', 'customer04@example.com', NULL),
    ('Тестовий-Д', 'customer05@example.com', '+380000000005')
ON CONFLICT (email) DO NOTHING;

-- 6. Замовлення за березень і квітень.
-- Є події останнього дня місяця після 00:00.
-- Замовлення 10 є чернеткою без позицій.
INSERT INTO orders (
    customer_id, ordered_at, status, order_number
)
VALUES
    (1, '2026-03-05 10:00:00+02', 'shipped', 'ORD-2026-001'),
    (2, '2026-03-12 12:30:00+02', 'shipped', 'ORD-2026-002'),
    (3, '2026-03-20 15:00:00+02', 'shipped', 'ORD-2026-003'),
    (1, '2026-03-31 18:30:00+03', 'paid', 'ORD-2026-004'),
    (4, '2026-04-01 09:15:00+03', 'new', 'ORD-2026-005'),
    (2, '2026-04-05 11:00:00+03', 'new', 'ORD-2026-006'),
    (3, '2026-04-10 14:20:00+03', 'cancelled', 'ORD-2026-007'),
    (4, '2026-04-15 16:00:00+03', 'new', 'ORD-2026-008'),
    (1, '2026-04-30 19:45:00+03', 'new', 'ORD-2026-009'),
    (2, '2026-04-30 20:00:00+03', 'draft', 'ORD-2026-010')
ON CONFLICT (order_number) DO NOTHING;

-- 7. Дванадцять позицій замовлень.
-- unit_price зберігає ціну на момент оформлення.
INSERT INTO order_items (
    order_id, product_id, quantity, unit_price
)
VALUES
    (1, 1, 1, 2400.00),
    (1, 3, 2, 170.00),
    (2, 4, 1, 650.00),
    (3, 5, 1, 2700.00),
    (3, 7, 1, 220.00),
    (4, 6, 1, 5200.00),
    (5, 8, 1, 3100.00),
    (6, 9, 2, 800.00),
    (7, 2, 1, 4300.00),
    (8, 3, 3, 180.00),
    (9, 1, 1, 2500.00),
    (9, 4, 1, 650.00)
ON CONFLICT (order_id, product_id) DO NOTHING;

-- 8. Оплати. П’ятий платіж очікує підтвердження.
INSERT INTO payments (order_id, amount, paid_at, status)
VALUES
    (1, 2740.00, '2026-03-05 10:10:00+02', 'paid'),
    (2, 650.00, '2026-03-12 12:40:00+02', 'paid'),
    (3, 2920.00, '2026-03-20 15:10:00+02', 'paid'),
    (4, 5200.00, '2026-03-31 18:40:00+03', 'paid'),
    (5, 3100.00, NULL, 'pending')
ON CONFLICT (order_id) DO NOTHING;

-- 9. Доставки трьох оплачених замовлень.
INSERT INTO shipments (
    order_id, address, shipped_at, status
)
VALUES
    (1, 'Навчальна адреса А, пункт 1',
     '2026-03-06 10:00:00+02', 'shipped'),
    (2, 'Навчальна адреса Б, пункт 2',
     '2026-03-13 11:00:00+02', 'shipped'),
    (3, 'Навчальна адреса В, пункт 3',
     '2026-03-21 12:00:00+02', 'shipped')
ON CONFLICT (order_id) DO NOTHING;