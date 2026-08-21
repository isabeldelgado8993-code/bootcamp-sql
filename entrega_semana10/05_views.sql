-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 05_views.sql
-- Descripción: 4 Vistas para reportes y dashboard ejecutivo
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- V1: v_active_employees
-- Empleados activos con departamento y antigüedad en años
-- ------------------------------------------------------------
CREATE VIEW v_active_employees AS
SELECT
    e.id,
    e.name,
    e.email,
    e.salary,
    d.name                                      AS department,
    ROUND(DATEDIFF(CURDATE(), e.hire_date) / 365, 1) AS tenure_years
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.is_active = TRUE;

-- ------------------------------------------------------------
-- V2: v_projects_team
-- Proyectos con lista de miembros y total de horas asignadas
-- ------------------------------------------------------------
CREATE VIEW v_projects_team AS
SELECT
    p.id,
    p.name                                              AS project,
    p.status,
    p.budget,
    GROUP_CONCAT(e.name ORDER BY a.role SEPARATOR ', ') AS team,
    SUM(a.assigned_hours)                               AS total_hours
FROM projects p
LEFT JOIN assignments a ON p.id  = a.project_id
LEFT JOIN employees   e ON a.employee_id = e.id
GROUP BY p.id, p.name, p.status, p.budget;

-- ------------------------------------------------------------
-- V3: v_monthly_payroll
-- Nómina agregada por mes/año
-- ------------------------------------------------------------
CREATE VIEW v_monthly_payroll AS
SELECT
    year,
    month,
    COUNT(*)       AS employees_paid,
    SUM(total)     AS total_payroll,
    ROUND(AVG(total), 2) AS avg_payment
FROM payroll
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- ------------------------------------------------------------
-- V4: v_hr_dashboard
-- Dashboard ejecutivo: métricas globales de RR.HH. en una fila
-- ------------------------------------------------------------
CREATE VIEW v_hr_dashboard AS
SELECT
    (SELECT COUNT(*)
     FROM employees
     WHERE is_active = TRUE)                                       AS active_employees,
    (SELECT COUNT(*)
     FROM employees
     WHERE is_active = FALSE)                                      AS inactive_employees,
    (SELECT ROUND(SUM(salary), 2)
     FROM employees
     WHERE is_active = TRUE)                                       AS annual_payroll_cost,
    (SELECT COUNT(*)
     FROM projects
     WHERE status = 'In Progress')                                 AS projects_in_progress,
    (SELECT COUNT(*)
     FROM departments)                                             AS total_departments,
    (SELECT total_payroll
     FROM v_monthly_payroll
     ORDER BY year DESC, month DESC
     LIMIT 1)                                                      AS last_month_payroll;

-- ------------------------------------------------------------
-- VERIFICACIÓN
-- ------------------------------------------------------------
SELECT * FROM v_active_employees    LIMIT 5;
SELECT * FROM v_projects_team       LIMIT 5;
SELECT * FROM v_monthly_payroll;
SELECT * FROM v_hr_dashboard;