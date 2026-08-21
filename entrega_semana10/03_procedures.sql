-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 03_procedures.sql
-- Descripción: 5 Stored Procedures con validaciones y lógica de negocio
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- SP1: sp_hire_employee
-- Contrata un nuevo empleado con validaciones completas
-- Parámetros: nombre, email, teléfono, salario, departamento
-- Retorna: id del empleado creado (OUT)
-- ------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE sp_hire_employee(
    IN  p_name          VARCHAR(100),
    IN  p_email         VARCHAR(150),
    IN  p_phone         VARCHAR(20),
    IN  p_salary        DECIMAL(10,2),
    IN  p_department_id INT,
    OUT p_employee_id   INT
)
BEGIN
    DECLARE v_exists INT;

    -- Validar email único
    SELECT COUNT(*) INTO v_exists FROM employees WHERE email = p_email;
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already registered';
    END IF;

    -- Validar salario mínimo
    IF p_salary < 30000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary below minimum (30000)';
    END IF;

    -- Validar departamento existe
    SELECT COUNT(*) INTO v_exists FROM departments WHERE id = p_department_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    INSERT INTO employees (name, email, phone, hire_date, salary, department_id, is_active)
    VALUES (p_name, p_email, p_phone, CURRENT_DATE, p_salary, p_department_id, TRUE);

    SET p_employee_id = LAST_INSERT_ID();
END$$

-- ------------------------------------------------------------
-- SP2: sp_assign_project
-- Asigna un empleado a un proyecto con validaciones
-- Parámetros: employee_id, project_id, horas asignadas, rol
-- ------------------------------------------------------------
CREATE PROCEDURE sp_assign_project(
    IN p_employee_id INT,
    IN p_project_id  INT,
    IN p_hours       INT,
    IN p_role        VARCHAR(50)
)
BEGIN
    DECLARE v_project_status  VARCHAR(20);
    DECLARE v_employee_active BOOLEAN;

    SELECT status    INTO v_project_status  FROM projects  WHERE id = p_project_id;
    SELECT is_active INTO v_employee_active FROM employees WHERE id = p_employee_id;

    IF v_project_status IN ('Cancelled', 'Completed') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project accepts no more assignments';
    END IF;

    IF v_employee_active = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inactive employee';
    END IF;

    INSERT INTO assignments (employee_id, project_id, assigned_hours, role)
    VALUES (p_employee_id, p_project_id, p_hours, p_role);
END$$

-- ------------------------------------------------------------
-- SP3: sp_calculate_payroll
-- Genera la nómina de un mes/año para todos los empleados activos
-- Aplica bonus del 5% para empleados con 5+ años de antigüedad
-- Aplica deducción del 10% a todos
-- Omite empleados que ya tienen nómina del periodo
-- ------------------------------------------------------------
CREATE PROCEDURE sp_calculate_payroll(
    IN p_month INT,
    IN p_year  INT
)
BEGIN
    INSERT INTO payroll (employee_id, month, year, base_salary, bonuses, deductions, total, payment_date)
    SELECT
        e.id,
        p_month,
        p_year,
        ROUND(e.salary / 12, 2),
        ROUND(IF(YEAR(e.hire_date) <= p_year - 5, e.salary / 12 * 0.05, 0), 2),
        ROUND(e.salary / 12 * 0.10, 2),
        ROUND(
            (e.salary / 12)
            + IF(YEAR(e.hire_date) <= p_year - 5, e.salary / 12 * 0.05, 0)
            - (e.salary / 12 * 0.10),
        2),
        LAST_DAY(STR_TO_DATE(CONCAT(p_year, '-', p_month, '-01'), '%Y-%m-%d'))
    FROM employees e
    WHERE e.is_active = TRUE
      AND NOT EXISTS (
          SELECT 1 FROM payroll n
          WHERE n.employee_id = e.id
            AND n.month = p_month
            AND n.year  = p_year
      );

    SELECT ROW_COUNT() AS employees_processed;
END$$

-- ------------------------------------------------------------
-- SP4: sp_department_report
-- Devuelve KPIs de un departamento: empleados, coste, salario medio,
-- proyectos activos
-- ------------------------------------------------------------
CREATE PROCEDURE sp_department_report(IN p_department_id INT)
BEGIN
    SELECT
        d.name                                    AS department,
        d.budget,
        COUNT(e.id)                               AS total_employees,
        SUM(e.salary)                             AS total_annual_cost,
        ROUND(AVG(e.salary), 2)                   AS avg_salary,
        (
            SELECT COUNT(DISTINCT a.project_id)
            FROM assignments a
            JOIN employees emp ON a.employee_id = emp.id
            WHERE emp.department_id = p_department_id
        )                                         AS projects_assigned
    FROM departments d
    LEFT JOIN employees e
           ON d.id = e.department_id AND e.is_active = TRUE
    WHERE d.id = p_department_id
    GROUP BY d.id, d.name, d.budget;
END$$

-- ------------------------------------------------------------
-- SP5: sp_deactivate_employee
-- Realiza la baja lógica de un empleado (is_active = FALSE)
-- El trigger tr_employees_update registra el cambio en audit_log
-- ------------------------------------------------------------
CREATE PROCEDURE sp_deactivate_employee(IN p_employee_id INT)
BEGIN
    DECLARE v_exists INT;

    SELECT COUNT(*) INTO v_exists FROM employees
    WHERE id = p_employee_id AND is_active = TRUE;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee not found or already inactive';
    END IF;

    UPDATE employees SET is_active = FALSE WHERE id = p_employee_id;

    SELECT CONCAT('Employee id=', p_employee_id, ' deactivated') AS result;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- VERIFICACIÓN: listar procedures creados
-- ------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'globaltech';