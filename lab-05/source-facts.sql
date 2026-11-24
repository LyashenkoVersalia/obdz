-- Лабораторна робота №5. Лише читання наявних даних бази dbsa.
-- Запити виконувати окремо в DBeaver; вони не створюють таблиць і не змінюють рядків.
-- Фактичні результати треба звірити перед внесенням наборів фактів до звіту.

-- 1. Сума позицій, підтверджена оплата, відправлення та формат для двох ситуацій.
-- Очікується: ORD-2026-004 / paid / 5200 / 5200 / true / true;
--             ORD-2026-005 / new  / 3100 /    0 / true / true.
-- pending із сумою 3100 і NULL paid_at не є підтвердженою оплатою.
WITH order_totals AS (
    SELECT order_id, sum(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.order_number,
    o.status AS order_status,
    coalesce(t.order_value, 0) AS order_value,
    CASE
        WHEN p.status = 'paid' AND p.paid_at IS NOT NULL THEN p.amount
        ELSE 0
    END AS confirmed_paid,
    s.shipped_at IS NULL AS shipment_not_recorded,
    EXISTS (
        SELECT 1
        FROM order_items AS oi
        JOIN products AS pr ON pr.id = oi.product_id
        JOIN product_formats AS pf ON pf.id = pr.format_id
        WHERE oi.order_id = o.id AND pf.name = 'флакон'
    ) AS has_flacon
FROM orders AS o
LEFT JOIN order_totals AS t ON t.order_id = o.id
LEFT JOIN payments AS p ON p.order_id = o.id
LEFT JOIN shipments AS s ON s.order_id = o.id
WHERE o.order_number IN ('ORD-2026-004', 'ORD-2026-005')
ORDER BY o.order_number;

-- 2. Чи є пробник кожного з двох ароматів у повному каталозі.
-- Очікується: Amber Night / Velvet Lab / true;
--             Wood Rain / Velvet Lab / false.
SELECT
    f.name AS fragrance_name,
    b.name AS brand_name,
    EXISTS (
        SELECT 1
        FROM products AS pr
        JOIN product_formats AS pf ON pf.id = pr.format_id
        WHERE pr.fragrance_id = f.id AND pf.name = 'пробник'
    ) AS sample_in_catalog
FROM fragrances AS f
JOIN brands AS b ON b.id = f.brand_id
WHERE b.name = 'Velvet Lab' AND f.name IN ('Amber Night', 'Wood Rain')
ORDER BY f.name;
