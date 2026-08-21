# Retail BI data dictionary

## `fact_transactions`

Grain: one deduplicated, commercially valid invoice-product line.

| Column | Type | Meaning |
|---|---|---|
| `transaction_key` | Text | Unique technical key derived from source period and source row. |
| `invoice_no` | Text | Source invoice identifier; `C` prefix denotes a return/cancellation. |
| `product_key` | Text | Foreign key to `dim_product`. |
| `customer_key` | Text | Foreign key to `dim_customer`; missing IDs use `CUST:UNKNOWN`. |
| `country_key` | Text | Foreign key to `dim_country`. |
| `date_key` | Integer | `YYYYMMDD` foreign key to `dim_date`. |
| `invoice_date` | Date | Calendar date of the transaction. |
| `invoice_datetime` | DateTime | Original invoice timestamp. |
| `invoice_time` | Time | Time component of the invoice timestamp. |
| `quantity` | Integer | Units on the source line; negative for retained returns. |
| `unit_price` | Decimal | Source price per unit. |
| `line_value` | Decimal | `quantity × unit_price`; negative for returns. |
| `transaction_type` | Text | `Sale` or `Return`. |
| `is_return` | Boolean | True for a retained `C` invoice row. |
| `gross_sales_value` | Decimal | Positive sales value; zero on return rows. |
| `return_value` | Decimal | Absolute value of retained returns; zero on sale rows. |
| `net_sales_value` | Decimal | Signed line value: sales less returns. |
| `source_period` | Text | Original workbook worksheet/year. |

## `dim_date`

Grain: one calendar date across the full analytical period. Includes year, quarter, month, week, weekday, and weekend attributes.

## `dim_product`

Grain: one stock code. The description is the latest nonblank description observed for that stock code, with first and last observed dates retained.

## `dim_customer`

Grain: one customer ID plus an explicit unknown member. Includes first/last purchase dates, order and unit counts, customer lifetime sales/returns, recency, RFM scores, RFM code, and segment.

## `dim_country`

Grain: one cleaned source country label.

## `agg_monthly_sales`

Grain: one calendar month. Contains order, customer, unit, gross-sales, return, and net-sales metrics for fast trend visuals.

## `agg_customer_cohort`

Grain: one acquisition-cohort month and activity month. `cohort_index` is the number of months since the customer's first sale month; `active_customers` is the retained-customer count.
