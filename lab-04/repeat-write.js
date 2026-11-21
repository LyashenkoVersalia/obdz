// Лабораторна робота №4. Повторний запис та upsert.
// Виконувати ОКРЕМИМИ БЛОКАМИ в MongoSH після: use dbsa
// Початковий стан: 10 вихідних замовлень, тимчасового _id 11001 вже немає.
// Вставка в блоці 2 НАВМИСНО завершується E11000. Після неї продовжити
// наступним блоком вручну; весь файл автоматично як один скрипт не запускати.
// Відповіді підтверджено виконанням у MongoSH; скриншоти — у README, розділ 7.

// 1. Запам'ятати справжній перший документ; перевірити кількість.
var lab04OrderForRepeat = db.orders.findOne({ _id: 1 });
db.orders.countDocuments(); // Фактично отримано 10.

// 2. Спроба вставити точну копію документа з тим самим _id.
// Фактично отримано E11000 duplicate key error. Повний текст помилки зберегти у звіт.
db.orders.insertOne(lab04OrderForRepeat);

// 3. Переконатися, що помилка не змінила кількість: фактично отримано 10.
db.orders.countDocuments();

var lab04RepeatFields = {
  order_number: lab04OrderForRepeat.order_number,
  ordered_at: lab04OrderForRepeat.ordered_at,
  status: lab04OrderForRepeat.status,
  customer: lab04OrderForRepeat.customer,
  items: lab04OrderForRepeat.items,
  payment: lab04OrderForRepeat.payment,
  shipment: lab04OrderForRepeat.shipment,
  order_value: lab04OrderForRepeat.order_value
};

// 4. Перший upsert тієї самої картки за тим самим _id.
// Документ уже існує й значення не змінюються:
// Фактично: matchedCount: 1, modifiedCount: 0, upsertedCount: 0.
db.orders.updateOne(
  { _id: 1 },
  { $set: lab04RepeatFields },
  { upsert: true }
);

// 5. Кількість після першого upsert: фактично отримано 10.
db.orders.countDocuments();

// 6. Другий ідентичний upsert. Фактично отримано ті самі лічильники: 1, 0, 0.
db.orders.updateOne(
  { _id: 1 },
  { $set: lab04RepeatFields },
  { upsert: true }
);

// 7. Кількість після другого upsert: фактично отримано 10.
db.orders.countDocuments();

// Це повторний запис без дублювання. Гілка вставки upsert у цьому досліді
// не спрацьовує: документ з _id 1 уже існує. Якби його не було, upsert
// створив би його з умовою _id і всіма вісьмома полями із $set.

// Після двох upsert кількість документів із позиціями: фактично 9.
db.orders.countDocuments({ "items.0": { $exists: true } });
