# Retail BI Project — Task Instructions

**Your dataset:** One Excel file, two sheets — `Year 2009-2010` (525,461 rows) and `Year 2010-2011` (541,910 rows).
Both sheets have the same 8 columns: Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country.

**How to use this guide:** Each task tells you *what* to do and *what to think about*. It does not give you the code or the answer. Work through each task, then move to the next.

**A note on Git:** Git tasks are woven into each phase at natural save points. You do not do all Git at the end — you commit as you go, just like a real analyst on a team. Each Git task tells you exactly when to commit and what message to use.

---

## PHASE 0 — Git Setup

Do this once, before anything else in the project.

---

### Task 0.1 — Install Git and configure your identity

Download and install Git from https://git-scm.com if you do not already have it. After installing, open a terminal (Command Prompt or Git Bash on Windows) and configure your name and email. These appear on every commit you make.

Look up the two `git config --global` commands for setting `user.name` and `user.email`.

Verify the setup worked by running `git --version` and `git config --list`.

**Think about:** Why does Git need your name and email? Where do these actually show up?

---

### Task 0.2 — Create a GitHub account and a new repository

Go to https://github.com and create a free account if you do not have one. Use a professional username — this will be on your portfolio.

Create a new **public** repository called `retail-bi-project`. When creating it:
- Add a short description (one sentence about the project)
- Do NOT initialize it with a README, .gitignore, or license yet — you will add those yourself from your local machine

Copy the repository URL (it ends in `.git`) — you will need it in Task 0.4.

---

### Task 0.3 — Initialize Git in your project folder

In your terminal, navigate into your `retail-bi-project` folder (the one you will create in Task 1.1 — do Task 1.1 first, then come back here, or do both together).

Run `git init` inside the folder. This turns the folder into a Git repository.

Then create a `.gitignore` file in the root of your project. This file tells Git which files and folders to never track. Add these entries to it:

```
data/raw/
data/clean/
__pycache__/
.ipynb_checkpoints/
*.pyc
.env
```

**Think about:** Why do you ignore `data/raw/` and `data/clean/`? Large data files do not belong in Git — they slow down the repository and GitHub has file size limits. Your data lives locally; your code lives on GitHub.

---

### Task 0.4 — Make your first commit and connect to GitHub

Add the `.gitignore` file to Git's staging area and commit it. The commit message should be:

`Initial commit — project structure and .gitignore`

Then connect your local repository to the GitHub repository you created in Task 0.2. Look up the `git remote add origin` command and use your repository URL.

Push your first commit to GitHub with `git push -u origin main` (or `master` depending on your Git version — check what your branch is called with `git branch`).

Go to your GitHub repository in a browser and confirm the `.gitignore` file appears there.

**Think about:** What is the difference between `git add`, `git commit`, and `git push`? Make sure you can explain all three in plain English.

---

## PHASE 1 — Project Setup & Data Loading

---

### Task 1.1 — Create your project folder structure

Create a folder called `retail-bi-project` on your computer. Inside it, create these subfolders:

```
retail-bi-project/
├── data/
│   ├── raw/
│   └── clean/
├── sql/
│   └── queries/
├── notebooks/
├── scripts/
├── screenshots/
└── dashboards/
    ├── powerbi/
    └── tableau/
```

Place your Excel file inside `data/raw/`. You will never edit or overwrite this file. It is your original source of truth.

Create an empty file called `notes.txt` in the root folder. You will use this throughout the project to write down observations.

**Think about:** Why is it important to separate raw data from clean data in a real analytics workflow?

---

### Task 1.2 — First look at the Excel file

Open the file in Excel. You will see two sheets at the bottom: `Year 2009-2010` and `Year 2010-2011`.

Do the following for **each sheet**:
- Look at every column name and data type (text, number, date?)
- Scroll through 20–30 rows to get a feel for what the data looks like
- Use Excel's filter to look for blank cells in each column — which columns have blanks?
- Check the minimum and maximum values in the Quantity and Price columns
- Notice: some Invoice values start with the letter `C` — what do you think those mean?
- Notice: some Quantity values are negative — what might those represent?

Write your observations in `notes.txt`.

**Think about:** What data quality problems do you already suspect before even writing a line of code?

---

### Task 1.3 — Set up your Python environment

Using Anaconda or pip, create a new environment for this project. Install the following libraries: pandas, numpy, matplotlib, seaborn, openpyxl, scikit-learn, sqlalchemy, jupyter, and plotly.

Activate your environment and confirm everything is installed by importing each library in a Python terminal without errors.

Create a `requirements.txt` file in your project root that lists all your installed packages. Look up how to generate this automatically with pip.

**Think about:** Why create a separate environment per project instead of using your base environment?

---

### Task 1.4 — Git commit: project skeleton

At this point you have your folder structure, `.gitignore`, `notes.txt`, and `requirements.txt`. Stage all of these files and make a commit.

