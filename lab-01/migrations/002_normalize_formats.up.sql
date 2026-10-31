-- Довідник можливих форматів товару.
CREATE TABLE product_formats (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

INSERT INTO product_formats (name)
VALUES
    ('флакон'),
    ('мініатюра'),
    ('пробник');

-- Заміна текстового формату зовнішнім ключем.
ALTER TABLE products
    ADD COLUMN format_id bigint;

-- Перенесення наявних значень формату до довідника.
INSERT INTO product_formats (name)
SELECT DISTINCT lower(trim(format))
FROM products
ON CONFLICT (name) DO NOTHING;

UPDATE products AS p
SET format_id = pf.id
FROM product_formats AS pf
WHERE lower(trim(p.format)) = pf.name;

ALTER TABLE products
    ALTER COLUMN format_id SET NOT NULL,
    ADD CONSTRAINT products_format_id_fkey
        FOREIGN KEY (format_id)
        REFERENCES product_formats (id)
        ON DELETE RESTRICT;

ALTER TABLE products
    DROP COLUMN format;

-- Унікальна ідентифікація покупця.
ALTER TABLE customers
    ALTER COLUMN email SET NOT NULL;

ALTER TABLE customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);