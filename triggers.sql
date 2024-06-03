Аналогично примерам презентации 4, 5, 6 организовать ведение истории событий для таблицы БД из ЛР1. Выбрать основную таблицу согласно вашему варианту, написать для нее триггеры, которые будут отслеживать обновление, удаление и добавление данных и записывать информацию об этих событиях в отдельную таблицу (название таблицы на ваше усмотрение).

Пример 4. 
Дано.Создать триггер который будет добавлять в таблицу History данные о добавлении товара.
CREATE TRIGGER Products_INSERT_NEW*
AFTER INSERT ON products FOR EACH ROW 
INSERT INTO History (ProductId, Operation, CreateAt)
VALUES (NEWId, concat(Добавлен товар ; NEWProductName, ; фирма ;
NEW.Manufacturer), NOW())

Пример 5.
Дано.Создать триггер который будет добавлять в таблицу History информацию об удаленных товарах
CREATE TRIGGER Products_DELETE*
AFTER DELETE ON products FOR EACH ROW
INSERT INTO History (ProductId, Operation, CreateAt)
VALUES (OLD.Id, concat(Удален товар, OLD.ProductName, ; фирма ;
OLD.Manufacturer), NOW())

Пример 6.
Дано. Создать триггер который будет добавлять в таблицу History информацию об обновлении информации о товарах
DELIMITER $$
CREATE TRIGGER `Products_ UPDATE`
AFTER UPDATE ON `products` FOR EACH ROW
BEGIN
IF OLD.ProductName=NEW.ProductName THEN
INSERT INTO History (ProductId, Operation, CreateAt)
VALUES (OLD.Id, concat('Обновлён товар ; OLD.ProductName, ; фирма ; OLD.Manufacturer), NOW());
ELSE
INSERT INTO History (ProductId, Operation, CreateAt)
VALUES (OLD.Id, concat('Обновлён товар, OLD.ProductName, 'на', NEW.ProductName, ; фирма ; OLD.Manufacturer), NOW());
END IF; END $$

-----------------------------------------------------------

CREATE TABLE History(
    id_history INT AUTO_INCREMENT PRIMARY KEY,
    RecordId INT,
    TableName VARCHAR(50),
    Operation VARCHAR(255),
    CreatedAt TIMESTAMP
);

----------------------------------------------------------

DELIMITER //

CREATE TRIGGER StudentINSERT
AFTER INSERT ON Student FOR EACH ROW 
BEGIN
    INSERT INTO History (RecordId, TableName, Operation, CreatedAt)
    VALUES (NEW.id_student, 'Student', CONCAT('Добавлен студент: ', NEW.last_name, ' ', NEW.first_name), NOW());
END //

DELIMITER ;

--------------------------------------------------------

DELIMITER //

CREATE TRIGGER StudentDELETE
AFTER DELETE ON Student FOR EACH ROW
BEGIN
    INSERT INTO History (RecordId, TableName, Operation, CreatedAt)
    VALUES (OLD.id_student, 'Student', CONCAT('Удален студент: ', OLD.last_name, ' ', OLD.first_name), NOW());
END //

DELIMITER ;

--------------------------------------------------------------

DELIMITER //

CREATE TRIGGER StudentUPDATE
AFTER UPDATE ON Student FOR EACH ROW
BEGIN
    IF OLD.last_name = NEW.last_name AND OLD.first_name = NEW.first_name THEN
        INSERT INTO History (RecordId, TableName, Operation, CreatedAt)
        VALUES (OLD.id_student, 'Student', CONCAT('Обновлена информация о студенте: ', OLD.last_name, ' ', OLD.first_name), NOW());
    ELSE
        INSERT INTO History (RecordId, TableName, Operation, CreatedAt)
        VALUES (OLD.id_student, 'Student', CONCAT('Обновлена информация о студенте: ', OLD.last_name, ' ', OLD.first_name, ' на ', NEW.last_name, ' ', NEW.first_name), NOW());
    END IF;
END //

DELIMITER ;

-----------------------------------------------------------

Добавление студента:

INSERT INTO Student (id_student, id_course, last_name, first_name, patronymic, birth_date, email) 
VALUES (6, 1, 'Иванов', 'Иван', 'Иванович', '2000-01-01', 'ivanov@gmail.com');

Удаление студента:

DELETE FROM Student WHERE id_student = 1;

Обновление информации о студенте:

UPDATE Student SET last_name = 'Петров', first_name = 'Петр' WHERE id_student = 1;



