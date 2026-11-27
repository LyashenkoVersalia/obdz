// Лабораторна робота №5. Три запити до графа магазину парфумерії.
// Виконувати запити ОКРЕМО в Neo4j Browser після graph.cypher.
// Виконано 27.11.2026. Усі три фактичні відповіді збіглися з очікуваними.

// Запит 1. Які позиції замовлень мають ціну одиниці від 3000 грн?
// WHERE перевіряє unit_price — властивість зв'язку CONTAINS.
// Очікується: ORD-2026-004 / Amber Night / 100 / 1 / 5200;
//             ORD-2026-005 / Wood Rain / 50 / 1 / 3100.
// Фактичний результат: ORD-2026-004 / Amber Night / 100 / 1 / 5200;
//                     ORD-2026-005 / Wood Rain / 50 / 1 / 3100.
MATCH (o:Order)-[i:CONTAINS]->(p:Product)
WHERE i.unit_price >= 3000
RETURN o.order_number AS order_number,
       p.fragrance_name AS fragrance,
       p.volume_ml AS volume_ml,
       i.quantity AS quantity,
       i.unit_price AS unit_price
ORDER BY order_number;

// Запит 2. Які аромати досяжні від Amber Night за 1-2 зв'язки схожості?
// Напрям SIMILAR_TO ігноруємо; шлях у два кроки не доводить пряму схожість.
// Очікується: Wood Rain / Velvet Lab / 1;
//             Vanilla Cloud / Serein Atelier / 2.
// Фактичний результат: Wood Rain / Velvet Lab / 1; Vanilla Cloud / Serein Atelier / 2.
MATCH path = (f:Fragrance {
    brand_name: 'Velvet Lab', fragrance_name: 'Amber Night'
})-[:SIMILAR_TO*1..2]-(other:Fragrance)
RETURN other.fragrance_name AS fragrance,
       other.brand_name AS brand,
       length(path) AS steps
ORDER BY steps, fragrance;

// Запит 3. У яких замовленнях є хоча б одна позиція формату флакон?
// Перевіряється умова П6 бази правил 1.0.
// Очікується: ORD-2026-004 / 1; ORD-2026-005 / 1.
// Фактичний результат: ORD-2026-004 / 1; ORD-2026-005 / 1.
// Рахуємо позиції, а не суму одиниць товару.
MATCH (o:Order)-[i:CONTAINS]->(p:Product)
WHERE p.format_name = 'флакон'
WITH o, count(i) AS flacon_positions
WHERE flacon_positions >= 1
RETURN o.order_number AS order_number, flacon_positions
ORDER BY order_number;
