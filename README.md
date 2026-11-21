# E-Commerce Sales, Customer Behaviour and Business Performance Analysis

An end-to-end analytics project on real marketplace data: MySQL, SQL, Python and Power BI, from raw CSV files to a four-page dashboard and business recommendations.

> **Project status:** setup, SQL, notebook and documentation are written. Sections marked **[to fill]** need results from your own run. Remove this note when the project is complete.

## Business problem
An online marketplace has thousands of transactions but no clear view of how its revenue is growing, which categories and regions drive it, who its customers are, and whether delivery performance affects customer satisfaction. This project analyzes the data and presents the answers in a dashboard for decision-makers.

## Objectives
1. Measure sales performance and trends (revenue, orders, customers, average order value, growth).
2. Understand customer behaviour (value, concentration, one-time vs repeat).
3. Identify top and weak product categories and regional patterns.
4. Link delivery performance to customer satisfaction.
5. Provide recommendations based only on the evidence.

## Dataset
- **Brazilian E-Commerce Public Dataset by Olist** (Kaggle): https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- 9 related tables of anonymized orders from 2016 to 2018. The raw data is not included in this repository. See `dataset/original/README.md` to download it.
- Full column descriptions and limitations: `documentation/dataset_documentation.md`.

## Tools
MySQL 8 and MySQL Workbench, SQL, Python (Pandas, NumPy, Matplotlib, Seaborn, Jupyter), Power BI Desktop, Excel (optional), Git/GitHub.

## Project structure
```
Ecommerce-Data-Analytics/
├── README.md, START_HERE.md, requirements.txt
├── dataset/        original/ (download here), cleaned/
├── database/       create, load, validate, views, import guide
├── sql/            45 business queries in 5 files
├── python/         ecommerce_eda.ipynb, supporting_scripts/
├── powerbi/        data model, DAX measures, dashboard design guide
├── reports/        business_insights.md
└── documentation/  dataset docs, workflow, troubleshooting, roadmap, interview prep
```

## Method
1. **Database:** designed a MySQL schema with primary and foreign keys and loaded the nine tables.
2. **Validation:** uniqueness, orphan-row, NULL, duplicate and reconciliation checks (`database/data_validation.sql`).
3. **Key decisions:**
   - Customers are counted with `customer_unique_id`, because `customer_id` changes with every order.
   - Revenue = sum of item price, excluding freight.
   - Canceled and unavailable orders are excluded from sales.
   - Payments and reviews are aggregated to one row per order before joining, to avoid inflating revenue.
4. **SQL analysis:** joins, CTEs, subqueries, CASE, window functions (LAG, running totals, RANK, DENSE_RANK, ROW_NUMBER, NTILE).
5. **Python EDA:** data quality, cleaning, charts, and an independent check of the SQL numbers.
6. **Power BI:** fact table + customer table + date table, DAX measures, four report pages.

## Key findings **[to fill]**
Use only numbers from your own results. See `reports/business_insights.md`.
- ...
- ...
- ...

## Dashboard **[to fill]**
Add real screenshots from your Power BI report to `dashboard-screenshots/` and link them here:
`![Executive Overview](dashboard-screenshots/page1_overview.png)`

## Recommendations **[to fill]**
Each recommendation should state the finding, the action and the metric to track.

## Limitations
- No cost data, so profit cannot be analyzed.
- No product names.
- Limited repeat purchasing, so retention analysis is thin.
- First and last months are incomplete, so growth statements exclude them.
- Data covers 2016 to 2018 only.

## How to reproduce
1. Read `START_HERE.md` and install the tools.
2. Download the dataset into `dataset/original/` and run `python python/supporting_scripts/check_schema.py`.
3. Run the scripts in `database/` (see `database/import_instructions.md`).
4. Run the queries in `sql/`.
5. Run `python/ecommerce_eda.ipynb`.
6. Build the dashboard using `powerbi/`.

## Author
[Your name], final-year B.Tech Data Science student. [LinkedIn] | [GitHub]
