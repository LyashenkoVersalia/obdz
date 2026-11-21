-- Лабораторна робота №4. Перевірка вихідних даних перед MongoDB.
-- Виконувати окремими запитами в PostgreSQL, база dbsa.
SELECT current_database() AS database_name,
       'brands' AS table_name, count(*) AS row_count FROM brands
UNION ALL SELECT current_database(), 'customers', count(*) FROM customers
UNION ALL SELECT current_database(), 'fragrances', count(*) FROM fragrances
UNION ALL SELECT current_database(), 'product_formats', count(*) FROM product_formats
UNION ALL SELECT current_database(), 'products', count(*) FROM products
UNION ALL SELECT current_database(), 'orders', count(*) FROM orders
UNION ALL SELECT current_database(), 'order_items', count(*) FROM order_items
UNION ALL SELECT current_database(), 'payments', count(*) FROM payments
UNION ALL SELECT current_database(), 'shipments', count(*) FROM shipments;

-- Очікується 10 замовлень; замовлення 10 без позицій має суму 0.
SELECT o.id, o.order_number, c.email, o.status,
       count(oi.product_id) AS line_count,
       coalesce(sum(oi.quantity * oi.unit_price), 0) AS order_value
FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id
LEFT JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY o.id, o.order_number, c.email, o.status
ORDER BY o.id;
