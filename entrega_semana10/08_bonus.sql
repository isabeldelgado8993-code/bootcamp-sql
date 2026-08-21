-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 08_bonus.sql
-- Descripción: Bonus — Función fn_tenure + queries de dashboard
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- BONUS 1: fn_tenure
-- Devuelve los años de antigüedad de un empleado
-- Usable directamente en SELECT como cualquier columna calculada
-- ------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION fn_tenure(p_employee_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_tenure DECIMAL(5,2);

    SELECT DATEDIFF(CURDATE(), hire_date) / 365.0
    INTO v_tenure
    FROM employees
    WHERE id = p_employee_id;

    RETURN v_tenure;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- BONUS 2: Dashboard extendido — 10+ queries de análisis
-- ------------------------------------------------------------

-- 1. Antigüedad de todos los empleados activos
SELECT name, department_id, fn_tenure(id) AS tenure_years
FROM employees
WHERE is_active = TRUE
ORDER BY tenure_years DESC;

-- 2. Top 5 empleados por salario
SELECT name, salary, fn_tenure(id) AS tenure_years
FROM employees
WHERE is_active = TRUE
ORDER BY salary DESC
LIMIT 5;

-- 3. Coste total por departamento
SELECT d.name AS department, COUNT(e.id) AS employees,
       SUM(e.salary) AS annual_cost, ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.id = e.department_id AND e.is_active = TRUE
GROUP BY d.id, d.name
ORDER BY annual_cost DESC;

-- 4. Proyectos en curso con horas y equipo
SELECT * FROM v_projects_team
WHERE status = 'In Progress';

-- 5. Empleados sin asignación a ningún proyecto
SELECT e.id, e.name, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.is_active = TRUE
  AND e.id NOT IN (SELECT DISTINCT employee_id FROM assignments);

-- 6. Nómina total pagada por mes
SELECT * FROM v_monthly_payroll;

-- 7. Empleados con 5+ años de antigüedad (con bonus)
SELECT name, hire_date, fn_tenure(id) AS tenure_years, salary,
       ROUND(salary / 12 * 0.05, 2) AS monthly_bonus
FROM employees
WHERE is_active = TRUE AND fn_tenure(id) >= 5
ORDER BY tenure_years DESC;

-- 8. Auditoría: últimos 20 cambios registrados
SELECT * FROM audit_log ORDER BY date DESC LIMIT 20;

-- 9. Resumen del dashboard ejecutivo
SELECT * FROM v_hr_dashboard;

-- 10. Proyectos por estado
SELECT status, COUNT(*) AS total, SUM(budget) AS total_budget
FROM projects
GROUP BY status
ORDER BY total DESC;

-- 11. Empleados con más horas asignadas en proyectos
SELECT e.name, SUM(a.assigned_hours) AS total_hours, COUNT(a.project_id) AS projects
FROM employees e
JOIN assignments a ON e.id = a.employee_id
GROUP BY e.id, e.name
ORDER BY total_hours DESC
LIMIT 10;

-- 12. Verificar permisos de usuarios creados
SHOW GRANTS FOR 'hr_manager'@'localhost';
SHOW GRANTS FOR 'hr_analyst'@'localhost';
SHOW GRANTS FOR 'app_system'@'%';