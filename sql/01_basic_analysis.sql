-- ============================================================
-- 01 | BASIC ANALYSIS
-- Uses the view vw_sales (valid orders only, see database/create_views.sql).
-- Each query: business question, explanation, what to look for, assumptions.
-- ============================================================
USE olist_ecommerce;

-- ------------------------------------------------------------
-- Q1. How many orders were placed, and how many are valid sales?
-- Explanation: COUNT(*) counts every row in orders. The second count
--   uses the view, which already removed canceled/unavailable orders,
--   so DISTINCT order_id gives valid orders.
-- What it tells the business: the gap between the two numbers is
--   the volume of orders that never became sales.
-- Assumption: 'canceled' and 'unavailable' are not real sales.
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM orders)                      AS all_orders,
    (SELECT COUNT(DISTINCT order_id) FROM vw_sales)    AS valid_orders;

-- ------------------------------------------------------------
-- Q2. How many real customers (people) do we have?
-- Explanation: customer_unique_id identifies a person. customer_id changes
--   with every order, so counting it would count orders, not people.
-- What it tells the business: the true size of the customer base.
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM vw_sales;

-- ------------------------------------------------------------
-- Q3. How many different products and categories were sold?
-- Explanation: DISTINCT removes repeats, so each product/category counts once.
-- What it tells the business: the breadth of the catalogue that actually sells.
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT product_id) AS products_sold,
       COUNT(DISTINCT category)   AS categories_sold
FROM vw_sales;

-- ------------------------------------------------------------
-- Q4. What is the total product revenue?
-- Explanation: SUM(price) adds item prices. Freight is NOT included
--   because it is a delivery charge, not product revenue.
-- What it tells the business: headline sales figure for the period covered.
-- Assumption: revenue means price only. There is no cost data, so no profit.
-- ------------------------------------------------------------
SELECT ROUND(SUM(price), 2) AS total_revenue,
       ROUND(SUM(freight_value), 2) AS total_freight
FROM vw_sales;

-- ------------------------------------------------------------
-- Q5. What is the average order value (AOV)?
-- Explanation: first add up revenue per order (subquery), then average it.
--   Averaging item prices directly would give "average item price", not
--   "average order value", because one order can hold several items.
-- What it tells the business: how much a typical order is worth.
-- ------------------------------------------------------------
SELECT ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM (
    SELECT order_id, SUM(price) AS order_revenue
    FROM vw_sales
    GROUP BY order_id
) AS per_order;

-- ------------------------------------------------------------
-- Q6. How many units were sold, and how many items per order?
-- Explanation: each row in order_items is one unit sold.
-- What it tells the business: basket size. A value near 1 means most
--   customers buy a single item per order.
-- ------------------------------------------------------------
SELECT COUNT(*) AS units_sold,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(COUNT(*) / COUNT(DISTINCT order_id), 2) AS items_per_order
FROM vw_sales;

-- ------------------------------------------------------------
-- Q7. What is the order status mix?
-- Explanation: GROUP BY status and use a window function to turn counts
--   into percentages of the total.
-- What it tells the business: the share of orders delivered vs problem orders.
-- Note: this query reads from the orders table (not the view) on purpose,
--   because the view hides canceled/unavailable orders.
-- ------------------------------------------------------------
SELECT order_status,
       COUNT(*) AS orders,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;
