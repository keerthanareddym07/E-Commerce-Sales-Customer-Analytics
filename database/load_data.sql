-- ============================================================
-- 03 | Load the CSV files (fast method: LOAD DATA LOCAL INFILE)
--
-- BEFORE RUNNING:
--   1. Put the 9 original CSV files in one folder, e.g. C:/olist_data/
--      (use forward slashes / in the paths, even on Windows)
--   2. Replace C:/olist_data/ below with YOUR folder path.
--   3. Do NOT open and re-save the CSVs in Excel (it changes line endings
--      and date formats). Use the original files.
--   4. Enable local_infile (see import_instructions.md, Section 2).
--
-- Load order matters (parents first). Empty values become NULL via NULLIF.
-- ============================================================
USE olist_ecommerce;
SET FOREIGN_KEY_CHECKS = 0;   -- speeds up the load; integrity is re-checked in data_validation.sql

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, @cat, @nl, @dl, @ph, @wt, @len, @hei, @wid)
SET product_category_name      = NULLIF(@cat, ''),
    product_name_lenght        = NULLIF(@nl, ''),
    product_description_lenght = NULLIF(@dl, ''),
    product_photos_qty         = NULLIF(@ph, ''),
    product_weight_g           = NULLIF(@wt, ''),
    product_length_cm          = NULLIF(@len, ''),
    product_height_cm          = NULLIF(@hei, ''),
    product_width_cm           = NULLIF(@wid, '');

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, @purchase, @approved, @carrier, @delivered, @estimated)
SET order_purchase_timestamp      = NULLIF(@purchase, ''),
    order_approved_at             = NULLIF(@approved, ''),
    order_delivered_carrier_date  = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@delivered, ''),
    order_estimated_delivery_date = NULLIF(@estimated, '');

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_order_payments_dataset.csv'
INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/olist_data/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id, order_id, @score, @title, @msg, @created, @answered)
SET review_score            = NULLIF(@score, ''),
    review_comment_title    = NULLIF(@title, ''),
    review_comment_message  = NULLIF(@msg, ''),
    review_creation_date    = NULLIF(@created, ''),
    review_answer_timestamp = NULLIF(@answered, '');

SET FOREIGN_KEY_CHECKS = 1;

-- Quick row-count check. Compare with the counts you recorded in Phase 1.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;
