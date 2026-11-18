-- Індекс за зовнішнім ключем покупця.
-- Прискорює пошук замовлень одного покупця.
-- REFERENCES сам по собі не створює індекс на orders.customer_id.

CREATE INDEX orders_customer_id_idx
    ON orders (customer_id);