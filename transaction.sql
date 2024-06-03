
DELIMITER $$

CREATE TRIGGER `update_products`
AFTER UPDATE ON `baskets`
FOR EACH ROW
BEGIN
    DECLARE product_before INT;
    DECLARE product_after INT;
    DECLARE diff_count INT;

    -- Получаем старое количество товара из таблицы products
    SELECT `count` INTO product_before FROM products WHERE id = NEW.idProduct;

    -- Получаем новое количество товара из таблицы baskets
    SELECT basketCount INTO product_after FROM baskets WHERE id = NEW.id;

    -- Вычисляем разницу в количестве товара
    SET diff_count = product_after - product_before;

    -- Обновляем количество товара и проданных единиц в таблице продуктов
    UPDATE products
    SET `count` = `count` - diff_count, sold = sold + diff_count
    WHERE id = NEW.idProduct;

END$$

DELIMITER ;

UPDATE baskets
SET basketCount = 2
WHERE id = 2;
