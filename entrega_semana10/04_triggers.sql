-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 04_triggers.sql
-- Descripción: 5 Triggers (3 auditoría + 2 validación de salario)
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- TR1: tr_employees_insert
-- AFTER INSERT — registra en audit_log cada alta de empleado
-- ------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_employees_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, user, details)
    VALUES (
        'employees',
        'INSERT',
        NEW.id,
        USER(),
        CONCAT('Employee added: ', NEW.name, ' (', NEW.email, ') | dept=', NEW.department_id, ' | salary=', NEW.salary)
    );
END$$

-- ------------------------------------------------------------
-- TR2: tr_employees_update
-- AFTER UPDATE — registra cambios en salario y estado activo
-- ------------------------------------------------------------
CREATE TRIGGER tr_employees_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, user, details)
    VALUES (
        'employees',
        'UPDATE',
        NEW.id,
        USER(),
        CONCAT(
            'Employee updated id=', NEW.id,
            ' | salary: ', OLD.salary, ' → ', NEW.salary,
            ' | active: ', OLD.is_active, ' → ', NEW.is_active
        )
    );
END$$

-- ------------------------------------------------------------
-- TR3: tr_employees_delete
-- AFTER DELETE — registra cada baja física de empleado
-- ------------------------------------------------------------
CREATE TRIGGER tr_employees_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, user, details)
    VALUES (
        'employees',
        'DELETE',
        OLD.id,
        USER(),
        CONCAT('Employee deleted: ', OLD.name, ' (id=', OLD.id, ')')
    );
END$$

-- ------------------------------------------------------------
-- TR4: tr_validate_salary_insert
-- BEFORE INSERT — bloquea salarios por debajo del mínimo
-- ------------------------------------------------------------
CREATE TRIGGER tr_validate_salary_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Minimum salary: 30000';
    END IF;
END$$

-- ------------------------------------------------------------
-- TR5: tr_validate_salary_update
-- BEFORE UPDATE — bloquea salarios < mínimo y aumentos > 50%
-- ------------------------------------------------------------
CREATE TRIGGER tr_validate_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Minimum salary: 30000';
    END IF;

    IF NEW.salary > OLD.salary * 1.5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Increase >50% requires managerial approval';
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- VERIFICACIÓN: probar que los triggers funcionan
-- ------------------------------------------------------------

-- Test TR1 + TR4: insertar empleado válido → debe auditar en audit_log
INSERT INTO employees (name, email, phone, hire_date, salary, department_id)
VALUES ('Test Trigger', 'test.trigger@globaltech.com', '555-8888', CURRENT_DATE, 45000, 1);

-- Test TR4: salario inválido → debe fallar
-- INSERT INTO employees (name, email, hire_date, salary, department_id)
-- VALUES ('Low Salary', 'low@globaltech.com', CURRENT_DATE, 20000, 1);
-- Error esperado: Minimum salary: 30000

-- Verificar auditoría
SELECT * FROM audit_log ORDER BY date DESC LIMIT 5;

-- Listar triggers creados
SHOW TRIGGERS FROM globaltech;