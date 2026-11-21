// Лабораторна робота №4. Операції над документами замовлень.
// Виконувати БЛОКАМИ в MongoSH Compass після окремої команди: use dbsa
// Початковий стан: десять документів із load-documents.js.
// Наведені відповіді підтверджено виконанням у MongoSH; скриншоти — у README, розділ 6.
// Тимчасова подія _id = 11001 існує лише для досліду CRUD і потім видаляється.
// PostgreSQL цими командами не змінюється.

// 0. Перевірка початкового стану. Очікується 10.
db.orders.countDocuments();

// 1. Читання з умовою: які замовлення мають хоча б одну позицію?
// Це відбір карток, представлених позиціями у запиті «З'єднання 2» роботи №2.
// Вихідний SQL з'єднував дев'ять таблиць і повертав 12 рядків позицій.
// Тут повертаємо дев'ять коротких карток замовлень; чернетка 10 не входить.
// Умова перевіряє один шлях: існування першого елемента items.
db.orders.find(
  { "items.0": { $exists: true } },
  { _id: 1, order_number: 1 }
).sort({ _id: 1 }).toArray();

// 2. Читання за вкладеним полем із проєкцією.
// Показати замовлення покупця customer01@example.com.
// Фактично отримано _id 1, 4, 9 із сумами 2740.00, 5200.00, 3150.00 грн.
db.orders.find(
  { "customer.email": "customer01@example.com" },
  { _id: 1, order_number: 1, "customer.email": 1, order_value: 1 }
).sort({ _id: 1 }).toArray();

// 3. Створення нової навчальної події, якої не було серед десяти вихідних.
// Відвантаження ще не виконано: shipment.shipped_at = null.
// Фактично отримано acknowledged: true, insertedId: 11001.
db.orders.insertOne({
  _id: 11001,
  order_number: "LAB4-TEST-001",
  ordered_at: ISODate("2026-05-01T10:00:00+03:00"),
  status: "new",
  customer: {
    customer_id: 1,
    last_name: "Тестовий-А",
    email: "customer01@example.com",
    phone: "+380000000001"
  },
  items: [
    {
      product_id: 3,
      fragrance_name: "Rose Mist",
      brand_name: "Aroma North",
      volume_ml: 2,
      format_name: "пробник",
      quantity: 1,
      unit_price: NumberDecimal("180.00")
    }
  ],
  payment: null,
  shipment: {
    shipment_id: null,
    address: "Навчальна адреса А, пункт 1",
    shipped_at: null,
    status: "pending"
  },
  order_value: NumberDecimal("180.00")
});

// 4. Кількість після вставки. Очікується 11.
db.orders.countDocuments();

// 5. Оновлення лише тимчасового документа: фіксуємо навчальне відвантаження.
// Фактично отримано matchedCount: 1, modifiedCount: 1.
db.orders.updateOne(
  { _id: 11001 },
  { $set: {
      "shipment.shipped_at": ISODate("2026-05-02T11:00:00+03:00"),
      "shipment.status": "shipped",
      status: "shipped"
  } }
);

// 6. Перевірка зміни: повертаємо лише номер і стан відвантаження.
db.orders.findOne(
  { _id: 11001 },
  { _id: 1, order_number: 1, status: 1, "shipment.shipped_at": 1, "shipment.status": 1 }
);

// 7. Кількість безпосередньо перед видаленням. Очікується 11.
db.orders.countDocuments();

// 8. Прибираємо помилково створене навчальне замовлення.
// Фактично отримано acknowledged: true, deletedCount: 1.
db.orders.deleteOne({ _id: 11001 });

// 9. Після видалення має лишитися початкова кількість 10.
db.orders.countDocuments();

// 10. Тимчасового документа більше немає. Очікується null.
db.orders.findOne({ _id: 11001 });

// Додаткова фактична перевірка після очищення: 9 замовлень із позиціями.
db.orders.countDocuments({ "items.0": { $exists: true } });
