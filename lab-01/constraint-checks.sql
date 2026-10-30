-- constraint-checks.sql
-- Кожну перевірку виконувати окремо.
-- Очікуваний результат кожної команди — помилка обмеження.
-- Після відхилення команди доданих рядків не залишається.

-- 1. Правило 1: назва бренду обов'язкова (NOT NULL).
-- Очікувано: null value in column "name" of relation "brands"
-- violates not-null constraint
INSERT INTO brands (name)
VALUES (NULL);

-- 2. Правило 1: назва бренду унікальна (UNIQUE).
-- Очікувано: duplicate key value violates unique constraint
-- "brands_name_key"
INSERT INTO brands (name)
VALUES ('Тестовий бренд'),
       ('Тестовий бренд');

-- 3. Правило 4: ціна товару більша за нуль (CHECK).
-- Очікувано: new row for relation "products"
-- violates check constraint "products_price_check"
INSERT INTO products (fragrance_id, volume_ml, format, price)
VALUES (999999, 50, 'флакон', -100);

-- 4. Правило 2: аромат належить наявному бренду (REFERENCES).
-- Очікувано: insert or update on table "fragrances"
-- violates foreign key constraint "fragrances_brand_id_fkey"
INSERT INTO fragrances (brand_id, name)
VALUES (999999, 'Тестовий аромат');

-- 5. Первинний ключ бренду не може повторюватися (PRIMARY KEY).
-- Назви різні, щоб перевірити саме первинний ключ.
-- Очікувано: duplicate key value violates unique constraint
-- "brands_pkey"
INSERT INTO brands (id, name)
OVERRIDING SYSTEM VALUE
VALUES (900001, 'Перший тестовий бренд'),
       (900001, 'Другий тестовий бренд');