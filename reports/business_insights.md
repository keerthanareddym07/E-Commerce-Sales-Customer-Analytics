# Business Insights Report (template: fill with YOUR results)

**Status: NOT COMPLETED.** This file was created before any analysis was run on your computer, so it contains no findings. Every `[ ... ]` below must be replaced with a number or statement you saw in your own query results, notebook output or dashboard. Delete any line you cannot support. Do not leave placeholders in the published version.

Dataset: Olist Brazilian E-Commerce (2016 to 2018). Revenue means product price, excluding freight. No profit analysis is possible because the dataset has no cost data.

## 1. Headline numbers
Source: `sql/01_basic_analysis.sql` Q1 to Q6 (checked against the notebook and Power BI cards).
- Valid orders: [ ... ]
- Real customers (unique people): [ ... ]
- Total revenue (BRL): [ ... ]
- Average order value (BRL): [ ... ]
- Items per order: [ ... ]

## 2. Sales trend
Source: Q8 to Q15.
- Shape of monthly revenue and when it grew or fell: [ ... ]
- Peak month(s) and a possible reason (only if the data supports it): [ ... ]
- Months excluded from growth statements because they are incomplete: [ ... ]
- Year-over-year comparison, where both periods exist: [ ... ]

## 3. Where sales come from
Source: Q16 to Q19.
- Top 3 states and their share of revenue: [ ... ]
- States where freight is a large share of revenue: [ ... ]
- Payment method mix: [ ... ]

## 4. Customers
Source: Q20 to Q29.
- Share of one-time customers and the share of revenue they bring: [ ... ]
- Share of repeat customers: [ ... ]
- Revenue concentration (top 20% of customers produce [ ... ]% of revenue): [ ... ]
- Average days to a second order, if available: [ ... ]

## 5. Products
Source: Q30 to Q37.
- Top 5 categories and their share of revenue: [ ... ]
- Categories with meaningful volume but low revenue: [ ... ]
- Seller concentration: [ ... ]
- Categories with the lowest review scores: [ ... ]

## 6. Delivery and satisfaction
Source: Q38 to Q41.
- Average delivery time and the share of late deliveries: [ ... ]
- Average review score on time vs late: [ ... ]
- Slowest states: [ ... ]
- Remember: this is an association, not proof that late delivery causes low scores.

## 7. Recommendations
Write each as: **Finding → Action → How to measure it.** Only use findings from sections 1 to 6.
1. [ finding ] → [ action ] → [ metric to watch ]
2. [ finding ] → [ action ] → [ metric to watch ]
3. [ finding ] → [ action ] → [ metric to watch ]

## 8. Limitations
- No cost data, so no profit.
- No product names.
- Limited repeat purchasing in the data, which limits retention analysis.
- Incomplete first and last months.
- Data is from 2016 to 2018 and may not reflect today's market.
- Public sample, not complete company data.
