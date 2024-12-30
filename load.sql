CREATE TEMP TABLE temp_customers (
    username VARCHAR(50),
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

INSERT INTO CUSTOMER (username, email, password, created_at)
SELECT t.username, t.email, t.password, t.created_at
FROM temp_customers t
WHERE NOT EXISTS (
    SELECT 1 FROM CUSTOMER c
    WHERE c.email = t.email OR c.username = t.username
);

INSERT INTO CATEGORY (name, description)
SELECT t.name, t.description
FROM temp_categories t
ON CONFLICT (name)
DO UPDATE SET description = EXCLUDED.description;

DROP TABLE temp_customers;
DROP TABLE temp_categories;
