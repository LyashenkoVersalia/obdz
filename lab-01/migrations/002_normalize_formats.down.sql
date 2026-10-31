ALTER TABLE customers
    DROP CONSTRAINT customers_email_key;

ALTER TABLE customers
    ALTER COLUMN email DROP NOT NULL;

ALTER TABLE products
    ADD COLUMN format text;

UPDATE products AS p
SET format = pf.name
FROM product_formats AS pf
WHERE p.format_id = pf.id;

ALTER TABLE products
    ALTER COLUMN format SET NOT NULL;

ALTER TABLE products
    DROP CONSTRAINT products_format_id_fkey;

ALTER TABLE products
    DROP COLUMN format_id;

DROP TABLE product_formats;