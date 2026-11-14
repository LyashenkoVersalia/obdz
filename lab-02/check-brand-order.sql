-- Перевірка перестановки брендів і повторного наповнення.
-- Використовуються тимчасові таблиці в одній транзакції.
BEGIN;

CREATE TEMP TABLE brands (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
) ON COMMIT DROP;

CREATE TEMP TABLE fragrances (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id bigint NOT NULL
        REFERENCES pg_temp.brands (id) ON DELETE RESTRICT,
    name text NOT NULL,
    description text,
    UNIQUE (brand_id, name)
) ON COMMIT DROP;

-- 1. Бренди. Четвертий бренд поки не має ароматів.
INSERT INTO brands (name)
VALUES
    ('Velvet Lab'),
    ('Aroma North'),
    ('Serein Atelier'),
    ('Amber Studio')
ON CONFLICT (name) DO NOTHING;


-- 3. Аромати. Бренд визначається за унікальною назвою.
-- Зв'язок не залежить від порядку додавання брендів.
-- Для частини ароматів опис не заповнено.
INSERT INTO fragrances (brand_id, name, description)
VALUES
    (
        (SELECT id FROM brands WHERE name = 'Aroma North'),
        'Rose Mist',
        'Квітковий аромат із нотами троянди'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Aroma North'),
        'Citrus Dawn',
        'Свіжий цитрусовий аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Velvet Lab'),
        'Amber Night',
        'Теплий амбровий аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Velvet Lab'),
        'Wood Rain',
        NULL
    ),
    (
        (SELECT id FROM brands WHERE name = 'Serein Atelier'),
        'Vanilla Cloud',
        'М’який ванільний аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Serein Atelier'),
        'Iris Light',
        NULL
    )
ON CONFLICT (brand_id, name) DO NOTHING;


-- 1. Бренди. Четвертий бренд поки не має ароматів.
INSERT INTO brands (name)
VALUES
    ('Velvet Lab'),
    ('Aroma North'),
    ('Serein Atelier'),
    ('Amber Studio')
ON CONFLICT (name) DO NOTHING;


-- 3. Аромати. Бренд визначається за унікальною назвою.
-- Зв'язок не залежить від порядку додавання брендів.
-- Для частини ароматів опис не заповнено.
INSERT INTO fragrances (brand_id, name, description)
VALUES
    (
        (SELECT id FROM brands WHERE name = 'Aroma North'),
        'Rose Mist',
        'Квітковий аромат із нотами троянди'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Aroma North'),
        'Citrus Dawn',
        'Свіжий цитрусовий аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Velvet Lab'),
        'Amber Night',
        'Теплий амбровий аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Velvet Lab'),
        'Wood Rain',
        NULL
    ),
    (
        (SELECT id FROM brands WHERE name = 'Serein Atelier'),
        'Vanilla Cloud',
        'М’який ванільний аромат'
    ),
    (
        (SELECT id FROM brands WHERE name = 'Serein Atelier'),
        'Iris Light',
        NULL
    )
ON CONFLICT (brand_id, name) DO NOTHING;


-- Перевірка після двох запусків наповнення.
SELECT
    f.name AS fragrance_name,
    b.id AS brand_id,
    b.name AS actual_brand,
    e.brand_name AS expected_brand,
    b.name = e.brand_name AS correct_brand,
    (SELECT count(*) FROM pg_temp.brands) AS brands_count,
    (SELECT count(*) FROM pg_temp.fragrances) AS fragrances_count
FROM pg_temp.fragrances AS f
JOIN pg_temp.brands AS b
    ON b.id = f.brand_id
JOIN (
    VALUES
        ('Rose Mist', 'Aroma North'),
        ('Citrus Dawn', 'Aroma North'),
        ('Amber Night', 'Velvet Lab'),
        ('Wood Rain', 'Velvet Lab'),
        ('Vanilla Cloud', 'Serein Atelier'),
        ('Iris Light', 'Serein Atelier')
) AS e (fragrance_name, brand_name)
    ON e.fragrance_name = f.name
ORDER BY f.id;

ROLLBACK;