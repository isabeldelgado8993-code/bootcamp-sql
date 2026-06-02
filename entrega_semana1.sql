-- ENTREGA SEMANA 1 - CATALOGO STREAMFLIX
-- Nombre: Isabel
-- Fecha: 02/06/2026

-- PARTE 1: DISEÑO DE BD
DROP DATABASE IF EXISTS streamflix;
CREATE DATABASE streamflix;
USE streamflix;

CREATE TABLE peliculas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    titulo_original VARCHAR(200),
    director VARCHAR(100) NOT NULL,
    año INT NOT NULL,
    duracion_minutos INT,
    genero VARCHAR(50) NOT NULL,
    calificacion DECIMAL(3, 1),
    sinopsis TEXT,
    idioma_original VARCHAR(50) DEFAULT 'Inglés',
    destacada BOOLEAN DEFAULT FALSE,
    fecha_agregada DATE DEFAULT (CURRENT_DATE)
);

-- PARTE 2: INSERCIÓN DE DATOS
INSERT INTO peliculas
    (titulo, titulo_original, director, año, duracion_minutos, genero, calificacion, sinopsis, idioma_original, destacada)
VALUES
    ('El Padrino', 'The Godfather', 'Francis Ford Coppola', 1972, 175, 'Drama', 9.2,
     'La historia de la familia Corleone en el mundo de la mafia italiana.', 'Inglés', TRUE),
    ('Pulp Fiction', 'Pulp Fiction', 'Quentin Tarantino', 1994, 154, 'Crimen', 8.9,
     'Historias entrelazadas de criminales en Los Ángeles.', 'Inglés', TRUE),
    ('El Caballero de la Noche', 'The Dark Knight', 'Christopher Nolan', 2008, 152, 'Acción', 9.0,
     'Batman enfrenta al caótico Joker en Gotham City.', 'Inglés', TRUE),
    ('Inception', 'Inception', 'Christopher Nolan', 2010, 148, 'Ciencia Ficción', 8.8,
     'Un ladrón que roba secretos del subconsciente durante el sueño.', 'Inglés', TRUE),
    ('Forrest Gump', 'Forrest Gump', 'Robert Zemeckis', 1994, 142, 'Drama', 8.8,
     'La vida extraordinaria de un hombre simple que presencia eventos históricos.', 'Inglés', TRUE),
    ('Matrix', 'The Matrix', 'Lana y Lilly Wachowski', 1999, 136, 'Ciencia Ficción', 8.7,
     'Un programador descubre que la realidad es una simulación.', 'Inglés', FALSE),
    ('El Señor de los Anillos: La Comunidad del Anillo', 'The Lord of the Rings: The Fellowship of the Ring',
     'Peter Jackson', 2001, 178, 'Fantasía', 8.8,
     'Frodo inicia su viaje para destruir el Anillo Único.', 'Inglés', TRUE),
    ('Gladiador', 'Gladiator', 'Ridley Scott', 2000, 155, 'Acción', 8.5,
     'Un general romano busca venganza contra el emperador corrupto.', 'Inglés', FALSE),
    ('El Laberinto del Fauno', 'El Laberinto del Fauno', 'Guillermo del Toro', 2006, 118, 'Fantasía', 8.2,
     'Una niña descubre un mundo mágico durante la Guerra Civil Española.', 'Español', FALSE),
    ('Interestelar', 'Interstellar', 'Christopher Nolan', 2014, 169, 'Ciencia Ficción', 8.6,
     'Exploradores viajan por un agujero de gusano buscando un nuevo hogar.', 'Inglés', FALSE),
    ('Parásitos', 'Gisaengchung', 'Bong Joon-ho', 2019, 132, 'Thriller', 8.6,
     'Una familia pobre infiltra la casa de una familia rica.', 'Coreano', TRUE),
    ('Tiempos Violentos', 'Reservoir Dogs', 'Quentin Tarantino', 1992, 99, 'Crimen', 8.3,
     'Un atraco sale mal y los criminales sospechan de un traidor.', 'Inglés', FALSE),
    ('El Club de la Pelea', 'Fight Club', 'David Fincher', 1999, 139, 'Drama', 8.8,
     'Un hombre insomne forma un club clandestino de pelea.', 'Inglés', FALSE),
    ('La Lista de Schindler', 'Schindler''s List', 'Steven Spielberg', 1993, 195, 'Drama', 9.0,
     'La historia real de un empresario que salvó a más de mil judíos.', 'Inglés', TRUE),
    ('Toy Story', 'Toy Story', 'John Lasseter', 1995, 81, 'Animación', 8.3,
     'Los juguetes de Andy cobran vida cuando él no está.', 'Inglés', FALSE);

     -- PARTE 3: CONSULTAS

