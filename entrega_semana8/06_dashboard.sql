-- ============================================================
-- SEMANA 8 — ÍNDICES Y PERFORMANCE
-- 06_dashboard.sql — BONUS: Query unificada para dashboard
-- ============================================================

USE megamart_slow;

SELECT metrica, valor FROM (

    -- Métrica 1: ventas del día
    SELECT 'ventas_hoy' AS metrica,
           CAST(COUNT(*) AS CHAR) AS valor,
           1 AS orden
    FROM ventas
    WHERE fecha_venta >= CURDATE()
      AND fecha_venta <  CURDATE() + INTERVAL 1 DAY

) m1

UNION ALL

SELECT metrica, valor FROM (
    -- Métrica 2: top 3 productos
    SELECT CONCAT('top_producto_', ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC)) AS metrica,
           CONCAT(p.nombre, ' (', COUNT(*), ' ventas)') AS valor
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    GROUP BY p.id, p.nombre
    ORDER BY COUNT(*) DESC
    LIMIT 3
) m2

UNION ALL

SELECT metrica, valor FROM (
    -- Métrica 3: top 3 clientes por gasto
    SELECT CONCAT('top_cliente_', ROW_NUMBER() OVER (ORDER BY SUM(v.cantidad * v.precio_unitario) DESC)) AS metrica,
           CONCAT(c.nombre, ' ($', ROUND(SUM(v.cantidad * v.precio_unitario), 2), ')') AS valor
    FROM ventas v
    JOIN clientes c ON v.cliente_id = c.id
    GROUP BY c.id, c.nombre
    ORDER BY SUM(v.cantidad * v.precio_unitario) DESC
    LIMIT 3
) m3

UNION ALL

SELECT metrica, valor FROM (
    -- Métrica 4: productos sin stock
    SELECT 'stock_agotado' AS metrica,
           CAST(COUNT(*) AS CHAR) AS valor
    FROM productos
    WHERE stock = 0 AND activo = TRUE
) m4;