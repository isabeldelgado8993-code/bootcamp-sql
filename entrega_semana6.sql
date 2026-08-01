-- ============================================================
-- ENTREGA SEMANA 6 — GLOBALMART ANÁLISIS
-- Subconsultas y Operadores Avanzados
-- Nombre: Isabel Delgado  |  Fecha: 2026-08-01
-- Bootcamp SQL — NIEVA
-- ============================================================


-- ============================================================
-- PARTE 1: SETUP — Base de datos globalmart
-- ============================================================

DROP DATABASE IF EXISTS globalmart;
CREATE DATABASE globalmart;
USE globalmart;

CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    pais VARCHAR(50),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

INSERT INTO categorias (nombre) VALUES
    ('Electrónica'), ('Ropa'), ('Deportes'), ('Hogar'), ('Libros');

INSERT INTO productos (nombre, categoria_id, precio, costo, stock) VALUES
    ('Laptop HP',           1,  799.99, 600.00, 25),
    ('Mouse Logitech',      1,   25.99,  15.00, 150),
    ('Teclado Mecánico',    1,   89.99,  50.00, 80),
    ('Audífonos Sony',      1,  149.99,  90.00, 45),
    ('Monitor LG',          1,  299.99, 200.00, 30),
    ('Camiseta Nike',       2,   29.99,  12.00, 200),
    ('Zapatillas Adidas',   2,   89.99,  45.00, 90),
    ('Pantalón Levi',       2,   59.99,  30.00, 120),
    ('Chaqueta NF',         2,  149.99,  80.00, 50),
    ('Balón Fútbol',        3,   24.99,  10.00, 100),
    ('Raqueta Tenis',       3,  119.99,  60.00, 35),
    ('Bicicleta',           3,  499.99, 300.00, 15),
    ('Pesas 20kg',          3,   79.99,  40.00, 45),
    ('Licuadora',           4,   59.99,  30.00, 70),
    ('Cafetera',            4,  199.99, 120.00, 40),
    ('Aspiradora',          4,  399.99, 250.00, 20),
    ('Clean Code',          5,   39.99,  20.00, 60),
    ('Design Patterns',     5,   49.99,  25.00, 45),
    ('Refactoring',         5,   42.99,  21.00, 55),
    ('Producto sin ventas', 4,   29.99,  10.00, 30);

INSERT INTO clientes (nombre, email, pais, fecha_registro) VALUES
    ('Ana García',      'ana@email.com',    'España',    '2023-01-15'),
    ('Carlos López',    'carlos@email.com', 'México',    '2023-02-20'),
    ('María Torres',    'maria@email.com',  'Argentina', '2023-03-10'),
    ('Juan Pérez',      'juan@email.com',   'Colombia',  '2023-04-05'),
    ('Lucía Martínez',  'lucia@email.com',  'Chile',     '2023-05-12'),
    ('Diego Fernández', 'diego@email.com',  'Perú',      '2023-06-08'),
    ('Cliente nuevo',   'nuevo@email.com',  'México',    '2024-04-01');

INSERT INTO ventas (cliente_id, producto_id, cantidad, precio_unitario, fecha_venta) VALUES
    (1, 1,  1, 799.99, '2024-01-05'),
    (1, 6,  2,  29.99, '2024-01-10'),
    (1, 10, 1,  24.99, '2024-01-15'),
    (1, 14, 1,  59.99, '2024-01-20'),
    (1, 17, 1,  39.99, '2024-01-25'),
    (2, 2,  3,  25.99, '2024-02-01'),
    (2, 3,  1,  89.99, '2024-02-05'),
    (2, 7,  2,  89.99, '2024-02-10'),
    (3, 4,  1, 149.99, '2024-02-15'),
    (3, 11, 1, 119.99, '2024-02-20'),
    (4, 15, 1, 199.99, '2024-03-01'),
    (4, 16, 1, 399.99, '2024-03-05'),
    (5, 17, 5,  39.99, '2024-03-10'),
    (5, 18, 3,  49.99, '2024-03-15'),
    (6, 5,  1, 299.99, '2024-04-01'),
    (6, 9,  1, 149.99, '2024-04-05');


-- ============================================================
-- PARTE 2: SUBCONSULTAS ESCALARES (R1–R5)
-- ============================================================

-- R1. Productos más caros que el promedio global
-- La subconsulta calcula AVG una sola vez y ese valor se usa para filtrar
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos)
ORDER BY precio DESC;

-- R2. Clientes que gastaron más que el promedio de clientes
-- Subconsulta anidada: primero agrupa por cliente, luego promedia esos totales
SELECT cl.nombre, SUM(v.cantidad * v.precio_unitario) AS total_gastado
FROM clientes cl
JOIN ventas v ON cl.id = v.cliente_id
GROUP BY cl.id, cl.nombre
HAVING SUM(v.cantidad * v.precio_unitario) > (
    SELECT AVG(total_por_cliente)
    FROM (
        SELECT SUM(cantidad * precio_unitario) AS total_por_cliente
        FROM ventas
        GROUP BY cliente_id
    ) AS por_cliente
);

