# Interview Preparation

**Important:** the answers below explain the approach and use `[your number]` wherever a result belongs. Fill those with the numbers you actually found. If you say a number in an interview, you must be able to show where it came from. Read each answer, then say it aloud in your own words. Do not memorize it.

## 1-minute introduction
"I built an end-to-end analytics project on a real e-commerce dataset from Olist, a Brazilian marketplace, with about 100,000 orders across 9 tables. I loaded it into MySQL, validated and cleaned it, wrote SQL to answer business questions about sales, customers and products, cross-checked the numbers in Python, and built a four-page Power BI dashboard. My main findings were [your finding 1], [your finding 2] and [your finding 3]. I also documented the limitations, like the fact that the data has no cost information, so I could only analyze revenue, not profit."

## 3-minute explanation
"The business problem was that a marketplace has a lot of transaction data but no clear view of where revenue comes from, who its customers are, and how delivery affects satisfaction.

I used the Olist public dataset because it is real, it has nine related tables, and it is not perfectly clean. I created a MySQL database with primary and foreign keys and loaded the CSV files. Before analysis I ran validation queries: uniqueness checks, orphan-row checks and NULL checks. Two things mattered a lot. First, `customer_id` changes with every order, so I counted customers using `customer_unique_id`. Second, orders can have several payment rows and review rows, so joining those tables directly would multiply rows and inflate revenue. I aggregated them first.

I defined revenue as the sum of item prices, excluding freight, and I excluded canceled and unavailable orders. Then I wrote about 45 queries using joins, CTEs, subqueries, CASE statements and window functions, like LAG for month-over-month growth and NTILE for customer segments. I repeated the key calculations in Python with Pandas, and the numbers matched.

In Power BI I built a small star-style model with a fact table, a customer table and a date table, wrote DAX measures, and built four pages: executive overview, sales performance, customer insights and product analysis.

The main findings were [your findings]. The limitations are [your limitations], and if I had more data, I would add [your improvement]."

## Questions and answers

**1. Why did you choose this project?**
I wanted to practice the full workflow a data analyst follows, from raw data to a business recommendation, on data that is real and messy instead of a clean practice file.

**2. Why this dataset?**
It is a real marketplace dataset with nine related tables, so I could practice joins, data quality checks and business analysis. It also has known problems, which made me make real decisions.

**3. How big is the dataset?**
About [your number] orders and [your number] items across nine tables, covering [your date range]. The geolocation table alone has roughly a million rows.

**4. What business problem does the project address?**
Understanding where revenue comes from, who the customers are, which categories perform best and worst, and whether delivery performance is linked to customer satisfaction.

**5. How did you define revenue?**
Sum of item price, without freight, for orders that are not canceled or unavailable. I kept freight separate because it is a delivery charge, not product revenue.

**6. Did you calculate profit?**
No. The dataset has no cost data, so any profit number would be invented. I stated that as a limitation.

**7. What is the difference between `customer_id` and `customer_unique_id`?**
`customer_id` is created for each order, so it identifies the order's customer record. `customer_unique_id` identifies the real person. To count customers or repeat buyers I used `customer_unique_id`. There were [your number] rows but only [your number] unique people.

**8. What data quality problems did you find?**
For example missing delivery dates, [your number] orders without items, products without a category, categories without an English translation, duplicate geolocation rows and orders with several review or payment rows. I checked each one and decided how to treat it.

**9. How did you handle missing values?**
I checked whether they made sense before changing anything. Missing delivery dates are expected for orders that were never delivered, so I left them as NULL and only used delivered orders for delivery analysis.

**10. How did you avoid inflating revenue in joins?**
I checked the number of rows per key before joining. Payments and reviews can have several rows per order, so I aggregated them to one row per order first. I also compared row counts before and after joins.

**11. What SQL concepts did you use?**
Joins, GROUP BY with HAVING, CASE, subqueries, CTEs, views, and window functions like LAG, running totals with SUM OVER, ROW_NUMBER, DENSE_RANK and NTILE.

**12. Explain a window function you used.**
For month-over-month growth I calculated monthly revenue in a CTE, then used LAG to read the previous month's revenue on the same row, and computed the percentage change. A window function keeps every row, unlike GROUP BY.

**13. What is the difference between WHERE and HAVING?**
WHERE filters rows before grouping. HAVING filters groups after aggregation. I used HAVING to keep only categories or states with enough orders.

**14. What is a CTE and why did you use one?**
A named temporary result defined with WITH. I used CTEs to build a query step by step, so it is easier to read than nested subqueries.

**15. How did you segment customers?**
With NTILE(3) on total spending I split people into high, medium and low spenders, and compared how much revenue each group brought. It is a simple, explainable method. A more advanced option would be RFM.

**16. What did you find about repeat customers?**
[Your number]% of customers bought only once. That means the business depends on acquiring new customers, and bringing buyers back is an opportunity. I would be careful about conclusions because the data has a limited time window.

**17. What did you do in Python that SQL could not do easily?**
Quick exploration, charts, missing-value and duplicate reports, and an independent check of my SQL numbers. The same KPIs matched in both, which gave me confidence.

**18. How did you validate your results?**
I calculated the headline numbers in SQL, Python and Power BI and compared them. I also ran orphan checks, uniqueness checks and row-count checks after joins.

**19. Why did you not use machine learning?**
The business questions were descriptive: what happened and where. Machine learning would not have answered them better, so I kept the project focused.

**20. Describe your Power BI data model.**
One fact table at order-item level, a customer table with one row per person, and a date table. The relationships are one-to-many from the dimensions to the fact table. I linked customers on `customer_unique_id`.

**21. Why do you need a date table?**
Time intelligence functions like month-over-month and year-to-date need a continuous calendar. A date table also gives me clean year, month and sorting fields.

**22. Give an example of a DAX measure you wrote.**
Average Order Value = DIVIDE([Total Revenue], [Total Orders]). Total Orders uses DISTINCTCOUNT of order ID, because one order can have several items.

**23. What does the dashboard show?**
Four pages: an executive overview with KPIs, a sales performance page with trends and growth, a customer page with repeat and segment analysis, and a product page with top and bottom categories.

**24. What were your main business recommendations?**
[Your recommendation 1 with the finding behind it], [recommendation 2], [recommendation 3]. Each one is tied to a result I can show.

**25. What were the limitations?**
No cost data, no product names, uneven time coverage in the first and last months, limited repeat purchasing, and old data from 2016 to 2018.

**26. What was the hardest part?**
[Your own answer. For example, understanding why customer_id and customer_unique_id differ, or finding why a join gave the wrong total.]

**27. What would you do differently or add next?**
Add cost data if it were available, build an RFM segmentation, add a cohort retention analysis, and automate the refresh of the dashboard.

**28. How would you present these findings to a non-technical manager?**
Start with the three most important findings, show one chart for each, state what action I recommend and how we would measure it, and mention the main limitation.

**29. Late deliveries and reviews: what did you find, and can you say late delivery causes low scores?**
[Your numbers]. I can say they are associated. I cannot say one causes the other, because other factors could affect both, such as product type or region.

**30. How do you know your project is correct?**
Row counts matched after loading, orphan checks returned zero, the same KPIs matched across SQL, Python and Power BI, and I documented my decisions in a log.
