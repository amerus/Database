CREATE DATABASE IF NOT EXISTS HW8;
ALTER DATABASE HW8 CHARACTER SET utf8 COLLATE utf8_general_ci;
USE HW8;

# В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
# Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

DROP TABLE IF EXISTS shop_users;
CREATE TABLE shop_users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO shop_users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
DROP TABLE IF EXISTS sample_users;
CREATE TABLE sample_users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  birthday_at DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

# Решение задачи. Для простоты, трансакция перемещает из одной таблицы в другую одной и тойже базы данных.

START TRANSACTION;
INSERT INTO sample_users SELECT * FROM shop_users WHERE id=1;
DELETE FROM shop_users WHERE id = 1;
COMMIT;

# Создайте представление, которое выводит название name товарной позиции из таблицы products и 
# соответствующее название каталога name из таблицы catalogs.

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

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
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2); 

 # Решение задачи
 DROP VIEW IF EXISTS twoNames;
 CREATE VIEW twoNames AS 
 SELECT p.name AS `Product Name`, c.name AS `Category Name`
 FROM products AS p
 JOIN
 catalogs AS c 
 ON p.catalog_id = c.id;
 
# Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
# С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
# с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT NOT DETERMINISTIC
BEGIN
	DECLARE `time` INT DEFAULT DATE_FORMAT(NOW(), "%H");
       IF( `time` <= '6') THEN
           RETURN "Доброй ночи";
       ELSEIF (`time` <= '12') THEN
           RETURN "Доброе утро";
       ELSE
           RETURN "Добрый день";
    END IF;
END //

SELECT hello() //

# В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие 
# обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, 
# добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо 
# отменить операцию.

CREATE TRIGGER check_name_description_insert BEFORE INSERT ON products
FOR EACH ROW BEGIN
  IF (NEW.name IS NULL AND new.description IS NULL) THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled because both name and description are NULL';
  END IF;  
END//

# Данная операция должа пройти успешно
INSERT INTO products 
   (name, description, price, catalog_id)
VALUES 
   (NULL, 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
   ('Intel Core i3-8100', NULL, 7890.00, 1)//

# Данная операция отменится insert-триггером   
INSERT INTO products 
   (name, description, price, catalog_id)
VALUES    
   (NULL, NULL, 7890.00, 1)//
   
CREATE TRIGGER check_name_description_update BEFORE UPDATE ON products
FOR EACH ROW BEGIN
   DECLARE description_current TEXT;
   SELECT description INTO description_current FROM products WHERE name = NEW.name LIMIT 1; 
   IF (NEW.name IS NULL and description_current IS NULL) THEN 
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE canceled because both name and description are NULL';
   END IF;
END //

# Данная операция отменится update-триггером
UPDATE products
SET name = NULL 
WHERE description IS NULL //

# Данная операция отменится update-триггером
UPDATE products
SET description = NULL
WHERE name IS NULL //
