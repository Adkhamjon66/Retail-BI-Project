-- Retail BI analytical model
-- Source table expected: raw_transactions
-- Grain of raw_transactions: one source workbook row.

CREATE OR REPLACE TABLE clean_transactions AS
SELECT
    source_period,
    CAST(source_row AS BIGINT) AS source_row,
    NULLIF(TRIM(CAST(invoice AS VARCHAR)), '') AS invoice_no,
    NULLIF(TRIM(CAST(stock_code AS VARCHAR)), '') AS stock_code,
    NULLIF(TRIM(CAST(description AS VARCHAR)), '') AS description,
    TRY_CAST(quantity AS INTEGER) AS quantity,
    TRY_CAST(invoice_date AS TIMESTAMP) AS invoice_datetime,
    TRY_CAST(price AS DOUBLE) AS unit_price,
    NULLIF(
        REGEXP_REPLACE(TRIM(CAST(customer_id AS VARCHAR)), '\\.0$', ''),
        ''
    ) AS customer_id,
    NULLIF(TRIM(CAST(country AS VARCHAR)), '') AS country
FROM raw_transactions;

CREATE OR REPLACE TABLE deduplicated_transactions AS
WITH numbered AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                invoice_no,
                stock_code,
                description,
                quantity,
                invoice_datetime,
                unit_price,
                customer_id,
                country
            ORDER BY source_period, source_row
        ) AS duplicate_number
    FROM clean_transactions
)
SELECT * EXCLUDE (duplicate_number)
FROM numbered
WHERE duplicate_number = 1;

CREATE OR REPLACE TABLE fact_transactions AS
SELECT
    'TXN:' || MD5(source_period || ':' || CAST(source_row AS VARCHAR))
        AS transaction_key,
    invoice_no,
    'PROD:' || stock_code AS product_key,
    CASE
        WHEN customer_id IS NULL THEN 'CUST:UNKNOWN'
        ELSE 'CUST:' || customer_id
    END AS customer_key,
    'COUNTRY:' || MD5(UPPER(country)) AS country_key,
    CAST(STRFTIME(invoice_datetime, '%Y%m%d') AS INTEGER) AS date_key,
    CAST(invoice_datetime AS DATE) AS invoice_date,
    invoice_datetime,
    CAST(invoice_datetime AS TIME) AS invoice_time,
    quantity,
    unit_price,
    quantity * unit_price AS line_value,
    CASE
        WHEN UPPER(invoice_no) LIKE 'C%' THEN 'Return'
        ELSE 'Sale'
    END AS transaction_type,
    CASE WHEN UPPER(invoice_no) LIKE 'C%' THEN TRUE ELSE FALSE END AS is_return,
    CASE WHEN UPPER(invoice_no) LIKE 'C%' THEN 0.0
         ELSE quantity * unit_price END AS gross_sales_value,
    CASE WHEN UPPER(invoice_no) LIKE 'C%' THEN ABS(quantity * unit_price)
         ELSE 0.0 END AS return_value,
    quantity * unit_price AS net_sales_value,
    source_period
FROM deduplicated_transactions
WHERE invoice_no IS NOT NULL
  AND stock_code IS NOT NULL
  AND country IS NOT NULL
  AND invoice_datetime IS NOT NULL
  AND unit_price > 0
  AND (
        (UPPER(invoice_no) NOT LIKE 'A%' AND UPPER(invoice_no) NOT LIKE 'C%' AND quantity > 0)
        OR
        (UPPER(invoice_no) LIKE 'C%' AND quantity < 0)
      );

CREATE OR REPLACE TABLE dim_product AS
WITH product_profile AS (
    SELECT
        stock_code,
        ARG_MAX(description, invoice_datetime)
            FILTER (WHERE description IS NOT NULL) AS product_description,
        MIN(CAST(invoice_datetime AS DATE)) AS first_observed_date,
        MAX(CAST(invoice_datetime AS DATE)) AS last_observed_date
    FROM deduplicated_transactions
    WHERE stock_code IS NOT NULL
    GROUP BY stock_code
)
SELECT
    'PROD:' || stock_code AS product_key,
    stock_code,
    COALESCE(product_description, 'Unknown product') AS product_description,
    first_observed_date,
    last_observed_date
FROM product_profile;

CREATE OR REPLACE TABLE dim_country AS
SELECT DISTINCT
    'COUNTRY:' || MD5(UPPER(country)) AS country_key,
    country
FROM deduplicated_transactions
WHERE country IS NOT NULL;

