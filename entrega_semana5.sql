-- ============================================================
-- ENTREGA SEMANA 5 — TECHMART ANALYTICS DASHBOARD
-- Bootcamp SQL | Isabel Delgado
-- Fecha: 09/07/2026
-- Base de datos: techmart_analytics
-- Descripción: Dashboard ejecutivo con 14 reportes analíticos
--              usando agregaciones, GROUP BY, HAVING y JOINs
-- ============================================================

-- ============================================================
-- PARTE 1: SETUP
-- ============================================================

DROP DATABASE IF EXISTS techmart_analytics;
CREATE DATABASE techmart_analytics;
USE techmart_analytics;

-- ------------------------------------------------------------
-- TABLAS
-- Orden: categorias → productos → clientes → ventas
-- productos depende de categorias (FK categoria_id)
-- ventas depende de productos y clientes (FK doble)
-- ------------------------------------------------------------

CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    costo DECIMAL(10,2) NOT NULL CHECK (costo > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    fecha_agregado DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    ciudad VARCHAR(100),
    pais VARCHAR(50),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(5,2) DEFAULT 0 CHECK (descuento BETWEEN 0 AND 100),
    fecha_venta DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- ------------------------------------------------------------
-- DATOS
-- ------------------------------------------------------------

INSERT INTO categorias (nombre) VALUES
    ('Electrónica'), ('Ropa'), ('Deportes'), ('Hogar'), ('Libros');

INSERT INTO productos (nombre, categoria_id, precio, costo, stock) VALUES
    ('Laptop HP 15',          1,  799.99, 600.00,  25),
    ('Mouse Logitech',        1,   25.99,  15.00, 150),
    ('Teclado Mecánico',      1,   89.99,  50.00,  80),
    ('Monitor LG 27"',        1,  299.99, 200.00,  30),
    ('Webcam HD',             1,   79.99,  45.00,  60),
    ('Audífonos Sony',        1,  149.99,  90.00,  45),
    ('Camiseta Nike',         2,   29.99,  12.00, 200),
    ('Pantalón Levi',         2,   59.99,  30.00, 120),
    ('Zapatillas Adidas',     2,   89.99,  45.00,  90),
    ('Chaqueta North Face',   2,  149.99,  80.00,  50),
    ('Gorra Nike',            2,   19.99,   8.00, 180),
    ('Balón Fútbol',          3,   24.99,  10.00, 100),
    ('Raqueta Tenis',         3,  119.99,  60.00,  35),
    ('Bicicleta Montaña',     3,  499.99, 300.00,  15),
    ('Pesas 20kg',            3,   79.99,  40.00,  45),
    ('Colchoneta Yoga',       3,   29.99,  12.00,  80),
    ('Licuadora Oster',       4,   59.99,  30.00,  70),
    ('Cafetera Nespresso',    4,  199.99, 120.00,  40),
    ('Aspiradora Dyson',      4,  399.99, 250.00,  20),
    ('Lámpara LED',           4,   34.99,  15.00, 100),
    ('Clean Code',            5,   39.99,  20.00,  60),
    ('Design Patterns',       5,   49.99,  25.00,  45),
    ('The Pragmatic Programmer', 5, 44.99, 22.00,  50),
    ('Refactoring',           5,   42.99,  21.00,  55);

INSERT INTO clientes (nombre, email, ciudad, pais, fecha_registro) VALUES
    ('Ana García',       'ana@email.com',       'Madrid',       'España',    '2023-01-15'),
    ('Carlos López',     'carlos@email.com',    'Barcelona',    'España',    '2023-02-20'),
    ('María Torres',     'maria@email.com',     'CDMX',         'México',    '2023-03-10'),
    ('Juan Pérez',       'juan@email.com',      'Buenos Aires', 'Argentina', '2023-04-05'),
    ('Lucía Martínez',   'lucia@email.com',     'Bogotá',       'Colombia',  '2023-05-12'),
    ('Diego Fernández',  'diego@email.com',     'Lima',         'Perú',      '2023-06-08'),
    ('Sofía Rodríguez',  'sofia@email.com',     'Santiago',     'Chile',     '2023-07-14'),
    ('Pedro Sánchez',    'pedro@email.com',     'Montevideo',   'Uruguay',   '2023-08-22'),
    ('Laura Ramírez',    'laura@email.com',     'Quito',        'Ecuador',   '2023-09-03'),
    ('Miguel Ángel',     'miguel@email.com',    'Madrid',       'España',    '2023-10-17'),
    ('Carmen Díaz',      'carmen@email.com',    'Valencia',     'España',    '2023-11-09'),
    ('Roberto Silva',    'roberto@email.com',   'São Paulo',    'Brasil',    '2023-12-01'),
    ('Isabel Morales',   'isabel@email.com',    'Guadalajara',  'México',    '2024-01-05'),
    ('Francisco Ruiz',   'francisco@email.com', 'Córdoba',      'Argentina', '2024-01-18'),
    ('Elena Castro',     'elena@email.com',     'Medellín',     'Colombia',  '2024-02-02'),
    ('Antonio Jiménez',  'antonio@email.com',   'Sevilla',      'España',    '2024-02-14'),
    ('Rosa Vargas',      'rosa@email.com',      'Monterrey',    'México',    '2024-02-28'),
    ('Javier Ortiz',     'javier@email.com',    'Rosario',      'Argentina', '2024-03-12'),
    ('Patricia Herrera', 'patricia@email.com',  'Cali',         'Colombia',  '2024-03-25'),
    ('Manuel Navarro',   'manuel@email.com',    'Bilbao',       'España',    '2024-04-08');

INSERT INTO ventas (cliente_id, producto_id, cantidad, precio_unitario, descuento, fecha_venta) VALUES
    (1,  1,  1, 799.99,  0, '2024-01-05'),  (2,  2, 2,  25.99,  5, '2024-01-06'),
    (3,  7,  3,  29.99,  0, '2024-01-08'),  (4, 12, 2,  24.99, 10, '2024-01-10'),
    (5,  3,  1,  89.99,  0, '2024-01-12'),  (6, 21, 2,  39.99,  5, '2024-01-15'),
    (7,  8,  1,  59.99,  0, '2024-01-18'),  (8,  4, 1, 299.99, 10, '2024-01-20'),
    (9, 14,  1, 499.99, 15, '2024-01-22'),  (10, 6, 1, 149.99,  5, '2024-01-25'),
    (11, 9,  2,  89.99, 10, '2024-02-02'),  (12, 17, 1, 59.99,  0, '2024-02-05'),
    (13, 13, 1, 119.99,  5, '2024-02-08'),  (14, 10, 1, 149.99, 10, '2024-02-10'),
    (15, 18, 1, 199.99,  0, '2024-02-12'),  (16,  2, 5,  25.99, 15, '2024-02-15'),
    (17, 7,  4,  29.99,  5, '2024-02-18'),  (18, 22, 1,  49.99,  0, '2024-02-20'),
    (19, 15, 2,  79.99, 10, '2024-02-22'),  (20, 11, 3,  19.99,  5, '2024-02-25'),
    (1, 19,  1, 399.99, 20, '2024-03-02'),  (3,  5, 2,  79.99, 10, '2024-03-05'),
    (5, 23,  1,  44.99,  0, '2024-03-08'),  (7, 16, 1,  29.99,  5, '2024-03-10'),
    (9, 20,  3,  34.99,  0, '2024-03-12'),  (2,  3, 1,  89.99, 10, '2024-03-15'),
    (4,  8,  2,  59.99,  5, '2024-03-18'),  (6, 12, 3,  24.99,  0, '2024-03-20'),
    (8,  1,  1, 799.99,  5, '2024-03-22'),  (10, 4, 1, 299.99, 15, '2024-03-25'),
    (12, 6,  1, 149.99, 10, '2024-04-02'),  (14, 13, 1, 119.99,  5, '2024-04-05'),
    (16, 9,  1,  89.99,  0, '2024-04-08'),  (18, 17, 1,  59.99, 10, '2024-04-10'),
    (20, 21, 3,  39.99,  5, '2024-04-12'),  (1,   2, 10, 25.99, 20, '2024-04-15'),
    (3,  7,  5,  29.99, 10, '2024-04-18'),  (5,  14, 1, 499.99, 10, '2024-04-20'),
    (7, 10,  1, 149.99,  5, '2024-04-22'),  (9,  18, 1, 199.99, 15, '2024-04-25'),
    (11, 15, 3,  79.99, 10, '2024-04-26'),  (13, 22, 2,  49.99,  5, '2024-04-27'),
    (15, 11, 4,  19.99,  0, '2024-04-28'),  (17, 16, 2,  29.99,  5, '2024-04-29'),
    (19, 23, 1,  44.99,  0, '2024-04-30');

-- Verificación: esperado 5 | 24 | 20 | 45
SELECT
    (SELECT COUNT(*) FROM categorias) AS num_categorias,
    (SELECT COUNT(*) FROM productos)  AS num_productos,
    (SELECT COUNT(*) FROM clientes)   AS num_clientes,
    (SELECT COUNT(*) FROM ventas)     AS num_ventas;

-- ============================================================
-- PARTE 2: DASHBOARD EJECUTIVO — 14 REPORTES
-- Patrón de revenue: cantidad * precio_unitario * (1 - descuento/100)
-- ============================================================

-- R1: Dashboard general
-- Métricas globales del negocio en una sola fila
SELECT
    COUNT(*) AS total_ventas,
    COUNT(DISTINCT cliente_id) AS clientes_unicos,
    COUNT(DISTINCT producto_id) AS productos_distintos_vendidos,
    SUM(cantidad) AS unidades_vendidas,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario * (1 - descuento/100)), 2)) AS revenue_total,
    CONCAT('$', FORMAT(AVG(cantidad * precio_unitario * (1 - descuento/100)), 2)) AS ticket_promedio
