-- ============================================================
-- SEMANA 8 — ÍNDICES Y PERFORMANCE
-- 01_setup.sql — Creación de tablas y datos volumétricos
-- Proyecto: MegaMart (e-commerce lento sin índices)
-- ============================================================

DROP DATABASE IF EXISTS megamart_slow;
CREATE DATABASE megamart_slow;
USE megamart_slow;

-- ------------------------------------------------------------
-- TABLAS SIN ÍNDICES (excepto PK) — intencionalmente lentas
-- ------------------------------------------------------------

CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    descripcion TEXT
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200),
    descripcion TEXT,
    categoria_id INT,
    precio DECIMAL(10,2),
    stock INT,
    fecha_creacion DATETIME,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(150),
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    fecha_registro DATE
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    fecha_venta DATETIME,
    estado VARCHAR(50)
);

-- ------------------------------------------------------------
-- DATOS VOLUMÉTRICOS
-- Volumen final: 207.575 productos | 5.000 clientes | 20.000 ventas
-- Nota: productos insertados en lotes mediante procedimiento
-- para evitar timeout de Workbench (límite 30s por defecto).
-- ------------------------------------------------------------

-- 8 categorías
INSERT INTO categorias (nombre, descripcion) VALUES
    ('Electrónica', 'Dispositivos y gadgets'),
    ('Ropa', 'Moda y accesorios'),
    ('Deportes', 'Equipamiento deportivo'),
    ('Hogar', 'Muebles y decoración'),
    ('Libros', 'Literatura y educación'),
    ('Juguetes', 'Juegos y entretenimiento'),
    ('Alimentos', 'Comida y bebidas'),
    ('Belleza', 'Cuidado personal');

-- Procedimiento para insertar productos en lotes (evita timeout)
DELIMITER $$
CREATE PROCEDURE insertar_productos(IN inicio INT, IN fin INT)
BEGIN
    DECLARE i INT DEFAULT inicio;
    WHILE i <= fin DO
        INSERT INTO productos (nombre, descripcion, categoria_id, precio, stock, fecha_creacion, activo)
        VALUES (
            CONCAT('Producto ', i),
            'Descripción genérica del producto',
            1 + FLOOR(RAND() * 8),
            ROUND(10 + RAND() * 1990, 2),
            FLOOR(RAND() * 100),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1500) DAY),
            IF(RAND() > 0.05, TRUE, FALSE)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

-- Ejecutar en lotes de ~8.000 para no superar timeout:
-- CALL insertar_productos(1, 8000);
-- CALL insertar_productos(8001, 16000);
-- CALL insertar_productos(16001, 20000);
-- (repetir hasta el volumen deseado)

-- 5.000 clientes con CTE recursiva
SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO clientes (nombre, email, ciudad, pais, fecha_registro)
WITH RECURSIVE gen AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM gen WHERE n < 5000
)
SELECT
    CONCAT('Cliente ', n),
    CONCAT('cliente', n, '@email.com'),
    ELT(1 + (n MOD 5), 'CDMX', 'Madrid', 'Buenos Aires', 'Bogotá', 'Lima'),
    ELT(1 + (n MOD 5), 'México', 'España', 'Argentina', 'Colombia', 'Perú'),
    DATE_ADD('2022-01-01', INTERVAL (n MOD 800) DAY)
FROM gen;

-- 20.000 ventas con CTE recursiva
INSERT INTO ventas (cliente_id, producto_id, cantidad, precio_unitario, fecha_venta, estado)
WITH RECURSIVE gen AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM gen WHERE n < 10000
)
SELECT
    1 + (n MOD 5000),
    1 + (n MOD 207575),
    1 + (n MOD 5),
    ROUND(10 + (n MOD 1990), 2),
    DATE_ADD('2024-01-01', INTERVAL (n MOD 365) DAY),
    ELT(1 + (n MOD 3), 'completada', 'cancelada', 'pendiente')
FROM gen;

-- Verificar volúmenes finales
SELECT 'categorias' AS tabla, COUNT(*) AS filas FROM categorias
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'clientes',  COUNT(*) FROM clientes
UNION ALL SELECT 'ventas',    COUNT(*) FROM ventas;