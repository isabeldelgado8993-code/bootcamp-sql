-- ======================================
-- ENTREGA SEMANA 3 — BIBLIOTECH LIBRARY
-- Nombre: Isabel Delgado
-- Fecha: 22/06/2026
-- ======================================

-- ============ PARTE 1: ERD ============
-- Diagrama entidad-relación del sistema BiblioTech
-- Imagen: https://github.com/isabeldelgado8993-code/bootcamp-sql/blob/main/erd_week3.png

-- ============ SETUP ============
DROP DATABASE IF EXISTS library;
CREATE DATABASE library;
USE library;

SELECT DATABASE(); -- debe imprimir 'library'

-- ============ PARTE 2: DDL — 6 TABLAS ============

-- 2.1 CATEGORIES
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 2.2 AUTHORS
CREATE TABLE authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    country VARCHAR(50),
    birth_date DATE,
    biography TEXT
);

-- 2.3 USERS
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    membership_type ENUM('basic', 'premium', 'vip') DEFAULT 'basic',
    is_active BOOLEAN DEFAULT TRUE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.4 BOOKS (con FK a categories y CHECKs)
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(250) NOT NULL,
    category_id INT,
    publication_year INT,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_year  CHECK (publication_year BETWEEN 1450 AND 2100),
    CONSTRAINT chk_price CHECK (price > 0),
    CONSTRAINT chk_stock CHECK (stock >= 0)
);

-- 2.5 LOANS (con 2 FKs y RESTRICT)
CREATE TABLE loans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    fine DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,

    CONSTRAINT fk_loans_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_loans_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_fine CHECK (fine >= 0),
    CONSTRAINT chk_return_date CHECK (
        return_date IS NULL OR
        return_date >= loan_date
    )
);

-- 2.6 BOOK_AUTHORS (tabla pivote N:M)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,

    PRIMARY KEY (book_id, author_id),

    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE CASCADE
);

-- ============ PARTE 3: DML — DATOS EN ORDEN ============

-- categories → authors → users → books → book_authors → loans

INSERT INTO categories (name, description) VALUES
    ('Fiction',    'Novels and fiction stories'),
    ('Science',    'Scientific and technical books'),
    ('History',    'History books and biographies'),
    ('Children',   'Literature for children'),
    ('Technology', 'Programming, development, AI');

INSERT INTO authors (name, country, birth_date) VALUES
    ('Gabriel García Márquez', 'Colombia',       '1927-03-06'),
    ('Isabel Allende',         'Chile',          '1942-08-02'),
    ('Stephen Hawking',        'United Kingdom', '1942-01-08'),
    ('J.K. Rowling',           'United Kingdom', '1965-07-31'),
    ('Yuval Noah Harari',      'Israel',         '1976-02-24'),
    ('Roald Dahl',             'United Kingdom', '1916-09-13'),
    ('Andrew S. Tanenbaum',    'United States',  '1944-03-16'),
    ('Ian Goodfellow',         'United States',  '1985-01-01'),
    ('Yoshua Bengio',          'Canada',         '1964-03-05'),
    ('Eric Matthes',           'United States',  '1970-01-01'),
    ('Joshua Bloch',           'United States',  '1961-08-28');

INSERT INTO users (email, name, phone, membership_type) VALUES
    ('alice.garcia@email.com',     'Alice Garcia',     '555-0001', 'premium'),
    ('charles.lopez@email.com',    'Charles Lopez',    '555-0002', 'basic'),
    ('mary.torres@email.com',      'Mary Torres',      '555-0003', 'vip'),
    ('john.perez@email.com',       'John Perez',        NULL,      'basic'),
    ('lucy.martinez@email.com',    'Lucy Martinez',    '555-0005', 'premium'),
    ('sophie.rodriguez@email.com', 'Sophie Rodriguez', '555-0006', 'basic'),
    ('david.fernandez@email.com',  'David Fernandez',   NULL,      'basic');

INSERT INTO books (isbn, title, category_id, publication_year, price, stock) VALUES
    ('978-0307474728', 'One Hundred Years of Solitude',             1, 1967, 18.99, 5),
    ('978-0142437247', 'The House of the Spirits',                  1, 1982, 16.50, 3),
    ('978-0439708180', 'Harry Potter and the Philosopher''s Stone', 1, 1997, 22.99, 8),
    ('978-0553380163', 'A Brief History of Time',                   2, 1988, 15.99, 4),
    ('978-0062316097', 'Sapiens: A Brief History of Humankind',     2, 2011, 24.99, 6),
    ('978-0062464310', 'Homo Deus',                                 2, 2015, 26.50, 4),
    ('978-0062315007', '21 Lessons for the 21st Century',           3, 2018, 20.99, 5),
    ('978-0142410318', 'Matilda',                                   4, 1988, 12.99, 10),
    ('978-0142410387', 'Charlie and the Chocolate Factory',         4, 1964, 14.50, 7),
    ('978-0141365534', 'The BFG',                                   4, 1982, 13.99, 6),
    ('978-0132126953', 'Modern Operating Systems',                  5, 2007, 89.99, 3),
    ('978-0262035613', 'Deep Learning',                             5, 2016, 75.00, 2),
    ('978-0135957059', 'Computer Networks',                         5, 2010, 95.50, 2),
    ('978-1593279288', 'Python Crash Course',                       5, 2019, 39.99, 8),
    ('978-0134685991', 'Effective Java',                            5, 2017, 54.99, 4);