FROM ventas;

-- R2: Revenue por categoría
-- LEFT JOIN para incluir categorías sin ventas
SELECT
    c.nombre AS categoria,
    COUNT(v.id) AS num_ventas,
    SUM(v.cantidad) AS unidades,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
LEFT JOIN ventas    v ON p.id = v.producto_id
GROUP BY c.id, c.nombre
ORDER BY SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) DESC;

-- R3: Top 10 productos más vendidos
SELECT
    p.nombre AS producto,
    c.nombre AS categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    COUNT(v.id) AS num_ventas,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue
FROM productos p
JOIN ventas     v ON p.id = v.producto_id
JOIN categorias c ON p.categoria_id = c.id
GROUP BY p.id, p.nombre, c.nombre
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- R4: Top 10 clientes por revenue
SELECT
    cl.nombre AS cliente,
    cl.pais,
    COUNT(v.id) AS num_compras,
    SUM(v.cantidad) AS unidades,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS gastado
FROM clientes cl
JOIN ventas v ON cl.id = v.cliente_id
GROUP BY cl.id, cl.nombre, cl.pais
ORDER BY SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) DESC
LIMIT 10;

-- R5: Revenue por mes
SELECT
    DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo,
    COUNT(*) AS num_ventas,
    SUM(cantidad) AS unidades,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario * (1 - descuento/100)), 2)) AS revenue