-- R3. Categorías con precio promedio mayor al promedio global
SELECT c.nombre, AVG(p.precio) AS promedio_categoria
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre
HAVING AVG(p.precio) > (SELECT AVG(precio) FROM productos);

-- R4. Productos sin ventas (NOT IN)
-- Decisión de diseño: WHERE producto_id IS NOT NULL evita la trampa del NULL en NOT IN
SELECT id, nombre, stock
FROM productos
WHERE id NOT IN (
    SELECT DISTINCT producto_id FROM ventas
    WHERE producto_id IS NOT NULL
);

-- R5. Productos con stock por encima del promedio de su categoría (correlacionada)
-- La subconsulta se ejecuta una vez por cada producto — compara contra su propio grupo
SELECT p.nombre, p.stock, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock > (
    SELECT AVG(p2.stock) FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);


-- ============================================================
-- PARTE 3: OPERADORES AVANZADOS (R6–R10)
-- ============================================================

-- R6. Clientes que compraron al menos 1 producto de Electrónica (IN)
SELECT DISTINCT cl.nombre
FROM clientes cl
JOIN ventas v ON cl.id = v.cliente_id
WHERE v.producto_id IN (
    SELECT p.id FROM productos p
    JOIN categorias cat ON p.categoria_id = cat.id
    WHERE cat.nombre = 'Electrónica'
);

-- R7. Productos que tienen al menos 1 venta (EXISTS)
-- EXISTS se detiene al primer match — más rápido que IN en tablas grandes
SELECT p.nombre, p.precio
FROM productos p
WHERE EXISTS (
    SELECT 1 FROM ventas v WHERE v.producto_id = p.id
);

-- R8. Clientes sin ninguna compra (NOT EXISTS)
-- Versión segura de "no aparece en otra tabla" — sin trampa del NULL
SELECT cl.nombre, cl.email, cl.pais
FROM clientes cl
WHERE NOT EXISTS (
    SELECT 1 FROM ventas v WHERE v.cliente_id = cl.id
);

-- R9. Productos más caros que TODOS los de Ropa (> ALL)
-- Equivalente a: precio > MAX(precio de Ropa)
SELECT nombre, precio
FROM productos
WHERE precio > ALL (
    SELECT p.precio FROM productos p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE c.nombre = 'Ropa'
);

-- R10. Productos más caros que AL MENOS UNO de Deportes (> ANY)
-- Equivalente a: precio > MIN(precio de Deportes)
SELECT nombre, precio
FROM productos
WHERE precio > ANY (
    SELECT p.precio FROM productos p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE c.nombre = 'Deportes'
);


-- ============================================================
-- PARTE 4: UNION (R11–R12)
-- ============================================================

-- R11. Productos etiquetados como En stock o Agotado
-- UNION ALL porque las dos queries son disjuntas — no puede haber duplicados
SELECT nombre, precio, 'En stock' AS estado
FROM productos WHERE stock > 0
UNION ALL
SELECT nombre, precio, 'Agotado'
FROM productos WHERE stock = 0
ORDER BY estado, nombre;

-- R12. Top 3 productos más caros por categoría
-- Paréntesis necesarios para que LIMIT aplique a cada bloque, no al total
(SELECT p.nombre, p.precio, 'Electrónica' AS categoria
 FROM productos p JOIN categorias c ON p.categoria_id = c.id
 WHERE c.nombre = 'Electrónica' ORDER BY p.precio DESC LIMIT 3)
UNION ALL
(SELECT p.nombre, p.precio, 'Ropa'
 FROM productos p JOIN categorias c ON p.categoria_id = c.id
 WHERE c.nombre = 'Ropa' ORDER BY p.precio DESC LIMIT 3)
UNION ALL
(SELECT p.nombre, p.precio, 'Deportes'
 FROM productos p JOIN categorias c ON p.categoria_id = c.id
 WHERE c.nombre = 'Deportes' ORDER BY p.precio DESC LIMIT 3);


-- ============================================================
-- PARTE 5: QUERIES COMPLEJAS (R13–R14)
-- ============================================================

-- R13. Clientes que compraron en TODAS las categorías
-- Compara categorías distintas compradas por el cliente vs total de categorías existentes
SELECT cl.nombre
FROM clientes cl
WHERE (
    SELECT COUNT(DISTINCT p.categoria_id)
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE v.cliente_id = cl.id
) = (SELECT COUNT(*) FROM categorias);

-- R14. Productos cuyas unidades vendidas superan el promedio de unidades por producto
-- Subconsulta anidada: agrupa por producto → promedia esos totales → filtra con HAVING
SELECT p.nombre, SUM(v.cantidad) AS unidades_vendidas
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.id, p.nombre
HAVING SUM(v.cantidad) > (
    SELECT AVG(unidades_por_producto)
    FROM (
        SELECT SUM(cantidad) AS unidades_por_producto
        FROM ventas
        GROUP BY producto_id
    ) AS por_producto
)
ORDER BY unidades_vendidas DESC;