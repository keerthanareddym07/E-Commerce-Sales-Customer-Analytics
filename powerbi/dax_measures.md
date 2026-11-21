# DAX Measures

Create a separate table to hold measures: Home > Enter data > name it `_Measures`, load it, then right-click > New measure. Keep every measure in `_Measures` so they are easy to find.

## 0. Date table (create first)
Modeling > New table:

```DAX
dim_date =
ADDCOLUMNS (
    CALENDAR (
        DATE ( YEAR ( MIN ( fact_sales[order_date] ) ), 1, 1 ),
        DATE ( YEAR ( MAX ( fact_sales[order_date] ) ), 12, 31 )
    ),
    "Year", YEAR ( [Date] ),
    "Month Number", MONTH ( [Date] ),
    "Month Name", FORMAT ( [Date], "MMM" ),
    "Year-Month", FORMAT ( [Date], "YYYY-MM" )
)
```
**What it does:** builds one row per day from January of the first sales year to December of the last. Then set `Month Name` > Sort by column > `Month Number`. Mark the table as a date table.

## 1. Core KPIs

```DAX
Total Revenue = SUM ( fact_sales[price] )
```
Product revenue (freight excluded). The dataset has no cost data, so this is revenue, not profit.

```DAX
Total Freight = SUM ( fact_sales[freight_value] )
```

```DAX
Total Orders = DISTINCTCOUNT ( fact_sales[order_id] )
```
Distinct, because one order can have several item rows.

```DAX
Total Customers = DISTINCTCOUNT ( fact_sales[customer_unique_id] )
```
Counts real people, not `customer_id`.

```DAX
Total Products = DISTINCTCOUNT ( fact_sales[product_id] )
```

```DAX
Units Sold = COUNTROWS ( fact_sales )
```
Each row in `fact_sales` is one unit.

```DAX
Average Order Value = DIVIDE ( [Total Revenue], [Total Orders] )
```
`DIVIDE` returns blank instead of an error when the denominator is zero.

```DAX
Items per Order = DIVIDE ( [Units Sold], [Total Orders] )
```

## 2. Time intelligence

```DAX
Revenue Previous Month =
CALCULATE ( [Total Revenue], DATEADD ( dim_date[Date], -1, MONTH ) )
```

```DAX
MoM Growth % =
DIVIDE ( [Total Revenue] - [Revenue Previous Month], [Revenue Previous Month] )
```
Format as percentage. Ignore the first and last months of the data (incomplete).

```DAX
Revenue Previous Year =
CALCULATE ( [Total Revenue], DATEADD ( dim_date[Date], -1, YEAR ) )
```

```DAX
YoY Growth % =
DIVIDE ( [Total Revenue] - [Revenue Previous Year], [Revenue Previous Year] )
```
Only meaningful where the same period exists in both years.

```DAX
Revenue YTD = TOTALYTD ( [Total Revenue], dim_date[Date] )
```

## 3. Share and ranking

```DAX
Revenue Share % =
DIVIDE ( [Total Revenue], CALCULATE ( [Total Revenue], ALLSELECTED () ) )
```
Share of the total for whatever the user has filtered. Use it with category, state or product visuals.

```DAX
Category Rank =
RANKX ( ALLSELECTED ( fact_sales[category] ), [Total Revenue], , DESC, DENSE )
```

## 4. Customer measures (use `dim_customer` for lifetime behaviour)

```DAX
Repeat Customers =
CALCULATE ( COUNTROWS ( dim_customer ), dim_customer[total_orders] > 1 )
```

```DAX
One-time Customers =
CALCULATE ( COUNTROWS ( dim_customer ), dim_customer[total_orders] = 1 )
```

```DAX
Repeat Customer % =
DIVIDE ( [Repeat Customers], COUNTROWS ( dim_customer ) )
```

```DAX
Revenue per Customer = DIVIDE ( [Total Revenue], [Total Customers] )
```

```DAX
Orders per Customer = DIVIDE ( [Total Orders], [Total Customers] )
```

**Calculated column in `dim_customer`** (Table tools > New column):

```DAX
Customer Type =
IF ( dim_customer[total_orders] = 1, "One-time", "Repeat" )
```

**Calculated column for spending tiers** (simple, explainable):

```DAX
Spend Tier =
VAR rankPos =
    RANKX ( ALL ( dim_customer ), dim_customer[total_spent], , DESC, DENSE )
VAR totalCust = COUNTROWS ( ALL ( dim_customer ) )
RETURN
    SWITCH (
        TRUE (),
        rankPos <= totalCust / 3, "High",
        rankPos <= 2 * totalCust / 3, "Medium",
        "Low"
    )
```
Note: this ranking column runs over about 96,000 rows. It can take a minute. If it is too slow, use the SQL query Q24 instead and import the tier as a column.

## 5. Top N helper

```DAX
Top 10 Product Revenue =
CALCULATE (
    [Total Revenue],
    TOPN ( 10, ALLSELECTED ( fact_sales[product_id] ), [Total Revenue], DESC )
)
```
In practice, the easier method is to use a Top N filter on the visual (Filters pane > Top N > 10 > By value > `Total Revenue`).

## How to verify each measure
Compare the card totals with the SQL results from `sql/01_basic_analysis.sql` (Q1, Q2, Q4, Q5). If Total Revenue, Total Orders, Total Customers and AOV match SQL, the model and measures are correct. Record this check in your decision log.