Suggested commit message: `Add project structure, requirements, and initial notes`

Push to GitHub. Verify on GitHub that your folder structure is visible.

**Note:** Your `data/` folders will appear empty on GitHub because the Excel file is in `.gitignore`. That is correct.

---

### Task 1.5 — Load both sheets with Python and combine them

Open a Jupyter notebook and name it `01_data_loading.ipynb` inside your `notebooks/` folder.

Your tasks:
- Load **each sheet separately** using pandas — look up how to specify a sheet name when reading an Excel file
- Print the shape (rows and columns) of each sheet after loading
- Check whether the column names are identical across both sheets
- Combine both sheets into a single DataFrame — look up how to stack or concatenate DataFrames vertically in pandas
- After combining, verify the total row count is roughly 525K + 542K
- Check whether the combined DataFrame has any duplicate rows

**Think about:** After combining, how will you know which row came from which year? Should you add a column to track this?

---

### Task 1.6 — Load the data into MySQL

> **Note on SQL in this project:** All SQL tasks are written for MySQL. Where MySQL differs from SQLite (which many tutorials use), a note is provided. Key differences: date functions (`YEAR()`, `MONTH()` in MySQL vs `strftime()` in SQLite), and how NULLs behave. A full reference note appears at the start of Phase 2.

Open MySQL Workbench or your MySQL client.

Your tasks:
- Create a new database called `retail_db`
- Create a table called `transactions` with columns matching the dataset. Decide the right MySQL data type for each column: Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country
- Load the data from your combined DataFrame into MySQL using Python and SQLAlchemy — look up how `DataFrame.to_sql()` works with a SQLAlchemy engine
- After loading, run `SELECT COUNT(*) FROM transactions;` to confirm the row count

**Think about:** Customer ID has missing values. MySQL stores missing values as `NULL`. How does pandas handle NaN when writing to MySQL via SQLAlchemy?

---

### Task 1.7 — Git commit: data loading complete

Your notebook and any scripts you wrote to load data are now ready to commit. Stage `notebooks/01_data_loading.ipynb` and any scripts in `scripts/`.

Suggested commit message: `Phase 1 complete — data loading notebook and MySQL setup`

Push to GitHub.

---

## PHASE 2 — SQL Business Queries

> Save each query as its own `.sql` file in `sql/queries/`. Use a numbered prefix: `01_monthly_revenue.sql`, `02_top_customers.sql`, etc.

> **MySQL vs SQLite — quick reference you will use across all queries:**
> | Task | MySQL | SQLite |
> |---|---|---|
> | Year from date | `YEAR(InvoiceDate)` | `strftime('%Y', InvoiceDate)` |
> | Month from date | `MONTH(InvoiceDate)` | `strftime('%m', InvoiceDate)` |
> | Year-Month string | `DATE_FORMAT(InvoiceDate, '%Y-%m')` | `strftime('%Y-%m', InvoiceDate)` |
> | Hour from datetime | `HOUR(InvoiceDate)` | `strftime('%H', InvoiceDate)` |
> | Day of week | `DAYOFWEEK()` or `DAYNAME()` | `strftime('%w', InvoiceDate)` |
> | Days between dates | `DATEDIFF(date1, date2)` | `JULIANDAY(date1) - JULIANDAY(date2)` |
> | String starts with | `LEFT(col, 1) = 'C'` or `col LIKE 'C%'` | `col LIKE 'C%'` |
> | Previous row value | `LAG(col) OVER (ORDER BY ...)` | `LAG(col) OVER (ORDER BY ...)` *(same)* |
> | Top N rows | `LIMIT N` | `LIMIT N` *(same)* |
> | CTE syntax | `WITH cte AS (...)` | `WITH cte AS (...)` *(same)* |

---

### Task 2.1 — Document your filtering rules

Before writing any business query, decide what rows to exclude. Based on your exploration in Task 1.2, think about:

- What does a negative Quantity mean? Should sales queries include those rows?
- What does a zero or negative Price mean?
- What do Invoice values starting with `C` represent?
- What does a NULL Customer ID mean for customer-specific queries?

Create `sql/queries/00_data_notes.sql` and write your answers as SQL comments at the top. This documents your assumptions for anyone who reads your code.

**Think about:** These filtering decisions affect every query you write. If you change your mind about one rule later, you will need to update many files. That is normal — document your reasoning so you remember why you made each choice.

---

### Task 2.2 — Monthly revenue

Write a query showing total revenue by month and year, ordered earliest to latest.

You will need to multiply Quantity × Price inside the query to get revenue, extract year and month from InvoiceDate, apply your filtering rules, group and order correctly.

**Think about:** If you order by a `YYYY-MM` string, does it sort correctly? What if you order by month number only — what goes wrong?

---

### Task 2.3 — Top 10 customers by total spend

Write a query returning the 10 customers with the highest total spend, plus their number of orders and average order value. Exclude NULL Customer IDs.

