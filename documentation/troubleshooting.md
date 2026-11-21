# Troubleshooting

## Git
| Problem | Fix |
|---|---|
| `'git' is not recognized` | Install Git from git-scm.com, then open a NEW terminal. |
| `Author identity unknown` | `git config --global user.name "Your Name"` and `git config --global user.email "you@example.com"` |
| Raw CSVs got committed | `git reset HEAD~1`, make sure `.gitignore` contains the CSV rules, `git status`, commit again, `git push --force-with-lease` |
| `LF will be replaced by CRLF` warning | Harmless on Windows. |
| Typed `!data/raw/...` in the terminal and got "not recognized" | Those lines belong inside the `.gitignore` file, not in the terminal. |

## MySQL Workbench
| Problem | Fix |
|---|---|
| Error 3948 / "Loading local data is disabled" | Enable local_infile. In Workbench: Connection settings > Advanced > in "Others" add `OPT_LOCAL_INFILE=1`. On the server run `SET GLOBAL local_infile = 1;` (needs admin rights). |
| Error 1290 / `--secure-file-priv` | You used `LOAD DATA INFILE` without LOCAL. The scripts use `LOCAL`, so keep it. |
| Error 1265 "Data truncated" | Usually a wrong column type or a shifted column. Check the CSV header matches `create_tables.sql`. Re-run `check_schema.py`. |
| Error 1292 incorrect datetime | Empty date strings. The load script converts them with `NULLIF`. Make sure you did not remove those lines. |
| Error 1452 foreign key fails | Parent table is empty or loaded after the child. Load in the order in `load_data.sql`. Run the orphan checks in `data_validation.sql`. |
| Error 1175 safe update mode | Edit > Preferences > SQL Editor > untick "Safe Updates", reconnect. |
| Row counts are lower than the CSV | The load stopped on a warning. Run `SHOW WARNINGS;` right after the failed load. A common cause is an Excel-saved CSV. Download the original again. |
| Reviews table has fewer rows | Review comments contain line breaks. The `ENCLOSED BY '"'` option handles them. If the file's line endings are Windows style (`\r\n`), change `LINES TERMINATED BY '\n'` to `'\r\n'` for that file. |
| Window functions error (syntax near OVER) | You are on MySQL 5.7 or older. Install MySQL 8.0 or newer. |
| Table Data Import Wizard is very slow | Use the `LOAD DATA` script instead. |
| `Unknown column 'order_month'` | You queried a table instead of the view. Run `create_views.sql` and query `vw_sales`. |

## Python / Jupyter
| Problem | Fix |
|---|---|
| `python` is not recognized | Install Python from python.org and tick "Add Python to PATH", then open a new terminal. |
| `ModuleNotFoundError` | `pip install -r requirements.txt` |
| `FileNotFoundError` for a CSV | The notebook expects the files in `dataset/original/` (path `../dataset/original`). Open the notebook from the `python/` folder, or fix `DATA_DIR`. |
| Notebook kernel dies on geolocation | Close other programs. You can skip loading geolocation (not used in the analysis). |
| `NameError: name 'display' is not defined` | You are running the code as a plain `.py` file. Use Jupyter. |
| Join check assertion fails | A join multiplied rows. Check which table has repeated IDs (section 4) and aggregate it first. |

## Power BI
| Problem | Fix |
|---|---|
| MySQL connector missing | Install MySQL Connector/NET (version 8 or newer) then restart Power BI. Or use Option B (CSV). |
| Month names sort alphabetically | Select `Month Name`, Column tools > Sort by column > `Month Number`. |
| Numbers differ from SQL | Check relationships (single direction, one-to-many), check for blank dates, and check you used `DISTINCTCOUNT` for orders and customers. |
| A measure shows the same value everywhere | The visual field is not related to the fact table. Check the relationship. |
| Time intelligence returns blank | Date table is not marked, or has gaps. Recreate `dim_date` and mark it. |
