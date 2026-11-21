"""
check_schema.py  -  run this BEFORE the notebook.

It checks that the 9 Olist CSV files exist in dataset/original/ and that each
file has the column names this project expects. If a column name differs
(for example because Kaggle updated the files), you find out here instead of
getting a confusing error in the middle of the analysis.

Run from the project root:
    python python/supporting_scripts/check_schema.py
"""
from pathlib import Path
import csv

DATA_DIR = Path(__file__).resolve().parents[2] / "dataset" / "original"

EXPECTED = {
    "olist_customers_dataset.csv": [
        "customer_id", "customer_unique_id", "customer_zip_code_prefix",
        "customer_city", "customer_state"],
    "olist_geolocation_dataset.csv": [
        "geolocation_zip_code_prefix", "geolocation_lat", "geolocation_lng",
        "geolocation_city", "geolocation_state"],
    "olist_order_items_dataset.csv": [
        "order_id", "order_item_id", "product_id", "seller_id",
        "shipping_limit_date", "price", "freight_value"],
    "olist_order_payments_dataset.csv": [
        "order_id", "payment_sequential", "payment_type",
        "payment_installments", "payment_value"],
    "olist_order_reviews_dataset.csv": [
        "review_id", "order_id", "review_score", "review_comment_title",
        "review_comment_message", "review_creation_date", "review_answer_timestamp"],
    "olist_orders_dataset.csv": [
        "order_id", "customer_id", "order_status", "order_purchase_timestamp",
        "order_approved_at", "order_delivered_carrier_date",
        "order_delivered_customer_date", "order_estimated_delivery_date"],
    "olist_products_dataset.csv": [
        "product_id", "product_category_name", "product_name_lenght",
        "product_description_lenght", "product_photos_qty", "product_weight_g",
        "product_length_cm", "product_height_cm", "product_width_cm"],
    "olist_sellers_dataset.csv": [
        "seller_id", "seller_zip_code_prefix", "seller_city", "seller_state"],
    "product_category_name_translation.csv": [
        "product_category_name", "product_category_name_english"],
}


def main():
    problems = 0
    print(f"Looking for CSV files in: {DATA_DIR}\n")
    for filename, expected_cols in EXPECTED.items():
        path = DATA_DIR / filename
        if not path.exists():
            print(f"[MISSING]  {filename}")
            problems += 1
            continue
        with open(path, newline="", encoding="utf-8-sig") as f:
            header = next(csv.reader(f))
        if header == expected_cols:
            print(f"[OK]       {filename}  ({len(header)} columns)")
        else:
            problems += 1
            print(f"[DIFFERENT] {filename}")
            print(f"    expected: {expected_cols}")
            print(f"    found:    {header}")
    print()
    if problems == 0:
        print("All files found and all column names match. You can run the notebook.")
    else:
        print(f"{problems} problem(s) found. Fix them before continuing "
              "(see documentation/troubleshooting.md).")


if __name__ == "__main__":
    main()
