# START HERE

This guide takes you from the ZIP file to a finished project. Read it fully once, then follow the steps.

## What this project is
An end-to-end analysis of real e-commerce data (Olist, Brazil, 2016 to 2018): MySQL for storage and analysis, Python for exploration and cross-checks, Power BI for the dashboard, GitHub for the portfolio page.

## Be clear about what is already done and what is not
| Item | Status |
|---|---|
| SQL scripts (schema, load, validation, views, 45 analysis queries) | Written, **not yet run on the real data** |
| Python notebook and schema-check script | Written, **not yet run on the real data** |
| DAX measures, data model, dashboard design guide | Written |
| Power BI file (.pbix) | **Not included.** You build it. |
| Dataset | **Not included.** You download it from Kaggle. |
| Business insights | **Template only.** You fill it with your own results. |

Because nothing has been run on the real data, there are **no results in this project**. You will generate them. If a script fails because of a column name or an environment difference, use `documentation/troubleshooting.md`. Never publish a number you did not see on your own screen.

## 1. Extract the ZIP on Windows
1. Save `Ecommerce-Data-Analytics.zip` somewhere simple, e.g. `C:\Projects\` (avoid OneDrive folders with a huge amount of data).
2. Right-click the ZIP > **Extract All...** > choose the folder > **Extract**.
3. Open the extracted folder `Ecommerce-Data-Analytics`. You should see `README.md`, `START_HERE.md`, and folders named `database`, `sql`, `python`, `powerbi`, and so on.
(Do not run files from inside the ZIP without extracting them.)

## 2. Software to install (all free)
| Software | Why | Check it works |
|---|---|---|
| MySQL Server 8.0+ and MySQL Workbench | Database and SQL | Open Workbench, connect to Local instance, run `SELECT VERSION();` |
| Python 3.10+ (python.org, tick "Add Python to PATH") | Notebook | `python --version` in a new terminal |
| Power BI Desktop (Microsoft Store) | Dashboard | Opens without errors |
| MySQL Connector/NET (optional) | Lets Power BI read MySQL | Only needed for Power BI Option A |
| Git (git-scm.com) | GitHub | `git --version` |
| Excel (optional) | Quick inspection | - |

Python libraries: open a terminal in the project folder and run
```
pip install -r requirements.txt
```

## 3. Open the project
- Open the folder in **VS Code** (free) or just in File Explorer.
- Read `README.md` and `documentation/project_workflow.md`.
- Create `documentation/decisions.md` (an empty file with a title). It is your decision log: one line per finding or decision.

## 4. Get the dataset
Follow `dataset/original/README.md`. Put the 9 CSV files in `dataset/original/`, then run:
```
python python/supporting_scripts/check_schema.py
```
Every line should say `[OK]`.

## 5. Import the CSV files into MySQL Workbench
Follow `database/import_instructions.md` step by step. Short version: allow local loading, run `create_database.sql`, `create_tables.sql`, edit the path in `load_data.sql` and run it, then compare row counts.

## 6. Execute the SQL scripts
Run in this order: `database/data_validation.sql`, then `database/create_views.sql`, then the five files in `sql/`. Run one query at a time and read the comment above it. Save important results to your decision log.

## 7. Run the Python notebook
```
cd python
jupyter notebook
```
Open `ecommerce_eda.ipynb` and run it cell by cell (Shift + Enter). After the headline numbers cell, compare with your SQL results.

## 8. Connect Power BI to the data
Follow `powerbi/data_model.md`. Option A connects to MySQL; Option B uses CSV exports.

## 9. Create the dashboard
Use `powerbi/dax_measures.md` for the measures and `powerbi/dashboard_design_guide.md` for the four pages. Check that your KPI cards match your SQL numbers before designing anything.

## 10. Order to follow while learning
1. `documentation/dataset_documentation.md` (understand the data)
2. `database/` scripts (build the database)
3. `database/data_validation.sql` (trust the data)
4. `sql/` files, in numeric order
5. Python notebook (second opinion on the numbers)
6. `powerbi/` (model, measures, pages)
7. `reports/business_insights.md` (your findings)
8. `README.md` (fill in the results)
9. `documentation/interview_questions.md` (practice)

The day-by-day plan is in `documentation/learning_roadmap_30_days.md`.

## 11. Common errors
See `documentation/troubleshooting.md`. The most common ones: `local_infile` disabled, a wrong folder path in `load_data.sql`, files re-saved in Excel, MySQL older than 8.0, and Power BI missing the MySQL connector.

## 12. Use it as a learning project
Do not just run everything. For each query, say aloud what business question it answers and what the result means. If you cannot explain a step, you cannot defend it in an interview.