INSERT INTO book_authors (book_id, author_id, author_order) VALUES
    (1,  1, 1),   -- One Hundred Years → García Márquez
    (2,  2, 1),   -- The House of the Spirits → Allende
    (3,  4, 1),   -- Harry Potter → Rowling
    (4,  3, 1),   -- A Brief History → Hawking
    (5,  5, 1),   -- Sapiens → Harari
    (6,  5, 1),   -- Homo Deus → Harari
    (7,  5, 1),   -- 21 Lessons → Harari
    (8,  6, 1),   -- Matilda → Dahl
    (9,  6, 1),   -- Charlie → Dahl
    (10, 6, 1),   -- The BFG → Dahl
    (11, 7, 1),   -- Modern Operating Systems → Tanenbaum
    (12, 8, 1),   -- Deep Learning → Goodfellow (autor principal)
    (12, 9, 2),   -- Deep Learning → Bengio (co-autor)
    (13, 7, 1),   -- Computer Networks → Tanenbaum
    (14, 10, 1),  -- Python Crash Course → Matthes
    (15, 11, 1);  -- Effective Java → Bloch

INSERT INTO loans (user_id, book_id, loan_date, due_date, return_date, fine) VALUES
    -- Devueltos (históricos)
    (1, 1, '2024-01-01', '2024-01-15', '2024-01-14',  0.00),  -- Alice, a tiempo
    (2, 3, '2024-01-05', '2024-01-19', '2024-01-25', 15.00),  -- Charles, 6 días tarde
    (3, 5, '2024-01-08', '2024-01-22', '2024-01-20',  0.00),  -- Mary, antes
    (1, 8, '2024-01-10', '2024-01-24', '2024-01-23',  0.00),  -- Alice, a tiempo
    (4, 9, '2024-01-12', '2024-01-26', '2024-02-05', 25.00),  -- John, 10 días tarde

    -- Activos (return_date = NULL)
    (1,  4, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL  6 DAY), NULL, 0.00),
    (5,  5, DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL  2 DAY), NULL, 0.00),
    (6, 10, DATE_SUB(CURDATE(), INTERVAL  9 DAY), DATE_ADD(CURDATE(), INTERVAL  5 DAY), NULL, 0.00),
    (7, 14, DATE_SUB(CURDATE(), INTERVAL  6 DAY), DATE_ADD(CURDATE(), INTERVAL  8 DAY), NULL, 0.00),
    (2, 11, DATE_SUB(CURDATE(), INTERVAL  4 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), NULL, 0.00);

-- Verificación general
SELECT
    (SELECT COUNT(*) FROM categories) AS categories,
    (SELECT COUNT(*) FROM authors)    AS authors,
    (SELECT COUNT(*) FROM books)      AS books,
    (SELECT COUNT(*) FROM users)      AS users;

-- Verificación N:M: libros co-escritos
SELECT b.title, COUNT(*) AS num_authors
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
GROUP BY ba.book_id, b.title
HAVING COUNT(*) > 1;

-- ============ PARTE 4: REPORTES ============

-- 5.1 Libros de tecnología con su autor
SELECT
    b.title,
    a.name AS author,
    b.price,
    b.stock
FROM books b
JOIN categories   c  ON b.category_id = c.id
JOIN book_authors ba ON b.id = ba.book_id
JOIN authors      a  ON ba.author_id = a.id
WHERE c.name = 'Technology'
ORDER BY b.title, ba.author_order;

-- 5.2 Usuarios con préstamos activos
SELECT
    u.name AS user,
    b.title AS book,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_late
FROM users u
JOIN loans l ON u.id = l.user_id
JOIN books b ON l.book_id = b.id
WHERE l.return_date IS NULL
ORDER BY l.due_date;

-- 5.3 Top 5 libros más prestados
SELECT
    b.title,
    a.name AS author,
    COUNT(l.id) AS times_borrowed
