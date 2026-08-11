-- ============================================================
-- SEMANA 8 — ÍNDICES Y PERFORMANCE
-- 02_queries_originales.sql — 6 queries sin optimizar
-- Ejecutar con EXPLAIN para diagnóstico (Fase 3)
-- ============================================================

USE megamart_slow;

-- Q1: Búsqueda de texto (LIKE con % al inicio — Full Table Scan)
SELECT * FROM productos WHERE nombre LIKE '%laptop%';

-- Q2: JOIN con filtro por categoría (sin índice en categoria_id ni en categorias.nombre)
SELECT p.id, p.nombre, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónica'
LIMIT 100;

-- Q3: Filtro por fecha con función en WHERE (invalida el índice)
SELECT * FROM ventas
WHERE DATE(fecha_venta) = '2024-06-15'
LIMIT 100;

-- Q4: Lookup por email (sin índice — revisa todas las filas)
SELECT * FROM clientes WHERE email = 'cliente1234@email.com';

-- Q5: Filtro compuesto stock + activo (sin índice compuesto)
SELECT id, nombre, precio FROM productos
WHERE stock = 0 AND activo = TRUE
LIMIT 100;

-- Q6: Top clientes con subconsultas correlacionadas
-- (cada subconsulta se ejecuta una vez por cliente)
SELECT
    c.nombre,
    (SELECT COUNT(*) FROM ventas v WHERE v.cliente_id = c.id) AS total_compras,
    (SELECT SUM(cantidad * precio_unitario) FROM ventas v WHERE v.cliente_id = c.id) AS total_gastado
FROM clientes c
ORDER BY total_gastado DESC
LIMIT 10;

-- ------------------------------------------------------------
-- EXPLAIN de cada query para diagnóstico (Fase 3)
-- Columnas clave: type, possible_keys, key, rows
-- Objetivo: detectar type=ALL y key=NULL
-- ------------------------------------------------------------

EXPLAIN SELECT * FROM productos WHERE nombre LIKE '%laptop%';

EXPLAIN SELECT p.id, p.nombre, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónica'
LIMIT 100;

EXPLAIN SELECT * FROM ventas WHERE DATE(fecha_venta) = '2024-06-15' LIMIT 100;

EXPLAIN SELECT * FROM clientes WHERE email = 'cliente12345@email.com';

EXPLAIN SELECT id, nombre, precio FROM productos
WHERE stock = 0 AND activo = TRUE LIMIT 100;

EXPLAIN SELECT
    c.nombre,
    (SELECT COUNT(*) FROM ventas v WHERE v.cliente_id = c.id) AS total_compras,
    (SELECT SUM(cantidad * precio_unitario) FROM ventas v WHERE v.cliente_id = c.id) AS total_gastado
FROM clientes c
ORDER BY total_gastado DESC
LIMIT 10;