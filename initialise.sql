CREATE TYPE order_status AS ENUM ('getting_prepared', 'in_transition', 'completed');
CREATE TYPE payment_type AS ENUM ('Visa', 'MasterCard', 'AmEx', 'PayPal');

CREATE TABLE "USER" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "CATEGORY" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE "PRODUCT" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES "CATEGORY"(id)
);

CREATE TABLE "ORDER" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    status order_status NOT NULL DEFAULT 'getting_prepared',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES "USER"(id) ON DELETE CASCADE
);

CREATE TABLE "ORDER_ITEM" (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES "ORDER"(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES "PRODUCT"(id) ON DELETE RESTRICT
);

CREATE TABLE "REVIEW" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES "USER"(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES "PRODUCT"(id) ON DELETE CASCADE,
    CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE "ADDRESS" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES "USER"(id) ON DELETE CASCADE
);

CREATE TABLE "PAYMENT_METHOD" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    card_number VARCHAR(255) NOT NULL,
    expiry_date DATE NOT NULL,
    payment_type payment_type NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES "USER"(id) ON DELETE CASCADE
);

CREATE INDEX idx_product_category ON "PRODUCT"(category_id);
CREATE INDEX idx_order_user ON "ORDER"(user_id);
CREATE INDEX idx_order_item_order ON "ORDER_ITEM"(order_id);
CREATE INDEX idx_order_item_product ON "ORDER_ITEM"(product_id);
CREATE INDEX idx_review_product ON "REVIEW"(product_id);
CREATE INDEX idx_review_user ON "REVIEW"(user_id);
CREATE INDEX idx_address_user ON "ADDRESS"(user_id);
CREATE INDEX idx_payment_user ON "PAYMENT_METHOD"(user_id);