CREATE OR REPLACE TABLE dim_date AS
WITH bounds AS (
    SELECT MIN(invoice_date) AS min_date, MAX(invoice_date) AS max_date
    FROM fact_transactions
), calendar AS (
    SELECT CAST(calendar_date AS DATE) AS date
    FROM bounds,
    RANGE(min_date, max_date + INTERVAL 1 DAY, INTERVAL 1 DAY) AS t(calendar_date)
)
SELECT
    CAST(STRFTIME(date, '%Y%m%d') AS INTEGER) AS date_key,
    date,
    YEAR(date) AS year,
    QUARTER(date) AS quarter_number,
    'Q' || CAST(QUARTER(date) AS VARCHAR) AS quarter,
    MONTH(date) AS month_number,
    STRFTIME(date, '%B') AS month_name,
    STRFTIME(date, '%Y-%m') AS year_month,
    WEEK(date) AS week_number,
    DAYOFWEEK(date) AS day_of_week_number,
    STRFTIME(date, '%A') AS day_name,
    DAY(date) AS day_of_month,
    CASE WHEN DAYOFWEEK(date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM calendar;

CREATE OR REPLACE TABLE customer_metrics AS
WITH customer_base AS (
    SELECT
        customer_key,
        MIN(invoice_date) AS first_purchase_date,
        MAX(invoice_date) AS last_purchase_date,
        COUNT(DISTINCT CASE WHEN transaction_type = 'Sale' THEN invoice_no END)
            AS order_count,
        SUM(CASE WHEN transaction_type = 'Sale' THEN quantity ELSE 0 END)
            AS units_purchased,
        SUM(gross_sales_value) AS gross_sales_value,
        SUM(return_value) AS return_value,
        SUM(net_sales_value) AS net_sales_value
    FROM fact_transactions
    WHERE customer_key <> 'CUST:UNKNOWN'
    GROUP BY customer_key
), reference_date AS (
    SELECT MAX(invoice_date) + INTERVAL 1 DAY AS as_of_date
    FROM fact_transactions
), scored AS (
    SELECT
        cb.*,
        DATE_DIFF('day', last_purchase_date, rd.as_of_date) AS recency_days,
        6 - NTILE(5) OVER (ORDER BY DATE_DIFF('day', last_purchase_date, rd.as_of_date))
            AS recency_score,
        NTILE(5) OVER (ORDER BY order_count) AS frequency_score,
        NTILE(5) OVER (ORDER BY net_sales_value) AS monetary_score
    FROM customer_base cb
    CROSS JOIN reference_date rd
)
SELECT
    *,
    CAST(recency_score AS VARCHAR)
        || CAST(frequency_score AS VARCHAR)
        || CAST(monetary_score AS VARCHAR) AS rfm_code,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4
            THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3
            THEN 'Loyal customers'
        WHEN recency_score >= 4 AND frequency_score <= 2
            THEN 'Promising'
        WHEN recency_score <= 2 AND frequency_score >= 4
            THEN 'At risk'
        WHEN recency_score <= 2 AND frequency_score <= 2
            THEN 'Hibernating'
        ELSE 'Needs attention'
    END AS rfm_segment
FROM scored;

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    customer_key,
    REPLACE(customer_key, 'CUST:', '') AS customer_id,
    first_purchase_date,
    last_purchase_date,
    order_count,
    units_purchased,
    gross_sales_value,
    return_value,
    net_sales_value,
    recency_days,
    recency_score,
    frequency_score,
    monetary_score,
    rfm_code,
    rfm_segment
FROM customer_metrics
UNION ALL
SELECT
    'CUST:UNKNOWN',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Unknown customer';

CREATE OR REPLACE TABLE agg_monthly_sales AS
SELECT
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month_number,
    STRFTIME(invoice_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT CASE WHEN transaction_type = 'Sale' THEN invoice_no END)
        AS order_count,
    COUNT(DISTINCT CASE WHEN customer_key <> 'CUST:UNKNOWN' THEN customer_key END)
        AS identified_customer_count,
    SUM(CASE WHEN transaction_type = 'Sale' THEN quantity ELSE 0 END)
        AS units_sold,
    SUM(gross_sales_value) AS gross_sales_value,
    SUM(return_value) AS return_value,
    SUM(net_sales_value) AS net_sales_value
FROM fact_transactions
GROUP BY YEAR(invoice_date), MONTH(invoice_date), STRFTIME(invoice_date, '%Y-%m')
ORDER BY year, month_number;

CREATE OR REPLACE TABLE agg_customer_cohort AS
WITH first_purchase AS (
    SELECT customer_key, DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM fact_transactions
    WHERE customer_key <> 'CUST:UNKNOWN'
      AND transaction_type = 'Sale'
    GROUP BY customer_key
), activity AS (
    SELECT DISTINCT customer_key, DATE_TRUNC('month', invoice_date) AS activity_month
    FROM fact_transactions
    WHERE customer_key <> 'CUST:UNKNOWN'
      AND transaction_type = 'Sale'
)
SELECT
    fp.cohort_month,
    a.activity_month,
    DATE_DIFF('month', fp.cohort_month, a.activity_month) AS cohort_index,
    COUNT(DISTINCT a.customer_key) AS active_customers
FROM first_purchase fp
JOIN activity a USING (customer_key)
WHERE a.activity_month >= fp.cohort_month
GROUP BY fp.cohort_month, a.activity_month
ORDER BY fp.cohort_month, a.activity_month;
