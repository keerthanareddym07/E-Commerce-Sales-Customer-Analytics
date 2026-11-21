# Project Workflow

```
1. Understand the business problem
2. Download the data -> dataset/original/
3. Create the database (database/create_database.sql, create_tables.sql)
4. Load the CSVs (database/load_data.sql)
5. Validate the data (database/data_validation.sql)  -> note findings in decisions
6. Create the views (database/create_views.sql)       -> define "revenue" and "valid order"
7. SQL analysis (sql/01 ... 05)
8. Python EDA (python/ecommerce_eda.ipynb)            -> cross-check the SQL numbers
9. Power BI model, measures and dashboard (powerbi/)
10. Write business insights (reports/business_insights.md)
11. GitHub README, screenshots
12. Interview preparation
```

## Business problem
An e-commerce marketplace has transaction data but no clear view of how its revenue is growing, which categories and regions drive it, who its customers are, and whether delivery performance affects satisfaction. This project analyzes the data and delivers a dashboard and a set of recommendations.

## Business questions (all answerable with this dataset)
- Sales: monthly and yearly trends, peak periods, growth, key KPIs (revenue, orders, customers, AOV).
- Customers: top customers, one-time vs repeat, spending concentration, segments by state.
- Products: top and bottom categories, product concentration, price and freight by category.
- Operations: delivery time, late deliveries, and their link to review scores.

## Questions this dataset can NOT answer
- Profit or margin (no cost data).
- Marketing channel performance (no channel data).
- Product-name level analysis (no names).
- Long-term retention (most customers appear once).

## Key definitions (keep consistent everywhere)
| Term | Definition |
|---|---|
| Revenue | SUM(order_items.price), freight excluded |
| Valid order | order_status not 'canceled' and not 'unavailable' |
| Customer | a distinct customer_unique_id |
| Order value | revenue summed per order |
| Repeat customer | person with 2 or more valid orders |
| Late order | delivered after the estimated delivery date |

## The cross-check habit
Every headline number should be calculated in at least two tools:
SQL (`sql/01_basic_analysis.sql`) = Python (notebook section 8) = Power BI (KPI cards).
If they differ, find out why before you publish anything.
