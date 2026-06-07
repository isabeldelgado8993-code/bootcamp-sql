# 🎬 Proyecto StreamFlix — SQL Bootcamp Week 1

Este repositorio contiene la base de datos relacional de **StreamFlix**, un catálogo de streaming desarrollado desde cero en MySQL. El proyecto abarca desde la creación de la base de datos, el modelado detallado de tablas con tipos de datos óptimos, la inserción de registros reales y la ejecución de consultas con filtros avanzados.

## 🛠️ Tecnologías
*   **Motor de Datos:** MySQL (v8.0+)
*   **Entorno de Desarrollo:** MySQL Workbench

## 📂 Contenido del Repositorio
*   `entrega_semana1.sql`: Script completo estructurado en tres bloques principales: Diseño DDL, inserción de datos DML y explotación del catálogo mediante 14 consultas analíticas (DQL).

---

## 🧠 Conceptos Aplicados y Estructura del Script

### 1. Arquitectura de Datos (DDL)
Se diseñó la tabla `peliculas` asegurando la integridad de los datos mediante restricciones de nulidad (`NOT NULL`), valores automáticos (`AUTO_INCREMENT`), control de estados lógicos (`BOOLEAN`) y fechas de auditoría automáticas (`DEFAULT CURRENT_DATE`).

### 2. Inserción de Registros (DML)
Población de la base de datos con un catálogo inicial de 15 películas icónicas de la industria cinematográfica recopilando métricas reales de año, duración, género y calificación exacta.

### 3. Explotación Analítica (DQL)
Desarrollo de consultas de negocio cubriendo los siguientes requerimientos:
*   **Filtros de Rangos y Conjuntos:** Uso de `BETWEEN` para análisis por décadas y cláusulas `IN` para agrupaciones de categorías múltiples.
*   **Búsquedas de Texto Avanzadas:** Uso de comodines `%` con operadores `LIKE` para coincidencias parciales y filtrado de directores.
*   **Optimización de Resultados:** Implementación de sentencias `DISTINCT` para eliminar redundancia, ordenamientos con `ORDER BY` y segmentación de datos con cláusulas de paginación `LIMIT`.

---

## 💻 Consulta Destacada de la Semana (Reto Complejo)
De entre los desafíos resueltos de la entrega, esta consulta demuestra el dominio de filtros lógicos cruzados y ordenación de datos prioritarios:

```sql
-- Filtrar películas de Acción o Ciencia Ficción estrenadas en el siglo XXI con nota superior a 8.0
SELECT titulo, genero, calificacion, año
FROM peliculas
WHERE genero IN ('Acción', 'Ciencia Ficción')
  AND calificacion > 8.0
  AND año > 2000
ORDER BY calificacion DESC;
```

---

## 📐 Decisiones de Ingeniería de Datos Adoptadas
A diferencia de un desarrollo básico, la base de datos fue optimizada bajo los siguientes estándares de producción:

*   **Precisión Financiera y Métrica:** Uso de `DECIMAL(3,1)` para el campo `calificacion` en lugar de datos de punto flotante (`FLOAT`), evitando errores binarios de aproximación de software y asegurando exactitud estricta en las notas de los usuarios.
*   **Eficiencia en el Almacenamiento:** Elección de `VARCHAR(200)` para los títulos frente al tipo de datos `TEXT`, optimizando la velocidad de respuesta, el uso de memoria en disco y permitiendo la correcta indexación futura de las búsquedas frecuentes.
