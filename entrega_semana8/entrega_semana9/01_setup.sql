-- ============================================================
-- Semana 9 — Vistas (Views)
-- Archivo 01: Setup — Base de datos TechStore
-- ============================================================

DROP DATABASE IF EXISTS techstore;
CREATE DATABASE techstore;
USE techstore;

-- Tablas
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100),
    registered_at DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Datos
INSERT INTO categories (name) VALUES
    ('Laptops'), ('Smartphones'), ('Tablets'), ('Accessories'), ('Audio');

INSERT INTO products (name, category_id, price, cost, stock, is_active) VALUES
    ('MacBook Air M2',              1, 1299.00, 1000.00, 12, TRUE),
    ('Dell XPS 13',                 1, 1499.00, 1100.00,  8, TRUE),
    ('HP Pavilion 15',              1,  799.00,  600.00,  5, TRUE),
    ('Lenovo Yoga (discontinued)',  1,  899.00,  700.00,  0, FALSE),
    ('iPhone 15',                   2,  999.00,  750.00, 25, TRUE),
    ('Samsung S24',                 2,  849.00,  640.00, 18, TRUE),
    ('Pixel 8',                     2,  699.00,  500.00,  3, TRUE),
    ('iPad Air',                    3,  599.00,  430.00, 15, TRUE),
    ('iPad Pro',                    3,  999.00,  720.00,  9, TRUE),
    ('Samsung Tab S9',              3,  649.00,  470.00,  4, TRUE),
    ('Mouse Logitech MX3',          4,   99.00,   65.00, 50, TRUE),
    ('Keychron K2 Keyboard',        4,   89.00,   55.00, 35, TRUE),
    ('USB-C Hub 7-port',            4,   45.00,   25.00,  2, TRUE),
    ('HDMI Cable 2.1',              4,   19.00,    8.00, 80, TRUE),
    ('Sony WH-1000 Headphones',     5,  399.00,  280.00,  6, TRUE),
    ('AirPods Pro',                 5,  249.00,  180.00, 11, TRUE),
    ('Bose Speakers',               5,  199.00,  130.00,  7, TRUE),
    ('Blue Yeti Microphone',        5,  129.00,   85.00,  8, TRUE);

INSERT INTO customers (name, email, city, country, registered_at, is_active) VALUES
    ('Alice Garcia',     'alice@email.com',    'Madrid',       'Spain',     '2023-01-15', TRUE),
    ('Charles Lopez',    'charles@email.com',  'Mexico City',  'Mexico',    '2023-03-20', TRUE),
    ('Mary Torres',      'mary@email.com',     'Buenos Aires', 'Argentina', '2023-05-10', TRUE),
    ('John Perez',       'john@email.com',     'Bogota',       'Colombia',  '2023-07-05', TRUE),
    ('Lucy Martinez',    'lucy@email.com',     'Lima',         'Peru',      '2023-09-12', TRUE),
    ('David Fernandez',  'david@email.com',    'Santiago',     'Chile',     '2024-01-08', TRUE),
    ('Inactive Customer','inactive@email.com', 'Mexico City',  'Mexico',    '2023-02-01', FALSE);

INSERT INTO sales (customer_id, product_id, quantity, unit_price, discount, sale_date) VALUES
    (1,  1, 1, 1299.00,  5, '2024-01-10'),
    (1,  5, 1,  999.00,  0, '2024-02-05'),
    (1, 11, 2,   99.00, 10, '2024-02-20'),
    (1,  8, 1,  599.00,  5, '2024-03-15'),
    (1, 15, 1,  399.00,  0, '2024-04-02'),
    (1, 18, 1,  129.00, 10, '2024-04-15'),
    (2,  3, 1,  799.00,  0, '2024-01-20'),
    (2, 12, 1,   89.00,  5, '2024-02-10'),
    (2, 14, 3,   19.00,  0, '2024-03-05'),
    (3,  6, 1,  849.00, 10, '2024-02-15'),
    (3, 16, 1,  249.00,  0, '2024-04-10'),
    (4, 11, 1,   99.00,  0, '2024-03-20'),
    (5,  9, 1,  999.00,  5, '2024-04-25'),
    (6, 11, 2,   99.00,  5, '2024-01-25'),
    (6, 12, 1,   89.00,  0, '2024-02-15'),
    (6, 13, 1,   45.00,  0, '2024-03-08'),
    (6, 14, 5,   19.00,  0, '2024-04-12');