FROM ventas
GROUP BY periodo
ORDER BY periodo;

-- R6: Margen de ganancia por categoría
-- Ganancia = revenue - costo; margen% = ganancia / revenue
SELECT
    c.nombre AS categoria,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue,
    CONCAT('$', FORMAT(SUM(v.cantidad * p.costo), 2)) AS costo,
    CONCAT('$', FORMAT(
        SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100))
        - SUM(v.cantidad * p.costo), 2
    )) AS ganancia,
    CONCAT(ROUND(
        100.0 *
        (SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) - SUM(v.cantidad * p.costo))
        / SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2
    ), '%') AS margen_pct
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
JOIN ventas    v ON p.id = v.producto_id
GROUP BY c.id, c.nombre
ORDER BY SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) - SUM(v.cantidad * p.costo) DESC;

-- R7: Clientes y revenue por país
SELECT
    cl.pais,
    COUNT(DISTINCT cl.id) AS num_clientes,
    COUNT(v.id) AS num_ventas,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue,
    CONCAT('$', FORMAT(AVG(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS ticket_promedio
FROM clientes cl
LEFT JOIN ventas v ON cl.id = v.cliente_id
GROUP BY cl.pais
ORDER BY SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) DESC;

-- R8: Productos con stock por debajo del promedio
-- Subconsulta en WHERE para calcular el promedio global
SELECT
    p.nombre AS producto,
    p.stock,
    ROUND((SELECT AVG(stock) FROM productos), 0) AS stock_promedio,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas
FROM productos p
LEFT JOIN ventas v ON p.id = v.producto_id
WHERE p.stock < (SELECT AVG(stock) FROM productos)
GROUP BY p.id, p.nombre, p.stock
ORDER BY p.stock ASC;

-- R9: Análisis de descuentos por rango
-- CASE WHEN para crear bins sin normalizar datos
SELECT
    CASE
        WHEN descuento = 0   THEN 'Sin descuento'
        WHEN descuento < 10  THEN '1-9%'
        WHEN descuento < 20  THEN '10-19%'
        ELSE '20%+'
    END AS rango_descuento,
    COUNT(*) AS num_ventas,
    SUM(cantidad) AS unidades,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario), 2)) AS revenue_bruto,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario * (1 - descuento/100)), 2)) AS revenue_neto,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario * descuento/100), 2)) AS descuento_otorgado
