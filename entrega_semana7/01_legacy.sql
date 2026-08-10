-- ============================================================
-- SEMANA 7 — TechStore: Sistema Legacy (0FN)
-- Archivo 01: Tabla original desnormalizada
-- ============================================================

DROP DATABASE IF EXISTS techstore_legacy;
CREATE DATABASE techstore_legacy;
USE techstore_legacy;

-- ============================================================
-- Tabla única con todo mezclado
-- Violaciones: multi-valores, redundancia, dependencias transitivas
-- ============================================================

CREATE TABLE ventas_completas (
    venta_id            INT PRIMARY KEY AUTO_INCREMENT,
    fecha_venta         DATE,

    -- Vendedor (sin tabla propia — datos duplicados en cada venta)
    vendedor_nombre     VARCHAR(100),
    vendedor_email      VARCHAR(100),
    vendedor_departamento VARCHAR(50),
    vendedor_depto_jefe VARCHAR(100),

    -- Cliente (sin tabla propia — datos duplicados en cada venta)
    cliente_nombre      VARCHAR(100),
    cliente_email       VARCHAR(100),
    cliente_telefono    VARCHAR(20),
    cliente_ciudad      VARCHAR(50),
    cliente_estado      VARCHAR(50),
    cliente_pais        VARCHAR(50),

    -- Items de venta — VIOLACIÓN 1FN: listas en texto plano
    productos           TEXT,   -- "Laptop Pro,Mouse Inalámbrico,Teclado Mecánico"
    categorias          TEXT,   -- "Computadoras,Periféricos,Periféricos"
    precios             TEXT,   -- "1299.99,45.99,189.99"
    cantidades          TEXT,   -- "1,2,1"
    descuentos          TEXT    -- "0.10,0.05,0.15"
);

INSERT INTO ventas_completas VALUES
(1, '2024-01-15',
 'Ana García',     'ana@techstore.com',   'Ventas', 'Carlos López',
 'Juan Pérez',     'juan@email.com',      '555-0100', 'CDMX',        'Ciudad de México', 'México',
 'Laptop Pro,Mouse Inalámbrico', 'Computadoras,Periféricos', '1299.99,45.99', '1,2', '0.10,0.05'),

(2, '2024-01-16',
 'Ana García',     'ana@techstore.com',   'Ventas', 'Carlos López',
 'María González', 'maria@email.com',     '555-0200', 'Guadalajara', 'Jalisco',          'México',
 'Teclado Mecánico', 'Periféricos', '189.99', '1', '0.15'),

(3, '2024-01-17',
 'Pedro Martínez', 'pedro@techstore.com', 'Ventas', 'Carlos López',
 'Juan Pérez',     'juan@email.com',      '555-0100', 'CDMX',        'Ciudad de México', 'México',
 'Monitor 4K,Cable HDMI', 'Periféricos,Accesorios', '599.99,19.99', '1,3', '0.20,0.00');

-- Verificar
SELECT * FROM ventas_completas;