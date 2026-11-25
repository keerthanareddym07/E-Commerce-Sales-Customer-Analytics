\#decision log



\- customer\_id changes with every order, so it can't count real people. Customers will be counted using customer\_unique\_id (96,096 unique people vs 99,441 orders).



\- Loaded all 9 Olist tables into MySQL (database olist\_ecommerce). Eight row counts matched the CSV files immediately.

\- order\_reviews: LOAD DATA loaded 99,223 of 99,224 rows with no warning about a skipped row. The file uses Windows \\r\\n line endings, so I changed LINES TERMINATED BY to '\\r\\n', but the count stayed the same. I found the missing review by comparing review\_id/order\_id keys between the CSV and the table, and inserted it manually. Row count is now 99,224.



\- product\_category\_translation: 70 of 71 English category names had a hidden \\r at the end (the CSV uses Windows line endings). Removed it with REPLACE(..., '\\r', ''). Verified: count of affected names is now 0.



\- Orphan checks: all six returned 0 (no orders without customers, no items without order/product/seller, no payments or reviews without an order). Foreign keys are consistent even though they were disabled during load.



\- 775 orders have no rows in order\_items (603 unavailable, 164 canceled, 5 created, 2 invoiced, 1 shipped). They cannot produce revenue. Sales and order counts use order\_items, so these orders are excluded. Orders with status canceled or unavailable are also excluded from sales even if they have items.



\- Delivery dates vs status: 8 orders have status delivered but no delivery date; 6 orders are canceled but have a delivery date. All other missing delivery dates are on orders that were not delivered (expected). Delivery-time and late-delivery analysis will use only delivered orders with a delivery date. Dates are not filled in.

