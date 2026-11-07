-- Ключі для безпечного повторного наповнення.
-- Міграція виконується до завантаження даних.
-- Назва аромату унікальна в межах бренду.
-- Товар визначається ароматом, обсягом і форматом.
-- Кожне замовлення має власний унікальний номер.

BEGIN;

ALTER TABLE fragrances
    ADD CONSTRAINT fragrances_brand_id_name_key
    UNIQUE (brand_id, name);

ALTER TABLE products
    ADD CONSTRAINT products_fragrance_volume_format_key
    UNIQUE (fragrance_id, volume_ml, format_id);

ALTER TABLE orders
    ADD COLUMN order_number text NOT NULL;

ALTER TABLE orders
    ADD CONSTRAINT orders_order_number_key
    UNIQUE (order_number);

COMMIT;