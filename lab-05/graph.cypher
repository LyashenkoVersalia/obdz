// Лабораторна робота №5. Інтернет-магазин нішевої парфумерії.
// Один запит: скопіювати ВЕСЬ файл у верхній редактор Neo4j Browser і виконати.
// Джерело об'єктів і подій: початкові дані lab-02/seed-data.sql.
// Перевірені замовлення: ORD-2026-004 та ORD-2026-005.
// SIMILAR_TO — додані навчальні оцінки консультанта, а не дані PostgreSQL.
// Схожість не є транзитивною: шлях у два кроки дає варіанти для розгляду,
// а не доводить пряму схожість першого та останнього ароматів.
// Очікується 11 вершин і 11 зв'язків у початково порожньому графі.
// Після кожного з двох послідовних запусків кількості перевірити ОКРЕМО.
// Набори властивостей незмінні; значення null у шаблонах не записуємо.
// Ціни цього фрагмента задані цілими гривнями без втрати дробової частини:
// усі обрані ціни джерела мають копійки .00.

// 1. Два покупці. Природний ідентифікатор — унікальний email.
MERGE (customer1:Customer {
    email: 'customer01@example.com',
    last_name: 'Тестовий-А',
    phone: '+380000000001'
})
MERGE (customer4:Customer {
    email: 'customer04@example.com',
    last_name: 'Тестовий-Г'
})

// 2. Два замовлення. Природний ідентифікатор — order_number.
MERGE (order4:Order {
    order_number: 'ORD-2026-004',
    ordered_at: datetime('2026-03-31T18:30:00+03:00'),
    status: 'paid'
})
MERGE (order5:Order {
    order_number: 'ORD-2026-005',
    ordered_at: datetime('2026-04-01T09:15:00+03:00'),
    status: 'new'
})

// 3. Один бренд. Ідентифікатор — brand_name.
MERGE (velvet:Brand {brand_name: 'Velvet Lab'})

// 4. Три аромати. Ідентифікатор — пара brand_name, fragrance_name.
MERGE (amber:Fragrance {
    brand_name: 'Velvet Lab',
    fragrance_name: 'Amber Night'
})
MERGE (wood:Fragrance {
    brand_name: 'Velvet Lab',
    fragrance_name: 'Wood Rain'
})
MERGE (vanilla:Fragrance {
    brand_name: 'Serein Atelier',
    fragrance_name: 'Vanilla Cloud'
})

// 5. Три товарні варіанти. Складений природний ідентифікатор:
// brand_name, fragrance_name, volume_ml, format_name.
MERGE (amberBottle:Product {
    brand_name: 'Velvet Lab',
    fragrance_name: 'Amber Night',
    volume_ml: 100,
    format_name: 'флакон',
    price: 5200
})
MERGE (amberSample:Product {
    brand_name: 'Velvet Lab',
    fragrance_name: 'Amber Night',
    volume_ml: 2,
    format_name: 'пробник',
    price: 220
})
MERGE (woodBottle:Product {
    brand_name: 'Velvet Lab',
    fragrance_name: 'Wood Rain',
    volume_ml: 50,
    format_name: 'флакон',
    price: 3100
})

// 6. Два зв'язки покупець — замовлення.
MERGE (customer1)-[:PLACED]->(order4)
MERGE (customer4)-[:PLACED]->(order5)

// 7. Дві позиції замовлень. Історична ціна належить саме позиції.
MERGE (order4)-[:CONTAINS {quantity: 1, unit_price: 5200}]->(amberBottle)
MERGE (order5)-[:CONTAINS {quantity: 1, unit_price: 3100}]->(woodBottle)

// 8. Три зв'язки товар — аромат.
MERGE (amberBottle)-[:OF_FRAGRANCE]->(amber)
MERGE (amberSample)-[:OF_FRAGRANCE]->(amber)
MERGE (woodBottle)-[:OF_FRAGRANCE]->(wood)

// 9. Два зв'язки аромат — бренд для обраного фрагмента каталогу.
// Бренд Serein Atelier не включено окремою вершиною до цього фрагмента.
MERGE (amber)-[:BY_BRAND]->(velvet)
MERGE (wood)-[:BY_BRAND]->(velvet)

// 10. Дві нові оцінки схожості. У запиті про схожість напрям ігноруємо.
MERGE (amber)-[:SIMILAR_TO {
    assessment_source: 'Навчальна оцінка консультанта'
}]->(wood)
MERGE (wood)-[:SIMILAR_TO {
    assessment_source: 'Навчальна оцінка консультанта'
}]->(vanilla)

RETURN 'Завантаження завершено. Перевірте кількості окремими запитами.' AS message;
