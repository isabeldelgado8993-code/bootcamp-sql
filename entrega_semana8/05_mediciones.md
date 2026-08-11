# Semana 8 — Mediciones de Performance
## MegaMart: de queries lentas a queries optimizadas

**Entorno:** MySQL 8.0 + Workbench 8.0.47 | Windows 11  
**Volumen:** 207.575 productos | 5.000 clientes | 20.000 ventas | 8 categorías  
**Fecha:** 2026-08-11

---

## Tabla comparativa antes/después

| Query | Descripción | Antes | Después | Mejora |
|-------|-------------|-------|---------|--------|
| Q1 | LIKE '%laptop%' → FULLTEXT | 0.375s | 0.016s | ~23x |
| Q2 | JOIN categoría sin índice | 0.000s | 0.000s | índice aplicado |
| Q3 | DATE(fecha_venta) → rango | 0.016s | 0.000s | >16x |
| Q4 | Lookup por email | 0.000s | 0.000s | índice aplicado |
| Q5 | Filtro stock + activo | 0.015s | 0.000s | >15x |
| Q6 | Subconsultas → JOIN+GROUP BY | 64.750s | 0.219s | ~295x |

> Q2 y Q4 ya eran rápidas en tabla pequeña pero el índice es crítico en producción con millones de filas.

---

## Diagnóstico EXPLAIN — Antes (sin índices)

### Q1 — LIKE '%laptop%'
| Columna | Valor |
|---------|-------|
| type | ALL |
| key | NULL |
| rows | 206.430 |
| Problema | LIKE con % al inicio = Full Table Scan. B-Tree no puede navegar con prefijo desconocido. |

### Q2 — JOIN categoría
| Columna | Valor |
|---------|-------|
| type | ALL (ambas tablas) |
| key | NULL |
| rows | 8 + 206.430 |
| Problema | Sin índice en categoria_id ni categorias.nombre → hash join sin índice. |

### Q3 — DATE(fecha_venta)
| Columna | Valor |
|---------|-------|
| type | ALL |
| key | NULL |
| rows | 19.815 |
| Problema | Función DATE() sobre columna indexada invalida el B-Tree. |

### Q4 — Lookup por email
| Columna | Valor |
|---------|-------|
| type | ALL |
| key | NULL |
| rows | 4.989 |
| Problema | Sin índice en email → full scan para encontrar 1 fila. |

### Q5 — stock=0 AND activo=TRUE
| Columna | Valor |
|---------|-------|
| type | ALL |
| key | NULL |
| rows | 206.430 |
| Problema | Sin índice compuesto → full scan con doble filtro. |

### Q6 — Subconsultas correlacionadas
| Columna | Valor |
|---------|-------|
| type | ALL (3 filas: PRIMARY + 2 DEPENDENT SUBQUERY) |
| key | NULL |
| rows | 4.989 + 19.815 + 19.815 |
| Problema | 2 subconsultas × 4.989 clientes = ~10.000 ejecuciones sobre ventas. |

---

## Diagnóstico EXPLAIN — Después (con índices y reescrituras)

### Q1 — MATCH(nombre) AGAINST('laptop')
| Columna | Valor |
|---------|-------|
| type | fulltext |
| key | ft_productos_nombre |
| rows | 1 |

### Q2 — JOIN con idx_productos_categoria_id
| Columna | Valor |
|---------|-------|
| type | ref (categorias) + ref (productos) |
| key | idx_categorias_nombre + idx_productos_categoria_id |
| rows | 1 + 29.466 |
| Nota | categorias resuelve en 1 fila; productos filtra por categoria_id sin full scan |

### Q3 — Rango de fechas sin DATE()
| Columna | Valor |
|---------|-------|
| type | range |
| key | idx_ventas_fecha |
| rows | 54 |

### Q4 — Lookup por email con UNIQUE index
| Columna | Valor |
|---------|-------|
| type | const |
| key | idx_clientes_email |
| rows | 1 |

### Q5 — Filtro compuesto con idx_productos_stock_activo
| Columna | Valor |
|---------|-------|
| type | ref |
| key | idx_productos_stock_activo |
| rows | 1.919 |

### Q6 — JOIN + GROUP BY con idx_ventas_cliente
| Columna | Valor |
|---------|-------|
| type | ALL (clientes) + ref (ventas) |
| key | idx_ventas_cliente |
| rows | 4.989 clientes + 3 filas por lookup en ventas |
| Nota | ventas pasa de 19.815 a 3 filas por cliente — de ahí el salto de 64.750s a 0.219s |

---

## Índices creados

| Índice | Tabla | Columna(s) | Tipo | Resuelve |
|--------|-------|------------|------|---------|
| ft_productos_nombre | productos | nombre | FULLTEXT | Q1 |
| idx_productos_categoria_id | productos | categoria_id | INDEX | Q2 |
| idx_categorias_nombre | categorias | nombre | INDEX | Q2 |
| idx_ventas_fecha | ventas | fecha_venta | INDEX | Q3 |
| idx_clientes_email | clientes | email | UNIQUE | Q4 |
| idx_productos_stock_activo | productos | stock, activo | INDEX compuesto | Q5 |
| idx_ventas_cliente | ventas | cliente_id | INDEX | Q6 |
| idx_ventas_producto | ventas | producto_id | INDEX | Q6 |

---

## Conclusiones

- Q6 pasó de 64.750s a 0.219s (~295x) solo reescribiendo subconsultas como JOIN+GROUP BY.
- Funciones en WHERE invalidan cualquier índice B-Tree — mover la transformación al valor.
- LIKE con % al inicio requiere FULLTEXT, no B-Tree.
- Índices compuestos resuelven filtros de baja cardinalidad combinando columnas.
- El 80% de los problemas de performance se resuelven con índices bien colocados + reescritura de antipatrones.