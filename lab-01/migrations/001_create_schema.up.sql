-- 001_create_schema.up.sql
-- Створення схеми інтернет-магазину парфумерії:
-- таблиці, первинні й зовнішні ключі та обмеження цілісності.

-- Бренди: назва обов'язкова та унікальна.
CREATE TABLE brands (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

-- Кожен аромат належить одному наявному бренду.
CREATE TABLE fragrances (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id bigint NOT NULL
        REFERENCES brands (id) ON DELETE RESTRICT,
    name text NOT NULL,
    description text
);

-- Товарний варіант аромату з додатними об'ємом і ціною.
CREATE TABLE products (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fragrance_id bigint NOT NULL
        REFERENCES fragrances (id) ON DELETE RESTRICT,
    volume_ml numeric(8, 2) NOT NULL CHECK (volume_ml > 0),
    format text NOT NULL,
    price numeric(12, 2) NOT NULL CHECK (price > 0)
);

-- Покупці: телефон та електронна пошта не є ключами.
CREATE TABLE customers (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name text NOT NULL,
    email text,
    phone text
);

-- Кожне замовлення належить одному наявному покупцю.
CREATE TABLE orders (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint NOT NULL
        REFERENCES customers (id) ON DELETE RESTRICT,
    ordered_at timestamptz NOT NULL,
    status text NOT NULL
);

-- Один товар може бути в одному замовленні лише один раз.
-- Позиції видаляються разом із замовленням, якщо його видалення дозволене.
CREATE TABLE order_items (
    order_id bigint NOT NULL
        REFERENCES orders (id) ON DELETE CASCADE,
    product_id bigint NOT NULL
        REFERENCES products (id) ON DELETE RESTRICT,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12, 2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);

-- Для замовлення допускається не більше одного запису оплати.
CREATE TABLE payments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id bigint NOT NULL UNIQUE
        REFERENCES orders (id) ON DELETE RESTRICT,
    amount numeric(12, 2) NOT NULL,
    paid_at timestamptz,
    status text NOT NULL
);

-- Для замовлення допускається не більше одного запису доставки.
CREATE TABLE shipments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id bigint NOT NULL UNIQUE
        REFERENCES orders (id) ON DELETE RESTRICT,
    address text NOT NULL,
    shipped_at timestamptz,
    status text NOT NULL
);