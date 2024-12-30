CREATE TYPE order_status AS ENUM ('getting_prepared', 'in_transition', 'completed', 'returned', 'cancelled');
CREATE TYPE card_type AS ENUM ('Visa', 'MasterCard', 'AmEx');

CREATE TABLE CUSTOMER (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BRAND (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE CATEGORY (
    id SERIAL PRIMARY KEY,
    parent_id INTEGER REFERENCES CATEGORY(id),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE PRODUCT (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    category_id INTEGER NOT NULL REFERENCES CATEGORY(id),
    brand_id INTEGER REFERENCES BRAND(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "order" (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    status order_status NOT NULL DEFAULT 'getting_prepared',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id) ON DELETE CASCADE
);

CREATE TABLE ORDER_ITEM (
    order_id INT NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES PRODUCT(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE REVIEW (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(id) ON DELETE CASCADE,
    CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE ADDRESS (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id) ON DELETE CASCADE
);

CREATE TABLE PAYMENT_METHOD (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    card_number VARCHAR(255) NOT NULL,
    expiry_date DATE NOT NULL,
    card_type card_type NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id) ON DELETE CASCADE
);

CREATE TABLE CART (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(id) ON DELETE CASCADE
);

CREATE TABLE CART_ITEM (
    cart_id INTEGER NOT NULL REFERENCES CART(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES PRODUCT(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (cart_id, product_id)
);

CREATE INDEX idx_category_parent ON CATEGORY(parent_id);
CREATE INDEX idx_product_category ON PRODUCT(category_id);
CREATE INDEX idx_product_brand ON PRODUCT(brand_id);
CREATE INDEX idx_order_customer ON "order"(customer_id);
CREATE INDEX idx_order_item_order ON ORDER_ITEM(order_id);
CREATE INDEX idx_order_item_product ON ORDER_ITEM(product_id);
CREATE INDEX idx_review_product ON REVIEW(product_id);
CREATE INDEX idx_review_customer ON REVIEW(customer_id);
CREATE INDEX idx_address_customer ON ADDRESS(customer_id);
CREATE INDEX idx_payment_customer ON PAYMENT_METHOD(customer_id);
CREATE INDEX idx_cart_customer ON CART(customer_id);
CREATE INDEX idx_cart_item_cart ON CART_ITEM(cart_id);
CREATE INDEX idx_cart_item_product ON CART_ITEM(product_id);
