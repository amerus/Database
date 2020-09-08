# База данных грибов.

DROP DATABASE IF EXISTS mycelium;
CREATE DATABASE mycelium;
USE mycelium;

# Названия грибов. Возможность культивации.
DROP TABLE IF EXISTS mushroom_names;
CREATE TABLE mushroom_names (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    name VARCHAR(150),
    `cultivation` ENUM('yes','no','rare'),
    location_id BIGINT UNSIGNED,
    season_id INT UNSIGNED,
    
    UNIQUE KEY mushroom_name_idx(name, location_id)
	
) COMMENT 'названия грибов';

# Таблица континентов.
DROP TABLE IF EXISTS continents;
CREATE TABLE IF NOT EXISTS continents (
	id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
	continent ENUM('Europe', 'North America', 'South America', 'Australia', 'Asia')
);

# Список стран.
DROP TABLE IF EXISTS geographic_locations;
CREATE TABLE geographic_locations (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    country VARCHAR(150) DEFAULT NULL,
    continent_id INT UNSIGNED NOT NULL,
    
    UNIQUE KEY mushroom_countries_idx(country, continent_id),
    
    PRIMARY KEY (id)
    
) COMMENT 'страны';

# Лечебные свойства.
DROP TABLE IF EXISTS medicinal_uses;
CREATE TABLE medicinal_uses (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	`condition primary` varchar(255) NOT NULL,
	`condition secondary` varchar(255),
	mushroom_id BIGINT UNSIGNED
	
	# UNIQUE KEY condition_idx(`condition`)

) COMMENT 'лечебные свойства';

# Внешние признаки.
DROP TABLE IF EXISTS identifying_characteristics;
CREATE TABLE identifying_characteristics (
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   cap varchar(255),
   stalk varchar(255),
   pore varchar(255),
   gills varchar(255),
   growth TINYTEXT,
   poisonous_lookalikes BIT DEFAULT 0,
   mushroom_id BIGINT UNSIGNED
) COMMENT 'внешние признаки';

# Способ приготовления.
DROP TABLE IF EXISTS preparation_methods;
CREATE TABLE preparation_methods (
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   preparation_method varchar(255) NOT NULL,
   
   UNIQUE KEY preparation_idx(`preparation_method`),
   
   mushroom_id BIGINT UNSIGNED
) COMMENT 'способ приготовления';

# Месяца  
DROP TABLE IF EXISTS months;
CREATE TABLE months (
   month_id TINYINT NOT NULL PRIMARY KEY,
   month_name VARCHAR(101) UNIQUE NOT NULL
) COMMENT 'месяца';

# Заполняем таблицу months значениями при помощи процедуры.
DELIMITER \\
DROP PROCEDURE IF EXISTS months_fill\\
CREATE PROCEDURE months_fill (startMonth INT, endMonth INT)
BEGIN	
	WHILE startMonth <= endMonth DO
	   SET @monName = DATE_FORMAT(CONCAT('2020-', startMonth, '-01'), '%M');
	   INSERT INTO months (month_id, month_name) VALUES (startMonth, @monName);
	   SET startMonth = startMonth + 1;
	END WHILE;
END\\
DELIMITER ;

# Триггер, проверяющий, что заданное количество месяцев находится в нужном диапазоне.
DELIMITER //
CREATE TRIGGER check_months_before_insert BEFORE INSERT ON months
FOR EACH ROW
BEGIN
	IF NEW.month_id > 12 THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert canceled. There are only 12 months in a year.';
	ELSEIF NEW.month_id < 1 THEN
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert canceled. Number of months cannot be fewer than 1.';
	END IF;
END//
DELIMITER ;

CALL months_fill(1,12);

# Таблица грибного сезона.
DROP TABLE IF EXISTS season;
CREATE TABLE season (
   id INT UNSIGNED NOT NULL PRIMARY KEY,
   startMonth VARCHAR(101) NOT NULL,
   endMonth VARCHAR(101) NOT NULL,
   season VARCHAR(101) GENERATED ALWAYS AS (CONCAT (startMonth, " - ", endMonth))
);

# Ядовитые грибы. 
DROP TABLE IF EXISTS poisonous_types;
CREATE TABLE poisonous_types (
   id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
   mushroom_id BIGINT UNSIGNED NOT NULL,
   toxicity_primary VARCHAR(255),
   toxicity_secondary VARCHAR(255)
   
) COMMENT 'ядовитые разновидности';

# Примеры рецептов.
DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    preparation_id BIGINT UNSIGNED NOT NULL,
    suggested_meal ENUM ('Breakfast', 'Lunch', 'Dinner', 'Other'),
    ingredient_list VARCHAR(255) NOT NULL,
    cooking_instructions TEXT,
    cuisine VARCHAR(255)
 
) COMMENT 'примеры рецептов';

