-- Проміжний шар: сирі значення нового підрозділу та причини відбракування.
BEGIN;

CREATE TABLE stage_order_items (
    source_row integer PRIMARY KEY,
    order_id_raw text,
    product_id_raw text,
    ordered_on_raw text,
    fragrance_name_raw text,
    brand_name_raw text,
    format_name_raw text,
    volume_ml_raw text,
    quantity_raw text,
    unit_price_raw text,
    line_amount_raw text
);

CREATE TABLE stage_rejects (
    source_row integer PRIMARY KEY,
    reject_reason text NOT NULL
);

COMMIT;
