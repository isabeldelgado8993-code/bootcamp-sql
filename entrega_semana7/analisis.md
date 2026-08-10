# Análisis de Violaciones — TechStore Legacy

## Tabla analizada
`ventas_completas` — base de datos `techstore_legacy`

---

## Violaciones de 1FN

Las siguientes columnas contienen múltiples valores separados por comas en una sola celda:

| Columna | Ejemplo de valor | Problema |
|---------|-----------------|---------|
| `productos` | "Laptop Pro,Mouse Inalámbrico" | Múltiples valores en una celda |
| `categorias` | "Computadoras,Periféricos" | Múltiples valores en una celda |
| `precios` | "1299.99,45.99" | Múltiples valores en una celda |
| `cantidades` | "1,2" | Múltiples valores en una celda |
| `descuentos` | "0.10,0.05" | Múltiples valores en una celda |

**Consecuencia directa**: `WHERE productos = 'Mouse Inalámbrico'` devuelve 0 filas.
Habría que usar `LIKE '%Mouse Inalámbrico%'` — frágil, lento, no escalable.

---

## Dependencias transitivas

| Cadena | Problema |
|--------|---------|
| `vendedor_email → vendedor_departamento → vendedor_depto_jefe` | El jefe depende del departamento, no del vendedor |
| `cliente_ciudad → cliente_estado → cliente_pais` | El país depende del estado, no del cliente |
| `producto → categoria` | La categoría depende del producto, no de la venta |

---

## Anomalías identificadas

**Anomalía de actualización**
Ana García aparece en 2 filas con el mismo email. Si cambia su email,
hay que actualizar N filas. Si se olvida una, la base de datos tiene
dos emails distintos para la misma persona — los datos mienten.

**Anomalía de inserción**
No es posible registrar un nuevo departamento si no existe una venta
asociada a un vendedor de ese departamento. La única forma de crear
datos es a través de una venta.

**Anomalía de eliminación**
Si se borra la última venta de María González, María desaparece
completamente de la base de datos — se pierde su nombre, email
y teléfono aunque no tengan relación con esa venta.

**Redundancia masiva**
- "Carlos López" como jefe de Ventas se repite en cada fila de Ana y Pedro
- "México" se repite en cada cliente mexicano
- Los datos del vendedor se duplican en cada venta que realiza

---

## Conclusión

La tabla `ventas_completas` mezcla 5 entidades distintas en una sola estructura:
vendedores, departamentos, clientes, productos y ventas.
La normalización a 3FN las separará en 9 tablas eliminando toda redundancia y anomalía.