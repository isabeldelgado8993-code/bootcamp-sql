-- ============================================
-- ENTREGA SEMANA 4 — TECHMASTER UNIVERSITY
-- Nombre: Isabel Delgado  |  Fecha: 03/07/2026
-- Tema: JOINs (INNER, LEFT, RIGHT, SELF, N:M)
-- ============================================

-- ============ SETUP ============
DROP DATABASE IF EXISTS techmaster_university;
CREATE DATABASE techmaster_university;
USE techmaster_university;

SELECT DATABASE(); -- debe imprimir 'techmaster_university'

-- ============ PARTE 1: DDL — 5 TABLAS ============

-- 1.1 DEPARTMENTS (no depende de nadie)
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    budget DECIMAL(12, 2),
    founding_date DATE
);

-- 1.2 PROFESSORS (depende de departments; manager_id es SELF FK hacia la misma tabla,
-- modela la jerarquía "cada profesor tiene un jefe que también es profesor")
CREATE TABLE professors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    department_id INT,
    manager_id INT,
    salary DECIMAL(10, 2),
    hire_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (manager_id) REFERENCES professors(id)
);

-- 1.3 STUDENTS (no depende de nadie)
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    birth_date DATE,
    enrollment_date DATE,
    gpa DECIMAL(4, 2),
    status ENUM('active', 'graduated', 'withdrawn') DEFAULT 'active'
);

