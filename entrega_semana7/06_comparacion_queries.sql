-- ============================================================
-- SEMANA 7 — TechStore: Comparación legacy vs 3FN
-- Archivo 06: Demostrar que las anomalías están resueltas
-- ============================================================

-- ============================================================
-- COMPARACIÓN 1: Reporte de ventas por categoría
-- ============================================================

-- LEGACY: imposible sin parsear strings
USE techstore_legacy;
-- WHERE categorias = 'Periféricos' devuelve 0 filas
-- La celda contiene "Computadoras,Periféricos" — no se puede filtrar limpio
SELECT 'Imposible sin LIKE frágil — no es SQL relacional' AS resultado_legacy;

-- 3FN: query limpia y mantenible
USE techstore_3fn;
SELECT
    c.nombre                                                    AS categoria,
    SUM(vi.cantidad * vi.precio_venta * (1 - vi.descuento))    AS revenue_total
FROM categorias c
JOIN productos   p  ON c.categoria_id = p.categoria_id
JOIN venta_items vi ON p.producto_id  = vi.producto_id
GROUP BY c.categoria_id, c.nombre
ORDER BY revenue_total DESC;

-- ============================================================
-- COMPARACIÓN 2: Anomalía de actualización resuelta
-- ============================================================

USE techstore_legacy;
-- Ana cambia su email → hay que actualizar N filas
-- Si se olvida una, la base queda inconsistente
UPDATE ventas_completas
SET vendedor_email = 'ana.nueva@techstore.com'
WHERE vendedor_nombre = 'Ana García';
SELECT 'Filas afectadas: ' AS nota, vendedor_email FROM ventas_completas WHERE vendedor_nombre = 'Ana García';

-- Revertir
UPDATE ventas_completas SET vendedor_email = 'ana@techstore.com' WHERE vendedor_nombre = 'Ana García';

USE techstore_3fn;
-- Ana cambia su email → 1 sola fila afectada, consistencia garantizada
UPDATE vendedores SET email = 'ana.nueva@techstore.com' WHERE vendedor_id = 1;
SELECT nombre, email FROM vendedores WHERE vendedor_id = 1;

-- Revertir
UPDATE vendedores SET email = 'ana@techstore.com' WHERE vendedor_id = 1;

-- ============================================================
-- COMPARACIÓN 3: Anomalía de inserción resuelta
-- ============================================================

USE techstore_legacy;
-- No se puede registrar un departamento sin una venta
SELECT 'No existe tabla departamentos — imposible insertar sin venta' AS resultado_legacy;

USE techstore_3fn;
-- Crear departamento sin necesidad de ventas
INSERT INTO departamentos (nombre, jefe) VALUES ('Marketing', 'Laura Vega');
SELECT * FROM departamentos;

-- ============================================================
-- COMPARACIÓN 4: Anomalía de eliminación resuelta
-- ============================================================

USE techstore_legacy;
-- Borrar la única venta de María elimina a María completa
SELECT 'Si DELETE venta_id=2 → María González desaparece de la base' AS resultado_legacy;

USE techstore_3fn;
-- María existe en su propia tabla — borrar su venta no la elimina
SELECT * FROM clientes WHERE cliente_id = 2;
-- Si borrásemos la venta 2, María sigue aquí
SELECT 'Cliente protegido — vive en su propia tabla independiente' AS resultado_3fn;