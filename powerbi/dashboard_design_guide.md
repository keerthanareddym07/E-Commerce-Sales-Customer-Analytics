# Dashboard Design Guide

No `.pbix` file is included. A dashboard has to be built in Power BI Desktop on your computer, and this guide gives you everything to build it. Build it yourself, page by page. That is what you will be asked about in interviews.

## Global design rules
- Canvas: 16:9 (default), background light grey `#F4F6F8`, white cards with a thin border.
- Fonts: Segoe UI. Title 20 pt bold, chart titles 12 pt, labels 10 pt.
- Palette (consistent across all pages):
  - Primary blue `#1F4E79`, accent teal `#2A9D8F`, highlight orange `#E76F51`, neutral grey `#8D99AE`.
  - Use orange only for things that need attention (declines, low performers).
- Layout: KPI cards in a row at the top, main chart left/center, secondary charts right, slicers in a narrow strip at the top or left.
- Every visual has a clear title that says what it shows ("Monthly revenue"), not "Chart 1".
- Navigation: use bookmarks or page-navigator buttons (Insert > Buttons > Navigator > Page navigator).
- Turn off unnecessary gridlines and keep decimal places consistent (currency 0 decimals, percentages 1 decimal).
- Currency: the data is in Brazilian reais (BRL). Say "R$" in titles or a footnote.

## Slicers (sync across pages: View > Sync slicers)
Year (`dim_date[Year]`), Category (`fact_sales[category]`), State (`fact_sales[customer_state]`).

## Page 1: Executive Overview
Question answered: *How is the business doing overall?*
- Cards: Total Revenue, Total Orders, Total Customers, Total Products, Average Order Value.
- Line chart: revenue by `Year-Month` (axis sorted by month).
- Bar chart: top 10 categories by revenue.
- Map or bar chart: revenue by `customer_state` (a horizontal bar chart is safer and easier to read than a map).
- Footnote text box: "Revenue = product price, excluding freight. Source: Olist public dataset, 2016 to 2018."

## Page 2: Sales Performance
Question answered: *When and where do sales happen, and is the business growing?*
- Line chart: monthly revenue with `Revenue Previous Year` as a second line (only meaningful where both exist).
- Column chart: `MoM Growth %`, orange for negative values (conditional formatting). Do not interpret the first or last month.
- Bar chart: revenue and orders by weekday (add a weekday column in Power Query if you want this).
- Matrix: states (rows) by year (columns) with `Total Revenue`.
- Line chart: `Revenue YTD`.
- Tooltip page (optional): hover on a month to see orders and AOV.

## Page 3: Customer Insights
Question answered: *Who are our customers and do they come back?*
- Cards: Total Customers, Repeat Customer %, Orders per Customer, Revenue per Customer.
- Donut or bar chart: One-time vs Repeat (`dim_customer[Customer Type]`) by customer count.
- Column chart: customers by number of orders (`dim_customer[total_orders]`).
- Bar chart: revenue by `Spend Tier`.
- Table: top 10 customers by `total_spent` (show the ID, orders, spend).
- Be honest in the page subtitle: repeat buying is low in this dataset, so the customer base is mostly one-time buyers (check your numbers).

## Page 4: Product Analysis
Question answered: *Which categories and products drive revenue, and which do not?*
- Cards: Units Sold, Total Products, Items per Order.
- Bar chart: top 10 categories by revenue with `Revenue Share %` in the tooltip.
- Bar chart: bottom 10 categories by revenue (Top N filter, Bottom 10) with at least 50 units (visual filter on `Units Sold`).
- Scatter chart: x = units sold, y = average price, detail = category (shows high-volume cheap vs low-volume expensive categories).
- Table: top 10 products by revenue (product ID + category).
- Drill-through: right-click a category to see its products and monthly trend (create a drill-through page filtered by `category`).

## Build order (recommended)
1. Build the model and measures. Check the card numbers against SQL.
2. Build Page 1 completely.
3. Copy the slicer strip to the other pages, sync it.
4. Build Pages 2, 3 and 4.
5. Polish: alignment, titles, colors, tooltips.
6. Export screenshots of each page (File > Export > PDF, or screenshot) into `dashboard-screenshots/` for your GitHub README. Only publish screenshots of your own real dashboard.

## Checklist before you call it finished
- [ ] KPI cards match your SQL numbers.
- [ ] No unlabeled axis or default title.
- [ ] Slicers work on all pages.
- [ ] Incomplete months are explained in a footnote.
- [ ] You can explain every measure in one sentence.
