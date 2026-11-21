// Лабораторна робота №4. Інтернет-магазин нішевої парфумерії.
// Виконувати у MongoSH MongoDB Compass після окремої команди: use dbsa
// Початкове наповнення: одна команда insertMany, десять замовлень роботи №2.
// _id = orders.id; order_number зберігаємо як бізнес-номер замовлення.
// Вкладені дані вручну складені з початкового seed-data.sql роботи №2.
// order_value = сума quantity * unit_price; це не сума отриманих оплат.
// Дати: ISODate; суми: NumberDecimal; відсутні значення: null.
// Замовлення 7 скасоване, замовлення 10 є чернеткою без позицій.
// Перед першим запуском db.orders.countDocuments() має повернути 0.
// Після запуску окремо виконати db.orders.countDocuments(); очікується 10.
// Повторний insertMany не є upsert і може завершитися E11000 через _id.

db.orders.insertMany([
  {
    _id: 1,
    order_number: "ORD-2026-001",
    ordered_at: ISODate("2026-03-05T10:00:00+02:00"),
    status: "shipped",
    customer: {
      customer_id: 1,
      last_name: "Тестовий-А",
      email: "customer01@example.com",
      phone: "+380000000001"
    },
    items: [
      {
        product_id: 1,
        fragrance_name: "Rose Mist",
        brand_name: "Aroma North",
        volume_ml: 50,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("2400.00")
      },
      {
        product_id: 3,
        fragrance_name: "Rose Mist",
        brand_name: "Aroma North",
        volume_ml: 2,
        format_name: "пробник",
        quantity: 2,
        unit_price: NumberDecimal("170.00")
      }
    ],
    payment: {
      payment_id: 1,
      amount: NumberDecimal("2740.00"),
      paid_at: ISODate("2026-03-05T10:10:00+02:00"),
      status: "paid"
    },
    shipment: {
      shipment_id: 1,
      address: "Навчальна адреса А, пункт 1",
      shipped_at: ISODate("2026-03-06T10:00:00+02:00"),
      status: "shipped"
    },
    order_value: NumberDecimal("2740.00")
  },
  {
    _id: 2,
    order_number: "ORD-2026-002",
    ordered_at: ISODate("2026-03-12T12:30:00+02:00"),
    status: "shipped",
    customer: {
      customer_id: 2,
      last_name: "Тестовий-Б",
      email: "customer02@example.com",
      phone: null
    },
    items: [
      {
        product_id: 4,
        fragrance_name: "Citrus Dawn",
        brand_name: "Aroma North",
        volume_ml: 10,
        format_name: "мініатюра",
        quantity: 1,
        unit_price: NumberDecimal("650.00")
      }
    ],
    payment: {
      payment_id: 2,
      amount: NumberDecimal("650.00"),
      paid_at: ISODate("2026-03-12T12:40:00+02:00"),
      status: "paid"
    },
    shipment: {
      shipment_id: 2,
      address: "Навчальна адреса Б, пункт 2",
      shipped_at: ISODate("2026-03-13T11:00:00+02:00"),
      status: "shipped"
    },
    order_value: NumberDecimal("650.00")
  },
  {
    _id: 3,
    order_number: "ORD-2026-003",
    ordered_at: ISODate("2026-03-20T15:00:00+02:00"),
    status: "shipped",
    customer: {
      customer_id: 3,
      last_name: "Тестовий-В",
      email: "customer03@example.com",
      phone: "+380000000003"
    },
    items: [
      {
        product_id: 5,
        fragrance_name: "Citrus Dawn",
        brand_name: "Aroma North",
        volume_ml: 50,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("2700.00")
      },
      {
        product_id: 7,
        fragrance_name: "Amber Night",
        brand_name: "Velvet Lab",
        volume_ml: 2,
        format_name: "пробник",
        quantity: 1,
        unit_price: NumberDecimal("220.00")
      }
    ],
    payment: {
      payment_id: 3,
      amount: NumberDecimal("2920.00"),
      paid_at: ISODate("2026-03-20T15:10:00+02:00"),
      status: "paid"
    },
    shipment: {
      shipment_id: 3,
      address: "Навчальна адреса В, пункт 3",
      shipped_at: ISODate("2026-03-21T12:00:00+02:00"),
      status: "shipped"
    },
    order_value: NumberDecimal("2920.00")
  },
  {
    _id: 4,
    order_number: "ORD-2026-004",
    ordered_at: ISODate("2026-03-31T18:30:00+03:00"),
    status: "paid",
    customer: {
      customer_id: 1,
      last_name: "Тестовий-А",
      email: "customer01@example.com",
      phone: "+380000000001"
    },
    items: [
      {
        product_id: 6,
        fragrance_name: "Amber Night",
        brand_name: "Velvet Lab",
        volume_ml: 100,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("5200.00")
      }
    ],
    payment: {
      payment_id: 4,
      amount: NumberDecimal("5200.00"),
      paid_at: ISODate("2026-03-31T18:40:00+03:00"),
      status: "paid"
    },
    shipment: null,
    order_value: NumberDecimal("5200.00")
  },
  {
    _id: 5,
    order_number: "ORD-2026-005",
    ordered_at: ISODate("2026-04-01T09:15:00+03:00"),
    status: "new",
    customer: {
      customer_id: 4,
      last_name: "Тестовий-Г",
      email: "customer04@example.com",
      phone: null
    },
    items: [
      {
        product_id: 8,
        fragrance_name: "Wood Rain",
        brand_name: "Velvet Lab",
        volume_ml: 50,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("3100.00")
      }
    ],
    payment: {
      payment_id: 5,
      amount: NumberDecimal("3100.00"),
      paid_at: null,
      status: "pending"
    },
    shipment: null,
    order_value: NumberDecimal("3100.00")
  },
  {
    _id: 6,
    order_number: "ORD-2026-006",
    ordered_at: ISODate("2026-04-05T11:00:00+03:00"),
    status: "new",
    customer: {
      customer_id: 2,
      last_name: "Тестовий-Б",
      email: "customer02@example.com",
      phone: null
    },
    items: [
      {
        product_id: 9,
        fragrance_name: "Wood Rain",
        brand_name: "Velvet Lab",
        volume_ml: 10,
        format_name: "мініатюра",
        quantity: 2,
        unit_price: NumberDecimal("800.00")
      }
    ],
    payment: null,
    shipment: null,
    order_value: NumberDecimal("1600.00")
  },
  {
    _id: 7,
    order_number: "ORD-2026-007",
    ordered_at: ISODate("2026-04-10T14:20:00+03:00"),
    status: "cancelled",
    customer: {
      customer_id: 3,
      last_name: "Тестовий-В",
      email: "customer03@example.com",
      phone: "+380000000003"
    },
    items: [
      {
        product_id: 2,
        fragrance_name: "Rose Mist",
        brand_name: "Aroma North",
        volume_ml: 100,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("4300.00")
      }
    ],
    payment: null,
    shipment: null,
    order_value: NumberDecimal("4300.00")
  },
  {
    _id: 8,
    order_number: "ORD-2026-008",
    ordered_at: ISODate("2026-04-15T16:00:00+03:00"),
    status: "new",
    customer: {
      customer_id: 4,
      last_name: "Тестовий-Г",
      email: "customer04@example.com",
      phone: null
    },
    items: [
      {
        product_id: 3,
        fragrance_name: "Rose Mist",
        brand_name: "Aroma North",
        volume_ml: 2,
        format_name: "пробник",
        quantity: 3,
        unit_price: NumberDecimal("180.00")
      }
    ],
    payment: null,
    shipment: null,
    order_value: NumberDecimal("540.00")
  },
  {
    _id: 9,
    order_number: "ORD-2026-009",
    ordered_at: ISODate("2026-04-30T19:45:00+03:00"),
    status: "new",
    customer: {
      customer_id: 1,
      last_name: "Тестовий-А",
      email: "customer01@example.com",
      phone: "+380000000001"
    },
    items: [
      {
        product_id: 1,
        fragrance_name: "Rose Mist",
        brand_name: "Aroma North",
        volume_ml: 50,
        format_name: "флакон",
        quantity: 1,
        unit_price: NumberDecimal("2500.00")
      },
      {
        product_id: 4,
        fragrance_name: "Citrus Dawn",
        brand_name: "Aroma North",
        volume_ml: 10,
        format_name: "мініатюра",
        quantity: 1,
        unit_price: NumberDecimal("650.00")
      }
    ],
    payment: null,
    shipment: null,
    order_value: NumberDecimal("3150.00")
  },
  {
    _id: 10,
    order_number: "ORD-2026-010",
    ordered_at: ISODate("2026-04-30T20:00:00+03:00"),
    status: "draft",
    customer: {
      customer_id: 2,
      last_name: "Тестовий-Б",
      email: "customer02@example.com",
      phone: null
    },
    items: [],
    payment: null,
    shipment: null,
    order_value: NumberDecimal("0.00")
  }
]);
