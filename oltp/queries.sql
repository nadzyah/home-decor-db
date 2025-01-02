-- Most active customers by order count and total spent
SELECT
    c.full_name,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_spent
FROM CUSTOMER c
JOIN "order" o ON c.id = o.customer_id
WHERE o.status != 'cancelled'
GROUP BY c.id, c.full_name
ORDER BY order_count DESC
LIMIT 10;

-- Product performance analysis
SELECT
    p.name as product_name,
    p.stock_quantity as current_stock,
    COUNT(DISTINCT oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.price) as total_revenue,
    ROUND(AVG(r.rating), 2) as avg_rating,
    COUNT(r.id) as review_count
FROM PRODUCT p
LEFT JOIN ORDER_ITEM oi ON p.id = oi.product_id
LEFT JOIN REVIEW r ON p.id = r.product_id
GROUP BY p.id, p.name, p.stock_quantity
ORDER BY total_revenue DESC NULLS LAST;

-- Cart abandonment analysis
SELECT
    p.name as product_name,
    COUNT(ci.cart_id) as times_in_cart,
    p.stock_quantity as current_stock,
    p.price as unit_price
FROM PRODUCT p
JOIN CART_ITEM ci ON p.id = ci.product_id
LEFT JOIN ORDER_ITEM oi ON p.id = oi.product_id
WHERE oi.product_id IS NULL
GROUP BY p.id, p.name, p.stock_quantity, p.price
ORDER BY times_in_cart DESC;

-- Customer address distribution
SELECT
    country,
    COUNT(*) as customer_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
FROM ADDRESS
GROUP BY country
ORDER BY customer_count DESC;
