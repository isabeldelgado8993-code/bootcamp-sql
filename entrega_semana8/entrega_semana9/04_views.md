# Catálogo de Vistas — TechStore

## Categoría: Básicas

### v_active_products
- **Propósito:** Lista productos disponibles ocultando `cost`.
- **Tablas base:** `products`
- **Actualizable:** SÍ
- **Uso:** Frontend, búsquedas, dropdowns.

### v_valued_inventory
- **Propósito:** Productos con valor monetario del stock calculado.
- **Tablas base:** `products JOIN categories`
- **Actualizable:** NO (tiene JOIN)
- **Uso:** Reporte de inventario para finanzas.

### v_active_customers
- **Propósito:** Clientes activos sin datos internos.
- **Tablas base:** `customers`
- **Actualizable:** SÍ
- **Uso:** Newsletters, listas de email.

### v_full_sales
- **Propósito:** Ventas con cliente, producto y totales calculados (subtotal, descuento, total final).
- **Tablas base:** `sales JOIN customers JOIN products`
- **Actualizable:** NO (tiene JOIN)
- **Uso:** Cualquier reporte de ventas.

### v_sales_by_month
- **Propósito:** Revenue agregado por mes con ticket promedio.
- **Tablas base:** `sales`
- **Actualizable:** NO (GROUP BY)
- **Uso:** Dashboards mensuales, tendencias.

---

## Categoría: Avanzadas

### v_products_metrics
- **Propósito:** Productos con métricas de venta y margen unitario.
- **Tablas base:** `products JOIN categories LEFT JOIN sales`
- **Actualizable:** NO (GROUP BY + JOIN)
- **Uso:** Análisis de portafolio, decisiones de compra.

### v_customers_stats
- **Propósito:** Cada cliente con sus métricas agregadas de compra.
- **Tablas base:** `customers LEFT JOIN sales`
- **Actualizable:** NO (GROUP BY)
- **Uso:** Segmentación, marketing, fidelización.

### v_vip_customers
- **Propósito:** Clientes con total_spent > 1000 y 3+ compras.
- **Tablas base:** `v_customers_stats`
- **Actualizable:** NO
- **Uso:** Programa de fidelidad, ofertas exclusivas.
- **Nota:** Si cambia el umbral de VIP, modificar solo esta vista.

### v_low_stock_products
- **Propósito:** Productos activos con stock < 10, ordenados por valor en riesgo.
- **Tablas base:** `products`
- **Actualizable:** SÍ
- **Uso:** Alertas de reposición para el equipo de compras.

### v_top_products
- **Propósito:** Top 20 productos por revenue generado.
- **Tablas base:** `products JOIN sales`
- **Actualizable:** NO (GROUP BY + LIMIT)
- **Uso:** Dashboards comerciales, decisiones de catálogo.

---

## Categoría: Seguridad

### v_public_catalog
- **Propósito:** Catálogo expuesto sin `cost` ni stock exacto (muestra YES/NO).
- **Tablas base:** `products JOIN categories`
- **Actualizable:** NO (tiene JOIN)
- **Uso:** API pública del sitio web, usuarios sin acceso a márgenes.

### v_executive_report
- **Propósito:** Métricas de alto nivel: productos activos, clientes, ventas y revenue del mes actual.
- **Tablas base:** Múltiples (subqueries)
- **Actualizable:** NO
- **Uso:** Dashboard ejecutivo, presentaciones a inversores.

---

## Categoría: Bonus

### v_products_by_segment
- **Propósito:** Clasifica productos en Budget / Mid-range / Premium / Luxury.