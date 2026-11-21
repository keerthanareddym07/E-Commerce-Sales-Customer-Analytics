-- ============================================================
-- 02 | Create tables (schema matches the Olist Kaggle CSV headers)
-- Source: "Brazilian E-Commerce Public Dataset by Olist" (Kaggle)
-- Two original column names contain a spelling mistake ("lenght").
-- We keep them exactly as in the CSV so the import works.
-- ============================================================
USE olist_ecommerce;

-- Parent tables first, child tables after (foreign keys need this order)

CREATE TABLE customers (
    customer_id               VARCHAR(32)  NOT NULL,   -- new ID for every ORDER
    customer_unique_id        VARCHAR(32)  NOT NULL,   -- the real PERSON
    customer_zip_code_prefix  VARCHAR(10),
    customer_city             VARCHAR(100),
    customer_state            CHAR(2),
    PRIMARY KEY (customer_id),
    INDEX idx_customers_unique (customer_unique_id)
);

CREATE TABLE sellers (
    seller_id               VARCHAR(32) NOT NULL,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            CHAR(2),
    PRIMARY KEY (seller_id)
);

CREATE TABLE product_category_translation (
    product_category_name          VARCHAR(100) NOT NULL,
    product_category_name_english  VARCHAR(100),
    PRIMARY KEY (product_category_name)
);

CREATE TABLE products (
    product_id                    VARCHAR(32) NOT NULL,
    product_category_name         VARCHAR(100),          -- Portuguese, can be NULL
    product_name_lenght           INT,
    product_description_lenght    INT,
    product_photos_qty            INT,
    product_weight_g              INT,
    product_length_cm             INT,
    product_height_cm             INT,
    product_width_cm              INT,
    PRIMARY KEY (product_id)
    -- No foreign key to the translation table on purpose: a few categories
    -- have no English translation, and we do not want to lose those rows.
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix  VARCHAR(10),
    geolocation_lat              DECIMAL(18,15),
    geolocation_lng              DECIMAL(18,15),
    geolocation_city             VARCHAR(100),
    geolocation_state            CHAR(2),
    INDEX idx_geo_zip (geolocation_zip_code_prefix)
    -- No primary key: the same ZIP prefix appears many times (many coordinates).
);

CREATE TABLE orders (
    order_id                       VARCHAR(32) NOT NULL,
    customer_id                    VARCHAR(32) NOT NULL,
    order_status                   VARCHAR(20),
    order_purchase_timestamp       DATETIME,
    order_approved_at              DATETIME,
    order_delivered_carrier_date   DATETIME,
    order_delivered_customer_date  DATETIME,
    order_estimated_delivery_date  DATETIME,
    PRIMARY KEY (order_id),
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_purchase (order_purchase_timestamp),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

CREATE TABLE order_items (
    order_id             VARCHAR(32) NOT NULL,
    order_item_id        INT         NOT NULL,   -- 1,2,3... item number inside the order
    product_id           VARCHAR(32) NOT NULL,
    seller_id            VARCHAR(32) NOT NULL,
    shipping_limit_date  DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    INDEX idx_items_product (product_id),
    INDEX idx_items_seller (seller_id),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_items_seller  FOREIGN KEY (seller_id)  REFERENCES sellers (seller_id)
);

CREATE TABLE order_payments (
    order_id               VARCHAR(32) NOT NULL,
    payment_sequential     INT         NOT NULL,
    payment_type           VARCHAR(20),
    payment_installments   INT,
    payment_value          DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

CREATE TABLE order_reviews (
    review_id                 VARCHAR(32) NOT NULL,
    order_id                  VARCHAR(32) NOT NULL,
    review_score              INT,
    review_comment_title      VARCHAR(255),
    review_comment_message    TEXT,
    review_creation_date      DATETIME,
    review_answer_timestamp   DATETIME,
    INDEX idx_reviews_order (order_id),
    INDEX idx_reviews_id (review_id)
    -- No primary key: review_id is NOT unique in the original data
    -- (the same review_id can appear for more than one order).
);
