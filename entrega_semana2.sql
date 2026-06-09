-- ======================================
-- ENTREGA SEMANA 2 — TECHSTORE INVENTARIO
-- Nombre: Isabel Delgado  |  Fecha: 08/06/2026
-- ======================================

-- PARTE 1: DDL
DROP DATABASE IF EXISTS techstore_inventario;
CREATE DATABASE techstore_inventario;
USE techstore_inventario;

-- TABLA PRODUCTOS
CREATE TABLE productos (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    codigo_producto     VARCHAR(20) UNIQUE NOT NULL,
    nombre              VARCHAR(150) NOT NULL,
    descripcion         TEXT,
    categoria           VARCHAR(50) NOT NULL,
    precio              DECIMAL(10,2) NOT NULL,
    costo               DECIMAL(10,2) NOT NULL,
    stock               INT DEFAULT 0,
    stock_minimo        INT DEFAULT 5,
    proveedor           VARCHAR(100),
    activo              BOOLEAN DEFAULT TRUE,
    fecha_creacion      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- TABLA VENTAS
CREATE TABLE ventas (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    total        DECIMAL(10,2) NOT NULL,
    fecha_venta  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- VERIFICAR
SHOW TABLES;
DESCRIBE productos;
DESCRIBE ventas;


-- PARTE 2: DML inicial
INSERT INTO productos
    (codigo_producto, nombre, descripcion, categoria, precio, costo, stock, stock_minimo, proveedor, activo)
VALUES
    -- Laptops
    ('LAP001', 'Laptop HP Pavilion 15', 'Laptop Intel i5, 8GB RAM, 256GB SSD', 'Laptops', 799.99, 650.00, 12, 5, 'HP Inc', TRUE),
    ('LAP002', 'MacBook Air M2', 'Apple MacBook Air con chip M2, 8GB, 256GB', 'Laptops', 1299.99, 1050.00, 8, 3, 'Apple', TRUE),
    ('LAP003', 'Dell XPS 13', 'Ultrabook Dell XPS 13, i7, 16GB, 512GB SSD', 'Laptops', 1499.99, 1200.00, 5, 3, 'Dell', TRUE),
    ('LAP004', 'Lenovo ThinkPad', NULL, 'Laptops', 899.99, 720.00, 0, 5, 'Lenovo', FALSE),

    -- Periféricos
    ('PER001', 'Mouse Logitech MX Master 3', 'Mouse ergonómico inalámbrico', 'Perifericos', 99.99, 65.00, 35, 10, 'Logitech', TRUE),
    ('PER002', 'Teclado Mecánico Keychron K2', 'Teclado mecánico RGB, switches Gateron Brown', 'Perifericos', 89.99, 55.00, 20, 8, 'Keychron', TRUE),
    ('PER003', 'Webcam Logitech C920', 'Webcam Full HD 1080p', 'Perifericos', 79.99, 50.00, 15, 10, 'Logitech', TRUE),
    ('PER004', 'Hub USB-C 7 puertos', NULL, 'Perifericos', 45.99, 25.00, 50, 15, 'Anker', TRUE),
    ('PER005', 'Mouse Pad XL', 'Mouse pad gaming 90x40cm', 'Perifericos', 24.99, 10.00, 80, 20, 'SteelSeries', TRUE),
    ('PER006', 'Soporte Laptop Ajustable', 'Soporte ergonómico aluminio', 'Perifericos', 39.99, 20.00, 25, 10, 'Rain Design', TRUE),

    -- Audio
    ('AUD001', 'Audífonos Sony WH-1000XM5', 'Audífonos con cancelación de ruido', 'Audio', 399.99, 280.00, 10, 5, 'Sony', TRUE),
    ('AUD002', 'Audífonos Gaming HyperX', NULL, 'Audio', 79.99, 45.00, 30, 10, 'HyperX', TRUE),
    ('AUD003', 'Micrófono Blue Yeti', 'Micrófono USB profesional', 'Audio', 129.99, 85.00, 12, 6, 'Logitech', TRUE),
    ('AUD004', 'Parlantes Logitech Z623', 'Sistema 2.1, 200W', 'Audio', 149.99, 95.00, 8, 5, 'Logitech', TRUE),
    ('AUD005', 'Audífonos Bluetooth JBL', 'Audífonos inalámbricos portátiles', 'Audio', 49.99, 25.00, 2, 10, 'JBL', TRUE),

    -- Componentes
    ('COM001', 'SSD Samsung 1TB', 'SSD NVMe M.2 1TB', 'Componentes', 89.99, 60.00, 40, 15, 'Samsung', TRUE),
    ('COM002', 'RAM Corsair 16GB DDR4', '16GB (2x8GB) DDR4 3200MHz', 'Componentes', 79.99, 50.00, 25, 10, 'Corsair', TRUE),
    ('COM003', 'Monitor LG 27" 4K', 'Monitor IPS 27 pulgadas 4K', 'Componentes', 449.99, 320.00, 7, 5, 'LG', TRUE),
    ('COM004', 'Cable HDMI 2.1 - 2m', NULL, 'Componentes', 19.99, 8.00, 100, 30, 'Cable Matters', TRUE),
    ('COM005', 'Adaptador USB-C a HDMI', 'Adaptador 4K 60Hz', 'Componentes', 29.99, 15.00, 60, 20, 'Anker', TRUE);

-- Verificar
SELECT COUNT(*) FROM productos;
SELECT categoria, COUNT(*) FROM productos GROUP BY categoria;

-- 5 ventas iniciales
INSERT INTO ventas (producto_id, cantidad, precio_venta, total) VALUES
    (1,  2,  799.99, 1599.98),
    (5,  5,   99.99,  499.95),
    (6,  3,   89.99,  269.97),
    (11, 1,  399.99,  399.99),
    (16, 4,   89.99,  359.96);

-- Verificar
SELECT COUNT(*) FROM productos;  -- 20
SELECT COUNT(*) FROM ventas;     -- 5
SELECT categoria, COUNT(*) FROM productos GROUP BY categoria;

-- PARTE 3: UPDATE seguro
-- 3.1 Aumentar precios de Audio 10%

-- PASO 1: Verificar
SELECT nombre, precio, ROUND(precio * 1.10, 2) AS nuevo_precio
FROM productos
WHERE categoria = 'Audio';

-- PASO 2: Ejecutar
SET SQL_SAFE_UPDATES = 0;
UPDATE productos SET precio = precio * 1.10 WHERE categoria = 'Audio';
SET SQL_SAFE_UPDATES = 1;

-- PASO 3: Confirmar
SELECT nombre, precio
FROM productos
WHERE categoria = 'Audio';

-- 3.2 Reducir stock por las 5 ventas iniciales
START TRANSACTION;

UPDATE productos SET stock = stock - 2 WHERE id = 1;
UPDATE productos SET stock = stock - 5 WHERE id = 5;
UPDATE productos SET stock = stock - 3 WHERE id = 6;
UPDATE productos SET stock = stock - 1 WHERE id = 11;
UPDATE productos SET stock = stock - 4 WHERE id = 16;

-- Verificar antes de COMMIT
SELECT id, nombre, stock FROM productos WHERE id IN (1, 5, 6, 11, 16);

COMMIT;

-- 3.3 Marcar inactivos productos con stock bajo
-- PASO 1: Verificar
SELECT nombre, stock, stock_minimo
FROM productos
WHERE stock < stock_minimo;

-- PASO 2: Ejecutar
SET SQL_SAFE_UPDATES = 0;
UPDATE productos SET activo = FALSE WHERE stock < stock_minimo;
SET SQL_SAFE_UPDATES = 1;

-- PASO 3: Confirmar
SELECT nombre, stock, stock_minimo, activo
FROM productos
WHERE activo = FALSE;

-- Verificar que fecha_actualizacion cambió sola
SELECT nombre, fecha_creacion, fecha_actualizacion
FROM productos
WHERE id IN (1, 5);

-- PARTE 4: Soft delete + Hard delete

-- 4.1 Soft delete: Lenovo ThinkPad
ALTER TABLE productos ADD COLUMN deleted_at TIMESTAMP NULL;

UPDATE productos
SET deleted_at = CURRENT_TIMESTAMP
WHERE codigo_producto = 'LAP004';

-- Ver solo activos
SELECT id, nombre FROM productos WHERE deleted_at IS NULL;

-- Ver eliminados
SELECT id, nombre, deleted_at FROM productos WHERE deleted_at IS NOT NULL;

-- 4.2 Hard delete: ventas viejas
-- PASO 1: Verificar
SELECT * FROM ventas WHERE fecha_venta < '2023-01-01';

-- PASO 2: Ejecutar
DELETE FROM ventas WHERE fecha_venta < '2023-01-01';

-- PASO 3: Confirmar
SELECT COUNT(*) FROM ventas;

-- PARTE 5: Transacción — venta atómica completa
-- Cliente compra 3 Mouse Pad XL (id=9)

START TRANSACTION;

-- Paso 1: Verificar stock disponible
SELECT id, nombre, stock, precio
FROM productos
WHERE id = 9 AND stock >= 3 AND deleted_at IS NULL;

-- Paso 2: Reducir stock
UPDATE productos SET stock = stock - 3 WHERE id = 9;

-- Paso 3: Capturar precio actual
SELECT @precio_actual := precio FROM productos WHERE id = 9;

-- Paso 4: Registrar venta
INSERT INTO ventas (producto_id, cantidad, precio_venta, total)
VALUES (9, 3, @precio_actual, @precio_actual * 3);

-- Paso 5: Verificar ambos cambios
SELECT id, nombre, stock FROM productos WHERE id = 9;
SELECT * FROM ventas WHERE id = LAST_INSERT_ID();

COMMIT;

-- PARTE 6: Reportes bonus

-- Reporte 1: Productos en alerta de stock bajo
SELECT
    codigo_producto,
    nombre,
    categoria,
    stock,
    stock_minimo,
    stock_minimo - stock AS unidades_faltantes
FROM productos
WHERE stock < stock_minimo
  AND deleted_at IS NULL
ORDER BY unidades_faltantes DESC;

-- Reporte 2: Top 10 margen de ganancia
SELECT
    nombre,
    categoria,
    precio,
    costo,
    precio - costo AS margen_abs,
    ROUND(((precio - costo) / precio) * 100, 2) AS margen_pct
FROM productos
WHERE deleted_at IS NULL
ORDER BY margen_abs DESC
LIMIT 10;

-- Reporte 3: Revenue por categoría
SELECT
    p.categoria,
    COUNT(v.id)     AS num_ventas,
    SUM(v.cantidad) AS unidades,
    SUM(v.total)    AS revenue_total
FROM ventas v
JOIN productos p ON v.producto_id = p.id
GROUP BY p.categoria
ORDER BY revenue_total DESC;
