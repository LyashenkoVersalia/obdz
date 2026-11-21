// Лабораторна робота №4. Схема на читанні та помилка в назві поля.
// Виконувати ОКРЕМИМИ БЛОКАМИ в MongoSH після: use dbsa
// Колекція product_cards: три демонстраційні картки різної повноти.
// Це підмножина каталогу, а не повне копіювання десяти товарів PostgreSQL.
// Значення взято з початкового seed-data.sql роботи №2:
// продукт 1 — Rose Mist, Aroma North; продукт 4 — Citrus Dawn, 10 мл;
// продукт 3 — Rose Mist, пробник, поточна ціна 180.00 грн.
// Відсутні поля тут навмисно НЕ додаються: це дослід різної форми.
// Робоча схема PostgreSQL і колекція orders не змінюються.

// 0. До першого запуску фактично отримано 0.
db.product_cards.countDocuments();

// 1. Базова картка: _id, fragrance_name, brand_name.
// Фактично отримано acknowledged: true, insertedId: 1.
db.product_cards.insertOne({
  _id: 1,
  fragrance_name: "Rose Mist",
  brand_name: "Aroma North"
});

// 2. Базові поля й одна додаткова характеристика volume_ml.
// Фактично отримано acknowledged: true, insertedId: 4.
db.product_cards.insertOne({
  _id: 4,
  fragrance_name: "Citrus Dawn",
  brand_name: "Aroma North",
  volume_ml: 10
});

// 3. Базові поля й дві додаткові характеристики format_name і price.
// Фактично отримано acknowledged: true, insertedId: 3.
db.product_cards.insertOne({
  _id: 3,
  fragrance_name: "Rose Mist",
  brand_name: "Aroma North",
  format_name: "пробник",
  price: NumberDecimal("180.00")
});

// 4. Фактично отримано 3 картки різної форми.
db.product_cards.find().sort({ _id: 1 }).toArray();
db.product_cards.countDocuments();

// 5. Навмисна помилка: brand_nam замість brand_name.
// Це навчальна картка продукту 6 Amber Night / Velvet Lab.
// Без валідатора MongoDB прийме інше ім'я поля.
// Фактично отримано acknowledged: true, insertedId: 6.
db.product_cards.insertOne({
  _id: 6,
  fragrance_name: "Amber Night",
  brand_nam: "Velvet Lab"
});

// 6. Фактично отримано 4: помилкова картка справді записана.
db.product_cards.countDocuments();

// 7. Пошук за правильним полем. Фактично отримано [], хоча картку Velvet Lab додано.
db.product_cards.find({ brand_name: "Velvet Lab" }).toArray();

// 8. Перевірка за _id знаходить документ і показує помилкове brand_nam.
db.product_cards.findOne({ _id: 6 });

// 9. Прибрати помилковий документ. Фактично отримано deletedCount: 1.
db.product_cards.deleteOne({ _id: 6 });

// 10. Фактично отримано 3 правильні картки; помилкова відсутня.
db.product_cards.countDocuments();
db.product_cards.findOne({ _id: 6 }); // Фактично отримано null.

// 11. Початкових замовлень як і раніше 10.
db.orders.countDocuments();

// Порівняння для звіту, НЕ команда до робочого PostgreSQL:
// якби окрема плоска таблиця product_cards спочатку містила лише
// id, fragrance_name, brand_name, для цих форм знадобилися б 3 поля:
// ALTER TABLE product_cards ADD COLUMN volume_ml numeric(8, 2);
// ALTER TABLE product_cards ADD COLUMN format_name text;
// ALTER TABLE product_cards ADD COLUMN price numeric(12, 2);
// Кожне додаткове поле заповнене в 1 рядку з 3, NULL у 2 рядках з 3.
// Разом 6 NULL із 9 клітинок трьох додаткових стовпців.
// Це умовне порівняння окремої базової картки. У чинній схемі products
// уже має volume_ml, price і format_id, тому нові міграції тут не потрібні.
