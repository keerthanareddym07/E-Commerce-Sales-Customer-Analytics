# Dataset Documentation

## 1. Source
- **Name:** Brazilian E-Commerce Public Dataset by Olist
- **Link:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- **What it is:** real, anonymized orders placed on the Olist marketplace in Brazil between 2016 and 2018, spread across 9 related tables. Company and partner names in the review text were anonymized by the publisher.
- **License:** check the Kaggle page before publishing (see `dataset/original/README.md`).

## 2. Size
These are the numbers expected for the standard Kaggle version. **Confirm them yourself** with `database/load_data.sql` (row count query at the end) or `df.shape` in the notebook, and write your numbers in `decisions.md`.

| Table | Expected rows | Columns |
|---|---|---|
| customers | 99,441 | 5 |
| geolocation | about 1,000,000 | 5 |
| order_items | 112,650 | 7 |
| order_payments | 103,886 | 5 |
| order_reviews | 99,224 | 7 |
| orders | 99,441 | 8 |
| products | 32,951 | 9 |
| sellers | about 3,100 | 4 |
| product_category_translation | 71 | 2 |

## 3. How the tables connect

```
customers ──< orders >── order_items >── products
                │              └──────── sellers
                ├──< order_payments
                └──< order_reviews
product_category_translation  (joined on product_category_name, no foreign key)
geolocation                   (joined on ZIP prefix, not used in the main analysis)
```

## 4. Column descriptions

### customers
| Column | Meaning |
|---|---|
| customer_id | ID given to the customer **on one order**. A new value for every order. |
| customer_unique_id | ID of the real person. Repeats if the person orders again. |
| customer_zip_code_prefix | First 5 digits of the customer ZIP code |
| customer_city, customer_state | Customer location (state is a 2-letter code) |

### orders
| Column | Meaning |
|---|---|
| order_id | Unique order ID |
| customer_id | Links to customers |
| order_status | delivered, shipped, canceled, unavailable, invoiced, processing, created, approved |
| order_purchase_timestamp | When the order was placed |
| order_approved_at | When payment was approved |
| order_delivered_carrier_date | When the order was handed to the carrier |
| order_delivered_customer_date | When the customer received it |
| order_estimated_delivery_date | Delivery date promised to the customer |

### order_items
| Column | Meaning |
|---|---|
| order_id | Links to orders |
| order_item_id | Item number within the order (1, 2, 3...) |
| product_id, seller_id | Product sold and the seller |
| shipping_limit_date | Deadline for the seller to hand the item to the carrier |
| price | Item price (BRL) |
| freight_value | Shipping cost charged for the item (BRL) |

### order_payments
| Column | Meaning |
|---|---|
| order_id | Links to orders |
| payment_sequential | Sequence number when an order is paid with several methods |
| payment_type | credit_card, boleto, voucher, debit_card |
| payment_installments | Number of instalments |
| payment_value | Amount paid for that payment row |

### order_reviews
| Column | Meaning |
|---|---|
| review_id | Review ID (not unique across rows) |
| order_id | Links to orders |
| review_score | 1 to 5 |
| review_comment_title, review_comment_message | Optional comment text (Portuguese) |
| review_creation_date, review_answer_timestamp | Survey sent and answered times |

### products
| Column | Meaning |
|---|---|
| product_id | Unique product ID |
| product_category_name | Category in Portuguese |
| product_name_lenght, product_description_lenght | Number of characters (spelling "lenght" is in the original file) |
| product_photos_qty | Number of photos |
| product_weight_g, product_length_cm, product_height_cm, product_width_cm | Size and weight |

### sellers
seller_id, seller_zip_code_prefix, seller_city, seller_state.

### product_category_translation
product_category_name (Portuguese) and product_category_name_english.

### geolocation
ZIP code prefix, latitude, longitude, city, state. Many rows per ZIP prefix.

## 5. Limitations and missing business information
1. **No cost data.** Profit and margin cannot be calculated. This project reports revenue only.
2. **No product names.** Products are identified by ID and category.
3. **Few repeat customers.** Most people ordered once, so retention analysis is limited. This is a finding in itself.
4. **Uneven time coverage.** The early months of the data and the last month are incomplete. Growth statements must avoid those months.
5. **Old data** (2016 to 2018), in Brazilian reais, with Brazil-specific payment types (e.g. boleto).
6. **Anonymized text.** Review comments are in Portuguese and were anonymized by the publisher.
7. **Revenue is not payments.** `payment_value` includes freight and other effects. Items and payments will not reconcile exactly (see check 10 in `database/data_validation.sql`).
8. **Sample, not the whole company.** It is a public sample released for analysis, so do not describe it as complete company data.

## 6. Known data-quality issues to look for
- Missing delivery dates for orders that were not delivered (expected).
- Orders with no items (cannot produce revenue).
- Products with no category, and categories with no English translation.
- Duplicate rows in geolocation.
- A review ID that appears for more than one order, and orders with more than one review.
- Orders with several payment rows (split payments).
