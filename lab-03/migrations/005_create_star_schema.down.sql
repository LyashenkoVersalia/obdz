-- Скасування міграції 005_create_star_schema.up.sql.
-- Спочатку видаляється факт, потім виміри.

BEGIN;

DROP TABLE fact_order_items;
DROP TABLE dim_dates;
DROP TABLE dim_products;

COMMIT;