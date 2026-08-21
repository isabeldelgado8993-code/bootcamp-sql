# Sistema de Gestión RR.HH. — GlobalTech

Capstone del SQL & MySQL Bootcamp de NIEVA (Semana 10). Sistema production-ready que integra diseño normalizado (3FN), stored procedures, triggers, vistas, índices y seguridad por roles sobre una base de datos de Recursos Humanos para la empresa ficticia GlobalTech.

## Stack

- MySQL 8.0+
- MySQL Workbench 8.0.47

## Instalación

Ejecutar los archivos en orden desde MySQL Workbench o terminal:

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_test_data.sql
mysql -u root -p < 03_procedures.sql
mysql -u root -p < 04_triggers.sql
mysql -u root -p < 05_views.sql
mysql -u root -p < 06_security.sql
```

## Diseño — ERD

6 tablas en 3FN con FKs y constraints.

```
departments ←── employees ──→ projects
                    │               ↑
                    ↓               │
                 payroll       assignments
                    
                audit_log  (poblada por triggers)
```

**Nota de diseño — FK circular:** `departments.manager_id` apunta a `employees.id` y `employees.department_id` apunta a `departments.id`. Se resuelve creando `departments` sin la FK circular, luego `employees`, y añadiendo la FK con `ALTER TABLE`.

## Tablas (6)

| Tabla | Descripción |
|---|---|
| `departments` | 5 departamentos con presupuesto y gerente |
| `employees` | 20 empleados con salario, departamento y estado activo |
| `projects` | 8 proyectos con estado y presupuesto |
| `assignments` | Tabla N:M entre empleados y proyectos |
| `payroll` | Pagos mensuales por empleado (UNIQUE por empleado/mes/año) |
| `audit_log` | Log automático de cambios (poblada por triggers) |

## Stored Procedures (5)

| Procedure | Propósito | Parámetros |
|---|---|---|
| `sp_hire_employee` | Alta de empleado con validaciones (email único, salario mínimo, departamento existe) | IN: nombre, email, teléfono, salario, dept_id / OUT: employee_id |
| `sp_assign_project` | Asigna empleado a proyecto (valida estado del proyecto y empleado activo) | IN: employee_id, project_id, horas, rol |
| `sp_calculate_payroll` | Genera nómina mensual para todos los activos (bonus 5% por antigüedad 5+ años, deducción 10%) | IN: mes, año |
| `sp_department_report` | KPIs de un departamento: empleados, coste anual, salario medio, proyectos | IN: department_id |
| `sp_deactivate_employee` | Baja lógica del empleado (is_active = FALSE) | IN: employee_id |

## Triggers (5)

| Trigger | Evento | Acción |
|---|---|---|
| `tr_employees_insert` | AFTER INSERT employees | Registra el alta en audit_log |
| `tr_employees_update` | AFTER UPDATE employees | Registra cambios de salario y estado en audit_log |
| `tr_employees_delete` | AFTER DELETE employees | Registra la baja física en audit_log |
| `tr_validate_salary_insert` | BEFORE INSERT employees | Bloquea salarios < 30.000 |
| `tr_validate_salary_update` | BEFORE UPDATE employees | Bloquea salarios < 30.000 y aumentos > 50% |

## Vistas (4)

| Vista | Uso |
|---|---|
| `v_active_employees` | Empleados activos con departamento y antigüedad |
| `v_projects_team` | Proyectos con equipo concatenado y horas totales |
| `v_monthly_payroll` | Nómina agregada por mes/año |
| `v_hr_dashboard` | Métricas globales de RR.HH. en una sola fila |

## Seguridad

3 usuarios con privilegio mínimo:

| Usuario | Rol | Acceso |
|---|---|---|
| `hr_manager@localhost` | Gerente RR.HH. | CRUD completo + EXECUTE en todos los procedures |
| `hr_analyst@localhost` | Analista RR.HH. | SELECT en todas las tablas + sp_department_report |
| `app_system@%` | Aplicación backend | SELECT en employees/departments/projects/v_active_employees + sp_hire_employee + sp_assign_project |

`app_system` no tiene acceso a `payroll` ni `audit_log`. Si la aplicación es comprometida, el atacante no puede leer salarios ni modificar registros de auditoría.

## Queries de demostración

```sql
-- Contratar un nuevo empleado
CALL sp_hire_employee('Ana García', 'ana@globaltech.com', '555-1234', 60000, 1, @id);
SELECT @id;

-- Asignar a proyecto
CALL sp_assign_project(@id, 1, 20, 'Junior Dev');

-- Generar nómina de mayo 2024
CALL sp_calculate_payroll(5, 2024);

-- Dashboard ejecutivo
SELECT * FROM v_hr_dashboard;

-- Reporte del departamento Engineering
CALL sp_department_report(1);

-- Auditoría reciente
SELECT * FROM audit_log ORDER BY date DESC LIMIT 10;

-- Proyectos con equipo
SELECT * FROM v_projects_team WHERE status = 'In Progress';
```

## Decisiones de diseño

- **Soft delete** en `employees.is_active`: nunca se borra físicamente para preservar historial de nómina y auditoría.
- **Trigger de auditoría** en lugar de auditoría manual en cada procedure: garantiza que TODO cambio queda registrado, incluso los UPDATEs directos fuera de los procedures.
- **UNIQUE (employee_id, month, year)** en `payroll`: impide pagar dos veces el mismo periodo.
- **FK circular** `departments.manager_id → employees`: resuelta con `ALTER TABLE` después de cargar datos.
- **Índices** en columnas de filtro frecuente: `idx_department`, `idx_active`, `idx_period`, `idx_status`, `idx_date`.

## Próximos pasos (fuera del alcance del bootcamp)

- Backup automatizado con `mysqldump` + cron
- Replicación master/replica para alta disponibilidad
- Tests automatizados con PyTest + pymysql
- Window Functions para rankings y running totals

---

Construido en el SQL & MySQL Bootcamp de NIEVA — 2026.