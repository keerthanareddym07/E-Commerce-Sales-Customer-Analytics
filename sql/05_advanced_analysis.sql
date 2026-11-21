-- ============================================================
-- 05 | ADVANCED / COMBINED ANALYSIS
-- These queries combine several tables or techniques.
-- ============================================================
USE olist_ecommerce;

-- ------------------------------------------------------------
-- Q38. How long does delivery take, and how often is it late?
-- Explanation: DATEDIFF counts days between two dates. An order is late when
--   it arrived after the estimated date. Only delivered orders have dates.
-- What it tells the business: delivery reliability, which drives satisfaction.
-- ------------------------------------------------------------
SELECT COUNT(*) AS delivered_orders,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS avg_delivery_days,
       SUM(order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
       ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*), 2) AS pct_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- ------------------------------------------------------------
-- Q39. Does late delivery lower review scores?
-- Explanation: CASE splits orders into on-time and late. Reviews are averaged
--   per order first so that duplicate review rows do not distort the result.
-- What it tells the business: whether fixing delivery performance could
--   raise satisfaction.
-- Caution: this shows association, not proof of cause.
-- ------------------------------------------------------------
WITH order_score AS (
    SELECT order_id, AVG(review_score) AS score
    FROM order_reviews
    GROUP BY order_id
)
SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(os.score), 2) AS avg_review_score
FROM orders o
JOIN order_score os ON os.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- ------------------------------------------------------------
-- Q40. Average delivery time by customer state.
-- What it tells the business: regions with slow delivery.
-- ------------------------------------------------------------
SELECT c.customer_state,
       COUNT(*) AS delivered_orders,
       ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_days DESC;

-- ------------------------------------------------------------
-- Q41. What is the distribution of review scores?
-- What it tells the business: overall satisfaction at a glance.
-- ------------------------------------------------------------
SELECT review_score,
       COUNT(*) AS reviews,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- ------------------------------------------------------------
-- Q42. Top 3 categories for each year (ranking inside a group).
-- Explanation: DENSE_RANK per year, then keep ranks 1 to 3.
-- What it tells the business: whether the leading categories are stable.
-- ------------------------------------------------------------
WITH cat_year AS (
    SELECT order_year, category, SUM(price) AS revenue
    FROM vw_sales
    GROUP BY order_year, category
),
ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY order_year ORDER BY revenue DESC) AS rnk
    FROM cat_year
)
SELECT order_year, rnk, category, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rnk <= 3
ORDER BY order_year, rnk;

-- ------------------------------------------------------------
-- Q43. Which categories do repeat customers buy most?
-- Explanation: a subquery picks the people with 2 or more orders; the main
--   query sums their spending by category.
-- What it tells the business: categories that bring people back.
-- Limitation: the repeat group is small, so read percentages with care.
-- ------------------------------------------------------------
SELECT s.category,
       COUNT(DISTINCT s.customer_unique_id) AS repeat_customers,
       ROUND(SUM(s.price), 2) AS revenue
FROM vw_sales s
WHERE s.customer_unique_id IN (
    SELECT customer_unique_id FROM vw_customer_summary WHERE total_orders >= 2
)
GROUP BY s.category
ORDER BY repeat_customers DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q44. Instalment behaviour: do larger orders use more instalments?
-- Explanation: bucket the payment value with CASE, then average the
--   number of instalments in each bucket.
-- What it tells the business: whether financing options matter for big baskets.
-- ------------------------------------------------------------
SELECT CASE WHEN payment_value < 50  THEN '1. under 50'
            WHEN payment_value < 150 THEN '2. 50 to 149'
            WHEN payment_value < 500 THEN '3. 150 to 499'
            ELSE '4. 500 and above' END AS payment_bucket,
       COUNT(*) AS payments,
       ROUND(AVG(payment_installments), 2) AS avg_installments
FROM order_payments
WHERE payment_type = 'credit_card'
GROUP BY payment_bucket
ORDER BY payment_bucket;

-- ------------------------------------------------------------
-- Q45. Revenue share by customer state and month (heatmap-ready table).
-- What it tells the business: whether the regional mix is changing.
--   This output is also a good source for a Power BI matrix visual.
-- ------------------------------------------------------------
SELECT customer_state, order_month, ROUND(SUM(price), 2) AS revenue
FROM vw_sales
GROUP BY customer_state, order_month
ORDER BY customer_state, order_month;
