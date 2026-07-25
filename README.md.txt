# Online Retail Revenue & Cancellation Analysis

## Project Overview

This project analyses transaction data from a UK-based online retailer to understand sales performance, customer activity, international markets, product performance and the financial impact of cancellations.

The complete workflow includes:

- Python data auditing and cleaning
- MySQL database creation and analysis
- Power BI data modelling
- DAX measures
- Interactive dashboard development
- Business insight generation

The original dataset contained **541,909 transaction rows** covering the period from **1 December 2010 to 9 December 2011**.

---

## Dashboard Preview

![Online Retail Dashboard](dashboard/dashboard-preview.png)

---

## Business Questions

The project was designed to answer the following questions:

- What was the total gross sales revenue?
- How much revenue was affected by cancellations?
- How many completed and cancelled orders were recorded?
- What was the average order value?
- How did monthly sales and cancellations change over time?
- Which international markets generated the most revenue?
- Which products generated the highest sales?
- Which products produced the greatest cancellation impact?
- How much revenue came from known and anonymous customers?

---

## Key Performance Indicators

| KPI | Result |
|---|---:|
| Gross Sales | £10,631,048.74 |
| Cancellation Value | £893,979.73 |
| Adjusted Sales | £9,737,069.01 |
| Completed Orders | 19,959 |
| Cancelled Orders | 3,836 |
| Order Cancellation Rate | 16.12% |
| Average Order Value | £532.64 |
| Cleaned Sales Rows | 524,877 |
| Cancellation Rows | 9,251 |

`Adjusted Sales` is used as an analytical indicator calculated by subtracting cancellation value from gross sales.

---

## Dataset

The project uses the **Online Retail** dataset from the UCI Machine Learning Repository.

The dataset contains the following columns:

| Column | Description |
|---|---|
| InvoiceNo | Unique invoice number |
| StockCode | Product code |
| Description | Product description |
| Quantity | Number of units purchased or cancelled |
| InvoiceDate | Transaction date and time |
| UnitPrice | Price per unit in pounds |
| CustomerID | Unique customer identifier |
| Country | Customer country |

December 2011 contains data only through **9 December** and is therefore treated as a partial month.

---

## Data Audit

The initial Python audit identified:

| Data-quality issue | Result |
|---|---:|
| Total rows | 541,909 |
| Unique invoices | 25,900 |
| Unique products | 4,070 |
| Known customers | 4,372 |
| Missing descriptions | 1,454 |
| Missing customer IDs | 135,080 |
| Exact duplicate rows | 5,268 |
| Cancelled transaction rows | 9,288 |
| Negative quantity rows | 10,624 |
| Non-positive price rows | 2,517 |

---

## Data Cleaning

The Python cleaning process:

- removed exact duplicate rows;
- standardised invoice numbers, stock codes and country names;
- identified cancelled invoices beginning with `C`;
- excluded cancelled records from completed sales;
- removed non-positive quantities;
- removed zero and negative unit prices;
- removed records with missing product descriptions;
- excluded the bad-debt accounting adjustment;
- replaced missing customer IDs with `-1`;
- created year, month and year-month fields;
- calculated transaction revenue;
- separated completed sales and cancellations;
- converted cancelled quantities to positive values;
- calculated cancellation value.

The cleaning script generated:

```text
sales_transactions.csv
cancelled_transactions.csv
```

The complete sales CSV is approximately 59 MB and is not included in the repository. A 10,000-row sample is provided instead.

---

## SQL Analysis

The cleaned data was imported into MySQL using bulk-loading statements.

The SQL analysis includes:

1. Overall sales and cancellation KPIs
2. Monthly sales and cancellation trends
3. Month-over-month growth
4. Country-level performance
5. Top revenue-generating products
6. Products with the highest cancellation impact
7. Customer segmentation using `NTILE`
8. Known versus anonymous customer analysis

SQL concepts used include:

- aggregate functions;
- joins;
- common table expressions;
- window functions;
- conditional aggregation;
- `CASE` statements;
- views of monthly and customer performance;
- ranking and customer segmentation.

---

## Power BI Data Model

The Power BI model contains two transaction tables:

- `sales_transactions`
- `cancelled_transactions`

Shared dimension tables were created for:

- Date
- Country

The Date and Country dimensions use one-to-many relationships with both transaction tables, allowing the slicers to filter sales and cancellation measures together.

---

## DAX Measures

Important measures include:

```DAX
Gross Sales =
SUM(sales_transactions[Revenue])
```

```DAX
Completed Orders =
DISTINCTCOUNT(sales_transactions[InvoiceNo])
```

```DAX
Cancellation Value =
SUM(cancelled_transactions[CancellationValue])
```

```DAX
Adjusted Sales =
[Gross Sales] - [Cancellation Value]
```

```DAX
Cancellation Rate =
DIVIDE(
    [Cancelled Orders],
    [Completed Orders] + [Cancelled Orders],
    0
)
```

```DAX
Average Order Value =
DIVIDE(
    [Gross Sales],
    [Completed Orders],
    0
)
```

---

## Key Insights

- Gross sales exceeded **£10.63 million**.
- Cancellations represented approximately **£894,000** in transaction value.
- Cancellation value reduced gross sales by approximately **8.4%**.
- The order cancellation rate was **16.12%**.
- Sales increased strongly during the final quarter of 2011, with November recording the highest complete-month sales.
- December 2011 should not be compared directly with full months because the dataset ends on 9 December.
- The Netherlands and EIRE were the strongest international markets outside the United Kingdom.
- A relatively small number of products generated a large share of top-product revenue.
- `PAPER CRAFT, LITTLE BIRDIE` produced the highest product-level cancellation impact.

---

## Business Recommendations

- Investigate products with unusually high cancellation values.
- Review fulfilment, stock availability and product-description accuracy for cancellation-heavy items.
- Prioritise high-performing international markets such as the Netherlands, EIRE, Germany and France.
- Prepare inventory and fulfilment capacity before the high-sales September–November period.
- Encourage customer registration to reduce anonymous transactions and improve customer-level analysis.
- Track both order cancellation rate and cancellation value because they measure different business risks.

---

## Repository Structure

```text
online-retail-revenue-cancellation-analysis/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── dashboard/
│   ├── online-retail-dashboard.pbix
│   └── dashboard-preview.png
│
├── python/
│   ├── audit_data.py
│   ├── clean_data.py
│   └── create_sample.py
│
├── sql/
│   ├── create_database.sql
│   ├── import_sales.sql
│   ├── import_cancellations.sql
│   └── analysis_queries.sql
│
└── data/
    ├── README.md
    ├── sales_transactions_sample.csv
    └── cancelled_transactions.csv
```

---

## Tools Used

- Python
- Pandas
- MySQL
- MySQL Workbench
- Microsoft Power BI
- DAX
- Power Query
- Visual Studio Code
- Git and GitHub

---

## How to Run the Project

### 1. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 2. Download the original dataset

Download the Online Retail Excel dataset from the UCI Machine Learning Repository.

Place it in the required data location using the filename:

```text
Online Retail.xlsx
```

### 3. Audit and clean the data

```bash
python python/audit_data.py
python python/clean_data.py
```

### 4. Create the MySQL database

Run:

```text
sql/create_database.sql
```

Then run the sales and cancellation import scripts.

### 5. Run the SQL analysis

```text
sql/analysis_queries.sql
```

### 6. Open the Power BI dashboard

```text
dashboard/online-retail-dashboard.pbix
```

---

## Author

**Akshat Arya**

Data analytics learner developing skills in Python, SQL, Excel, Power BI and business analysis.