FROM ventas
GROUP BY rango_descuento
ORDER BY MIN(descuento);

-- R10: Clientes recurrentes (2+ compras)
-- HAVING filtra grupos después de agregar — no es posible con WHERE
SELECT
    cl.nombre AS cliente,
    cl.email,
    COUNT(v.id) AS num_compras,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS gastado,
    DATEDIFF(MAX(v.fecha_venta), MIN(v.fecha_venta)) AS dias_cliente_activo
FROM clientes cl
JOIN ventas v ON cl.id = v.cliente_id
GROUP BY cl.id, cl.nombre, cl.email
HAVING COUNT(v.id) >= 2
ORDER BY num_compras DESC;

-- R11: Pareto — % del revenue total por categoría
SELECT
    c.nombre AS categoria,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue,
    ROUND(
        100.0 * SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100))
        / (SELECT SUM(cantidad * precio_unitario * (1 - descuento/100)) FROM ventas), 2
    ) AS pct_del_total
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
JOIN ventas    v ON p.id = v.producto_id
GROUP BY c.id, c.nombre
ORDER BY pct_del_total DESC;

-- R12: Tasa de conversión de inventario
-- NULLIF evita división entre cero si stock = 0
SELECT
    c.nombre AS categoria,
    SUM(p.stock) AS stock_actual,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas,
    ROUND(
        100.0 * COALESCE(SUM(v.cantidad), 0) / NULLIF(SUM(p.stock), 0), 2
    ) AS tasa_conversion_pct
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
LEFT JOIN ventas v ON p.id = v.producto_id
GROUP BY c.id, c.nombre
ORDER BY tasa_conversion_pct DESC;

-- R13: Crecimiento mensual (self-join sobre subconsultas de revenue por mes)
SELECT
    actual.periodo,
    CONCAT('$', FORMAT(actual.revenue, 2))   AS revenue,
    CONCAT('$', FORMAT(anterior.revenue, 2)) AS revenue_mes_anterior,
    ROUND(
        100.0 * (actual.revenue - anterior.revenue) / NULLIF(anterior.revenue, 0), 2
    ) AS crecimiento_pct
FROM (
    SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo,
           SUM(cantidad * precio_unitario * (1 - descuento/100)) AS revenue
    FROM ventas GROUP BY periodo
) AS actual
LEFT JOIN (
    SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo,
           SUM(cantidad * precio_unitario * (1 - descuento/100)) AS revenue
    FROM ventas GROUP BY periodo
) AS anterior
    ON actual.periodo = DATE_FORMAT(
        DATE_ADD(STR_TO_DATE(CONCAT(anterior.periodo, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
        '%Y-%m'
    )
ORDER BY actual.periodo;

-- R14: Resumen ejecutivo — todo en una sola fila
SELECT
    'Resumen Ejecutivo' AS reporte,
    COUNT(DISTINCT v.id) AS total_ventas,
    COUNT(DISTINCT v.cliente_id) AS clientes_unicos,
    CONCAT('$', FORMAT(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS revenue,
    CONCAT('$', FORMAT(SUM(v.cantidad * p.costo), 2)) AS costo,
    CONCAT('$', FORMAT(
        SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) - SUM(v.cantidad * p.costo), 2
    )) AS ganancia,
    CONCAT(ROUND(
        100.0 *
        (SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)) - SUM(v.cantidad * p.costo))
        / SUM(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2
    ), '%') AS margen_pct,
    CONCAT('$', FORMAT(AVG(v.cantidad * v.precio_unitario * (1 - v.descuento/100)), 2)) AS ticket_promedio
FROM ventas v
JOIN productos p ON v.producto_id = p.id;

-- B1: Día de la semana con más ventas
SELECT
    DAYNAME(fecha_venta)  AS dia_semana,
    COUNT(*)              AS num_ventas,
    SUM(cantidad)         AS unidades,
    CONCAT('$', FORMAT(SUM(cantidad * precio_unitario * (1 - descuento/100)), 2)) AS revenue
FROM ventas
GROUP BY dia_semana
ORDER BY num_ventas DESC;

-- B2: Productos que nunca se han vendido
SELECT
    p.nombre    AS producto,
    c.nombre    AS categoria,
    p.precio    AS precio,
    p.stock     AS stock
FROM productos p
LEFT JOIN ventas v    ON p.id = v.producto_id
JOIN categorias c     ON p.categoria_id = c.id
WHERE v.id IS NULL
ORDER BY c.nombre, p.nombre;