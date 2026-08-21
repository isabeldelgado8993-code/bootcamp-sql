-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 07_indexes.sql
-- Descripción: Verificación de performance con EXPLAIN e índices adicionales
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- ÍNDICES YA INCLUIDOS EN EL SCHEMA (01_schema.sql)
-- departments:  idx_manager
-- employees:    idx_department, idx_active
-- projects:     idx_status, idx_dates
-- assignments:  idx_project
-- payroll:      idx_period
-- audit_log:    idx_table, idx_date
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- EXPLAIN — verificar que las queries del dashboard usan índices
-- ------------------------------------------------------------

-- Query 1: empleados activos (usa idx_active)
EXPLAIN SELECT * FROM v_active_employees;

-- Query 2: nómina de un periodo específico (usa idx_period)
EXPLAIN SELECT * FROM v_monthly_payroll WHERE year = 2024 AND month = 4;

-- Query 3: proyectos en curso (usa idx_status)
EXPLAIN SELECT * FROM projects WHERE status = 'In Progress';

-- Query 4: auditoría por tabla (usa idx_table)
EXPLAIN SELECT * FROM audit_log WHERE table_name = 'employees' ORDER BY date DESC;

-- Query 5: asignaciones de un empleado (usa PK)
EXPLAIN SELECT * FROM assignments WHERE employee_id = 1;

-- ------------------------------------------------------------
-- ÍNDICES ADICIONALES (si EXPLAIN muestra type: ALL)
-- ------------------------------------------------------------

-- Índice en employees.email para búsquedas frecuentes de login
-- (ya cubierto por UNIQUE KEY en el schema, que crea índice implícito)

-- Índice compuesto para búsquedas de empleados activos por departamento
ALTER TABLE employees
    ADD INDEX idx_dept_active (department_id, is_active);

-- Índice en payroll.employee_id para historial por empleado
ALTER TABLE payroll
    ADD INDEX idx_employee (employee_id);

-- ------------------------------------------------------------
-- VERIFICAR ÍNDICES FINALES DE CADA TABLA
-- ------------------------------------------------------------
SHOW INDEX FROM employees;
SHOW INDEX FROM payroll;
SHOW INDEX FROM projects;
SHOW INDEX FROM audit_log;