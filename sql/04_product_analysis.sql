-- ============================================================
-- 04 | PRODUCT ANALYSIS
-- ============================================================
USE olist_ecommerce;

-- ------------------------------------------------------------
-- Q30. Which 10 categories earn the most revenue?
-- Explanation: group by the English category name from the view.
--   The window function gives each category's share of total revenue.
-- What it tells the business: where to focus inventory and marketing.
-- ------------------------------------------------------------
SELECT category,
       COUNT(*)                 AS units_sold,
       ROUND(SUM(price), 2)     AS revenue,
       ROUND(100 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS pct_of_revenue
FROM vw_sales
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q31. Which categories earn the least (with meaningful volume)?
-- Explanation: HAVING keeps categories with at least 50 units, so one-off
--   items do not appear as "worst".
-- What it tells the business: candidates to review, promote, or drop.
-- Assumption: 50 units is an arbitrary cut-off. Change it and see if the
--   story changes.
-- ------------------------------------------------------------
SELECT category,
       COUNT(*)             AS units_sold,
       ROUND(SUM(price), 2) AS revenue
FROM vw_sales
GROUP BY category
HAVING COUNT(*) >= 50
ORDER BY revenue ASC
LIMIT 10;

-- ------------------------------------------------------------
-- Q32. Top 10 individual products by revenue.
-- Explanation: the dataset has product IDs but no product names, so a
--   product is shown by its ID and category.
-- Limitation: no product names exist in this dataset.
-- ------------------------------------------------------------
SELECT product_id, category,
       COUNT(*) AS units_sold,
       ROUND(SUM(price), 2) AS revenue
FROM vw_sales
GROUP BY product_id, category
ORDER BY revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q33. Rank products inside each category.
-- Explanation: ROW_NUMBER and DENSE_RANK restart per category (PARTITION BY).
--   We keep the top 3 products of every category.
-- What it tells the business: the star product in each category.
-- ------------------------------------------------------------
WITH product_rev AS (
    SELECT category, product_id, SUM(price) AS revenue, COUNT(*) AS units
    FROM vw_sales
    GROUP BY category, product_id
),
ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
    FROM product_rev
)
SELECT category, rank_in_category, product_id, units, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- ------------------------------------------------------------
-- Q34. What is the average price and freight per category?
-- What it tells the business: price positioning, and categories where
--   freight is heavy compared with price.
-- ------------------------------------------------------------
SELECT category,
       COUNT(*) AS units_sold,
       ROUND(AVG(price), 2)          AS avg_price,
       ROUND(AVG(freight_value), 2)  AS avg_freight,
       ROUND(100 * SUM(freight_value) / SUM(price), 2) AS freight_pct_of_price
FROM vw_sales
GROUP BY category
HAVING COUNT(*) >= 100
ORDER BY avg_price DESC;

-- ------------------------------------------------------------
-- Q35. Which categories are growing or shrinking by year?
-- Explanation: revenue per category and year, plus the change versus the
--   previous year using LAG.
-- Limitation: partial years can look like a decline. Check months_covered
--   in Q9 before concluding anything.
-- ------------------------------------------------------------
WITH cat_year AS (
    SELECT category, order_year, SUM(price) AS revenue
    FROM vw_sales
    GROUP BY category, order_year
)
SELECT category, order_year,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (PARTITION BY category ORDER BY order_year))
                 / LAG(revenue) OVER (PARTITION BY category ORDER BY order_year), 2) AS change_vs_prev_year_pct
FROM cat_year
ORDER BY category, order_year;

-- ------------------------------------------------------------
-- Q36. How do review scores differ by category?
-- Explanation: join order items to reviews. An order can have more than one
--   review row, so we average reviews PER ORDER first to avoid counting
--   the same order several times (the join-multiplication problem).
-- What it tells the business: categories with unhappy customers.
-- ------------------------------------------------------------
WITH order_score AS (
    SELECT order_id, AVG(review_score) AS score
    FROM order_reviews
    GROUP BY order_id
),
order_category AS (
    SELECT DISTINCT order_id, category FROM vw_sales
)
SELECT oc.category,
       COUNT(*) AS reviewed_orders,
       ROUND(AVG(os.score), 2) AS avg_review_score
FROM order_category oc
JOIN order_score os ON os.order_id = oc.order_id
GROUP BY oc.category
HAVING COUNT(*) >= 100
ORDER BY avg_review_score ASC;

-- ------------------------------------------------------------
-- Q37. Which sellers generate the most revenue, and how concentrated is it?
-- What it tells the business: dependence on a few sellers is a risk.
-- ------------------------------------------------------------
SELECT seller_id,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2)     AS revenue,
       ROUND(100 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS pct_of_revenue
FROM vw_sales
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;
