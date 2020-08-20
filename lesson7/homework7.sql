# Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

CREATE DATABASE IF NOT EXISTS HW7;
ALTER DATABASE HW7 CHARACTER SET utf8 COLLATE utf8_general_ci;
USE HW7;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Gena', '1990-10-05'),
  ('Natasha', '1984-11-12'),
  ('Alexandr', '1985-05-20'),
  ('Sergey', '1988-02-14'),
  ('Ivan', '1998-01-12'),
  ('Maria', '1992-08-29');
 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Заказы';

ALTER TABLE orders
ADD FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE CASCADE;

INSERT INTO orders (user_id) VALUES
  (2),
  (3),
  (4);

# Два варианта решения. Второй вариант быстрее и более правилен. 
 
SELECT name, birthday_at
FROM users, orders
WHERE users.id = orders.user_id;

SELECT name
FROM users
JOIN orders
ON users.id = orders.user_id;

ALTER TABLE orders
DROP FOREIGN KEY orders_ibfk_1;

# Выведите список товаров products и разделов catalogs, который соответствует товару.

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Processors'),
  (NULL, 'Motherboards'),
  (NULL, 'Video Cards'),
  (NULL, 'Hard Drives'),
  (NULL, 'Random Access Memory');
 
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Intel processor i3 series', 7890.00, 1),
  ('Intel Core i5-7400', 'Intel processor i5 series', 12700.00, 1),
  ('AMD FX-8320E', 'AMD processor', 4780.00, 1),
  ('AMD FX-8320', 'AMD processor', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Motherboard ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Motherboard Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Motherboard MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
 
# Решение задания №1

SELECT products.name, products.description, catalogs.name
FROM products, catalogs
WHERE products.catalog_id = catalogs.id;

# Решение задания №2

SELECT p.name, p.description, c.name 
FROM products as p
JOIN catalogs as c 
ON p.catalog_id = c.id;

# Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
# Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS flights;
CREATE TABLE IF NOT EXISTS flights(
  `id` SERIAL PRIMARY KEY,
  `from` VARCHAR(255),
  `to` VARCHAR(255)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE IF NOT EXISTS cities(
  label VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255)
);

ALTER TABLE flights 
ADD FOREIGN KEY (`from`)
REFERENCES cities(`label`)
ON DELETE SET NULL;

INSERT INTO cities (`label`, `name`) VALUES
  ('Moscow', 'Москва'),
  ('Omsk', 'Омск'),
  ('Kazan', 'Казань'),
  ('Irkutsk', 'Иркутск');
 
INSERT INTO flights (`id`,`from`,`to`) VALUES
  (NULL, 'Moscow', 'Omsk'),
  (NULL, 'Kazan', 'Irkutsk'),
  (NULL, 'Irkutsk', 'Moscow');

# Решение задания

SELECT f.id, c1.name as `from`, c2.name as `to`
FROM flights as f
JOIN cities as c1 
ON f.from = c1.label
JOIN cities as c2 
ON f.to = c2.label;
 
ALTER TABLE flights 
DROP FOREIGN KEY flights_ibfk_1;
