-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 01_schema.sql
-- Descripción: Creación de base de datos y 6 tablas en 3FN
-- ============================================================

DROP DATABASE IF EXISTS globaltech;
CREATE DATABASE globaltech;
USE globaltech;

-- ------------------------------------------------------------
-- TABLA: departments
-- Se crea sin manager_id FK (FK circular, se resuelve con ALTER TABLE)
-- ------------------------------------------------------------
CREATE TABLE departments (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)   UNIQUE NOT NULL,
    budget     DECIMAL(12,2),
    manager_id INT,
    INDEX idx_manager (manager_id)
);

-- ------------------------------------------------------------
-- TABLA: employees
-- ------------------------------------------------------------
CREATE TABLE employees (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)   NOT NULL,
    email         VARCHAR(150)   UNIQUE NOT NULL,
    phone         VARCHAR(20),
    hire_date     DATE           NOT NULL,
    salary        DECIMAL(10,2)  NOT NULL CHECK (salary > 0),
    department_id INT            NOT NULL,
    is_active     BOOLEAN        DEFAULT TRUE,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    INDEX idx_department (department_id),
    INDEX idx_active     (is_active)
);

-- FK circular resuelta tras crear employees
ALTER TABLE departments
    ADD CONSTRAINT fk_dept_manager
    FOREIGN KEY (manager_id) REFERENCES employees(id);

-- ------------------------------------------------------------
-- TABLA: projects
-- ------------------------------------------------------------
CREATE TABLE projects (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    start_date  DATE         NOT NULL,
    end_date    DATE,
    budget      DECIMAL(12,2),
    status      ENUM('Planning','In Progress','Completed','Cancelled') DEFAULT 'Planning',
    INDEX idx_status (status),
    INDEX idx_dates  (start_date, end_date),
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- ------------------------------------------------------------
-- TABLA: assignments (N:M empleados ↔ proyectos)
-- ------------------------------------------------------------
CREATE TABLE assignments (
    employee_id    INT NOT NULL,
    project_id     INT NOT NULL,
    assigned_hours INT  DEFAULT 0 CHECK (assigned_hours >= 0),
    role           VARCHAR(50),
    assigned_date  DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (project_id)  REFERENCES projects(id),
    INDEX idx_project (project_id)
);

-- ------------------------------------------------------------
-- TABLA: payroll
-- UNIQUE (employee_id, month, year) evita pagar dos veces el mismo periodo
-- ------------------------------------------------------------
CREATE TABLE payroll (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    employee_id  INT           NOT NULL,
    month        INT           NOT NULL CHECK (month BETWEEN 1 AND 12),
    year         INT           NOT NULL,
    base_salary  DECIMAL(10,2) NOT NULL,
    bonuses      DECIMAL(10,2) DEFAULT 0,
    deductions   DECIMAL(10,2) DEFAULT 0,
    total        DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    UNIQUE KEY uk_emp_month_year (employee_id, month, year),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    INDEX idx_period (year, month)
);

-- ------------------------------------------------------------
-- TABLA: audit_log
-- Registro automático de cambios (poblado por triggers)
-- ------------------------------------------------------------
CREATE TABLE audit_log (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50)                        NOT NULL,
    action     ENUM('INSERT','UPDATE','DELETE')   NOT NULL,
    record_id  INT,
    user       VARCHAR(100),
    date       DATETIME DEFAULT CURRENT_TIMESTAMP,
    details    TEXT,
    INDEX idx_table (table_name),
    INDEX idx_date  (date)
);