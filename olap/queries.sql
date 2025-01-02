-- Sales trends by category and time
SELECT
    dc.category_name,
    dt.year,
    dt.quarter,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.quantity_sold) as total_units_sold,
    SUM(fs.total_amount) as total_revenue,
    SUM(fs.total_amount) / SUM(fs.quantity_sold) as avg_unit_price
FROM FACT_SALES fs
JOIN DIM_TIME dt ON fs.time_key = dt.time_key
JOIN DIM_PRODUCT dp ON fs.product_key = dp.product_key
JOIN DIM_CATEGORY dc ON dp.category_key = dc.category_key
GROUP BY dc.category_name, dt.year, dt.quarter
ORDER BY dt.year, dt.quarter, total_revenue DESC;

-- Customer purchase pattern analysis
SELECT
    CASE
        WHEN dt.is_weekend THEN 'Weekend'
        ELSE 'Weekday'
    END as day_type,
    dt.month_name,
    COUNT(DISTINCT fs.customer_key) as unique_customers,
    COUNT(DISTINCT fs.order_id) as total_orders,
    ROUND(SUM(fs.total_amount)::numeric, 2) as total_revenue,
    ROUND(SUM(fs.total_amount) / COUNT(DISTINCT fs.order_id)::numeric, 2) as avg_order_value
FROM FACT_SALES fs
JOIN DIM_TIME dt ON fs.time_key = dt.time_key
GROUP BY day_type, dt.month_name, dt.month
ORDER BY dt.month;

-- Brand performance over time
WITH monthly_brand_sales AS (
    SELECT
        db.brand_name,
        dt.year,
        dt.month,
        SUM(fs.total_amount) as revenue,
        SUM(fs.quantity_sold) as units_sold
    FROM FACT_SALES fs
    JOIN DIM_PRODUCT dp ON fs.product_key = dp.product_key
    JOIN DIM_BRAND db ON dp.brand_key = db.brand_key
    JOIN DIM_TIME dt ON fs.time_key = dt.time_key
    GROUP BY db.brand_name, dt.year, dt.month
)
SELECT
    brand_name,
    year,
    month,
    revenue,
    units_sold,
    revenue - LAG(revenue) OVER (PARTITION BY brand_name ORDER BY year, month) as revenue_change,
    ROUND(
        ((revenue - LAG(revenue) OVER (PARTITION BY brand_name ORDER BY year, month)) /
        LAG(revenue) OVER (PARTITION BY brand_name ORDER BY year, month) * 100)::numeric,
        2
    ) as revenue_growth_percent
FROM monthly_brand_sales
ORDER BY brand_name, year, month;

-- Customer lifecycle analysis
SELECT
    dc.customer_key,
    MIN(dt.full_date) as first_purchase_date,
    MAX(dt.full_date) as last_purchase_date,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.total_amount) as total_spent,
    SUM(fs.total_amount) / COUNT(DISTINCT fs.order_id) as avg_order_value,
    COUNT(DISTINCT dp.product_key) as unique_products_bought,
    COUNT(DISTINCT dp.category_key) as unique_categories_bought
FROM FACT_SALES fs
JOIN DIM_CUSTOMER dc ON fs.customer_key = dc.customer_key
JOIN DIM_TIME dt ON fs.time_key = dt.time_key
JOIN DIM_PRODUCT dp ON fs.product_key = dp.product_key
WHERE dc.is_current = true
GROUP BY dc.customer_key
ORDER BY total_spent DESC;