ALTER TABLE poisonous_types 
    ADD CONSTRAINT mushroom_id_fk_1
    FOREIGN KEY (mushroom_id) REFERENCES mushroom_names (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

ALTER TABLE recipes 
    ADD CONSTRAINT preparation_id_fk_1
    FOREIGN KEY (preparation_id) REFERENCES preparation_methods (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
   
ALTER TABLE geographic_locations 
    ADD CONSTRAINT continents_fk_1
    FOREIGN KEY (continent_id) REFERENCES continents (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
   
ALTER TABLE mushroom_names 
	ADD CONSTRAINT location_fk_1
	FOREIGN KEY (location_id) REFERENCES geographic_locations(id)
	ON UPDATE CASCADE
	ON DELETE SET NULL,
	ADD CONSTRAINT season_fk_1
	FOREIGN KEY (season_id) REFERENCES season (id)
	ON UPDATE CASCADE
	ON DELETE SET NULL;

ALTER TABLE medicinal_uses 
	ADD CONSTRAINT mushroom_names_fk_1
	FOREIGN KEY (mushroom_id) REFERENCES mushroom_names (id)
	ON UPDATE CASCADE
	ON DELETE SET NULL;
	
ALTER TABLE identifying_characteristics
    ADD CONSTRAINT mushroom_names_fk_2
    FOREIGN KEY (mushroom_id) REFERENCES mushroom_names (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;
    
ALTER TABLE preparation_methods
    ADD CONSTRAINT mushroom_names_fk_3
    FOREIGN KEY (mushroom_id) REFERENCES mushroom_names (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE season
    ADD CONSTRAINT monthstart_fk_1
    FOREIGN KEY (startMonth) REFERENCES months (month_name)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    ADD CONSTRAINT monthend_fk_1
    FOREIGN KEY (endMonth) REFERENCES months (month_name)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT;

# Представление №1. Названия только ядовитых грибов и характерных симптомов отравлений.
CREATE OR REPLACE VIEW poisonous_names
AS 
    SELECT mn.name AS `Mushroom Name`, pt.toxicity_primary AS `Toxicity Primary`, pt.toxicity_secondary AS `Toxicity Secondary`
    FROM mushroom_names AS mn
       JOIN poisonous_types AS pt ON mn.id = pt.mushroom_id;

# Представление №2. Способы приготовления и рецепты.    
CREATE OR REPLACE VIEW consumption 
AS
    SELECT mn.name AS `Mushroom Name`, pm.preparation_method AS `Preparation`, re.cooking_instructions AS `Recipe`, re.ingredient_list AS `Ingredients`
    FROM mushroom_names AS mn
       JOIN preparation_methods AS pm ON mn.id = pm.mushroom_id 
       JOIN recipes AS re ON re.preparation_id = pm.id;
   
INSERT INTO continents (id, continent) VALUES
    (1, 'Europe'),
    (2, 'Asia'),
    (3, 'North America'),
    (4, 'South America'),
    (5, 'Australia');
   
INSERT INTO geographic_locations (id, country, continent_id) VALUES 
    (1, 'Russia', 1),
	(2, 'United States', 3),
	(3, 'China', 2),
	(4, 'Japan', 2);

INSERT INTO season (id, startMonth, endMonth) VALUES
    (1, 'July', 'December'),
    (2, 'June', 'November');
   
INSERT INTO mushroom_names (id, name, `cultivation`, location_id, season_id ) VALUES
    (1, 'Turkey Tail', 'yes', 3, 1),
    (2, 'Sweating Mushroom', 'no', 2, 2);
   
INSERT INTO poisonous_types (id, mushroom_id, toxicity_primary, toxicity_secondary ) VALUES
	(1, 2, 'muscarine poisoning', 'secretion of tears and saliva');

INSERT INTO medicinal_uses (id, mushroom_id, `condition primary`, `condition secondary`) VALUES
    (1, 1, 'Cancer', 'Anti-viral');
   
INSERT INTO identifying_characteristics (id, mushroom_id, stalk, cap, pore, poisonous_lookalikes, growth ) VALUES
	(1, 1, 'stalkless', 'multicolored rings', 'white', 0, 'dead trees');

INSERT INTO preparation_methods (id, mushroom_id, preparation_method ) VALUES
	(1, 1, 'tea');

INSERT INTO recipes (id, preparation_id, cuisine, ingredient_list,cooking_instructions ) VALUES
    (1, 1, 'Asian', '1 tablespoon of pulverised mushroom, 2 cups of water', 'Add powder in water and boil for 20-30 minutes.');
   
# Вызов представлений
SELECT * FROM poisonous_names; 
SELECT * FROM consumption;

# Поиск всех лечебных грибов в Китае, помогающих больным раковыми заболеваниями.
SELECT mn.name, gl.country, mu.`condition primary` 
FROM mushroom_names mn
JOIN geographic_locations gl ON mn.location_id = gl.id
JOIN medicinal_uses mu ON mn.id = mu.mushroom_id
WHERE gl.country = 'China' AND `condition primary` = 'Cancer';

    