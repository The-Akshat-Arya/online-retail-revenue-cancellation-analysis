-- base schema for the online retail dataset

CREATE DATABASE IF NOT EXISTS online_retail_analysis;

USE online_retail_analysis;

CREATE TABLE IF NOT EXISTS sales_transactions (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description VARCHAR(255),
    quantity INT,
    invoice_date DATETIME,
    unit_price DECIMAL(10,2),
    customer_id INT NULL,
    country VARCHAR(100),
    is_cancelled BOOLEAN,
    invoice_year INT,
    invoice_month INT,
    month_name VARCHAR(20),
    invoice_year_month VARCHAR(7),
    revenue DECIMAL(12,2)
);
