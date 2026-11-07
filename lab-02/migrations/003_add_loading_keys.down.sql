-- Скасування міграції 003_add_loading_keys.up.sql.
-- Видалення номера замовлення також видаляє його значення.
-- Перевірка виконується до наповнення таблиць.

BEGIN;

ALTER TABLE orders
    DROP CONSTRAINT orders_order_number_key;

ALTER TABLE orders
    DROP COLUMN order_number;

ALTER TABLE products
    DROP CONSTRAINT products_fragrance_volume_format_key;

ALTER TABLE fragrances
    DROP CONSTRAINT fragrances_brand_id_name_key;

COMMIT;