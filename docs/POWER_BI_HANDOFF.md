# Power BI handoff

The notebook creates the following files in `data/processed/`:

| File | Purpose | Power BI role |
|---|---|---|
| `fact_transactions.parquet` | Commercial sale and return lines | Central fact table |
| `dim_date.parquet` | Continuous calendar | Date dimension |
| `dim_product.parquet` | One row per stock code | Product dimension |
| `dim_customer.parquet` | One row per customer, including RFM fields | Customer dimension |
| `dim_country.parquet` | One row per country | Geography dimension |
| `agg_monthly_sales.parquet` | Pre-aggregated monthly trend | Optional performance table |
| `agg_customer_cohort.parquet` | Cohort-retention matrix input | Optional cohort page |

## Load order

1. Open Power BI Desktop.
2. Select **Get data → More → Parquet**.
3. Choose each Parquet file from `data/processed/`.
4. Select **Transform Data** and confirm the inferred types.
5. Select **Close & Apply**.

## Star-schema relationships

Create these active, one-to-many, single-direction relationships:

| One side | Many side |
|---|---|
| `dim_date[date_key]` | `fact_transactions[date_key]` |
| `dim_product[product_key]` | `fact_transactions[product_key]` |
| `dim_customer[customer_key]` | `fact_transactions[customer_key]` |
| `dim_country[country_key]` | `fact_transactions[country_key]` |

Do not connect the dimension tables to each other. Keep the two aggregate tables disconnected initially; use them only for dedicated monthly-trend or cohort visuals.

After creating the date relationship, mark `dim_date` as the date table using `dim_date[date]`.

## Recommended first measures

```DAX
Gross Sales = SUM ( fact_transactions[gross_sales_value] )

Return Value = SUM ( fact_transactions[return_value] )

Net Sales = SUM ( fact_transactions[net_sales_value] )

Sales Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_transactions[invoice_no] ),
    fact_transactions[transaction_type] = "Sale"
)

Units Sold =
CALCULATE (
    SUM ( fact_transactions[quantity] ),
    fact_transactions[transaction_type] = "Sale"
)

Customer Count =
CALCULATE (
    DISTINCTCOUNT ( fact_transactions[customer_key] ),
    fact_transactions[customer_key] <> "CUST:UNKNOWN"
)

Average Order Value = DIVIDE ( [Gross Sales], [Sales Orders] )

Return Rate = DIVIDE ( [Return Value], [Gross Sales] )
```

## Model check before dashboard design

Create a temporary page named `00 Model Check` containing:

- cards for Gross Sales, Return Value, Net Sales, Sales Orders, and Customer Count;
- a table with `dim_date[year]`, Gross Sales, Net Sales, and Sales Orders;
- slicers from `dim_date[year]`, `dim_country[country]`, `dim_product[product_description]`, and `dim_customer[rfm_segment]`.

Every slicer must change the measures. If one does not, inspect the corresponding relationship before building the showcase pages.
