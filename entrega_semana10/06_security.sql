-- ============================================================
-- SEMANA 10 — CAPSTONE: Sistema de RR.HH. GlobalTech
-- Archivo: 06_security.sql
-- Descripción: 3 usuarios MySQL con permisos por rol (privilegio mínimo)
-- ============================================================

USE globaltech;

-- ------------------------------------------------------------
-- Limpiar usuarios si existen (para re-ejecución segura)
-- ------------------------------------------------------------
DROP USER IF EXISTS 'hr_manager'@'localhost';
DROP USER IF EXISTS 'hr_analyst'@'localhost';
DROP USER IF EXISTS 'app_system'@'%';

-- ------------------------------------------------------------
-- USUARIO 1: hr_manager
-- Rol: Gerente de RR.HH.
-- Acceso: CRUD completo + ejecutar todos los procedures
-- ------------------------------------------------------------
CREATE USER 'hr_manager'@'localhost' IDENTIFIED BY 'HrManager_Strong_2026!';

GRANT SELECT, INSERT, UPDATE, DELETE ON globaltech.* TO 'hr_manager'@'localhost';
GRANT EXECUTE ON globaltech.*                         TO 'hr_manager'@'localhost';

-- ------------------------------------------------------------
-- USUARIO 2: hr_analyst
-- Rol: Analista de RR.HH.
-- Acceso: solo lectura en todas las tablas/vistas + reporte de departamento
-- ------------------------------------------------------------
CREATE USER 'hr_analyst'@'localhost' IDENTIFIED BY 'HrAnalyst_Strong_2026!';

GRANT SELECT ON globaltech.*                                             TO 'hr_analyst'@'localhost';
GRANT EXECUTE ON PROCEDURE globaltech.sp_department_report               TO 'hr_analyst'@'localhost';

-- ------------------------------------------------------------
-- USUARIO 3: app_system
-- Rol: Aplicación backend (privilegio mínimo)
-- Acceso: lectura de tablas operativas + procedures de operación
-- Sin acceso a: payroll, audit_log
-- ------------------------------------------------------------
CREATE USER 'app_system'@'%' IDENTIFIED BY 'AppSystem_Strong_2026!';

GRANT SELECT ON globaltech.employees          TO 'app_system'@'%';
GRANT SELECT ON globaltech.departments        TO 'app_system'@'%';
GRANT SELECT ON globaltech.projects           TO 'app_system'@'%';
GRANT SELECT ON globaltech.v_active_employees TO 'app_system'@'%';
GRANT EXECUTE ON PROCEDURE globaltech.sp_hire_employee   TO 'app_system'@'%';
GRANT EXECUTE ON PROCEDURE globaltech.sp_assign_project  TO 'app_system'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- ------------------------------------------------------------
-- VERIFICACIÓN: mostrar permisos de cada usuario
-- ------------------------------------------------------------
SHOW GRANTS FOR 'hr_manager'@'localhost';
SHOW GRANTS FOR 'hr_analyst'@'localhost';
SHOW GRANTS FOR 'app_system'@'%';