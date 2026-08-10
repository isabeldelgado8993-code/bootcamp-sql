-- ============================================================
-- SEMANA 7 — TechStore: Tercera Forma Normal (3FN)
-- Archivo 04: Esquema final — eliminar dependencias transitivas
-- 9 tablas: geografía, organización, productos, transacciones
-- ============================================================

DROP DATABASE IF EXISTS techstore_3fn;
CREATE DATABASE techstore_3fn;
USE techstore_3fn;

-- ============================================================
-- GEOGRAFÍA — cadena: ciudad → estado → país
-- Dependencia transitiva eliminada con 3 tablas catálogo
-- ============================================================

CREATE TABLE paises (
    pais_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre  VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE estados (
    estado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(50) NOT NULL,
    pais_id   INT NOT NULL,
    FOREIGN KEY (pais_id) REFERENCES paises(pais_id),
    UNIQUE (nombre, pais_id)
);

CREATE TABLE ciudades (
    ciudad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(50) NOT NULL,
    estado_id INT NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES estados(estado_id),
    UNIQUE (nombre, estado_id)
);

-- ============================================================
-- ORGANIZACIÓN — cadena: vendedor → departamento → jefe
-- Dependencia transitiva eliminada separando departamentos
-- ============================================================

CREATE TABLE departamentos (
    departamento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(50)  UNIQUE NOT NULL,
    jefe            VARCHAR(100)
);

CREATE TABLE vendedores (
    vendedor_id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    departamento_id INT NOT NULL,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(departamento_id)
);

-- ============================================================
-- CLIENTES — referencia ciudad_id en lugar de texto duplicado
-- ============================================================

CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    telefono   VARCHAR(20),
    ciudad_id  INT,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(ciudad_id)
);

-- ============================================================
-- PRODUCTOS — categoria en su propia tabla (dependencia transitiva)
-- producto → categoria eliminada separando categorias
-- ============================================================

CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) UNIQUE NOT NULL,
    categoria_id INT NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
);

-- ============================================================
-- TRANSACCIONES
-- ============================================================

CREATE TABLE ventas (
    venta_id    INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    vendedor_id INT NOT NULL,
    cliente_id  INT NOT NULL,
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(vendedor_id),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id)
);

CREATE TABLE venta_items (
    venta_id     INT           NOT NULL,
    producto_id  INT           NOT NULL,
    cantidad     INT           NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL, -- precio al momento de la venta (dato histórico)
    descuento    DECIMAL(5,2)  DEFAULT 0,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id)    REFERENCES ventas(venta_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- Verificar estructura
SHOW TABLES;