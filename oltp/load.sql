CREATE TEMP TABLE temp_customers (
    full_name VARCHAR(50),
    email VARCHAR(255),
    password VARCHAR(255),
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_categories (
    name VARCHAR(100),
    description TEXT
);

CREATE TEMP TABLE temp_brands (
    name VARCHAR(100),
    description TEXT
);

CREATE TEMP TABLE temp_products (
    name VARCHAR(255),
    description TEXT,
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    category_name VARCHAR(100),
    brand_name VARCHAR(100)
);

CREATE TEMP TABLE temp_addresses (
    customer_email VARCHAR(255),
    address_line_1 VARCHAR(255),
    address_line_2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100)
);

CREATE TEMP TABLE temp_orders (
    customer_email VARCHAR(255),
    status order_status,
    created_at TIMESTAMP,
    total_amount DECIMAL(10,2)
);

CREATE TEMP TABLE temp_order_items (
    order_id INTEGER,
    product_name VARCHAR(255),
    quantity INTEGER,
    price DECIMAL(10,2)
);

\copy temp_customers FROM './datasets/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_categories FROM './datasets/categories.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_brands FROM './datasets/brands.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_products FROM './datasets/products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_addresses FROM './datasets/addresses.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_orders FROM './datasets/orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_order_items FROM './datasets/order_items.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');

BEGIN;

INSERT INTO CUSTOMER (full_name, email, password, created_at)
SELECT t.full_name, t.email, t.password, t.created_at
FROM temp_customers t
WHERE NOT EXISTS (
    SELECT 1 FROM CUSTOMER c
    WHERE c.email = t.email OR c.full_name = t.full_name
);

INSERT INTO CATEGORY (name, description)
SELECT t.name, t.description
FROM temp_categories t
ON CONFLICT (name)
DO UPDATE SET description = EXCLUDED.description;

INSERT INTO BRAND (name, description)
SELECT t.name, t.description
FROM temp_brands t
ON CONFLICT (name)
DO UPDATE SET description = EXCLUDED.description;

INSERT INTO PRODUCT (name, description, price, stock_quantity, category_id, brand_id)
SELECT
    p.name,
    p.description,
    p.price,
    p.stock_quantity,
    c.id as category_id,
    b.id as brand_id
FROM temp_products p
JOIN CATEGORY c ON p.category_name = c.name
JOIN BRAND b ON p.brand_name = b.name
WHERE NOT EXISTS (
    SELECT 1 FROM PRODUCT
    WHERE name = p.name
);

INSERT INTO ADDRESS (customer_id, address_line_1, address_line_2, city, state, postal_code, country)
SELECT
    c.id as customer_id,
    a.address_line_1,
    a.address_line_2,
    a.city,
    a.state,
    a.postal_code,
    a.country
FROM temp_addresses a
JOIN CUSTOMER c ON a.customer_email = c.email
WHERE NOT EXISTS (
    SELECT 1 FROM ADDRESS
    WHERE customer_id = c.id
    AND address_line_1 = a.address_line_1
);

WITH inserted_orders AS (
    INSERT INTO "order" (customer_id, status, created_at, total_amount)
    SELECT
        c.id as customer_id,
        o.status,
        o.created_at,
        o.total_amount
    FROM temp_orders o
    JOIN CUSTOMER c ON o.customer_email = c.email
    RETURNING id
)
INSERT INTO ORDER_ITEM (order_id, product_id, quantity, price)
SELECT
    o.id,
    p.id as product_id,
    oi.quantity,
    oi.price
FROM temp_order_items oi
JOIN inserted_orders o ON oi.order_id = o.id
JOIN PRODUCT p ON oi.product_name = p.name;

COMMIT;

DROP TABLE temp_customers;
DROP TABLE temp_categories;
DROP TABLE temp_brands;
DROP TABLE temp_products;
DROP TABLE temp_addresses;
DROP TABLE temp_orders;
DROP TABLE temp_order_items;
