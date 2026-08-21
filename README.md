# Retail BI Analytics Portfolio Project

End-to-end retail analytics project built from the raw **Online Retail II** workbook using Python, DuckDB SQL, Parquet, and Power BI.

## What this project demonstrates

- reproducible ingestion of two raw Excel worksheets;
- source profiling and explicit data-quality decisions;
- SQL-based cleaning and exact-duplicate handling;
- separation of sales, returns, and administrative adjustments;
- a validated star schema for Power BI;
- customer RFM segmentation and cohort-retention preparation;
- compressed Parquet exports and relationship validation;
- portfolio SQL covering trends, products, countries, RFM, and product pairs.

## Pipeline

```text
Raw Online Retail II workbook
             |
             v
Python ingestion and provenance fields
             |
             v
DuckDB raw + cleaned layers
             |
             v
Validated star schema
  |          |          |          |
Date      Product    Customer    Country
  \          |          |          /
         Fact Transactions
             |
             v
ZSTD-compressed Parquet files
             |
             v
Power BI semantic model and dashboards
```

## Repository structure

```text
retail-bi-project/
├── data/
│   ├── raw/                 # Local source workbook; ignored by Git
│   └── processed/           # Generated Parquet and DuckDB files; ignored by Git
├── docs/
│   ├── POWER_BI_HANDOFF.md
│   └── validation/          # Commit-safe metadata and test results
├── notebooks/
│   └── retail_bi_pipeline.ipynb
├── sql/
│   └── queries/
│       ├── 01_build_retail_model.sql
│       └── 02_portfolio_analysis_queries.sql
├── dashboards/              # Power BI file and dashboard screenshots
├── requirements.txt
└── README.md
```

## Run the pipeline

1. Place `online_retail_2.xlsx` in `data/raw/`.
2. Create and activate a virtual environment.
3. Install dependencies with `python -m pip install -r requirements.txt`.
4. Open `notebooks/retail_bi_pipeline.ipynb` in VS Code or Jupyter.
5. Select the project virtual-environment kernel.
6. Choose **Restart Kernel and Run All Cells**.
7. Confirm the final message says the pipeline completed successfully.

The notebook exports the Power BI tables to `data/processed/`. See [the Power BI handoff](docs/POWER_BI_HANDOFF.md) for load order, relationships, and starter measures.

## Analytical grain and KPI policy

- Raw grain: one row from one workbook worksheet.
- Fact grain: one deduplicated, commercially valid invoice-product line.
- Sales: normal invoices with positive quantity and price.
- Returns: `C` invoices with negative quantity and positive price.
- Administrative/stock adjustments remain auditable but do not enter commercial KPIs.
- Missing customer IDs use an explicit unknown member so total revenue still reconciles.

## Data publication

Raw, cleaned, and processed data files are intentionally excluded from Git. The public repository contains code, SQL, validation metadata, documentation, and dashboard images. Users must obtain the source data independently and run the notebook locally.
