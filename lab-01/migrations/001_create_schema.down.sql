-- 001_create_schema.down.sql
-- Скасування створення схеми інтернет-магазину парфумерії.
-- Таблиці видаляються у зворотному порядку створення.

DROP TABLE shipments;
DROP TABLE payments;
DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE customers;
DROP TABLE products;
DROP TABLE fragrances;
DROP TABLE brands;