**Think about:** What is the difference between `COUNT(Invoice)` and `COUNT(DISTINCT Invoice)` for the same customer? Which gives you the real number of orders?

---

### Task 2.4 — Revenue by country

Write a query showing total revenue, total orders, and total unique customers per country, ordered by revenue descending.

**Think about:** The UK has far more rows than any other country. Write a second version of this query that excludes the UK so you can see international performance clearly.

---

### Task 2.5 — Best and worst products by revenue

Write two queries:
- Top 10 products by total revenue, showing StockCode, Description, revenue, and units sold
- Bottom 10 products by total revenue (only above zero — exclude returns)

**Think about:** Does your top-revenue list match your top-units list? What does it mean for the business if a high-volume product generates low revenue?

---

### Task 2.6 — Return rate by product

Write a query showing which products have the highest return rates. You need both the units sold (positive Quantity) and units returned (negative Quantity) per product to compute the rate.

Look up how to use `CASE WHEN` inside a `SUM()` — this technique is called conditional aggregation and lets you do it in a single query.

**Think about:** A 100% return rate on 2 units is very different from a 30% return rate on 10,000 units. How do you filter your results to show only products with meaningful sales volume?

---

### Task 2.7 — Average order value

Write a query calculating the overall average order value. An order is one unique Invoice. You need the total value per invoice first, then average across those totals.

This requires a subquery or a CTE. Look up `WITH ... AS (...)` syntax in MySQL.

---

### Task 2.8 — Repeat customer rate

Write a query calculating what percentage of customers placed more than one order.

Steps: count distinct invoices per customer, then count how many customers have more than one, divide by total customers, multiply by 100.

**Think about:** Does including or excluding guest orders (NULL Customer ID) change your answer significantly?

---

### Task 2.9 — Customer Lifetime Value table

Write a query showing for each non-guest customer: their first purchase date, last purchase date, total number of orders, total revenue, and number of days between first and last purchase.

In MySQL, use `DATEDIFF()` for the days calculation. Order by total revenue descending.

---

### Task 2.10 — Revenue by day of week

Write a query showing total revenue for each day of the week. In MySQL, `DAYNAME()` returns the name directly (Monday, Tuesday, etc.) and `DAYOFWEEK()` returns a number (1=Sunday through 7=Saturday).

**Think about:** Which day has the highest revenue? Does that pattern make sense for a B2B-style retail company?

---

### Task 2.11 — Revenue by hour of day

Write a query showing total revenue for each hour (0–23), ordered by hour. In MySQL use `HOUR(InvoiceDate)`.

**Think about:** What does the hourly distribution tell you about when customers are active? Is there a dead zone you would highlight to management?

---

### Task 2.12 — UK vs International revenue split

Write a query showing revenue in exactly two groups: United Kingdom and International (everything else). Use `CASE WHEN` on the Country column.

---

### Task 2.13 — Registered vs guest customer revenue

Write a query showing revenue, order count, and average order value separately for customers with a Customer ID (registered) versus those without (guest). Use `CASE WHEN` or `IS NULL` to split the groups.

---

### Task 2.14 — Monthly new vs returning customers

For each month, show how many customers made their **first ever** purchase that month (new) and how many had purchased before and came back (returning).

This requires two steps: first find each customer's earliest purchase month, then use that to classify each transaction. Work through it step by step — write the first part as a CTE, then build the second part on top of it.

---

### Task 2.15 — High value orders

List all orders where the total order value exceeded £500. Show Invoice, total value, Customer ID, Country, and order date. Order by value descending.

---

### Task 2.16 — Products never returned

Find products that appear in sales transactions but have never appeared in a return (negative Quantity). Show their total revenue and units sold.

**Think about:** Does "never returned" mean the product is high quality, or could there be another explanation?

---

### Task 2.17 — Basket size analysis

Write a query that for each invoice shows: number of unique products, total items, and order total. Then use that as a subquery or CTE to calculate the *average* basket size across all orders.

---

### Task 2.18 — Revenue by price band

Group products into price ranges (for example: under £1, £1–£5, £5–£20, £20–£100, over £100) and show total revenue per band. Use `CASE WHEN` on the Price column.

---

### Task 2.19 — Cancellation rate

Calculate what percentage of all invoices are cancellations (Invoice starting with 'C'). In MySQL use `LEFT(Invoice, 1) = 'C'` or `Invoice LIKE 'C%'`.

---

### Task 2.20 — Top 10 countries excluding UK

Show the top 10 countries by revenue with the United Kingdom explicitly excluded. Include revenue, number of orders, and number of unique customers.

---

### Task 2.21 — Quarter-over-quarter revenue

Show total revenue by quarter (1–4) and year. In MySQL use `QUARTER(InvoiceDate)`.

**Think about:** The dataset spans roughly Dec 2009 – Dec 2011 across both sheets. Do some quarters contain only partial months of data? How does that affect your interpretation?

---

### Task 2.22 — Revenue per customer by country

