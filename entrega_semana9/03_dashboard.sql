-- ============================================================
-- Semana 9 — Vistas (Views)
-- Archivo 03: Dashboard — Queries usando solo vistas
-- ============================================================

USE techstore;

-- D1. Top 5 clientes VIP
SELECT name, total_spent, total_purchases
FROM v_vip_customers
LIMIT 5;

-- D2. Revenue por categoría (este mes)
SELECT
    cat.name AS category,
    SUM(fs.final_total) AS revenue
FROM v_full_sales fs
JOIN products p ON fs.product = p.name
JOIN categories cat ON p.category_id = cat.id
WHERE DATE_FORMAT(fs.sale_date, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
GROUP BY cat.name
ORDER BY revenue DESC;

-- D3. Productos con bajo stock pero alta demanda
SELECT
    bs.name,
    bs.stock,
    pm.units_sold
FROM v_low_stock_products bs
JOIN v_products_metrics pm ON bs.id = pm.id
WHERE pm.units_sold > 0
ORDER BY pm.units_sold DESC;

-- D4. Evolución mensual de ingresos
SELECT * FROM v_sales_by_month ORDER BY month;

-- D5. Clientes sin compras en 90 días
SELECT
    name, email, country, last_purchase,
    DATEDIFF(CURDATE(), last_purchase) AS days_inactive
FROM v_customers_stats
WHERE last_purchase < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
ORDER BY days_inactive DESC;