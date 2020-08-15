
USE vk;
SELECT DATABASE ();

# Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

ALTER TABLE users DROP created_at;
ALTER TABLE users DROP updated_at;

ALTER TABLE users ADD COLUMN created_at DATETIME DEFAULT NULL;
ALTER TABLE users ADD COLUMN updated_at DATETIME DEFAULT NULL;

UPDATE users SET created_at = NOW();
UPDATE users SET updated_at = NOW();

# Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое 
# время помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

ALTER TABLE users DROP created_at;
ALTER TABLE users DROP updated_at;

ALTER TABLE users ADD COLUMN created_at VARCHAR(255) DEFAULT "20.10.2020 7:59";
ALTER TABLE users ADD COLUMN updated_at VARCHAR(255) DEFAULT "20.10.2020 7:59";

UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%c.%Y %h:%i');
ALTER TABLE users MODIFY created_at DATETIME;

# Подсчитайте средний возраст пользователей в таблице users

SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, birthday,NOW())),0) AS average_age FROM profiles;

# Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, 
# а не года рождения.

SELECT DATE_FORMAT(CONCAT('2020-',SUBSTRING(birthday, 6, 5)), '%W') as Days, Count(*) as Times from profiles
GROUP BY Days
ORDER BY Times DESC;

# В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, 
# если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
# Однако, нулевые запасы должны выводиться в конце, после всех записей.

CREATE DATABASE IF NOT EXISTS products;
USE products;

DROP TABLE IF EXISTS storehouse_products;
CREATE TABLE IF NOT EXISTS storehouses_products (
    `value` INT UNSIGNED NOT NULL
);

INSERT INTO storehouses_products(`value`) VALUES 
    (10),
    (0),
    (350),
    (2500),
    (0),
    (20),
    (40);
   
SELECT `value` FROM storehouses_products
ORDER BY
CASE `value` WHEN 0 THEN TRUE ELSE FALSE
END, `value` ASC;

# Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')

USE vk;

SELECT firstname, lastname, DATE_FORMAT(birthday,'%M') AS months 
FROM profiles
JOIN users ON user_id = id
HAVING months IN ('May','August');

# Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, 
# заданном в списке IN.

CREATE DATABASE IF NOT EXISTS HW5;
USE HW5;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES 
    (NULL, "Processors"),
    (NULL, "Motherboards"),
    (NULL, "Video Cards"),
    (NULL, "Hard Drives"),
    (NULL, "Read-Only Memory");
   
SELECT * FROM catalogs WHERE id IN (5, 1, 2)
ORDER BY
CASE id
   WHEN 5 THEN 0
   WHEN 1 THEN 1
   WHEN 2 THEN 2
END,
name ASC;

# Подсчитайте произведение чисел в столбце таблицы
CREATE DATABASE IF NOT EXISTS HW5;
USE HW5;

DROP TABLE IF EXISTS multiply; 
CREATE TABLE IF NOT EXISTS multiply(
    `value` SERIAL
);

INSERT INTO multiply(`value`) VALUES
    (NULL),
    (NULL),
    (NULL),
    (NULL),
    (NULL);

SELECT * FROM multiply 
GROUP BY `value`;
   