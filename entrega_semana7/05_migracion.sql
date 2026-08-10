-- ============================================================
-- SEMANA 7 — TechStore: Migración de datos
-- Archivo 05: Cargar datos de legacy a techstore_3fn
-- Orden: catálogos primero, luego personas, luego transacciones
-- ============================================================

USE techstore_3fn;

-- ============================================================
-- 1. GEOGRAFÍA
-- ============================================================

INSERT INTO paises (nombre) VALUES ('México');

INSERT INTO estados (nombre, pais_id) VALUES
('Ciudad de México', 1),
('Jalisco',          1);

INSERT INTO ciudades (nombre, estado_id) VALUES
('CDMX',        1),
('Guadalajara', 2);

-- ============================================================
-- 2. ORGANIZACIÓN
-- ============================================================

INSERT INTO departamentos (nombre, jefe) VALUES
('Ventas', 'Carlos López');

INSERT INTO vendedores (nombre, email, departamento_id) VALUES
('Ana García',     'ana@techstore.com',   1),
('Pedro Martínez', 'pedro@techstore.com', 1);

-- ============================================================
-- 3. CLIENTES
-- ============================================================

INSERT INTO clientes (nombre, email, telefono, ciudad_id) VALUES
('Juan Pérez',     'juan@email.com',  '555-0100', 1),
('María González', 'maria@email.com', '555-0200', 2);

-- ============================================================
-- 4. PRODUCTOS
-- ============================================================

INSERT INTO categorias (nombre) VALUES
('Computadoras'),
('Periféricos'),
('Accesorios');

INSERT INTO productos (nombre, categoria_id, precio) VALUES
('Laptop Pro',        1, 1299.99),
('Mouse Inalámbrico', 2,   45.99),
('Teclado Mecánico',  2,  189.99),
('Monitor 4K',        2,  599.99),
('Cable HDMI',        3,   19.99);

-- ============================================================
-- 5. TRANSACCIONES
-- ============================================================

INSERT INTO ventas (venta_id, fecha_venta, vendedor_id, cliente_id) VALUES
(1, '2024-01-15', 1, 1),  -- Ana García → Juan Pérez
(2, '2024-01-16', 1, 2),  -- Ana García → María González
(3, '2024-01-17', 2, 1);  -- Pedro Martínez → Juan Pérez

INSERT INTO venta_items (venta_id, producto_id, cantidad, precio_venta, descuento) VALUES
(1, 1, 1, 1299.99, 0.10),  -- Laptop Pro
(1, 2, 2,   45.99, 0.05),  -- Mouse Inalámbrico
(2, 3, 1,  189.99, 0.15),  -- Teclado Mecánico
(3, 4, 1,  599.99, 0.20),  -- Monitor 4K
(3, 5, 3,   19.99, 0.00);  -- Cable HDMI

-- ============================================================
-- Verificar migración completa
-- ============================================================

SELECT 'paises'        AS tabla, COUNT(*) AS filas FROM paises
UNION ALL
SELECT 'estados',       COUNT(*) FROM estados
UNION ALL
SELECT 'ciudades',      COUNT(*) FROM ciudades
UNION ALL
SELECT 'departamentos', COUNT(*) FROM departamentos
UNION ALL
SELECT 'vendedores',    COUNT(*) FROM vendedores
UNION ALL
SELECT 'clientes',      COUNT(*) FROM clientes
UNION ALL
SELECT 'categorias',    COUNT(*) FROM categorias
UNION ALL
SELECT 'productos',     COUNT(*) FROM productos
UNION ALL
SELECT 'ventas',        COUNT(*) FROM ventas
UNION ALL
SELECT 'venta_items',   COUNT(*) FROM venta_items;