FROM books b
LEFT JOIN loans        l  ON b.id = l.book_id
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN authors      a  ON ba.author_id = a.id
GROUP BY b.id, b.title, a.name
ORDER BY times_borrowed DESC, b.title
LIMIT 5;

-- 5.4 Total de multas por usuario
SELECT
    u.name AS user,
    COUNT(l.id) AS num_loans,
    SUM(l.fine) AS total_fines
FROM users u
LEFT JOIN loans l ON u.id = l.user_id
GROUP BY u.id, u.name
HAVING total_fines > 0
ORDER BY total_fines DESC;

-- ============ PARTE 5: TRANSACCIONES ============

-- 6.1 Registrar préstamo (Mary pide Deep Learning, libro id=12)
START TRANSACTION;
-- Paso 1: verificar stock
SELECT id, title, stock FROM books WHERE id = 12 AND stock > 0;
-- Paso 2: reducir stock
UPDATE books SET stock = stock - 1 WHERE id = 12;
-- Paso 3: registrar el préstamo (14 días)
INSERT INTO loans (user_id, book_id, loan_date, due_date)
VALUES (3, 12, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
-- Paso 4: verificar antes de confirmar
SELECT id, title, stock FROM books WHERE id = 12;
SELECT * FROM loans WHERE id = LAST_INSERT_ID();
-- Paso 5: confirmar
COMMIT;

-- 6.2 Devolución con multa (Alice, préstamo id=6)
START TRANSACTION;
-- Paso 1: calcular multa ($2.50/día)
SET @days_late = (SELECT DATEDIFF(CURDATE(), due_date) FROM loans WHERE id = 6);
SET @fine = GREATEST(0, @days_late * 2.50);
SELECT @days_late AS dias_retraso, @fine AS multa;
-- Paso 2: marcar como devuelto
UPDATE loans SET return_date = CURDATE(), fine = @fine WHERE id = 6;
-- Paso 3: devolver al stock
UPDATE books SET stock = stock + 1
WHERE id = (SELECT book_id FROM loans WHERE id = 6);
-- Paso 4: verificar y confirmar
SELECT id, return_date, fine FROM loans WHERE id = 6;
COMMIT;

-- ============ PARTE 6: PRUEBAS DE INTEGRIDAD ============

-- 7.1 ON DELETE SET NULL
START TRANSACTION;
SELECT id, title, category_id FROM books WHERE id = 7;  -- antes: cat=3
DELETE FROM categories WHERE id = 3;
SELECT id, title, category_id FROM books WHERE id = 7;  -- después: NULL
ROLLBACK;

-- 7.2 ON DELETE RESTRICT
DELETE FROM users WHERE id = 1;  -- Error 1451 esperado

START TRANSACTION;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM loans WHERE user_id = 1;
SET SQL_SAFE_UPDATES = 1;
DELETE FROM users WHERE id = 1;  -- ahora sí funciona
ROLLBACK;
SELECT name FROM users WHERE id = 1;  -- Alice sigue ahí ✅

-- 7.3 CHECK rechazando valores inválidos
INSERT INTO books (isbn, title, publication_year, price)
VALUES ('978-0000000001', 'Medieval manuscript', 1200, 29.99);  -- Error 3819: chk_year

INSERT INTO books (isbn, title, publication_year, price)
VALUES ('978-0000000002', 'Free book', 2020, -10.00);  -- Error 3819: chk_price

SELECT COUNT(*) FROM books;  -- sigue siendo 15 ✅

-- ============ BONUS ============

-- BONUS 1: Tabla de reseñas (+5 pts)
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    rating INT,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    UNIQUE (user_id, book_id)
);

INSERT INTO reviews (user_id, book_id, rating, comment) VALUES
    (1, 1, 5, 'Masterpiece, absolutely loved it'),
    (2, 3, 4, 'Great read for Harry Potter fans'),
    (3, 5, 5, 'Changed the way I see history'),
    (1, 8, 4, 'Perfect for kids and adults alike'),
    (5, 12, 5, 'Essential for anyone in AI');

-- BONUS 2: Trigger de auditoría de precios (+5 pts)
CREATE TABLE price_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER tr_price_audit
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_audit (book_id, old_price, new_price)
        VALUES (NEW.id, OLD.price, NEW.price);
    END IF;
END$$
DELIMITER ;

UPDATE books SET price = 29.99 WHERE id = 5;
SELECT * FROM price_audit;

-- BONUS 3: Vista de libros disponibles (+5 pts)
CREATE VIEW available_books AS
SELECT
    b.id,
    b.title,
    a.name AS author,
    c.name AS category,
    b.price,
    b.stock
FROM books b
JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
JOIN authors a       ON ba.author_id = a.id
JOIN categories c    ON b.category_id = c.id
WHERE b.stock > 0
ORDER BY b.title;

SELECT * FROM available_books;