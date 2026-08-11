-- ============================================================
-- SEMANA 8 — ÍNDICES Y PERFORMANCE
-- 03_indices.sql — Índices estratégicos con justificación
-- ============================================================

USE megamart_slow;

-- ------------------------------------------------------------
-- Q1: búsqueda de texto en productos.nombre
-- Problema: LIKE '%laptop%' con % al inicio = Full Table Scan.
-- B-Tree no puede ayudar con prefijo desconocido.
-- Solución: FULLTEXT INDEX permite búsqueda de palabras completas.
-- ------------------------------------------------------------
CREATE FULLTEXT INDEX ft_productos_nombre ON productos(nombre);

-- ------------------------------------------------------------
-- Q2: JOIN productos ↔ categorias filtrado por categorias.nombre
-- Problema: sin índice en categoria_id ni en categorias.nombre,
-- MySQL hace full scan en ambas tablas para el JOIN.
-- Solución: indexar ambas columnas del JOIN + columna de filtro.
-- ------------------------------------------------------------
CREATE INDEX idx_productos_categoria_id ON productos(categoria_id);
CREATE INDEX idx_categorias_nombre      ON categorias(nombre);

-- ------------------------------------------------------------
-- Q3: filtro por rango de fecha en ventas
-- Problema: DATE(fecha_venta) aplica función a la columna →
-- MySQL no puede navegar el B-Tree aunque exista índice.
-- Solución: índice en fecha_venta + reescribir la query sin DATE().
-- ------------------------------------------------------------
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);

-- ------------------------------------------------------------
-- Q4: lookup exacto por email en clientes
-- Problema: sin índice = full scan sobre toda la tabla.
-- Solución: UNIQUE porque cada email aparece una sola vez.
-- UNIQUE crea índice implícitamente + garantiza integridad.
-- ------------------------------------------------------------
CREATE UNIQUE INDEX idx_clientes_email ON clientes(email);

-- ------------------------------------------------------------
-- Q5: filtro compuesto stock=0 AND activo=TRUE
-- Problema: ambas columnas de baja cardinalidad (pocos valores únicos).
-- Un índice simple en cada una sería poco selectivo.
-- Solución: índice compuesto — filtra la combinación exacta.
-- stock primero porque tiene más valores únicos que activo (BOOLEAN).
-- ------------------------------------------------------------
CREATE INDEX idx_productos_stock_activo ON productos(stock, activo);

-- ------------------------------------------------------------
-- Q6: agregación de ventas por cliente
-- Problema: subconsultas correlacionadas buscan en ventas
-- por cliente_id sin índice = full scan por cada cliente.
-- Solución: índice en cliente_id para que el JOIN/lookup sea directo.
-- ------------------------------------------------------------
CREATE INDEX idx_ventas_cliente  ON ventas(cliente_id);
CREATE INDEX idx_ventas_producto ON ventas(producto_id);

-- ------------------------------------------------------------
-- FOREIGN KEYS — también añaden restricciones de integridad
-- Los índices anteriores ya cubren las columnas FK,
-- pero declaramos las FK para documentar las relaciones.
-- ------------------------------------------------------------
ALTER TABLE productos
    ADD CONSTRAINT fk_productos_categoria
    FOREIGN KEY (categoria_id) REFERENCES categorias(id);

ALTER TABLE ventas
    ADD CONSTRAINT fk_ventas_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    ADD CONSTRAINT fk_ventas_producto
    FOREIGN KEY (producto_id) REFERENCES productos(id);

-- Verificar índices creados
SHOW INDEX FROM productos;
SHOW INDEX FROM clientes;
SHOW INDEX FROM ventas;
SHOW INDEX FROM categorias;