-- Q1: Listado básico (título, director y año)
SELECT titulo, director, año
FROM peliculas;
-- Q2: Solo películas destacadas
SELECT titulo, calificacion, destacada
FROM peliculas
WHERE destacada = TRUE;
-- Q3: Películas de Ciencia Ficción
SELECT titulo, genero, año
FROM peliculas
WHERE genero = 'Ciencia Ficción';
-- Q4: Películas con calificación mayor a 8.5
SELECT titulo, calificacion
FROM peliculas
WHERE calificacion > 8.5
ORDER BY calificacion DESC;
-- Q5: Películas estrenadas entre 1990 y 2000
SELECT titulo, año
FROM peliculas
WHERE año BETWEEN 1990 AND 2000
ORDER BY año;
-- Q6: Películas de Drama o Thriller
SELECT titulo, genero
FROM peliculas
WHERE genero IN ('Drama', 'Thriller');
-- Q7: Títulos que empiezan con "El"
SELECT titulo
FROM peliculas
WHERE titulo LIKE 'El%';
-- Q8: Directores cuyo nombre contiene "Nolan"
SELECT DISTINCT director
FROM peliculas
WHERE director LIKE '%Nolan%';
-- Q9: Top 5 películas mejor calificadas
SELECT titulo, calificacion
FROM peliculas
ORDER BY calificacion DESC
LIMIT 5;
-- Q10: Las 3 películas más antiguas
SELECT titulo, año
FROM peliculas
ORDER BY año ASC
LIMIT 3;
-- Q11: Películas ordenadas por duración (más largas primero)
SELECT titulo, duracion_minutos
FROM peliculas
WHERE duracion_minutos IS NOT NULL
ORDER BY duracion_minutos DESC;

-- BONUS: Reto 1
SELECT titulo, genero, calificacion, año
FROM peliculas
WHERE genero IN ('Acción', 'Ciencia Ficción')
  AND calificacion > 8.0
  AND año > 2000
ORDER BY calificacion DESC;
-- BONUS: Reto 2
SELECT DISTINCT genero
FROM peliculas
ORDER BY genero;
-- BONUS: Reto 3
SELECT titulo, destacada, duracion_minutos, calificacion
FROM peliculas
WHERE destacada = TRUE
  AND duracion_minutos > 140
  AND calificacion > 8.5
ORDER BY calificacion DESC;

-- DECISIONES DE DISEÑO
-- ======================================
--
-- 1. ¿Por qué DECIMAL(3,1) para calificacion en vez de FLOAT?
--    DECIMAL guarda el número exacto: 9.5 es siempre 9.5.
--    FLOAT aproxima en binario y puede devolver 9.4999999.
--    Para calificaciones, donde la precisión importa, DECIMAL es la única opción correcta.
--
-- 2. ¿Por qué VARCHAR(200) para titulo en vez de TEXT?
--    Un título tiene un límite lógico de caracteres, VARCHAR(200) lo cubre perfectamente.
--    Además VARCHAR es más rápido en búsquedas e índices.
--    TEXT se reserva para contenido largo sin límite conocido, como la sinopsis.
--
-- 3. ¿Qué ventaja tiene AUTO_INCREMENT en id?
--    MySQL genera el número solo, de forma consecutiva y sin repeticiones.
--    Elimina el riesgo de duplicar un id por error humano y simplifica los INSERTs
--    porque no necesitas especificar el id manualmente.
--
-- 4. Si tuvieras que agregar precio_renta, ¿qué tipo usarías?
--    DECIMAL(5,2) — es dinero, necesita precisión exacta.
--    5 dígitos totales y 2 decimales cubre hasta $999.99, suficiente para rentas.
--
-- 5. ¿Qué fue lo que más te sorprendió esta semana?
--    Lo bien que se estructura todo en SQL: la lógica es muy clara y
--    las queries se leen casi como frases en inglés. Ver cómo cada
--    concepto encaja con el siguiente hace que todo tenga sentido.