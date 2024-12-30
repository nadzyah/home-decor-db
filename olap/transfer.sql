\c home_decor_dw;
CREATE EXTENSION IF NOT EXISTS dblink;

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.customers (
    customer_id INTEGER,
    full_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.categories (
    category_id INTEGER,
    category_name VARCHAR(100),
    parent_id INTEGER,
    description TEXT
);

CREATE TABLE IF NOT EXISTS staging.brands (
    brand_id INTEGER,
    brand_name VARCHAR(100),
    description TEXT
);

CREATE TABLE IF NOT EXISTS staging.products (
    product_id INTEGER,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    category_id INTEGER,
    brand_id INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.sales (
    order_id INTEGER,
    customer_id INTEGER,
    order_date TIMESTAMP,
    status VARCHAR(20),
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2)
);

TRUNCATE TABLE staging.customers, staging.categories, staging.brands,
              staging.products, staging.sales;

INSERT INTO staging.customers
SELECT * FROM dblink('dbname=home_decor_db',
    'SELECT c.id, c.full_name, c.email, c.created_at
     FROM CUSTOMER c')
    AS c(customer_id INTEGER, full_name VARCHAR, email VARCHAR, created_at TIMESTAMP);

INSERT INTO staging.categories
SELECT * FROM dblink('dbname=home_decor_db',
    'SELECT id, name, parent_id, description FROM CATEGORY')
    AS c(category_id INTEGER, category_name VARCHAR, parent_id INTEGER, description TEXT);

INSERT INTO staging.brands
SELECT * FROM dblink('dbname=home_decor_db',
    'SELECT id, name, description FROM BRAND')
    AS b(brand_id INTEGER, brand_name VARCHAR, description TEXT);

INSERT INTO staging.products
SELECT * FROM dblink('dbname=home_decor_db',
    'SELECT id, name, price, stock_quantity, category_id, brand_id, created_at
     FROM PRODUCT')
    AS p(product_id INTEGER, product_name VARCHAR, price DECIMAL,
         stock_quantity INTEGER, category_id INTEGER, brand_id INTEGER,
         created_at TIMESTAMP);

INSERT INTO staging.sales
SELECT * FROM dblink('dbname=home_decor_db',
    'SELECT o.id, o.customer_id, o.created_at, o.status,
            oi.product_id, oi.quantity, oi.price,
            oi.quantity * oi.price as total_amount
     FROM "order" o
     JOIN ORDER_ITEM oi ON o.id = oi.order_id
     WHERE o.created_at >= CURRENT_DATE - INTERVAL ''1 year''
     AND o.status != ''cancelled''')
    AS s(order_id INTEGER, customer_id INTEGER, order_date TIMESTAMP,
         status VARCHAR, product_id INTEGER, quantity INTEGER,
         unit_price DECIMAL, total_amount DECIMAL);

INSERT INTO DIM_TIME (
    full_date, year, quarter, month, month_name,
    day, day_name, is_weekend
)
SELECT DISTINCT
    date_trunc('day', order_date)::date as full_date,
    EXTRACT(YEAR FROM order_date) as year,
    EXTRACT(QUARTER FROM order_date) as quarter,
    EXTRACT(MONTH FROM order_date) as month,
    TO_CHAR(order_date, 'Month') as month_name,
    EXTRACT(DAY FROM order_date) as day,
    TO_CHAR(order_date, 'Day') as day_name,
    EXTRACT(ISODOW FROM order_date) IN (6, 7) as is_weekend
FROM staging.sales
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO DIM_BRAND (brand_name, description)
SELECT brand_name, description
FROM staging.brands
ON CONFLICT (brand_name) DO UPDATE
SET description = EXCLUDED.description;

WITH RECURSIVE category_hierarchy AS (
    SELECT
        category_id,
        category_name,
        parent_id,
        category_name::TEXT as category_path,
        1 as level
    FROM staging.categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_id,
        (ch.category_path || ' > ' || c.category_name::TEXT),
        ch.level + 1
    FROM staging.categories c
    JOIN category_hierarchy ch ON c.parent_id = ch.category_id
)
INSERT INTO DIM_CATEGORY (
    category_name,
    parent_category_key,
    category_path
)
SELECT DISTINCT ON (c.category_name)
    c.category_name,
    p.category_key,
    ch.category_path
FROM category_hierarchy ch
JOIN staging.categories c ON ch.category_id = c.category_id
LEFT JOIN DIM_CATEGORY p ON c.parent_id = p.category_key
ON CONFLICT (category_name) DO UPDATE
SET
    parent_category_key = EXCLUDED.parent_category_key,
    category_path = EXCLUDED.category_path;

INSERT INTO DIM_PRODUCT (
    product_id, product_name, unit_price, brand_key, category_key
)
SELECT
    p.product_id,
    p.product_name,
    p.price,
    b.brand_key,
    c.category_key
FROM staging.products p
JOIN DIM_BRAND b ON p.brand_id = (SELECT brand_id FROM staging.brands WHERE brand_name = b.brand_name)
JOIN DIM_CATEGORY c ON p.category_id = (SELECT category_id FROM staging.categories WHERE category_name = c.category_name)
ON CONFLICT (product_id) DO UPDATE
SET
    product_name = EXCLUDED.product_name,
    unit_price = EXCLUDED.unit_price,
    brand_key = EXCLUDED.brand_key,
    category_key = EXCLUDED.category_key;

INSERT INTO DIM_CUSTOMER (
    customer_id, full_name, email, city, country,
    valid_from, valid_to, is_current
)
SELECT
    customer_id,
    full_name,
    email,
    city,
    country,
    CURRENT_TIMESTAMP,
    NULL,
    TRUE
FROM staging.customers s
WHERE NOT EXISTS (
    SELECT 1
    FROM DIM_CUSTOMER d
    WHERE d.customer_id = s.customer_id
    AND d.is_current = TRUE
    AND d.full_name = s.full_name
    AND COALESCE(d.city, '') = COALESCE(s.city, '')
    AND COALESCE(d.country, '') = COALESCE(s.country, '')
);

INSERT INTO FACT_SALES (
    time_key,
    customer_key,
    product_key,
    order_id,
    quantity_sold,
    unit_price,
    total_amount
)
SELECT
    t.time_key,
    c.customer_key,
    p.product_key,
    s.order_id,
    s.quantity,
    s.unit_price,
    s.total_amount
FROM staging.sales s
JOIN DIM_TIME t ON DATE_TRUNC('day', s.order_date)::date = t.full_date
JOIN DIM_CUSTOMER c ON s.customer_id = c.customer_id AND c.is_current = TRUE
JOIN DIM_PRODUCT p ON s.product_id = p.product_id
ON CONFLICT (time_key, customer_key, product_key, order_id) DO NOTHING;

TRUNCATE TABLE staging.customers;
TRUNCATE TABLE staging.categories;
TRUNCATE TABLE staging.brands;
TRUNCATE TABLE staging.products;
TRUNCATE TABLE staging.sales;
