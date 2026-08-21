-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 02_test_data.sql
-- Descripción: Datos de prueba realistas (20 empleados, 8 proyectos)
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- DEPARTAMENTOS (sin manager aún — FK circular)
-- ------------------------------------------------------------
INSERT INTO departments (name, budget) VALUES
    ('Engineering',     5000000),
    ('Marketing',       1500000),
    ('Sales',           2000000),
    ('Human Resources',  800000),
    ('Finance',         1200000);

-- ------------------------------------------------------------
-- EMPLEADOS (20 empleados distribuidos en los 5 departamentos)
-- ------------------------------------------------------------
INSERT INTO employees (name, email, phone, hire_date, salary, department_id, is_active) VALUES
    ('Sara Rios',         'sara@globaltech.com',      '555-0101', '2020-03-15', 95000, 1, TRUE),
    ('Thomas Vega',       'thomas@globaltech.com',    '555-0102', '2021-06-01', 78000, 1, TRUE),
    ('Lisa Chen',         'lisa@globaltech.com',      '555-0103', '2022-01-10', 82000, 1, TRUE),
    ('Peter Nunez',       'peter@globaltech.com',     '555-0104', '2023-04-20', 65000, 1, TRUE),
    ('Alex Torres',       'alex@globaltech.com',      '555-0105', '2023-08-15', 60000, 1, TRUE),
    ('Martha Solis',      'martha@globaltech.com',    '555-0201', '2019-10-01', 88000, 2, TRUE),
    ('Diego Vazquez',     'diego@globaltech.com',     '555-0202', '2022-05-12', 62000, 2, TRUE),
    ('Caroline Mendez',   'caroline@globaltech.com',  '555-0203', '2023-09-01', 55000, 2, TRUE),
    ('Philip Castro',     'philip@globaltech.com',    '555-0301', '2018-02-20', 92000, 3, TRUE),
    ('Romina Aguilar',    'romina@globaltech.com',    '555-0302', '2021-11-15', 70000, 3, TRUE),
    ('Sebastian Pino',    'sebastian@globaltech.com', '555-0303', '2023-03-08', 58000, 3, TRUE),
    ('Camila Reyes',      'camila@globaltech.com',    '555-0304', '2024-01-22', 50000, 3, TRUE),
    ('Andrew Soto',       'andrew@globaltech.com',    '555-0401', '2020-08-10', 75000, 4, TRUE),
    ('Mariana Lopez',     'mariana@globaltech.com',   '555-0402', '2022-12-05', 60000, 4, TRUE),
    ('Robert Diaz',       'robert@globaltech.com',    '555-0501', '2019-04-15', 85000, 5, TRUE),
    ('Patricia Vega',     'patricia@globaltech.com',  '555-0502', '2021-07-20', 68000, 5, TRUE),
    ('Lucas Mora',        'lucas@globaltech.com',     '555-0503', '2023-11-01', 55000, 5, TRUE),
    ('Valeria Cruz',      'valeria@globaltech.com',   '555-0106', '2024-02-15', 58000, 1, TRUE),
    ('George Bravo',      'george@globaltech.com',    '555-0107', '2024-03-01', 60000, 1, TRUE),
    ('Inactive Employee', 'inactive@globaltech.com',  '555-0999', '2018-01-01', 50000, 1, FALSE);

-- ------------------------------------------------------------
-- ASIGNAR GERENTES (los más antiguos de cada departamento)
-- ------------------------------------------------------------
UPDATE departments SET manager_id = 1  WHERE id = 1;  -- Sara Rios
UPDATE departments SET manager_id = 6  WHERE id = 2;  -- Martha Solis
UPDATE departments SET manager_id = 9  WHERE id = 3;  -- Philip Castro
UPDATE departments SET manager_id = 13 WHERE id = 4;  -- Andrew Soto
UPDATE departments SET manager_id = 15 WHERE id = 5;  -- Robert Diaz

-- ------------------------------------------------------------
-- PROYECTOS (8 proyectos con distintos estados)
-- ------------------------------------------------------------
INSERT INTO projects (name, description, start_date, end_date, budget, status) VALUES
    ('Cloud Migration',     'Migrate on-premise infra to AWS',  '2024-01-15', NULL,         500000, 'In Progress'),
    ('Web Redesign',        'New corporate site',               '2024-02-01', '2024-06-30', 150000, 'In Progress'),
    ('Q2 Campaign',         'Q2 marketing campaign',            '2024-04-01', '2024-06-30', 200000, 'Completed'),
    ('CRM System',          'Internal CRM',                     '2024-03-01', NULL,         300000, 'In Progress'),
    ('Audit 2024',          'Annual financial audit',           '2024-05-01', '2024-08-31', 100000, 'Planning'),
    ('Improved Onboarding', 'Employee onboarding platform',     '2024-06-01', NULL,          80000, 'In Progress'),
    ('LatAm Expansion',     'Market opening',                   '2024-07-01', NULL,         700000, 'Planning'),
    ('Cancelled Project',   'Cancelled due to priority change', '2024-01-01', '2024-02-15',  50000, 'Cancelled');

-- ------------------------------------------------------------
-- ASIGNACIONES (empleado → proyecto)
-- ------------------------------------------------------------
INSERT INTO assignments (employee_id, project_id, assigned_hours, role) VALUES
    (1,  1, 40, 'Tech Lead'),
    (2,  1, 30, 'Senior Dev'),
    (3,  1, 30, 'Senior Dev'),
    (4,  1, 20, 'Junior Dev'),
    (5,  2, 30, 'Frontend'),
    (18, 2, 30, 'Frontend'),
    (1,  4, 20, 'Architect'),
    (3,  4, 30, 'Senior Dev'),
    (19, 4, 25, 'Junior Dev'),
    (6,  3, 30, 'Lead'),
    (7,  3, 25, 'Designer'),
    (8,  3, 25, 'Copy'),
    (9,  4, 15, 'Sponsor'),
    (10, 4, 30, 'Sales Rep'),
    (13, 6, 20, 'HR Lead'),
    (14, 6, 20, 'HR'),
    (15, 5, 25, 'CFO'),
    (16, 5, 30, 'Senior Acct'),
    (17, 5, 25, 'Acct'),
    (1,  7, 10, 'Advisor'),
    (9,  7, 20, 'Sales Lead'),
    (2,  6, 15, 'Tech Support'),
    (4,  6, 10, 'Junior Dev');

-- ------------------------------------------------------------
-- NÓMINA — Mes 04/2024 para todos los empleados activos
-- ------------------------------------------------------------
INSERT INTO payroll (employee_id, month, year, base_salary, bonuses, deductions, total, payment_date)
SELECT
    e.id,
    4                        AS month,
    2024                     AS year,
    ROUND(e.salary / 12, 2)  AS base_salary,
    0                        AS bonuses,
    ROUND(e.salary / 12 * 0.10, 2) AS deductions,
    ROUND(e.salary / 12 * 0.90, 2) AS total,
    '2024-04-30'             AS payment_date
FROM employees e
WHERE e.is_active = TRUE;

-- ------------------------------------------------------------
-- VERIFICACIÓN
-- ------------------------------------------------------------
SELECT 'departments' AS tabla, COUNT(*) AS filas FROM departments
UNION ALL
SELECT 'employees',  COUNT(*) FROM employees
UNION ALL
SELECT 'projects',   COUNT(*) FROM projects
UNION ALL
SELECT 'assignments',COUNT(*) FROM assignments
UNION ALL
SELECT 'payroll',    COUNT(*) FROM payroll;