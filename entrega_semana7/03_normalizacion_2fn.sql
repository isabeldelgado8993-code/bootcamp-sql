-- ============================================================
-- SEMANA 7 — TechStore: Segunda Forma Normal (2FN)
-- Archivo 03: Eliminar dependencias parciales
-- Mejora: categoria y precio salen de venta_items a productos
-- ============================================================

DROP DATABASE IF EXISTS techstore_2fn;
CREATE DATABASE techstore_2fn;
USE techstore_2fn;

-- ============================================================
-- ventas: igual que en 1FN
-- Pendiente: dependencias transitivas (las resuelve 3FN)
-- ============================================================

CREATE TABLE ventas (
    venta_id              INT PRIMARY KEY AUTO_INCREMENT,
    fecha_venta           DATE,
    vendedor_nombre       VARCHAR(100),
    vendedor_email        VARCHAR(100),
    vendedor_departamento VARCHAR(50),
    vendedor_depto_jefe   VARCHAR(100),
    cliente_nombre        VARCHAR(100),
    cliente_email         VARCHAR(100),
    cliente_telefono      VARCHAR(20),
    cliente_ciudad        VARCHAR(50),
    cliente_estado        VARCHAR(50),
    cliente_pais          VARCHAR(50)
);

-- ============================================================
-- productos: nueva tabla — categoria y precio dependen solo
-- de producto_id, no de la PK compuesta (venta_id, producto_id)
-- Dependencia parcial eliminada
-- ============================================================

CREATE TABLE productos (
    producto_id INT          AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) UNIQUE NOT NULL,
    categoria   VARCHAR(50),
    precio      DECIMAL(10,2)
);

-- ============================================================
-- venta_items: pierde categoria y precio — ahora viven en productos
-- Solo quedan columnas que dependen de la PK completa
-- ============================================================

CREATE TABLE venta_items (
    venta_id    INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad    INT,
    descuento   DECIMAL(5,2),
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id)    REFERENCES ventas(venta_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- ============================================================
-- Datos migrados
-- ============================================================

INSERT INTO ventas (venta_id, fecha_venta,
    vendedor_nombre, vendedor_email, vendedor_departamento, vendedor_depto_jefe,
    cliente_nombre, cliente_email, cliente_telefono,
    cliente_ciudad, cliente_estado, cliente_pais) VALUES
(1, '2024-01-15',
 'Ana García',     'ana@techstore.com',   'Ventas', 'Carlos López',
 'Juan Pérez',     'juan@email.com',      '555-0100', 'CDMX',        'Ciudad de México', 'México'),
(2, '2024-01-16',
 'Ana García',     'ana@techstore.com',   'Ventas', 'Carlos López',
 'María González', 'maria@email.com',     '555-0200', 'Guadalajara', 'Jalisco',          'México'),
(3, '2024-01-17',
 'Pedro Martínez', 'pedro@techstore.com', 'Ventas', 'Carlos López',
 'Juan Pérez',     'juan@email.com',      '555-0100', 'CDMX',        'Ciudad de México', 'México');

INSERT INTO productos (nombre, categoria, precio) VALUES
('Laptop Pro',        'Computadoras', 1299.99),
('Mouse Inalámbrico', 'Periféricos',    45.99),
('Teclado Mecánico',  'Periféricos',   189.99),
('Monitor 4K',        'Periféricos',   599.99),
('Cable HDMI',        'Accesorios',     19.99);

INSERT INTO venta_items (venta_id, producto_id, cantidad, descuento) VALUES
(1, 1, 1, 0.10),
(1, 2, 2, 0.05),
(2, 3, 1, 0.15),
(3, 4, 1, 0.20),
(3, 5, 3, 0.00);

-- Verificar
SELECT * FROM ventas;
SELECT * FROM productos;
SELECT * FROM venta_items;