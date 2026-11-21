# 30-Day Learning Roadmap

About 1.5 to 2 hours a day. Each day has a **goal**, a **task**, and a **proof** (something you write or save). If you skip the proof, you will forget the lesson.

Keep `documentation/decisions.md` open all month. One line per decision: what you found, what you decided, why.

## Week 1: Set up and understand the data
| Day | Goal | Task | Proof |
|---|---|---|---|
| 1 | Install tools | Follow START_HERE.md Section 2 (MySQL, Python, Power BI, Git). | Screenshots of each version command or app open |
| 2 | Get the data | Download from Kaggle, run `check_schema.py`. | Output with all [OK] |
| 3 | Understand the 9 tables | For each file: rows, columns, what one row means. | A table in decisions.md |
| 4 | Understand keys | Learn `order_id`, `customer_id`, `customer_unique_id`. Explain it to someone. | 3-sentence explanation |
| 5 | Create database | Run `create_database.sql` and `create_tables.sql`. Read every line. | `SHOW TABLES;` result |
| 6 | Load data | Run `load_data.sql`. | Row counts match the CSVs |
| 7 | Review | Fix any load problems with troubleshooting.md. | Notes on what broke and how you fixed it |

## Week 2: SQL
| Day | Goal | Task | Proof |
|---|---|---|---|
| 8 | Data quality | Run `data_validation.sql` sections 1 to 4. | Answers to the "expected" notes |
| 9 | More quality checks | Sections 5 to 10. | 5 decisions in the log |
| 10 | Views | Read `create_views.sql`, run it, explain why revenue excludes freight. | Written definition of revenue |
| 11 | Basic queries | `01_basic_analysis.sql` Q1 to Q7. Change one query yourself. | Your headline KPI numbers |
| 12 | Sales queries | Q8 to Q12. | Monthly revenue result saved |
| 13 | Window functions | Q13 to Q15 (LAG, running total). Rewrite Q13 without looking. | Your own version |
| 14 | Geography and payments | Q16 to Q19. | 3 observations |

## Week 3: Customers, products, Python
| Day | Goal | Task | Proof |
|---|---|---|---|
| 15 | Customers I | Q20 to Q23. | One-time vs repeat numbers |
| 16 | Customers II | Q24 to Q29 (NTILE, DENSE_RANK). | Pareto result in words |
| 17 | Products | `04_product_analysis.sql` Q30 to Q37. | Top and bottom categories |
| 18 | Advanced | `05_advanced_analysis.sql` Q38 to Q45. | Late delivery vs score finding |
| 19 | Python load and checks | Notebook sections 1 to 6. | Uniqueness table |
| 20 | Python cleaning and joins | Sections 7 and 8. Compare with SQL KPIs. | SQL = Python check written down |
| 21 | Python analysis | Sections 9 to 14. | 4 charts saved |

## Week 4: Power BI, insights, GitHub
| Day | Goal | Task | Proof |
|---|---|---|---|
| 22 | Connect and model | `data_model.md`. Build the relationships. | Screenshot of model view |
| 23 | Date table and core measures | `dax_measures.md` sections 0 and 1. | KPI cards match SQL |
| 24 | Time and share measures | Sections 2 and 3. | MoM and share visuals |
| 25 | Page 1 | Executive Overview. | Screenshot |
| 26 | Pages 2 and 3 | Sales Performance, Customer Insights. | Screenshots |
| 27 | Page 4 and polish | Product Analysis, formatting, slicers. | Screenshots |
| 28 | Insights | Fill `reports/business_insights.md` with YOUR results. | Completed report |
| 29 | GitHub | Finish README, add screenshots, push. | Repo link |
| 30 | Interview prep | Fill the placeholders in `interview_questions.md`. Practice aloud. | Recorded 3-minute explanation |

## Rules for the month
1. Type queries yourself at least once instead of only running them.
2. If SQL, Python and Power BI disagree, stop and find out why.
3. Never write a result in your report that you did not see on your own screen.
