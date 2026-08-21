-- ============================================================
-- Semana 9 — Vistas (Views)
-- Archivo 02: Vistas — TechStore
-- ============================================================

USE techstore;

-- ── FASE 2: Vistas básicas ───────────────────────────────────

-- V1. Productos activos (oculta cost)
CREATE VIEW v_active_products AS
SELECT id, name, category_id, price, stock
FROM products
WHERE is_active = TRUE;

-- V2. Inventario valorizado
CREATE VIEW v_valued_inventory AS
SELECT
    p.id, p.name, c.name AS category,
    p.price, p.stock,
    (p.price * p.stock) AS inventory_value
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.is_active = TRUE;

-- V3. Clientes activos
CREATE VIEW v_active_customers AS
SELECT id, name, email, city, country
FROM customers
WHERE is_active = TRUE;

-- V4. Ventas completas (encapsula JOINs y cálculos)
CREATE VIEW v_full_sales AS
SELECT
    v.id AS sale_id,
    v.sale_date,
    cl.name AS customer,
    p.name  AS product,
    v.quantity,
    v.unit_price,
    v.discount,
    (v.quantity * v.unit_price)                          AS subtotal,
    (v.quantity * v.unit_price * v.discount / 100)       AS discount_applied,
    (v.quantity * v.unit_price * (1 - v.discount / 100)) AS final_total
FROM sales v
JOIN customers cl ON v.customer_id = cl.id
JOIN products  p  ON v.product_id  = p.id;

-- V5. Ventas por mes
CREATE VIEW v_sales_by_month AS
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    COUNT(*) AS num_sales,
    SUM(quantity * unit_price * (1 - discount / 100))  AS revenue,
    AVG(quantity * unit_price * (1 - discount / 100))  AS avg_ticket
FROM sales
GROUP BY month
ORDER BY month;

-- ── FASE 3: Vistas avanzadas ─────────────────────────────────

-- V6. Productos con métricas (ventas + márgenes)
CREATE VIEW v_products_metrics AS
SELECT
    p.id, p.name, c.name AS category,
    p.price, p.stock,
    COALESCE(SUM(v.quantity), 0) AS units_sold,
    COUNT(v.id) AS num_transactions,
    COALESCE(SUM(v.quantity * v.unit_price * (1 - v.discount / 100)), 0) AS revenue,
    (p.price - p.cost) AS unit_margin
FROM products p
JOIN categories c ON p.category_id = c.id
LEFT JOIN sales v ON p.id = v.product_id
WHERE p.is_active = TRUE
GROUP BY p.id, p.name, c.name, p.price, p.stock, p.cost;

-- V7. Clientes con estadísticas
CREATE VIEW v_customers_stats AS
SELECT
    cl.id, cl.name, cl.email, cl.country,
    COUNT(v.id) AS total_purchases,
    COALESCE(SUM(v.quantity * v.unit_price * (1 - v.discount / 100)), 0) AS total_spent,
    COALESCE(AVG(v.quantity * v.unit_price * (1 - v.discount / 100)), 0) AS avg_ticket,
    MIN(v.sale_date) AS first_purchase,
    MAX(v.sale_date) AS last_purchase
FROM customers cl
LEFT JOIN sales v ON cl.id = v.customer_id
WHERE cl.is_active = TRUE
GROUP BY cl.id, cl.name, cl.email, cl.country;

-- V8. Clientes VIP (vista sobre vista)
CREATE VIEW v_vip_customers AS
SELECT *
FROM v_customers_stats
WHERE total_spent > 1000 AND total_purchases >= 3
ORDER BY total_spent DESC;

-- V9. Productos bajo stock con valor en riesgo
CREATE VIEW v_low_stock_products AS
SELECT id, name, stock, price,
    (price * stock) AS value_at_risk
FROM products
WHERE is_active = TRUE AND stock < 10
ORDER BY value_at_risk DESC;

-- V10. Top productos por revenue
CREATE VIEW v_top_products AS
SELECT
    p.id, p.name,
    SUM(v.quantity * v.unit_price * (1 - v.discount / 100)) AS revenue,
    SUM(v.quantity) AS units
FROM products p
JOIN sales v ON p.id = v.product_id
GROUP BY p.id, p.name
ORDER BY revenue DESC
LIMIT 20;

-- ── FASE 4: Vistas de seguridad ──────────────────────────────

-- V11. Catálogo público (sin cost, stock como YES/NO)
CREATE VIEW v_public_catalog AS
SELECT
    p.id, p.name, p.description,
    c.name AS category,
    p.price,
    CASE WHEN p.stock = 0 THEN 'NO' ELSE 'YES' END AS available
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.is_active = TRUE;

-- V12. Reporte ejecutivo
CREATE VIEW v_executive_report AS
SELECT
    (SELECT COUNT(*) FROM products WHERE is_active = TRUE) AS active_products,
    (SELECT COUNT(*) FROM customers WHERE is_active = TRUE) AS active_customers,
    (SELECT COUNT(*) FROM sales
        WHERE DATE_FORMAT(sale_date, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
    ) AS sales_current_month,
    (SELECT COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0)
        FROM sales
        WHERE DATE_FORMAT(sale_date, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
    ) AS revenue_current_month,
    (SELECT COALESCE(AVG(quantity * unit_price * (1 - discount / 100)), 0)
        FROM sales
    ) AS global_avg_ticket;

-- ── BONUS ────────────────────────────────────────────────────

-- B1. Segmentación de productos por precio
CREATE VIEW v_products_by_segment AS
SELECT name, price,
    CASE
        WHEN price < 100  THEN 'Budget'
        WHEN price < 500  THEN 'Mid-range'
        WHEN price < 1000 THEN 'Premium'
        ELSE 'Luxury'
    END AS segment
FROM products
WHERE is_active = TRUE;

-- B2. Vista actualizable con WITH CHECK OPTION
CREATE VIEW v_active_products_editable AS
SELECT id, name, category_id, price, stock, is_active
FROM products
WHERE is_active = TRUE
WITH CHECK OPTION;