# Original dataset (not included in this ZIP)

The raw data is **not** bundled with the project. It belongs to Olist, it is large (the geolocation file alone is about a million rows), and the public source should be the single copy people download from.

## Dataset
- **Name:** Brazilian E-Commerce Public Dataset by Olist
- **Publisher:** Olist, shared on Kaggle
- **Link:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- **License:** check the "License" box on the Kaggle page before you publish anything (at the time of writing it is listed as CC BY-NC-SA 4.0; confirm it yourself).

## How to get it
1. Log in to Kaggle (free account).
2. Open the link above and click **Download**. You get a ZIP file.
3. Unzip it and copy the 9 CSV files into this folder (`dataset/original/`).
4. Do not edit or re-save the files in Excel.

## The 9 files you should have
```
olist_customers_dataset.csv
olist_geolocation_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
olist_orders_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
product_category_name_translation.csv
```

## Verify
From the project root run:
```
python python/supporting_scripts/check_schema.py
```
It checks that every file exists and the column names match what the SQL and Python code expect.
