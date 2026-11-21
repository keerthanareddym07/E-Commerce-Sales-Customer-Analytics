# Import Instructions (MySQL Workbench, Windows)

Requirement: **MySQL Server 8.0 or newer** (the SQL files use window functions and CTEs). Check with `SELECT VERSION();`.

## 1. Prepare the files
1. Download the 9 CSV files (see `dataset/original/README.md`).
2. Copy them to a simple folder without spaces, for example `C:\olist_data\`.
3. Do not open and save them in Excel.

## 2. Allow local file loading (one-time)
`LOAD DATA LOCAL INFILE` is disabled by default for safety. Turn it on in two places:

**Server side** (run in Workbench; needs an admin account such as root):
```sql
SET GLOBAL local_infile = 1;
```

**Client side** (Workbench connection):
1. On the Workbench home screen, right-click your connection > **Edit Connection**.
2. Open the **Advanced** tab.
3. In the **Others** box type: `OPT_LOCAL_INFILE=1`
4. Click **Close**, then reconnect.

## 3. Run the scripts in this order
Open each file with **File > Open SQL Script**, then press the lightning bolt (run all).

| Order | File | What it does |
|---|---|---|
| 1 | `create_database.sql` | Creates the `olist_ecommerce` database |
| 2 | `create_tables.sql` | Creates 9 tables with keys |
| 3 | `load_data.sql` | Loads the CSVs. **Edit the folder path first** (`C:/olist_data/`) |
| 4 | `data_validation.sql` | Checks the data. Read each result |
| 5 | `create_views.sql` | Creates the views used by the analysis |

The geolocation file has about a million rows, so loading takes a few minutes. That is normal.

## 4. Check the load
The last query in `load_data.sql` prints a row count per table. Compare with the counts you recorded from the CSV files. They must match. If a count is lower, run `SHOW WARNINGS;` immediately and see `documentation/troubleshooting.md`.

## 5. Alternative: Table Data Import Wizard (slower)
Use only if `LOAD DATA` does not work.
1. Right-click a table in the left Navigator > **Table Data Import Wizard**.
2. Select the matching CSV, choose **Use existing table**.
3. Check that columns map correctly, then finish.
4. Load the parent tables first (customers, sellers, translation, products, orders), then children.
5. For large files (geolocation, order_items) this can take a long time.
If date columns show errors, the wizard may not convert empty strings to NULL. The `LOAD DATA` method handles this better.

## 6. Run the analysis
Open files in `sql/` and run one query at a time (select the query, press `Ctrl + Enter`). Read the comment above each query first.
