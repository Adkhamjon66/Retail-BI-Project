-- Portfolio-ready DuckDB SQL examples.
-- Run after 01_build_retail_model.sql.

-- 1. Monthly sales, returns, and net revenue trend
SELECT
    year_month,
    order_count,
    gross_sales_value,
    return_value,
    net_sales_value,
    return_value / NULLIF(gross_sales_value, 0) AS return_rate
FROM agg_monthly_sales
ORDER BY year_month;

-- 2. Top products by net sales
SELECT
    p.stock_code,
    p.product_description,
    SUM(f.quantity) AS net_units,
    SUM(f.net_sales_value) AS net_sales_value,
    COUNT(DISTINCT f.invoice_no) AS invoice_count
FROM fact_transactions f
JOIN dim_product p USING (product_key)
GROUP BY p.stock_code, p.product_description
ORDER BY net_sales_value DESC
LIMIT 20;

-- 3. Country performance excluding the domestic UK market
SELECT
    c.country,
    COUNT(DISTINCT CASE WHEN f.transaction_type = 'Sale' THEN f.invoice_no END)
        AS order_count,
    COUNT(DISTINCT CASE WHEN f.customer_key <> 'CUST:UNKNOWN' THEN f.customer_key END)
        AS customer_count,
    SUM(f.net_sales_value) AS net_sales_value
FROM fact_transactions f
JOIN dim_country c USING (country_key)
WHERE c.country <> 'United Kingdom'
GROUP BY c.country
ORDER BY net_sales_value DESC;

-- 4. RFM customer-segment profile
SELECT
    rfm_segment,
    COUNT(*) AS customer_count,
    SUM(net_sales_value) AS customer_lifetime_value,
    AVG(order_count) AS average_orders,
    AVG(recency_days) AS average_recency_days
FROM dim_customer
WHERE customer_key <> 'CUST:UNKNOWN'
GROUP BY rfm_segment
ORDER BY customer_lifetime_value DESC;

-- 5. Products frequently bought together in the same sale invoice
WITH sale_lines AS (
    SELECT DISTINCT invoice_no, product_key
    FROM fact_transactions
    WHERE transaction_type = 'Sale'
), product_pairs AS (
    SELECT
        a.product_key AS product_a_key,
        b.product_key AS product_b_key,
        COUNT(*) AS invoices_together
    FROM sale_lines a
    JOIN sale_lines b
      ON a.invoice_no = b.invoice_no
     AND a.product_key < b.product_key
    GROUP BY a.product_key, b.product_key
)
SELECT
    pa.product_description AS product_a,
    pb.product_description AS product_b,
    pp.invoices_together
FROM product_pairs pp
JOIN dim_product pa ON pp.product_a_key = pa.product_key
JOIN dim_product pb ON pp.product_b_key = pb.product_key
ORDER BY pp.invoices_together DESC
LIMIT 20;
