-- ============================================================
-- 04 | Reusable views
-- Run AFTER loading the data and AFTER data_validation.sql.
--
-- DECISION (write this in your decision log):
--   Revenue = SUM(order_items.price). Freight is tracked separately.
--   Orders with status 'canceled' or 'unavailable' are excluded,
--   because they did not produce real sales.
--   The dataset has NO cost data, so profit cannot be calculated.
-- ============================================================
USE olist_ecommerce;

-- One row per ORDER ITEM, valid orders only, with English category names.
CREATE OR REPLACE VIEW vw_sales AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.order_status,
    o.order_purchase_timestamp,
    DATE(o.order_purchase_timestamp)                       AS order_date,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')       AS order_month,
    YEAR(o.order_purchase_timestamp)                       AS order_year,
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    oi.product_id,
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'unknown')                                    AS category,
    oi.seller_id,
    oi.price,
    oi.freight_value
FROM order_items oi
JOIN orders    o ON o.order_id    = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products  p ON p.product_id  = oi.product_id
LEFT JOIN product_category_translation t
       ON t.product_category_name = p.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable');

-- One row per ORDER (revenue summed from items, so no row multiplication).
CREATE OR REPLACE VIEW vw_orders_summary AS
SELECT
    order_id,
    customer_unique_id,
    customer_state,
    MIN(order_purchase_timestamp)  AS purchased_at,
    MIN(order_month)               AS order_month,
    COUNT(*)                       AS items_in_order,
    SUM(price)                     AS order_revenue,
    SUM(freight_value)             AS order_freight
FROM vw_sales
GROUP BY order_id, customer_unique_id, customer_state;

-- One row per PERSON.
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id)       AS total_orders,
    SUM(price)                     AS total_spent,
    MIN(order_purchase_timestamp)  AS first_order_at,
    MAX(order_purchase_timestamp)  AS last_order_at
FROM vw_sales
GROUP BY customer_unique_id;
