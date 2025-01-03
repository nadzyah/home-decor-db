CREATE TABLE DIM_TIME (
    time_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name VARCHAR(10) NOT NULL,
    day INTEGER NOT NULL CHECK (day BETWEEN 1 AND 31),
    day_name VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    UNIQUE (full_date)
);

CREATE TABLE DIM_CUSTOMER (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    joined_at TIMESTAMP NOT NULL CHECK (joined_at < CURRENT_TIMESTAMP),
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE DIM_BRAND (
    brand_key SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    description TEXT,
    UNIQUE (brand_name)
);

CREATE TABLE DIM_CATEGORY (
    category_key SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_key INTEGER REFERENCES DIM_CATEGORY(category_key) ON DELETE RESTRICT,
    category_path TEXT NOT NULL,
    UNIQUE (category_name)
);

CREATE TABLE DIM_PRODUCT (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    brand_key INTEGER REFERENCES DIM_BRAND(brand_key) ON DELETE RESTRICT,
    category_key INTEGER REFERENCES DIM_CATEGORY(category_key) ON DELETE RESTRICT,
    UNIQUE (product_id)
);

CREATE TABLE FACT_SALES (
    sale_key SERIAL,
    time_key INTEGER NOT NULL REFERENCES DIM_TIME(time_key) ON DELETE RESTRICT,
    customer_key INTEGER NOT NULL REFERENCES DIM_CUSTOMER(customer_key) ON DELETE RESTRICT,
    product_key INTEGER NOT NULL REFERENCES DIM_PRODUCT(product_key) ON DELETE RESTRICT,
    order_id INTEGER NOT NULL,
    quantity_sold INTEGER NOT NULL CHECK (quantity_sold > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
    CONSTRAINT pk_fact_sales PRIMARY KEY (sale_key),
    CONSTRAINT unique_order UNIQUE (time_key, customer_key, product_key, order_id)
);

CREATE TABLE FACT_INVENTORY (
    time_key INTEGER NOT NULL REFERENCES DIM_TIME(time_key) ON DELETE RESTRICT,
    product_key INTEGER NOT NULL REFERENCES DIM_PRODUCT(product_key) ON DELETE RESTRICT,
    quantity_available INTEGER NOT NULL CHECK (quantity_available >= 0),
    quantity_reserved INTEGER NOT NULL CHECK (quantity_reserved >= 0),
    avg_unit_price DECIMAL(10,2) NOT NULL CHECK (avg_unit_price > 0),
    CONSTRAINT pk_fact_inventory PRIMARY KEY (time_key, product_key)
);

CREATE INDEX idx_customer_current ON DIM_CUSTOMER(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_customer_id ON DIM_CUSTOMER(customer_id);
CREATE INDEX idx_time_date ON DIM_TIME(full_date);
CREATE INDEX idx_category_path ON DIM_CATEGORY(category_path);
CREATE INDEX idx_fact_sales_order ON FACT_SALES(order_id);
CREATE INDEX idx_fact_sales_composite ON FACT_SALES(time_key, customer_key, product_key);
CREATE INDEX idx_fact_inventory_composite ON FACT_INVENTORY(time_key, product_key);

CREATE OR REPLACE FUNCTION update_category_path()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.parent_category_key IS NULL THEN
        NEW.category_path = NEW.category_name;
    ELSE
        SELECT category_path || ' > ' || NEW.category_name
        INTO NEW.category_path
        FROM DIM_CATEGORY
        WHERE category_key = NEW.parent_category_key;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_category_path
BEFORE INSERT OR UPDATE ON DIM_CATEGORY
FOR EACH ROW EXECUTE FUNCTION update_category_path();

CREATE OR REPLACE FUNCTION update_customer_scd2()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM DIM_CUSTOMER
        WHERE customer_id = NEW.customer_id
        AND is_current = TRUE
    ) THEN
        UPDATE DIM_CUSTOMER
        SET valid_to = CURRENT_TIMESTAMP,
            is_current = FALSE
        WHERE customer_id = NEW.customer_id
        AND is_current = TRUE;
    END IF;

    NEW.joined_at = CURRENT_TIMESTAMP;
    NEW.is_current = TRUE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_scd2
BEFORE INSERT ON DIM_CUSTOMER
FOR EACH ROW
WHEN (NEW.customer_key IS NULL)
EXECUTE FUNCTION update_customer_scd2();
