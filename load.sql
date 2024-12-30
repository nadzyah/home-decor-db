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

\copy temp_customers FROM './datasets/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
\copy temp_categories FROM './datasets/categories.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');

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

DROP TABLE temp_customers;
DROP TABLE temp_categories;
