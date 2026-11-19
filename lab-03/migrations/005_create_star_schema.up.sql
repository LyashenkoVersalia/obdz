-- Сховище: два виміри та факти позицій замовлень.
-- Спочатку створюються виміри, потім таблиця фактів.

BEGIN;

CREATE TABLE dim_products (
    product_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_product_id bigint NOT NULL UNIQUE,
    fragrance_name text NOT NULL,
    brand_name text NOT NULL,
    format_name text NOT NULL,
    volume_ml numeric(8, 2) NOT NULL CHECK (volume_ml > 0)
);

CREATE TABLE dim_dates (
    date_key date PRIMARY KEY,
    year_number integer NOT NULL,
    month_label text NOT NULL,
    day_of_week integer NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    is_weekend boolean NOT NULL
);

CREATE TABLE fact_order_items (
    order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_key bigint NOT NULL
        REFERENCES dim_products (product_key) ON DELETE RESTRICT,
    date_key date NOT NULL
        REFERENCES dim_dates (date_key) ON DELETE RESTRICT,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12, 2) NOT NULL CHECK (unit_price > 0),
    line_amount numeric(24, 2) NOT NULL CHECK (line_amount > 0),
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fact_order_items_amount_matches_quantity_price
        CHECK (line_amount = quantity * unit_price)
);

COMMIT;