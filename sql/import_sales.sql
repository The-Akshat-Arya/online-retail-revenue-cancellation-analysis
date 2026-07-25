USE online_retail_analysis;
TRUNCATE TABLE sales_transactions;
LOAD DATA LOCAL INFILE
'C:/Users/Akshat Arya/Desktop/online-retail-performance/data/sales_transactions.csv'
INTO TABLE sales_transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @invoice_no,
    @stock_code,
    @description,
    @quantity,
    @invoice_date,
    @unit_price,
    @customer_id,
    @country,
    @is_cancelled,
    @invoice_year,
    @invoice_month,
    @month_name,
    @invoice_year_month,
    @revenue
)
SET
    invoice_no = @invoice_no,
    stock_code = @stock_code,
    description = @description,
    quantity = CAST(@quantity AS SIGNED),
    invoice_date = STR_TO_DATE(@invoice_date, '%Y-%m-%d %H:%i:%s'),
    unit_price = CAST(@unit_price AS DECIMAL(10,2)),
    customer_id = NULLIF(@customer_id, ''),
    country = @country,
    is_cancelled =
        CASE
            WHEN LOWER(@is_cancelled) = 'true' THEN 1
            ELSE 0
        END,
    invoice_year = CAST(@invoice_year AS UNSIGNED),
    invoice_month = CAST(@invoice_month AS UNSIGNED),
    month_name = @month_name,
    invoice_year_month = @invoice_year_month,
    revenue = CAST(
        TRIM(TRAILING '\r' FROM @revenue)
        AS DECIMAL(12,2)
    );