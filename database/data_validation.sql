-- ============================================================
-- 05 | Data validation: run after loading, BEFORE analysis
-- Each check has an "expected" result. Write what you actually
-- get in documentation/decisions.md.
-- ============================================================
USE olist_ecommerce;

-- 1. Is each key unique where it should be? (rows = distinct => no repeats)
SELECT 'orders'    AS tbl, COUNT(*) AS total_rows, COUNT(DISTINCT order_id)    AS distinct_ids FROM orders
UNION ALL
SELECT 'customers (customer_id)',        COUNT(*), COUNT(DISTINCT customer_id)        FROM customers
UNION ALL
SELECT 'customers (customer_unique_id)', COUNT(*), COUNT(DISTINCT customer_unique_id) FROM customers
UNION ALL
SELECT 'order_reviews (order_id)',       COUNT(*), COUNT(DISTINCT order_id)           FROM order_reviews
UNION ALL
SELECT 'order_payments (order_id)',      COUNT(*), COUNT(DISTINCT order_id)           FROM order_payments;
-- Expected: orders and customer_id show equal numbers; the others show
-- distinct < total (that is where joins can multiply rows).

-- 2. Orphan checks (referential integrity). Every result should be 0.
SELECT 'orders without customer' AS check_name, COUNT(*) AS problem_rows
FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items without order', COUNT(*)
FROM order_items oi LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_items without product', COUNT(*)
FROM order_items oi LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items without seller', COUNT(*)
FROM order_items oi LEFT JOIN sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'payments without order', COUNT(*)
FROM order_payments op LEFT JOIN orders o ON o.order_id = op.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'reviews without order', COUNT(*)
FROM order_reviews r LEFT JOIN orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

-- 3. Orders that have no items (cannot produce revenue)
SELECT o.order_status, COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status;

-- 4. NULL counts in the important columns
SELECT
    SUM(order_purchase_timestamp      IS NULL) AS null_purchase_date,
    SUM(order_approved_at             IS NULL) AS null_approved,
    SUM(order_delivered_carrier_date  IS NULL) AS null_carrier_date,
    SUM(order_delivered_customer_date IS NULL) AS null_delivered_date,
    SUM(order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM orders;
-- Missing delivery dates are expected for orders that were not delivered.

-- 5. Do missing delivery dates match the order status?
SELECT order_status,
       COUNT(*) AS orders,
       SUM(order_delivered_customer_date IS NULL) AS missing_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 6. Products with no category, and categories with no English translation
SELECT COUNT(*) AS products_without_category
FROM products WHERE product_category_name IS NULL;

SELECT DISTINCT p.product_category_name AS category_without_translation
FROM products p
LEFT JOIN product_category_translation t ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL;

-- 7. Price sanity: negative or zero prices, and extreme values
SELECT MIN(price) AS min_price, MAX(price) AS max_price, ROUND(AVG(price), 2) AS avg_price,
       SUM(price <= 0) AS non_positive_prices
FROM order_items;

-- 8. Date coverage (so we know which months are incomplete)
SELECT MIN(order_purchase_timestamp) AS first_order, MAX(order_purchase_timestamp) AS last_order
FROM orders;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month, COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
-- Expected: very few orders in the first months of 2016 and a partial last month.
-- Those months need care when you talk about "growth".

-- 9. Duplicate rows (exact duplicates) in geolocation: common in this dataset
SELECT COUNT(*) AS total_rows,
       COUNT(*) - COUNT(DISTINCT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng) AS duplicate_rows
FROM geolocation;

-- 10. Revenue reconciliation: items vs payments (they will NOT match exactly)
SELECT
    (SELECT ROUND(SUM(price), 2)                 FROM order_items)    AS items_price_total,
    (SELECT ROUND(SUM(price + freight_value), 2) FROM order_items)    AS items_price_plus_freight,
    (SELECT ROUND(SUM(payment_value), 2)         FROM order_payments) AS payments_total;
-- Payments include freight (and some vouchers / installment effects), so
-- items_price_plus_freight should be close to payments_total, not identical.
-- Note this difference in your decision log.