Show each country's total revenue divided by its number of unique customers. This reveals which countries have the highest-value customers on average — not just the highest total revenue.

---

### Task 2.23 — Frequently co-purchased products

Find pairs of StockCodes that appear together in the same invoice most often. This requires joining the transactions table to itself on the Invoice column (a self-join), where StockCode A is less than StockCode B to avoid counting the same pair twice. Show the top 20 most common pairs.

**Think about:** This query can be slow on over one million rows. What would make it faster — running it on a filtered subset of invoices, or adding a database index on the Invoice column?

---

### Task 2.24 — Month-over-month revenue growth

Show each month's revenue alongside the previous month's revenue and the percentage change. In MySQL you can use the `LAG()` window function: `LAG(revenue) OVER (ORDER BY month)`.

---

### Task 2.25 — Average days between customer orders

For each customer, calculate the average number of days between their consecutive orders. This requires ranking each customer's orders by date and computing the gap between consecutive rows. Use `LAG()` partitioned by Customer ID.

---

### Tasks 2.26–2.30 — Your own business questions

You have written 25 guided queries. For the final 5, come up with your own questions based on what you have seen in the data. Write each question in plain English first, then translate it into SQL.

Some starting ideas:
- Which StockCodes generate the highest revenue per unit sold?
- Which customers placed orders in both year ranges (2009-10 and 2010-11)?
- How are customers distributed by number of orders (how many placed exactly 1, 2, 3, etc.)?
- Which hour of the day has the highest *average* order value (not just total)?
- What percentage of total revenue comes from the top 10% of customers?

---

### Task 2.31 — Git commit: all SQL queries

Stage all files in `sql/` and commit.

Suggested commit message: `Phase 2 complete — 30 SQL business queries`

Push to GitHub. Browse to your repository and confirm all `.sql` files are visible.

**Think about:** Someone reading your repository on GitHub should be able to open any `.sql` file and immediately understand what business question it answers. Are your file names descriptive enough? Are there comments inside the files?

---

## PHASE 3 — Python: Cleaning, EDA, and Feature Engineering

Work in Jupyter notebooks. Create one notebook per task below, named in order.

---

### Task 3.1 — Exploratory Data Analysis (`02_eda.ipynb`)

Load the combined raw DataFrame from Phase 1 (both sheets merged). Do not clean anything yet — only observe.

Your tasks:
- Print the shape, column names, and data types
- Print a null count for every column
- Print summary statistics with `.describe()` for all numeric columns
- How many rows have negative Quantity? How many have negative Price? How many have an Invoice starting with 'C'?
- How many unique Customer IDs, StockCodes, and countries are there?
- Plot a histogram of Quantity (positive values only so the chart is readable)
- Plot a histogram of Price (cap the range at a reasonable maximum like £50)
- Plot total revenue by month as a bar or line chart
- Save every plot as a PNG file in `screenshots/`

At the end of the notebook, write a markdown cell summarizing: what data quality issues did you find, and what will you do about each one in the cleaning step?

---

### Task 3.2 — Data Cleaning (`03_cleaning.ipynb`)

