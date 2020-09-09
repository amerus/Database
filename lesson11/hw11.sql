# Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs 
# помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

CREATE DATABASE IF NOT EXISTS HW11;
ALTER DATABASE HW11 CHARACTER SET utf8 COLLATE utf8_general_ci;
USE HW11;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	created_at DATETIME NOT NULL,
	table_name VARCHAR(101) NOT NULL,
	primary_id BIGINT NOT NULL,
	name VARCHAR(101) NOT NULL
) ENGINE = ARCHIVE;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения'
) COMMENT = 'Покупатели';

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

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

DELIMITER //

DROP PROCEDURE IF EXISTS record_me//
CREATE PROCEDURE record_me (my_table VARCHAR(101), my_id INT, my_name VARCHAR(101))
BEGIN
	INSERT INTO logs (table_name, created_at, primary_id, name)
	VALUES (my_table, NOW(), my_id, my_name);
END//

DROP TRIGGER IF EXISTS log_users_before_insert//
CREATE TRIGGER log_before_insert BEFORE INSERT ON users
FOR EACH ROW
BEGIN
	SET @table_name = 'users';
	CALL record_me(@table_name, NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS log_catalogs_before_insert//
CREATE TRIGGER log_catalogs_before_insert BEFORE INSERT ON catalogs
FOR EACH ROW 
BEGIN
	SET @table_name = 'catalogs';
	CALL record_me(@table_name, NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS log_products_before_insert//
CREATE TRIGGER log_products_before_insert BEFORE INSERT ON products
FOR EACH ROW 
BEGIN
	SET @table_name = 'products';
	CALL record_me(@table_name, NEW.id, NEW.name);
END//

DELIMITER ;

INSERT INTO users (id, name, birthday_at) VALUES
  (1, 'Gena', '1990-10-05'),
  (2, 'Natasha', '1984-11-12'),
  (3, 'Alexandr', '1985-05-20'),
  (4, 'Sergey', '1988-02-14'),
  (5, 'Ivan', '1998-01-12'),
  (6, 'Maria', '1992-08-29');
 
INSERT INTO catalogs VALUES
  (1, 'Processors'),
  (2, 'Motherboards'),
  (3, 'Video Cards'),
  (4, 'Hard Drives'),
  (5, 'Random Access Memory');
 
INSERT INTO products
  (id, name, description, price, catalog_id)
VALUES
  (1, 'Intel Core i3-8100', 'Intel processor i3 series', 7890.00, 1),
  (2, 'Intel Core i5-7400', 'Intel processor i5 series', 12700.00, 1),
  (3, 'AMD FX-8320E', 'AMD processor', 4780.00, 1),
  (4, 'AMD FX-8320', 'AMD processor', 7120.00, 1),
  (5, 'ASUS ROG MAXIMUS X HERO', 'Motherboard ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  (6, 'Gigabyte H310M S2H', 'Motherboard Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  (7, 'MSI B250M GAMING PRO', 'Motherboard MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
 
 SELECT * FROM logs;
