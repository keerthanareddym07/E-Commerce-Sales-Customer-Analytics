-- ============================================================
-- 02 | SALES ANALYSIS
-- ============================================================
USE olist_ecommerce;

-- ------------------------------------------------------------
-- Q8. What is the monthly revenue and order count?
-- Explanation: order_month is 'YYYY-MM'. GROUP BY month, SUM price,
--   count distinct orders (not rows, since an order can have many items).
-- What it tells the business: the shape of sales over time, seasonality.
-- Limitation: the first and last months of the dataset are incomplete,
--   so do not read them as real drops or spikes.
-- ------------------------------------------------------------
SELECT order_month,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue
FROM vw_sales
GROUP BY order_month
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q9. What is the yearly revenue?
-- What it tells the business: year-level scale. Remember that not every
--   year covers 12 full months in this dataset.
-- ------------------------------------------------------------
SELECT order_year,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue,
       COUNT(DISTINCT order_month) AS months_covered
FROM vw_sales
GROUP BY order_year
ORDER BY order_year;

-- ------------------------------------------------------------
-- Q10. What is the daily sales trend?
-- Explanation: same idea as Q8, grouped by date. Useful to spot spikes.
-- Tip: look at the highest days with Q11 below.
-- ------------------------------------------------------------
SELECT order_date,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue
FROM vw_sales
GROUP BY order_date
ORDER BY order_date;

-- ------------------------------------------------------------
-- Q11. Which 10 days had the highest revenue?
-- Explanation: ORDER BY revenue DESC and LIMIT 10.
-- What it tells the business: peak days. Check whether they match
--   promotions or holidays before drawing conclusions.
-- ------------------------------------------------------------
SELECT order_date, ROUND(SUM(price), 2) AS revenue
FROM vw_sales
GROUP BY order_date
ORDER BY revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q12. Which weekdays and hours sell the most?
-- Explanation: DAYNAME and HOUR extract parts of the timestamp.
-- What it tells the business: when customers shop, useful for timing campaigns.
-- ------------------------------------------------------------
SELECT DAYNAME(order_purchase_timestamp) AS weekday,
       COUNT(DISTINCT order_id)          AS orders,
       ROUND(SUM(price), 2)              AS revenue
FROM vw_sales
GROUP BY weekday
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- Q13. What is the month-over-month (MoM) revenue growth?
-- Explanation: a CTE (a named temporary result) computes monthly revenue.
--   LAG() reads the previous month's revenue on the same row, so we can
--   calculate the percentage change. This is a WINDOW FUNCTION.
-- What it tells the business: whether sales are accelerating or slowing.
-- Limitation: ignore the first month (no previous month) and the partial
--   last month.
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT order_month, SUM(price) AS revenue
    FROM vw_sales
    GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY order_month), 2) AS prev_month_revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
                 / LAG(revenue) OVER (ORDER BY order_month), 2) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q14. What is the cumulative (running total) revenue by month?
-- Explanation: SUM() OVER (ORDER BY ...) adds each month to all earlier months.
-- What it tells the business: total growth path of the business.
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT order_month, SUM(price) AS revenue
    FROM vw_sales
    GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY order_month), 2) AS running_total
FROM monthly
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q15. How does revenue compare for the same month in different years (YoY)?
-- Explanation: we split the month into year and month number and compare
--   with LAG partitioned by month number.
-- What it tells the business: growth that is not distorted by seasonality.
-- Limitation: only months present in both years can be compared.
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT YEAR(order_purchase_timestamp)  AS yr,
           MONTH(order_purchase_timestamp) AS mth,
           SUM(price) AS revenue
    FROM vw_sales
    GROUP BY yr, mth
)
SELECT yr, mth,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (PARTITION BY mth ORDER BY yr), 2) AS same_month_last_year,
       ROUND(100 * (revenue - LAG(revenue) OVER (PARTITION BY mth ORDER BY yr))
                 / LAG(revenue) OVER (PARTITION BY mth ORDER BY yr), 2) AS yoy_growth_pct
FROM monthly
ORDER BY mth, yr;

-- ------------------------------------------------------------
-- Q16. Which states generate the most revenue?
-- Explanation: customer_state comes from the customers table via the view.
-- What it tells the business: where demand is concentrated. The window
--   function gives each state's share of total revenue.
-- ------------------------------------------------------------
SELECT customer_state,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue,
       ROUND(100 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS pct_of_revenue
FROM vw_sales
GROUP BY customer_state
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- Q17. What is the average order value by state?
-- Explanation: sum revenue per order first, then average by state.
-- What it tells the business: whether some regions spend more per order.
-- Assumption: states with very few orders give unstable averages, so we
--   show only states with at least 100 orders (HAVING).
-- ------------------------------------------------------------
SELECT customer_state,
       COUNT(*) AS orders,
       ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM vw_orders_summary
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_order_value DESC;

-- ------------------------------------------------------------
-- Q18. How much do customers pay for freight, relative to product price?
-- Explanation: freight / revenue per state.
-- What it tells the business: states where delivery cost is high compared
--   with the price of goods, which may discourage buying.
-- ------------------------------------------------------------
SELECT customer_state,
       ROUND(SUM(price), 2)          AS revenue,
       ROUND(SUM(freight_value), 2)  AS freight,
       ROUND(100 * SUM(freight_value) / SUM(price), 2) AS freight_pct_of_revenue
FROM vw_sales
GROUP BY customer_state
HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY freight_pct_of_revenue DESC;

-- ------------------------------------------------------------
-- Q19. Which payment methods are used, and how much do they carry?
-- Explanation: from order_payments. One order can have several payment rows,
--   so we count distinct orders per method.
-- What it tells the business: payment preferences, e.g. dependence on credit
--   cards or on boleto (a Brazilian bank-slip payment).
-- Note: payment_value includes freight, so it is not the same as revenue.
-- ------------------------------------------------------------
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(payment_value), 2) AS payment_value_total,
       ROUND(100 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 2) AS pct_of_payments
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value_total DESC;
