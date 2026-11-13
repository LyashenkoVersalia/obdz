-- Лабораторна робота №2. Досліди з двома незалежними сеансами.
-- Обидва сеанси підключені до бази dbsa.
-- Сеанс А: Script-4. Сеанс Б: Script-5.
--
-- Команди виконуються окремо у відповідному сеансі
-- у порядку кроків. Увесь файл одним запуском не виконувати.
-- Перед кожним дослідом попередні транзакції обох сеансів
-- мають бути завершені.
--
-- Об'єкт: products.price, товар з id = 1.
-- Початкова ціна: 2500.
-- Сеанс А зменшує ціну на 10 %.
-- Сеанс Б підвищує ціну на 300 грн.
-- Очікуваний результат для порядку А, потім Б:
-- 2500 * 0.90 + 300 = 2550.


-- Дослід 1. READ COMMITTED: запис готових значень.

-- Крок 0. Сеанс А: підготовка початкової ціни.
BEGIN;
UPDATE products SET price = 2500 WHERE id = 1;
COMMIT;

-- Крок 1. Сеанс А.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT id, price FROM products WHERE id = 1;
-- Результат: 2500.

-- Крок 2. Сеанс Б.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT id, price FROM products WHERE id = 1;
-- Результат: 2500.

-- Крок 3. Сеанс А: 2500 * 0.90 = 2250.
UPDATE products SET price = 2250 WHERE id = 1;
-- Updated Rows: 1. Транзакція залишається відкритою.

-- Крок 4. Сеанс Б: розрахунок за раніше прочитаною ціною.
UPDATE products SET price = 2800 WHERE id = 1;
-- Команда чекає на завершення транзакції сеансу А.

-- Крок 5. Сеанс А.
COMMIT;
-- Після цього UPDATE сеансу Б завершується:
-- Updated Rows: 1.

-- Крок 6. Сеанс Б.
COMMIT;
SELECT id, price FROM products WHERE id = 1;
-- Фактичний результат: 2800 замість 2550.
-- Зміну сеансу А втрачено.


-- Дослід 2. REPEATABLE READ: помилка і повтор транзакції.

-- Крок 0. Сеанс А: підготовка початкової ціни.
BEGIN;
UPDATE products SET price = 2500 WHERE id = 1;
COMMIT;

-- Крок 1. Сеанс А.
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
-- Результат: repeatable read.
SELECT id, price FROM products WHERE id = 1;
-- Результат: 2500.

-- Крок 2. Сеанс Б.
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
-- Результат: repeatable read.
SELECT id, price FROM products WHERE id = 1;
-- Результат: 2500.

-- Крок 3. Сеанс А.
UPDATE products SET price = 2250 WHERE id = 1;
-- Updated Rows: 1.

-- Крок 4. Сеанс Б.
UPDATE products SET price = 2800 WHERE id = 1;
-- Команда чекає на завершення транзакції сеансу А.

-- Крок 5. Сеанс А.
COMMIT;
-- У сеансі Б виникає очікувана помилка:
-- SQL Error [40001]:
-- ERROR: could not serialize access due to concurrent update.

-- Крок 6. Сеанс Б: завершення невдалої транзакції.
ROLLBACK;

-- Крок 7. Сеанс Б: повтор транзакції з новим читанням.
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
SELECT id, price FROM products WHERE id = 1;
-- Результат: 2250.

-- Крок 8. Сеанс Б: новий розрахунок 2250 + 300 = 2550.
UPDATE products SET price = 2550 WHERE id = 1;
COMMIT;

-- Крок 9. Сеанс А: перевірка з іншого сеансу.
SELECT id, price FROM products WHERE id = 1;
-- Фактичний результат: 2550. Обидві зміни збережено.


-- Дослід 3. READ COMMITTED: зміна відносно поточного значення.

-- Крок 0. Сеанс А: підготовка початкової ціни.
BEGIN;
UPDATE products SET price = 2500 WHERE id = 1;
COMMIT;

-- Крок 1. Сеанс А.
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
SELECT id, price FROM products WHERE id = 1;
-- Рівень: read committed. Ціна: 2500.

-- Крок 2. Сеанс Б.
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;
SELECT id, price FROM products WHERE id = 1;
-- Рівень: read committed. Ціна: 2500.

-- Крок 3. Сеанс А: обчислення всередині UPDATE.
UPDATE products
SET price = round(price * 0.90, 2)
WHERE id = 1;
-- Updated Rows: 1.

-- Крок 4. Сеанс Б: обчислення всередині UPDATE.
UPDATE products
SET price = price + 300
WHERE id = 1;
-- Команда чекає на завершення транзакції сеансу А.

-- Крок 5. Сеанс А.
COMMIT;
-- UPDATE сеансу Б завершується успішно: Updated Rows: 1.
-- До вже змінених 2250 додається 300.

-- Крок 6. Сеанс Б.
COMMIT;

-- Крок 7. Сеанс А: перевірка з іншого сеансу.
SELECT id, price FROM products WHERE id = 1;
-- Фактичний результат: 2550.
-- Обидві зміни збережено без помилки серіалізації.

-- Крок 8. Сеанс А: відновлення початкових даних після дослідів.
BEGIN;
UPDATE products SET price = 2500 WHERE id = 1;
COMMIT;

SELECT id, price FROM products WHERE id = 1;
-- Результат: 2500.