-- 1.4 COURSES (depende de professors y departments)
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    professor_id INT,
    department_id INT NOT NULL,
    max_capacity INT DEFAULT 30,
    semester VARCHAR(10),
    FOREIGN KEY (professor_id) REFERENCES professors(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- 1.5 ENROLLMENTS (tabla puente N:M entre students y courses,
-- PK compuesta (student_id, course_id) — mismo patrón que book_authors en Semana 3)
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade DECIMAL(4, 2) CHECK (grade >= 0 AND grade <= 10),
    status ENUM('enrolled', 'passed', 'failed', 'withdrawn') DEFAULT 'enrolled',
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- ============ PARTE 2: DML — DATOS ============

-- 2.1 Departamentos (5)
INSERT INTO departments (name, budget, founding_date) VALUES
    ('Computer Science', 5000000.00, '1998-08-15'),
    ('Mathematics',      3500000.00, '1995-01-10'),
    ('Physics',          4200000.00, '1995-01-10'),
    ('Humanities',       2000000.00, '2005-03-22'),
    ('Biology',          3800000.00, '2000-09-01');

-- 2.2 Profesores (11) — ids 1,2,6,8,9 son jefes de depto (manager_id NULL)
INSERT INTO professors (name, email, department_id, manager_id, salary, hire_date) VALUES
    ('Dr. Robert Mendez',   'rmendez@uni.edu',   1, NULL, 95000, '2010-08-01'),
    ('Dr. Sara Lopez',      'slopez@uni.edu',    2, NULL, 92000, '2008-01-15'),
    ('Dr. Michael Vega',    'mvega@uni.edu',     1,    1, 78000, '2015-03-10'),
    ('Dr. Anna Torres',     'atorres@uni.edu',   1,    1, 76000, '2017-09-05'),
    ('Dr. Charles Ruiz',    'cruiz@uni.edu',     2,    2, 72000, '2018-02-12'),
    ('Dr. Elena Martinez',  'emartinez@uni.edu', 3, NULL, 88000, '2012-08-20'),
    ('Dr. Felix Castro',    'fcastro@uni.edu',   3,    6, 70000, '2019-01-15'),
    ('Dr. Gabrielle Perez', 'gperez@uni.edu',    4, NULL, 75000, '2014-09-01'),
    ('Dr. Hector Silva',    'hsilva@uni.edu',    5, NULL, 80000, '2013-08-15'),
    ('Dr. Isabel Ramos',    'iramos@uni.edu',    5,    9, 68000, '2020-03-01'),
    ('Dr. James Nunez',     'jnunez@uni.edu',    4,    8, 65000, '2021-09-10');

-- 2.3 Estudiantes (12)
INSERT INTO students (name, email, birth_date, enrollment_date, gpa, status) VALUES
    ('Alice Garcia',    'agarcia@uni.edu',    '2002-05-15', '2020-08-20', 8.5,  'active'),
    ('Brian Hernandez', 'bhernandez@uni.edu', '2001-11-22', '2020-08-20', 7.2,  'active'),
    ('Carol Ruiz',      'cruiz.stu@uni.edu',  '2003-03-10', '2021-08-20', 9.1,  'active'),
    ('Daniel Torres',   'dtorres@uni.edu',    '2002-07-08', '2020-08-20', 8.8,  'active'),
    ('Emma Lopez',      'elopez.stu@uni.edu', '2001-12-30', '2019-08-20', 9.5,  'graduated'),
    ('Frank Salinas',   'fsalinas@uni.edu',   '2003-04-25', '2021-08-20', 6.8,  'active'),
    ('Grace Mendez',    'gmendez@uni.edu',    '2002-09-12', '2020-08-20', 8.2,  'active'),
    ('Hugo Vega',       'hvega@uni.edu',      '2003-06-18', '2022-08-20', 7.9,  'active'),
    ('Irene Castro',    'icastro@uni.edu',    '2001-10-05', '2019-08-20', 5.5,  'withdrawn'),
    ('Jacob Nunez',     'jnunez.stu@uni.edu', '2002-08-29', '2020-08-20', 8.0,  'active'),
    ('Karla Romero',    'kromero@uni.edu',    '2003-01-17', '2022-08-20', NULL, 'active'),   -- sin GPA
    ('Lucas Aguilar',   'laguilar@uni.edu',   '2004-02-22', '2023-08-20', NULL, 'active');   -- nuevo, sin notas

-- 2.4 Cursos (12) — COMP401 a propósito sin profesor asignado (professor_id NULL)
INSERT INTO courses (code, name, credits, professor_id, department_id, max_capacity, semester) VALUES
    ('COMP101', 'Introduction to Programming', 4, 1,    1, 30, '2026-1'),
    ('COMP201', 'Data Structures',             4, 3,    1, 25, '2026-1'),
    ('COMP301', 'Databases',                   4, 4,    1, 25, '2026-1'),
    ('MATH101', 'Differential Calculus',       5, 2,    2, 35, '2026-1'),
    ('MATH201', 'Linear Algebra',              4, 5,    2, 30, '2026-1'),
    ('PHYS101', 'General Physics',             4, 6,    3, 30, '2026-1'),
    ('PHYS202', 'Quantum Mechanics',           5, 7,    3, 20, '2026-1'),
    ('HUMA101', 'Contemporary Philosophy',     3, 8,    4, 40, '2026-1'),
    ('HUMA201', 'Latin American Literature',   3, 11,   4, 40, '2026-1'),
    ('BIOL101', 'Cell Biology',                4, 9,    5, 28, '2026-1'),
    ('BIOL202', 'Molecular Genetics',          5, 10,   5, 22, '2026-1'),
    ('COMP401', 'Distributed Systems',         4, NULL, 1, 20, '2026-1');  -- sin profesor asignado

-- 2.5 Inscripciones (27) — N:M estudiante-curso vía la tabla puente enrollments
-- Irene (10) y Lucas (12) quedan sin ninguna fila aquí: son los "huérfanos" plantados
-- a propósito para las queries de LEFT JOIN de la Fase 3
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
    (1, 1, 9.0,  'passed'),   (1, 4, 8.5,  'passed'),   (1, 6, NULL, 'enrolled'),
    (2, 1, 7.0,  'passed'),   (2, 4, 6.5,  'failed'),   (2, 8, NULL, 'enrolled'),
    (3, 1, 9.5,  'passed'),   (3, 2, 9.0,  'passed'),   (3, 3, NULL, 'enrolled'),
    (3, 4, 9.8,  'passed'),
    (4, 1, 8.5,  'passed'),   (4, 2, 9.0,  'passed'),   (4, 3, NULL, 'enrolled'),
    (5, 1, 9.5,  'passed'),   (5, 2, 9.8,  'passed'),   (5, 3, 9.5,  'passed'),
    (5, 4, 10.0, 'passed'),
    (6, 4, 5.5,  'failed'),   (6, 8, 7.0,  'passed'),
    (7, 6, 8.5,  'passed'),   (7, 7, NULL, 'enrolled'),
    (8, 1, NULL, 'enrolled'), (8, 4, NULL, 'enrolled'),
    (10, 8, 7.5, 'passed'),   (10, 9, NULL, 'enrolled'),
    (11, 1, NULL, 'enrolled'), (11, 4, NULL, 'enrolled');

-- 2.6 Verificación de carga (patrón UNION ALL, receta de esta semana)
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL SELECT 'professors',  COUNT(*) FROM professors
UNION ALL SELECT 'students',    COUNT(*) FROM students
UNION ALL SELECT 'courses',     COUNT(*) FROM courses
UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments;
-- Esperado: 5 / 11 / 12 / 12 / 27

-- ============ PARTE 3: QUERIES 1-3 (INNER JOIN) ============

-- Query 1: cada profesor con el nombre de su departamento
SELECT p.name AS professor, d.name AS department
FROM professors p
INNER JOIN departments d ON p.department_id = d.id
ORDER BY d.name, p.name;

-- Query 2: cursos con su profesor y su departamento
-- (INNER excluye COMP401 automáticamente, no tiene profesor asignado)
SELECT c.code, c.name AS course, p.name AS professor, d.name AS department
FROM courses c
INNER JOIN professors p ON c.professor_id = p.id
INNER JOIN departments d ON c.department_id = d.id
ORDER BY d.name, c.code;

-- Query 3: estudiantes inscritos en MATH101 con su calificación
-- (solo los que ya tienen nota, no los que siguen 'enrolled')
SELECT s.name AS student, c.code, e.grade
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
WHERE c.code = 'MATH101' AND e.grade IS NOT NULL
ORDER BY e.grade DESC;

-- ============ PARTE 4: QUERIES 4-6 (LEFT JOIN + huérfanos) ============

-- Query 4: TODOS los cursos, incluso los que no tienen profesor
SELECT
    c.code,
    c.name AS course,
    COALESCE(p.name, '(unassigned)') AS professor
FROM courses c
LEFT JOIN professors p ON c.professor_id = p.id
ORDER BY c.code;

-- Query 5: TODOS los estudiantes con su número de cursos (incluso los que tienen 0)
SELECT
    s.name AS student,
    COUNT(e.course_id) AS num_courses
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY num_courses DESC;

-- Demo: gotcha ON vs WHERE
-- Versión A (filtro en ON, correcta para "TODOS") — 19 filas
SELECT s.name, e.course_id, e.status
FROM students s
LEFT JOIN enrollments e
    ON s.id = e.student_id AND e.status = 'passed'
ORDER BY s.name, e.course_id;

-- Versión B (mismo filtro en WHERE) — 15 filas
-- El filtro en WHERE se evalúa DESPUÉS del JOIN. Para estudiantes sin
-- inscripciones passed, e.status es NULL, y NULL = 'passed' nunca es true,
-- así que WHERE los descarta. El LEFT JOIN se comportó como INNER en silencio.
SELECT s.name, e.course_id, e.status
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.status = 'passed'
ORDER BY s.name, e.course_id;

-- Query 6: profesores que NO tienen cursos asignados (patrón de oro de huérfanos)
-- Resultado: 0 filas — todos los profesores tienen al menos un curso
SELECT p.name AS professor
FROM professors p
LEFT JOIN courses c ON p.id = c.professor_id
WHERE c.id IS NULL;

-- ============ PARTE 5: QUERIES 7-9 (multi-tabla) ============

-- Query 7: por departamento, cuántos profesores y cuántos cursos
-- (LEFT + COUNT DISTINCT para no inflar con el cruce profesores × cursos)
SELECT
    d.name AS department,
    COUNT(DISTINCT p.id) AS num_professors,
    COUNT(DISTINCT c.id) AS num_courses
FROM departments d
LEFT JOIN professors p ON d.id = p.department_id
LEFT JOIN courses c    ON d.id = c.department_id
GROUP BY d.id, d.name
ORDER BY d.name;

-- Query 8: qué cursos tiene cada estudiante (solo con al menos una inscripción)
SELECT s.name AS student, c.code, c.name AS course, e.grade
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
ORDER BY s.name, c.code;

-- Query 9: estudiantes inscritos en cursos de Computer Science (con curso y profesor)
-- LEFT en professors porque COMP401 no tiene profesor asignado
SELECT s.name AS student, c.code, c.name AS course, COALESCE(p.name, '(unassigned)') AS professor
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN departments d ON c.department_id = d.id
LEFT JOIN professors p ON c.professor_id = p.id
WHERE d.name = 'Computer Science'
ORDER BY s.name, c.code;

-- ============ PARTE 6: QUERIES 10-12 (SELF JOIN) ============

-- Query 10: cada profesor con el nombre de su jefe
-- LEFT + COALESCE: los jefes de departamento tienen manager_id NULL
SELECT
    p.name AS professor,
    COALESCE(m.name, 'No manager') AS manager
FROM professors p
LEFT JOIN professors m ON p.manager_id = m.id
ORDER BY p.name;

-- Query 11: profesores que ganan más que su jefe
-- INNER: un profesor sin jefe no tiene con quién compararse
-- Resultado: 0 filas — nadie gana más que su jefe en este dataset
SELECT
    p.name AS professor,
    p.salary AS professor_salary,
    m.name AS manager,
    m.salary AS manager_salary
FROM professors p
INNER JOIN professors m ON p.manager_id = m.id
WHERE p.salary > m.salary;

-- Query 12: pares de profesores del mismo departamento (sin duplicados ni auto-pares)
-- p1.id < p2.id evita el auto-par y evita contar cada pareja dos veces
SELECT
    p1.name AS professor_1,
    p2.name AS professor_2,
    d.name AS department
FROM professors p1
INNER JOIN professors p2 ON p1.department_id = p2.department_id AND p1.id < p2.id
INNER JOIN departments d ON p1.department_id = d.id
ORDER BY d.name;

-- Demo: CROSS JOIN — producto cartesiano (único JOIN sin ON)
-- 144 filas = 12 estudiantes × 12 cursos, todas las combinaciones posibles
SELECT s.name AS student, c.code
FROM students s
CROSS JOIN courses c
ORDER BY s.name, c.code;

-- ============ PARTE 7: QUERIES 13-15 (negocio) ============

-- Query 13: top 3 cursos con más estudiantes inscritos (excluye withdrawn)
SELECT
    c.code,
    c.name AS course,
    COUNT(e.student_id) AS num_students
FROM courses c
INNER JOIN enrollments e ON c.id = e.course_id
WHERE e.status != 'withdrawn'
GROUP BY c.id, c.code, c.name
ORDER BY num_students DESC
LIMIT 3;

-- Query 14: estudiantes inscritos en cursos de 2+ departamentos distintos
-- HAVING filtra DESPUÉS de agrupar (WHERE no puede filtrar sobre un COUNT)
SELECT
    s.name AS student,
    COUNT(DISTINCT c.department_id) AS num_departments
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
GROUP BY s.id, s.name
HAVING COUNT(DISTINCT c.department_id) >= 2
ORDER BY num_departments DESC;

-- Query 15: reporte ejecutivo por departamento (capstone)
-- Para cada departamento (incluso vacío): profesores, cursos y estudiantes únicos inscritos
SELECT
    d.name AS department,
    COUNT(DISTINCT p.id) AS num_professors,
    COUNT(DISTINCT c.id) AS num_courses,
    COUNT(DISTINCT e.student_id) AS num_students
FROM departments d
LEFT JOIN professors p ON d.id = p.department_id
LEFT JOIN courses c ON d.id = c.department_id
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY d.id, d.name
ORDER BY d.name;