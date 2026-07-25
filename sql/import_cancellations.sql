USE online_retail_analysis;

CREATE TABLE IF NOT EXISTS cancelled_transactions (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description VARCHAR(255),
    quantity INT,
    invoice_date DATETIME,
    unit_price DECIMAL(10,2),
    customer_id INT,
    country VARCHAR(100),
    is_cancelled BOOLEAN,
    invoice_year INT,
    invoice_month INT,
    month_name VARCHAR(20),
    invoice_year_month VARCHAR(7),
    cancelled_quantity INT,
    cancellation_value DECIMAL(12,2)
);

TRUNCATE TABLE cancelled_transactions;

LOAD DATA LOCAL INFILE
'C:/Users/Akshat Arya/Desktop/online-retail-performance/data/cancelled_transactions.csv'
INTO TABLE cancelled_transactions
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
    @cancelled_quantity,
    @cancellation_value
)
SET
    invoice_no = @invoice_no,
    stock_code = @stock_code,
    description = @description,
    quantity = CAST(@quantity AS SIGNED),
    invoice_date = STR_TO_DATE(@invoice_date, '%Y-%m-%d %H:%i:%s'),
    unit_price = CAST(@unit_price AS DECIMAL(10,2)),
    customer_id = CAST(@customer_id AS SIGNED),
    country = @country,
    is_cancelled = CAST(@is_cancelled AS UNSIGNED),
    invoice_year = CAST(@invoice_year AS UNSIGNED),
    invoice_month = CAST(@invoice_month AS UNSIGNED),
    month_name = @month_name,
    invoice_year_month = @invoice_year_month,
    cancelled_quantity = CAST(@cancelled_quantity AS UNSIGNED),
    cancellation_value = CAST(
        TRIM(TRAILING '\r' FROM @cancellation_value)
        AS DECIMAL(12,2)
    );

SELECT
    COUNT(*) AS cancellation_rows,
    ROUND(SUM(cancellation_value), 2) AS total_cancellation_value
FROM cancelled_transactions;