Load the raw combined DataFrame fresh (always start from raw — never from a previous notebook's output). Apply each cleaning step one at a time. After each step, print the row count so you can see the effect of every decision.

Your cleaning steps:
- Remove rows where Invoice starts with 'C'
- Remove rows where Quantity is zero or negative
- Remove rows where Price is zero or negative
- Handle missing Description values — decide whether to drop them or fill with a placeholder like 'UNKNOWN'
- Handle missing Customer ID — do not drop these rows (guest purchases are real sales). Instead, create a new column called `Is_Guest` that is 1 where Customer ID is null and 0 otherwise. Then fill the null Customer IDs with 0 so the column has no nulls.
- Remove known non-product StockCodes such as 'POST', 'D', 'M', 'BANK CHARGES', 'DOT' — these are internal administrative codes, not real products
- Strip leading and trailing whitespace from text columns (Description, StockCode, Country)
- Standardize text case in Description (all uppercase or all lowercase — pick one and apply it consistently)

After all steps are applied, save the result to `data/clean/online_retail_clean.csv`.

**Think about:** For each row you remove, write a comment in the code explaining *why*, not just *how*. This is what separates a thoughtful analyst from someone who just ran code.

---

### Task 3.3 — Feature Engineering (`04_features.ipynb`)

Load `data/clean/online_retail_clean.csv`. Your goal is to create new columns and summary tables that will be used in both the visualizations and the machine learning phase.

**Add these columns directly to the main DataFrame:**
- `Revenue` = Quantity × Price
- `Year` = year extracted from InvoiceDate
- `Month` = month number (1–12)
- `DayOfWeek` = day of week as a number (0 = Monday, 6 = Sunday in pandas)
- `Hour` = hour of the day (0–23)
- `Quarter` = quarter number (1–4)
- `Is_Weekend` = 1 if DayOfWeek is 5 or 6 (Saturday or Sunday), 0 otherwise

**Create an orders summary table and save it as `data/clean/orders.csv`:**
Group by Invoice and compute: total revenue, total items (sum of Quantity), number of unique products (count distinct StockCode), and the order date.

**Create a customers summary table and save it as `data/clean/customers.csv`:**
Exclude guest rows (Is_Guest = 1). Group by Customer ID and compute: total revenue, number of distinct orders, first purchase date, last purchase date, and number of days between first and last purchase.

**Create an RFM table and save it as `data/clean/rfm.csv`:**
RFM stands for Recency, Frequency, Monetary. Exclude guest rows. For each customer compute:
- Recency: days since their last purchase (use the day after the dataset's last date as your reference "today")
- Frequency: number of distinct orders
- Monetary: total revenue

Then assign each customer a score from 1 to 5 on each dimension using quintiles. Look up `pd.qcut()`. For Recency, a *lower* number of days means *more recent* which is *better*, so reverse the scoring direction for that dimension.

Finally, create a `Segment` column using the scores. At minimum define these segments: Champions (high on all three), Loyal, At Risk (bought frequently but not recently), and Lost (very low recency score).

Save all four tables to `data/clean/`.

---

### Task 3.4 — EDA Visualizations

Using your cleaned and featured data, produce the following charts. Save every chart as a PNG file in `screenshots/`.

- Line chart: monthly revenue trend over the full date range
- Bar chart: revenue by day of week
- Bar chart: revenue by hour of day
- Bar chart: top 10 countries by revenue (try one version with UK included, one without)
- Pie or bar chart: distribution of customers across RFM segments
- Scatter plot: Frequency vs Monetary, each point colored by RFM segment
- Histogram: revenue per order (cap the x-axis at a reasonable maximum)
- Heatmap: revenue by day of week (rows) × hour of day (columns) — use seaborn's `heatmap` function

For each chart, write a one-sentence interpretation in a markdown cell below it. What does this chart tell you about the business?

---

### Task 3.5 — Git commit: Python phase complete

Stage all notebooks in `notebooks/` and all PNG files in `screenshots/`.

Suggested commit message: `Phase 3 complete — EDA, cleaning, feature engineering, visualizations`

Push to GitHub.

**Think about:** Jupyter notebook files (`.ipynb`) are JSON under the hood. When you look at a notebook diff on GitHub it can be hard to read. This is normal — the important thing is that your notebooks are on GitHub so recruiters can see them.

---

## PHASE 4 — Machine Learning

Work in a new notebook: `notebooks/05_machine_learning.ipynb`.

---

### Task 4.1 — Frame your problems in writing before writing any code

Open the notebook and write a markdown cell — no code yet. Answer these questions for each model you plan to build:

- What exact thing am I trying to predict?
- What is my target variable (the column being predicted)?
- What are my input features (the columns I am using to make the prediction)?
- Is this regression (predicting a number) or classification (predicting a category)?
- How will I measure whether the model is good? What metric and why?

Do this for at minimum: (1) a sales revenue forecast and (2) a customer churn predictor.

**Think about:** Interviewers ask these exact questions. Answering them in writing before coding forces you to actually understand what you are building.

---

### Task 4.2 — Sales forecasting model

Your goal is to predict weekly revenue.

Steps to work through:
- Aggregate your clean transaction data to weekly total revenue — one row per week
- Create lag features: revenue from 1, 2, 3, and 4 weeks ago. Look up `.shift()` in pandas
- Create rolling window features: 4-week rolling average of revenue, 4-week rolling standard deviation. Look up `.rolling()` in pandas
- Add calendar features: month number, quarter number, a binary flag for Q4 (months 10–12)
- Drop rows with NaN values that appear because of the lag and rolling operations
- Split into training and test sets — the last 8 weeks are test, everything before is training. Do NOT use random splitting
- Train at least three models: Linear Regression, Random Forest Regressor, and one more of your choice
- Evaluate each model on the test set using MAE (Mean Absolute Error) and RMSE (Root Mean Squared Error)
- Plot actual vs predicted revenue for your best model and save the chart to `screenshots/`

**Think about:** Why is random train/test splitting wrong for time-series data? What would happen to your evaluation results if you split randomly?

---

### Task 4.3 — Customer churn prediction model

Your goal is to predict whether a customer will churn.

First, define churn clearly: a customer is churned if their last purchase was more than 90 days before the dataset's end date. Add a binary column `churned` to your RFM table (1 = churned, 0 = active).

Steps to work through:
- Use the RFM table as your dataset. Features: recency, frequency, monetary, R score, F score, M score
- Target: the `churned` column
- Check the class balance — what percentage of customers are labeled churned? If it is very unequal, look up the `class_weight='balanced'` parameter in scikit-learn classifiers
- Split using `train_test_split`
- Train a Random Forest Classifier
- Evaluate using a classification report (precision, recall, F1-score) and ROC-AUC score
- Plot feature importances and save to `screenshots/`

**Think about:** For this business problem, is it worse to incorrectly flag an active customer as churned (false positive) or to miss a customer who actually churns (false negative)? Which metric — precision or recall — should you optimize for?

---

### Task 4.4 — Write your model conclusions

Write a markdown cell (not code) answering:
- Which forecasting model performed best, and by what margin?
- What does your churn model's ROC-AUC score actually mean in plain English?
- What would you do differently or try next if you had more time?

This cell is as important as the code itself. These are exactly the questions you will be asked in interviews.

---

### Task 4.5 — Git commit: machine learning complete

Stage the ML notebook and any new screenshots.

Suggested commit message: `Phase 4 complete — sales forecasting and churn prediction models`

Push to GitHub.

---

## PHASE 5 — Power BI Dashboard

---

### Task 5.1 — Verify your data files

Before opening Power BI, open each of the four CSV files in Excel to confirm they look correct:
- `data/clean/online_retail_clean.csv` — main transaction table
- `data/clean/orders.csv` — one row per order
- `data/clean/customers.csv` — one row per customer
- `data/clean/rfm.csv` — RFM scores and segments

Check that column names are clean (no special characters), dates look right, and there are no obvious errors.

---

### Task 5.2 — Import data and define relationships in Power BI

Open Power BI Desktop. Import all four CSV files using Get Data → Text/CSV.

Go to the Model view. Draw relationships between tables:
- Transaction table → orders table on Invoice (Many-to-One)
- Transaction table → customers table on Customer ID (Many-to-One)
- Customers table → RFM table on Customer ID (One-to-One)

**Think about:** Why do relationships matter? If you add a slicer filtering by Country, does it automatically filter charts on other tables? Test this — does it work as expected?

---

### Task 5.3 — Write your DAX measures

Create a dedicated Measures table in Power BI (look up how to create a blank table just for measures — it keeps things organized). Write DAX for at minimum:

- Total Revenue
- Total Orders (distinct count of invoices)
- Average Order Value
- Total Customers (distinct count of Customer IDs)
- Repeat Customer Rate % (customers with more than one order, divided by total customers)
- Month-over-Month Revenue Change % (look up the `DATEADD` function in DAX)

Test each measure by adding it to a card visual and checking the number looks reasonable.

---

### Task 5.4 — Build Page 1: Executive Summary

This page is for a manager who has 30 seconds. Answer: "How is the business performing overall?"

Build:
- 4 KPI cards showing your key measures
- A line chart of monthly revenue
- A bar chart of top 5 countries by revenue
- A country slicer

Keep it to 6 visuals maximum. Resist the temptation to add more.

---

### Task 5.5 — Build Page 2: Sales Analysis

This page answers: "When do we sell the most?"

Build:
- Bar chart: revenue by month
- Bar chart: revenue by day of week
- Matrix visual: revenue by day of week (rows) × hour of day (columns), with conditional formatting so high-revenue cells appear darker
- Slicers for year and quarter

---

### Task 5.6 — Build Page 3: Customer Analysis

This page answers: "Who are our customers and how loyal are they?"

Build:
- Donut or pie chart: percentage of customers in each RFM segment
- Scatter chart: Frequency on X-axis, Monetary on Y-axis, points colored by segment
- Table: top 20 customers with total spend, number of orders, and last purchase date
- KPI card: Repeat Customer Rate %

---

### Task 5.7 — Build Page 4: Product Analysis

This page answers: "What should we stock more of, and what should we consider dropping?"

Build:
- Bar chart: top 10 products by revenue
- Bar chart: top 10 products by units sold
- Treemap: each product is a box, sized by revenue
- Table: products with the highest return rates

---

### Task 5.8 — Build Page 5: Geography

This page answers: "Where in the world are our customers?"

Build:
- Map visual: each country shown with bubble size or fill color representing revenue
- Bar chart: top 10 countries by order count
- Table: country, revenue, orders, and average order value

---

### Task 5.9 — Polish and export

- Apply a consistent 2–3 color theme across all pages
- Add a title to every page
- Add navigation buttons so users can click between pages
- Add your name and the project date in a footer on each page
- Export to PDF: File → Export → Export to PDF
- Save the PDF to `dashboards/powerbi/retail_dashboard.pdf`

---

### Task 5.10 — Git commit: Power BI phase

Stage the exported PDF in `dashboards/powerbi/` and any new screenshots of your dashboards.

Suggested commit message: `Phase 5 complete — Power BI dashboard (5 pages, PDF exported)`

Push to GitHub.

**Note:** The `.pbix` Power BI file is often too large for GitHub. The PDF export is what you commit. If you want to share the interactive version, Power BI Service has a free publish option — look it up.

---

## PHASE 6 — Tableau Executive Story

---

### Task 6.1 — Connect your data in Tableau Public

Open Tableau Public (free at public.tableau.com). Connect to `online_retail_clean.csv` and also to `rfm.csv`. Create a relationship between them on the Customer ID field.

---

### Task 6.2 — Plan your story before building anything

Tableau Stories tell a narrative — they are different from dashboards. Write out your 4 story points on paper or in `notes.txt` before touching Tableau:

- Story Point 1: The state of the business — top-level headline numbers
- Story Point 2: When and where revenue comes from — time patterns and geography
- Story Point 3: Who the most valuable customers are — RFM insights
- Story Point 4: What the business should do next — three specific, data-backed recommendations

Each story point needs a one-sentence caption: what should the audience take away from this slide?

---

### Task 6.3 — Build each story point

For each story point, build a worksheet or simple dashboard, then add it to the Story canvas in Tableau.

Keep it executive-level: large numbers, clear titles, no clutter. This is a presentation, not a data exploration tool.

---

### Task 6.4 — Publish and get the URL

Publish your story to Tableau Public. Copy the public URL. You will put it in your README in Phase 7.

Take a screenshot of your Tableau story and save it to `screenshots/tableau_story.png`.

---

### Task 6.5 — Git commit: Tableau complete

Stage the Tableau screenshot.

Suggested commit message: `Phase 6 complete — Tableau executive story published`

Push to GitHub.

---

## PHASE 7 — GitHub Repository & README

---

### Task 7.1 — Write your README.md

Create `README.md` in the root of your project. Write it as if a recruiter who has never seen your project is reading it cold. It should include these sections in order:

**Project Title and one-line description** — at the very top

**Business Problem** — one paragraph describing what a retail company wants to know and why this kind of analysis matters

**Dataset** — describe the file: two sheets, total rows, date range, 8 columns with a brief description of each, where the dataset comes from (look up the UCI Machine Learning Repository — this dataset is publicly available there)

**Business Questions Answered** — list all 30 SQL queries by their question in plain English, not their code. For example: "Which 10 customers generated the most revenue?" not `SELECT Customer_ID FROM...`

**Key Findings** — 5 to 7 bullet points of the most interesting things you discovered. Use real numbers. For example: "The top 20% of customers generated X% of total revenue" not "some customers are more valuable than others."

**Tech Stack** — a table listing every tool (Excel, MySQL, Python, pandas, scikit-learn, Power BI, Tableau, Git, GitHub) and what you used each one for

**Project Structure** — show your folder layout

**How to Run** — step-by-step instructions so someone else could run your Python notebooks on their machine (environment setup, which notebook to run in which order)

**Dashboard Links** — link to the Power BI PDF and the Tableau Public URL

**Future Improvements** — 3 concrete things you would do if you had more time (not vague — be specific)

---

### Task 7.2 — Add screenshots to README

Embed your best screenshots directly into the README using markdown image syntax. Include at minimum:
- One Python EDA chart
- One Power BI page screenshot
- One Tableau story screenshot

A README with images is far more compelling to a recruiter than one with only text.

---

### Task 7.3 — Final repository review

Before the final commit, go through this checklist:

- Can you clone your own repo into a new folder and run the notebooks from scratch?
- Does the README explain everything someone needs without asking you a question?
- Are all `.sql` files named clearly?
- Are there comments in your SQL files explaining what each query answers?
- Are there markdown cells in your notebooks explaining what you did and why?
- Is the `data/` folder correctly absent from GitHub (only in `.gitignore`)?
- Are screenshots embedded in the README?

Fix anything that is missing, then commit.

Suggested commit message: `Phase 7 complete — polished README, screenshots, final review`

Push to GitHub.

---

## PHASE 8 — LinkedIn Post

---

### Task 8.1 — Write your LinkedIn post

Structure it exactly like this (aim for 150–250 words total):

1. **Opening line** — one sentence that makes someone stop scrolling. Base it on a specific finding with a number, not on "I completed a project." Bad: "I just finished a data analytics project!" Good: "I analyzed 1 million retail transactions and found that 20% of customers generate 80% of revenue — here's what that means."

2. **What you built** — 2–3 sentences describing the full pipeline: where the data came from, what tools you used, what the output was

3. **Three key findings** — use numbers. Readers skim. Make each bullet punchy.

4. **What you learned** — one technical thing and one business insight

5. **A question for your network** — invite comments. It increases reach. Ask something genuine.

6. **Link to your GitHub repo** — at the very end

Attach 2–3 screenshots as images in the post. LinkedIn posts with images get significantly more reach than text-only posts.

---

### Task 8.2 — Git commit: project complete

After posting on LinkedIn, add the LinkedIn post URL to your README (in the Portfolio section or at the bottom).

Final commit message: `Project complete — LinkedIn post published, README updated with links`

Push to GitHub.

---

## Git Workflow Summary

Here is every commit in the project in order. Use this as a reference:

```
Commit 0  →  Initial commit — project structure and .gitignore
Commit 1  →  Add project structure, requirements, and initial notes
Commit 2  →  Phase 1 complete — data loading notebook and MySQL setup
Commit 3  →  Phase 2 complete — 30 SQL business queries
Commit 4  →  Phase 3 complete — EDA, cleaning, feature engineering, visualizations
Commit 5  →  Phase 4 complete — sales forecasting and churn prediction models
Commit 6  →  Phase 5 complete — Power BI dashboard (5 pages, PDF exported)
Commit 7  →  Phase 6 complete — Tableau executive story published
Commit 8  →  Phase 7 complete — polished README, screenshots, final review
Commit 9  →  Project complete — LinkedIn post published, README updated with links
```

After every push, visit your GitHub repository in a browser and verify the files are there. This catches mistakes early.

---

## Complete Task Checklist

```
PHASE 0 — Git Setup
  □ Task 0.1   Git installed, name and email configured
  □ Task 0.2   GitHub account created, repository created
  □ Task 0.3   Git initialized locally, .gitignore created
  □ Task 0.4   First commit pushed, visible on GitHub

PHASE 1 — Setup & Data Loading
  □ Task 1.1   Folder structure created, Excel file in data/raw/
  □ Task 1.2   Excel exploration done, notes written in notes.txt
  □ Task 1.3   Python environment created, requirements.txt generated
  □ Task 1.4   Git commit: project skeleton pushed
  □ Task 1.5   Both sheets loaded and combined in Python notebook
  □ Task 1.6   Data loaded into MySQL, row count verified
  □ Task 1.7   Git commit: Phase 1 pushed

PHASE 2 — SQL Queries
  □ Task 2.1   Filtering rules documented in 00_data_notes.sql
  □ Task 2.2   Monthly revenue query
  □ Task 2.3   Top 10 customers query
  □ Task 2.4   Revenue by country query
  □ Task 2.5   Best and worst products queries
  □ Task 2.6   Return rate query
  □ Task 2.7   Average order value query
  □ Task 2.8   Repeat customer rate query
  □ Task 2.9   Customer lifetime value query
  □ Task 2.10  Revenue by day of week query
  □ Task 2.11  Revenue by hour query
  □ Task 2.12  UK vs international split query
  □ Task 2.13  Registered vs guest query
  □ Task 2.14  New vs returning customers monthly query
  □ Task 2.15  High value orders query
  □ Task 2.16  Products never returned query
  □ Task 2.17  Basket size query
  □ Task 2.18  Revenue by price band query
  □ Task 2.19  Cancellation rate query
  □ Task 2.20  Top countries excluding UK query
  □ Task 2.21  Quarter-over-quarter revenue query
  □ Task 2.22  Revenue per customer by country query
  □ Task 2.23  Frequently co-purchased products query
  □ Task 2.24  Month-over-month growth query
  □ Task 2.25  Average days between orders query
  □ Tasks 2.26–2.30  Five self-defined queries
  □ Task 2.31  Git commit: Phase 2 pushed

PHASE 3 — Python
  □ Task 3.1   EDA notebook complete, summary markdown written
  □ Task 3.2   Cleaning notebook complete, clean CSV saved
  □ Task 3.3   Feature engineering complete, 4 CSVs saved
  □ Task 3.4   8 charts produced and saved to screenshots/
  □ Task 3.5   Git commit: Phase 3 pushed

PHASE 4 — Machine Learning
  □ Task 4.1   Problem framing written in markdown before any code
  □ Task 4.2   Sales forecasting: 3 models trained and compared
  □ Task 4.3   Churn model trained, evaluated, feature importance plotted
  □ Task 4.4   Model conclusions written in plain English
  □ Task 4.5   Git commit: Phase 4 pushed

PHASE 5 — Power BI
  □ Task 5.1   4 CSV files verified
  □ Task 5.2   Data imported into Power BI, relationships defined
  □ Task 5.3   DAX measures written and tested
  □ Task 5.4   Page 1: Executive Summary built
  □ Task 5.5   Page 2: Sales Analysis built
  □ Task 5.6   Page 3: Customer Analysis built
  □ Task 5.7   Page 4: Product Analysis built
  □ Task 5.8   Page 5: Geography built
  □ Task 5.9   Dashboard polished and exported to PDF
  □ Task 5.10  Git commit: Phase 5 pushed

PHASE 6 — Tableau
  □ Task 6.1   Tableau connected to data
  □ Task 6.2   Story outline written before building
  □ Task 6.3   4 story points built
  □ Task 6.4   Published to Tableau Public, URL copied
  □ Task 6.5   Git commit: Phase 6 pushed

PHASE 7 — GitHub & README
  □ Task 7.1   README.md written with all sections
  □ Task 7.2   Screenshots embedded in README
  □ Task 7.3   Final repository review passed, commit pushed

PHASE 8 — LinkedIn
  □ Task 8.1   LinkedIn post written and published
  □ Task 8.2   Final commit: LinkedIn URL added to README, pushed
```
