-- ============================================================
-- SEMANA 8 — ÍNDICES Y PERFORMANCE
-- 04_queries_optimizadas.sql — Q1, Q3, Q6 reescritas
-- Q2, Q4, Q5 solo necesitaban índices (no reescritura)
-- ============================================================

USE megamart_slow;

-- ------------------------------------------------------------
-- Q1 REESCRITA: LIKE '%xxx%' → FULLTEXT MATCH
-- Problema original: % al inicio impide uso de B-Tree.
-- Solución: MATCH...AGAINST usa el FULLTEXT INDEX creado.
-- Nota: FULLTEXT busca palabras completas. Para autocompletado
-- usar LIKE 'laptop%' (sin % al inicio) que sí usa B-Tree.
-- ------------------------------------------------------------

-- ❌ Original
SELECT * FROM productos WHERE nombre LIKE '%laptop%';

-- ✅ Optimizada
SELECT * FROM productos
WHERE MATCH(nombre) AGAINST('laptop');

-- ------------------------------------------------------------
-- Q2: solo necesitaba índices (no reescritura)
-- idx_productos_categoria_id + idx_categorias_nombre
-- ya resuelven el problema — la query es correcta.
-- ------------------------------------------------------------

SELECT p.id, p.nombre, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónica'
LIMIT 100;

-- ------------------------------------------------------------
-- Q3 REESCRITA: función DATE() en WHERE → rango de fechas
-- Problema original: DATE(fecha_venta) invalida el índice.
-- MySQL no puede navegar el B-Tree con la función aplicada.
-- Solución: comparar fecha_venta directamente con un rango.
-- Regla general: nunca apliques funciones a columnas en WHERE.
-- Mueve la transformación al valor, no a la columna.
-- ------------------------------------------------------------

-- ❌ Original
SELECT * FROM ventas
WHERE DATE(fecha_venta) = '2024-06-15'
LIMIT 100;

-- ✅ Optimizada
SELECT * FROM ventas
WHERE fecha_venta >= '2024-06-15 00:00:00'
  AND fecha_venta <  '2024-06-16 00:00:00'
LIMIT 100;

-- ------------------------------------------------------------
-- Q4: solo necesitaba índice UNIQUE en email
-- La query es correcta — el problema era la falta de índice.
-- ------------------------------------------------------------

SELECT * FROM clientes WHERE email = 'cliente12345@email.com';

-- ------------------------------------------------------------
-- Q5: solo necesitaba índice compuesto (stock, activo)
-- La query es correcta — el problema era la falta de índice.
-- ------------------------------------------------------------

SELECT id, nombre, precio FROM productos
WHERE stock = 0 AND activo = TRUE
LIMIT 100;

-- ------------------------------------------------------------
-- Q6 REESCRITA: subconsultas correlacionadas → JOIN + GROUP BY
-- Problema original: cada subconsulta se ejecuta una vez
-- por cliente → N clientes = 2N ejecuciones de subconsulta.
-- Solución: un solo JOIN con GROUP BY hace una única pasada.
-- Patrón: subconsulta correlacionada en SELECT → JOIN + GROUP BY.
-- ------------------------------------------------------------

-- ❌ Original
SELECT
    c.nombre,
    (SELECT COUNT(*) FROM ventas v WHERE v.cliente_id = c.id) AS total_compras,
    (SELECT SUM(cantidad * precio_unitario) FROM ventas v WHERE v.cliente_id = c.id) AS total_gastado
FROM clientes c
ORDER BY total_gastado DESC
LIMIT 10;

-- ✅ Optimizada
SELECT
    c.nombre,
    COUNT(v.id)                        AS total_compras,
    SUM(v.cantidad * v.precio_unitario) AS total_gastado
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre
ORDER BY total_gastado DESC
LIMIT 10;

-- ------------------------------------------------------------
-- EXPLAIN de queries optimizadas (comparar con Fase 3)
-- Objetivo: type=ref/const, key=nombre_indice, rows bajo
-- ------------------------------------------------------------

EXPLAIN SELECT * FROM productos WHERE MATCH(nombre) AGAINST('laptop');

EXPLAIN SELECT * FROM ventas
WHERE fecha_venta >= '2024-06-15 00:00:00'
  AND fecha_venta <  '2024-06-16 00:00:00'
LIMIT 100;

EXPLAIN SELECT * FROM clientes WHERE email = 'cliente1234@email.com';

EXPLAIN SELECT
    c.nombre,
    COUNT(v.id) AS total_compras,
    SUM(v.cantidad * v.precio_unitario) AS total_gastado
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre
ORDER BY total_gastado DESC
LIMIT 10;