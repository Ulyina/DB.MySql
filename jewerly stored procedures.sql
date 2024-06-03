CREATE TABLE JewelryType (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    manufacturer VARCHAR(50)
);

CREATE TABLE Jewelry (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    quantity INT,
    price DECIMAL(10, 2),
    material VARCHAR(50),
    jewelry_type_id INT,
    FOREIGN KEY (jewelry_type_id) REFERENCES JewelryType(id)
);

CREATE TABLE Sales (
    id INT PRIMARY KEY,
    sale_date DATE,
    quantity INT,
    discount_amount DECIMAL(10, 2),
    jewelry_id INT,
    FOREIGN KEY (jewelry_id) REFERENCES Jewelry(id)
);

CREATE TABLE Customers (
    id INT PRIMARY KEY,
    login VARCHAR(50),
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Purchases (
    id INT PRIMARY KEY,
    customer_id INT,
    sale_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(id),
    FOREIGN KEY (sale_id) REFERENCES Sales(id)
);

ALTER TABLE Jewelry ADD COLUMN pre_order INT DEFAULT 0;

CREATE TABLE PreOrders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    jewelry_id INT,
    quantity_needed INT,
    FOREIGN KEY (jewelry_id) REFERENCES Jewelry(id)
);

-----------------------------------------------------------

-- Таблица JewelryType (Виды украшений)
INSERT INTO JewelryType (id, name, manufacturer) VALUES
(1, 'Кольцо', 'Золотая Мастерская'),
(2, 'Серьги', 'Серебряные Чудеса'),
(3, 'Ожерелье', 'Алмазный Рай'),
(4, 'Браслет', 'Магия Жемчуга'),
(5, 'Подвеска', 'Изумрудные Изыски');

-- Таблица Jewelry (Украшения)
INSERT INTO Jewelry (id, name, quantity, price, material, jewelry_type_id) VALUES
(1, 'Золотое кольцо с бриллиантом', 10, 5000.00, 'Золото', 1),
(2, 'Серебряные серьги с жемчугом', 15, 2000.00, 'Серебро', 2),
(3, 'Ожерелье с изумрудами', 5, 10000.00, 'Золото', 3),
(4, 'Браслет из жемчуга', 20, 1500.00, 'Жемчуг', 4),
(5, 'Подвеска с рубином', 8, 7000.00, 'Золото', 5);

-- Таблица Sales (Продажи)
INSERT INTO Sales (id, sale_date, quantity, discount_amount, jewelry_id) VALUES
(1, '2024-03-01', 2, 0.00, 1),
(2, '2024-03-02', 1, 200.00, 2),
(3, '2024-03-03', 1, 0.00, 3),
(4, '2024-03-04', 5, 50.00, 4),
(5, '2024-03-05', 1, 0.00, 5);

INSERT INTO Customers (id, login, name, email) VALUES
(1, 'root1', 'Носонова Ульяна', 'nosonova@mail.ru'),
(2, 'root2', 'Лазарева Виктория', 'lazr@mail.ru'),
(3, 'root3', 'Кубашева Мария', 'maria@mail.ru');

INSERT INTO Purchases (id, customer_id, sale_id) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 1, 4),
(5, 2, 5);

-------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE PopularJewelry()
BEGIN
    UPDATE Jewelry
    SET price = price + 500;

    SELECT j.name AS 'Название украшения', j.material AS 'Материал', j.price AS 'Цена'
    FROM Jewelry j
    JOIN (
        SELECT jewelry_id, SUM(quantity) AS total_sales
        FROM Sales
        GROUP BY jewelry_id
        ORDER BY total_sales DESC
        LIMIT 3
    ) s ON j.id = s.jewelry_id
    ORDER BY total_sales DESC, j.name DESC, j.material DESC, j.price DESC;
END //

DELIMITER ;

----------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE InfoBraslet()
BEGIN

	UPDATE Jewelry j
    JOIN Sales s ON j.id = s.jewelry_id
    JOIN JewelryType jt ON j.jewelry_type_id = jt.id
    JOIN Purchases p ON s.id = p.sale_id
    JOIN Customers c ON p.customer_id = c.id
    SET j.price = j.price * 1.12
    WHERE s.sale_date BETWEEN '2024-03-01' AND '2024-03-08'
    AND s.quantity > 5
    AND jt.name = 'Браслет';

    SELECT c.login AS 'Логин покупателя', s.sale_date AS 'Дата продажи', jt.name AS 'Вид украшения',
           j.name AS 'Название украшения', s.quantity AS 'Количество',
           ROUND(j.price / 1.12, 2) AS 'Старая цена', j.price AS 'Новая цена'
    FROM Sales s
    JOIN Jewelry j ON s.jewelry_id = j.id
    JOIN JewelryType jt ON j.jewelry_type_id = jt.id
    JOIN Purchases p ON s.id = p.sale_id
    JOIN Customers c ON p.customer_id = c.id
    WHERE s.sale_date BETWEEN '2024-03-01' AND '2024-03-08'
    AND s.quantity > 5
    AND jt.name = 'Браслет';
END //

DELIMITER ;

-------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE CalculateMonth()
BEGIN
    DECLARE sold_quantity INT;

    -- Рассчитываем остатки на конец месяца
    UPDATE Jewelry j
    SET j.quantity = j.quantity - (
        SELECT IFNULL(SUM(quantity), 0) FROM Sales s WHERE s.jewelry_id = j.id
    );

    -- Проверяем, превышает ли количество проданных украшений имеющийся остаток
    SELECT s.jewelry_id, SUM(s.quantity) AS sold_quantity
    FROM Sales s
    GROUP BY s.jewelry_id
    HAVING sold_quantity > (
        SELECT j.quantity FROM Jewelry j WHERE j.id = s.jewelry_id
    )
    INTO sold_quantity;

    -- Если превышает, создаем запись о недостающих украшениях в таблице PreOrders
    IF sold_quantity IS NOT NULL THEN
        INSERT INTO PreOrders (jewelry_id, quantity_needed)
        VALUES (s.jewelry_id, sold_quantity - (SELECT j.quantity FROM Jewelry j WHERE j.id = s.jewelry_id));
    END IF;
END //

DELIMITER ;

---------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE CalculateMonth()
BEGIN
    -- Рассчитываем остатки на конец месяца
    UPDATE Jewelry j
    JOIN (
        SELECT jewelry_id, SUM(quantity) AS total_sold
        FROM Sales
        GROUP BY jewelry_id
    ) s ON j.id = s.jewelry_id
    SET j.quantity = j.quantity - s.total_sold;

    -- Создаем записи о недостающих украшениях в таблице PreOrders
    INSERT INTO PreOrders (jewelry_id, quantity_needed)
    SELECT s.jewelry_id, GREATEST(0, s.total_sold - j.quantity)
    FROM (
        SELECT jewelry_id, SUM(quantity) AS total_sold
        FROM Sales
        GROUP BY jewelry_id
    ) s
    JOIN Jewelry j ON s.jewelry_id = j.id
    WHERE s.total_sold > j.quantity;
END //

DELIMITER ;



