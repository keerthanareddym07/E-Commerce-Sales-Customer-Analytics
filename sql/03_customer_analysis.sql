-- ============================================================
-- 03 | CUSTOMER ANALYSIS
-- Always count PEOPLE with customer_unique_id, never customer_id.
-- ============================================================
USE olist_ecommerce;

-- ------------------------------------------------------------
-- Q20. Who are the top 10 customers by total spending?
-- Explanation: vw_customer_summary has one row per person.
-- What it tells the business: the most valuable individuals. Check how large
--   their spending is compared with the average (see Q21).
-- ------------------------------------------------------------
SELECT customer_unique_id, total_orders, ROUND(total_spent, 2) AS total_spent
FROM vw_customer_summary
ORDER BY total_spent DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q21. What is the average and median-like spending per customer?
-- Explanation: AVG is simple. MySQL has no MEDIAN function, so we use
--   ROW_NUMBER + COUNT to pick the middle row(s).
-- What it tells the business: if the average is much higher than the median,
--   a few big spenders pull the average up.
-- ------------------------------------------------------------
WITH ranked AS (
    SELECT total_spent,
           ROW_NUMBER() OVER (ORDER BY total_spent) AS rn,
           COUNT(*)     OVER ()                     AS cnt
    FROM vw_customer_summary
)
SELECT ROUND((SELECT AVG(total_spent) FROM vw_customer_summary), 2) AS avg_spent,
       ROUND(AVG(total_spent), 2) AS median_spent
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2));

-- ------------------------------------------------------------
-- Q22. How many customers are one-time vs repeat buyers?
-- Explanation: CASE puts each person in a bucket based on order count.
-- What it tells the business: how much of the base ever comes back.
--   In this dataset repeat buying is expected to be low; treat that as
--   a finding, not as an error.
-- ------------------------------------------------------------
SELECT CASE WHEN total_orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
       ROUND(SUM(total_spent), 2) AS revenue,
       ROUND(100 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) AS pct_of_revenue
FROM vw_customer_summary
GROUP BY customer_type;

-- ------------------------------------------------------------
-- Q23. What is the purchase frequency distribution?
-- Explanation: how many customers placed 1, 2, 3... orders.
-- What it tells the business: the size of the "loyal" tail.
-- ------------------------------------------------------------
SELECT total_orders, COUNT(*) AS customers
FROM vw_customer_summary
GROUP BY total_orders
ORDER BY total_orders;

-- ------------------------------------------------------------
-- Q24. Segment customers by spending (high / medium / low).
-- Explanation: NTILE(3) splits customers into three equal-sized groups
--   ordered by spending. CASE gives the groups readable names.
-- What it tells the business: how much revenue each group brings.
-- Assumption: equal-sized groups are a simple, explainable starting point.
--   Real teams might use business-defined thresholds or RFM.
-- ------------------------------------------------------------
WITH tiers AS (
    SELECT customer_unique_id, total_spent,
           NTILE(3) OVER (ORDER BY total_spent DESC) AS tier
    FROM vw_customer_summary
)
SELECT CASE tier WHEN 1 THEN 'High' WHEN 2 THEN 'Medium' ELSE 'Low' END AS segment,
       COUNT(*) AS customers,
       ROUND(MIN(total_spent), 2) AS min_spent,
       ROUND(MAX(total_spent), 2) AS max_spent,
       ROUND(SUM(total_spent), 2) AS revenue,
       ROUND(100 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) AS pct_of_revenue
FROM tiers
GROUP BY tier
ORDER BY tier;

-- ------------------------------------------------------------
-- Q25. Do the top 20% of customers produce most of the revenue? (Pareto)
-- Explanation: NTILE(5) makes five groups; group 1 is the top 20%.
-- What it tells the business: how concentrated revenue is. Compare your
--   result with the "80/20" rule instead of assuming it holds.
-- ------------------------------------------------------------
WITH quintiles AS (
    SELECT total_spent,
           NTILE(5) OVER (ORDER BY total_spent DESC) AS quintile
    FROM vw_customer_summary
)
SELECT quintile,
       COUNT(*) AS customers,
       ROUND(SUM(total_spent), 2) AS revenue,
       ROUND(100 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2) AS pct_of_revenue
FROM quintiles
GROUP BY quintile
ORDER BY quintile;

-- ------------------------------------------------------------
-- Q26. Rank customers inside each state by spending.
-- Explanation: DENSE_RANK() OVER (PARTITION BY state ...) restarts the ranking
--   for every state. The outer query keeps the top 3 per state.
-- What it tells the business: who the best customers are in each region.
-- ------------------------------------------------------------
WITH per_customer AS (
    SELECT customer_unique_id, customer_state, SUM(price) AS spent
    FROM vw_sales
    GROUP BY customer_unique_id, customer_state
),
ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY customer_state ORDER BY spent DESC) AS state_rank
    FROM per_customer
)
SELECT customer_state, state_rank, customer_unique_id, ROUND(spent, 2) AS spent
FROM ranked
WHERE state_rank <= 3
ORDER BY customer_state, state_rank;

-- ------------------------------------------------------------
-- Q27. How many new vs returning customers per month?
-- Explanation: a customer is "new" in the month of their first order and
--   "returning" in later months. We find each person's first month with
--   MIN, then compare with the order's month.
-- What it tells the business: whether growth comes from acquiring new
--   customers or from existing ones coming back.
-- ------------------------------------------------------------
WITH first_month AS (
    SELECT customer_unique_id, MIN(order_month) AS first_month
    FROM vw_sales
    GROUP BY customer_unique_id
),
monthly_customers AS (
    SELECT DISTINCT s.order_month, s.customer_unique_id, f.first_month
    FROM vw_sales s
    JOIN first_month f ON f.customer_unique_id = s.customer_unique_id
)
SELECT order_month,
       SUM(order_month = first_month) AS new_customers,
       SUM(order_month > first_month) AS returning_customers
FROM monthly_customers
GROUP BY order_month
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q28. How long does it take repeat customers to place their second order?
-- Explanation: ROW_NUMBER numbers each person's orders by date. We keep
--   order 1 and order 2 and measure the days between them.
-- What it tells the business: the time window for follow-up campaigns.
-- Assumption: only customers with at least two valid orders appear.
-- ------------------------------------------------------------
WITH numbered AS (
    SELECT customer_unique_id, purchased_at,
           ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchased_at) AS order_no
    FROM vw_orders_summary
)
SELECT COUNT(*) AS repeat_customers,
       ROUND(AVG(DATEDIFF(second_order.purchased_at, first_order.purchased_at)), 1) AS avg_days_to_second_order
FROM numbered first_order
JOIN numbered second_order
  ON second_order.customer_unique_id = first_order.customer_unique_id
 AND first_order.order_no = 1
 AND second_order.order_no = 2;

-- ------------------------------------------------------------
-- Q29. Customer lifetime-style view: average orders and spend per person.
-- What it tells the business: a baseline to compare any future improvement against.
-- ------------------------------------------------------------
SELECT COUNT(*) AS customers,
       ROUND(AVG(total_orders), 3) AS avg_orders_per_customer,
       ROUND(AVG(total_spent), 2)  AS avg_spent_per_customer
FROM vw_customer_summary;
