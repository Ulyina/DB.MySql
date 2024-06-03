-- Создание функции для расчета размера отпускных в MySQL
DELIMITER //

CREATE FUNCTION CalculPay(
    teacher_id INT,
    salary DECIMAL(10,2),
    start_date DATE,
    end_date DATE
)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE avg_sal DECIMAL(10,2);
    DECLARE total_days INT;
    
    -- Расчет общего количества дней в отпуске
    SET total_days = DATEDIFF(end_date, start_date) + 1;
    
    -- Расчет среднедневного заработка за последние 12 месяцев для конкретного преподавателя
    SELECT AVG(amount / 29.3) INTO avg_sal
    FROM Payment
    WHERE id_teacher = teacher_id
      AND date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE();
    
    -- Расчет отпускных
    RETURN avg_sal * total_days;
END //

DELIMITER ;





CREATE VIEW VacationInfo AS SELECT
    t.id_teacher AS employee_id,
    CONCAT(t.last_name, ' ', t.first_name, ' ', t.patronymic) AS 'Сотрудник',
    p.amount AS 'Размер оклада',
    CalculPay(t.id_teacher, p.amount, t.vacation_start, t.vacation_end) AS 'Размер отпускных'
FROM Teacher t
JOIN Payment p ON t.id_teacher = p.id_teacher;

SELECT * FROM VacationInfo;


----------------------------------------------------------------------

DELIMITER //

CREATE FUNCTION CalculMedical(
    teacher_id INT,
    salary DECIMAL(10,2),
    start_date DATE,
    end_date DATE
)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE avg_sal DECIMAL(10,2);
    DECLARE total_days INT;
    
    -- Расчет общего количества дней в больничном
    SET total_days = DATEDIFF(end_date, start_date) + 1;
    
    -- Расчет среднедневного заработка за последние 12 месяцев для конкретного преподавателя
    SELECT AVG(amount / 29.3) INTO avg_sal
    FROM Payment
    WHERE id_teacher = teacher_id
      AND date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE();
    
    -- Расчет больничных
    RETURN avg_sal * total_days;
END //

DELIMITER ;


CREATE VIEW MedicalInfo AS SELECT
    t.id_teacher AS employee_id,
    CONCAT(t.last_name, ' ', t.first_name, ' ', t.patronymic) AS 'Сотрудник',
    p.amount AS 'Размер оклада',
    CalculMedical(t.id_teacher, p.amount, t.medical_start, t.medical_end) AS 'Размер больничных'
FROM Teacher t
JOIN Payment p ON t.id_teacher = p.id_teacher;



