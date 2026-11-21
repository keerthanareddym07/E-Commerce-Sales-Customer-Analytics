# Power BI Data Model

## What you load

| Power BI table | Source | Grain (one row = ...) |
|---|---|---|
| `fact_sales` | MySQL view `vw_sales` (or `dataset/cleaned/sales_clean.csv`) | one order item (valid orders only) |
| `dim_customer` | MySQL view `vw_customer_summary` | one real person (`customer_unique_id`) |
| `dim_date` | created in Power BI with DAX (see `dax_measures.md`) | one calendar day |

Why this small model: the dashboard answers sales, customer and product questions. Those all work from one fact table plus a customer table and a date table. Keeping it small makes it easy to explain and keeps DAX simple.

## Relationships

```
dim_date[Date]  1 ───────< *  fact_sales[order_date]
dim_customer[customer_unique_id]  1 ───────< *  fact_sales[customer_unique_id]
```

- Both relationships: **one-to-many**, **single direction** (from dim to fact).
- Mark `dim_date` as a date table: Table tools > Mark as date table > choose `Date`.

## Why the relationship goes on `customer_unique_id`
`customer_id` changes with every order, so it identifies an order, not a person. Linking on `customer_unique_id` lets one person's several orders show up together.

## Fields you will use most

`fact_sales`: `order_id`, `order_date`, `order_month`, `order_year`, `customer_unique_id`, `customer_state`, `category`, `product_id`, `seller_id`, `price`, `freight_value`

`dim_customer`: `customer_unique_id`, `total_orders`, `total_spent`, `first_order_at`, `last_order_at`

## Option A: connect to MySQL (recommended)
1. Install **MySQL Connector/NET** (Power BI needs it for the MySQL connector). Download it from the official MySQL site, then restart Power BI Desktop.
2. Home > Get data > MySQL database. Server: `localhost`. Database: `olist_ecommerce`.
3. Choose `vw_sales` and `vw_customer_summary`. Choose **Import** mode.
4. If it asks for credentials, use Database > your MySQL username and password.

## Option B: connect to CSV files (if the MySQL connector gives trouble)
1. In MySQL Workbench, run `SELECT * FROM vw_sales;` then use the result grid's **Export** button to save a CSV. Do the same for `vw_customer_summary`.
   (Or run the Python notebook, which saves `dataset/cleaned/sales_clean.csv` with the same columns as `vw_sales`. For `dim_customer` you still need the `vw_customer_summary` export.)
2. Home > Get data > Text/CSV, load the files, then check the data types in Power Query.

## Data type checks (Power Query)
- `order_date`: Date
- `price`, `freight_value`, `total_spent`: Fixed decimal number
- `order_year`: Whole number
- IDs: Text
