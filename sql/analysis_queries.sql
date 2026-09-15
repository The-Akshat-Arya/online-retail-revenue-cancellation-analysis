USE online_retail_analysis;

-- overall kpis
SELECT
    (SELECT COUNT(DISTINCT invoice_no) FROM sales_transactions) AS completed_orders,
    (SELECT COUNT(DISTINCT invoice_no) FROM cancelled_transactions) AS cancelled_orders,
    (SELECT COUNT(DISTINCT customer_id) FROM sales_transactions WHERE customer_id <> -1) AS known_customers,
    (SELECT COUNT(DISTINCT stock_code) FROM sales_transactions) AS products_sold,
    (SELECT ROUND(SUM(revenue), 2) FROM sales_transactions) AS gross_sales,
    (SELECT ROUND(SUM(cancellation_value), 2) FROM cancelled_transactions) AS cancellation_value,
    ROUND((SELECT SUM(revenue) FROM sales_transactions) - (SELECT SUM(cancellation_value) FROM cancelled_transactions), 2) AS adjusted_sales,
    ROUND((SELECT COUNT(DISTINCT invoice_no) FROM cancelled_transactions) /
        NULLIF((SELECT COUNT(DISTINCT invoice_no) FROM sales_transactions) + (SELECT COUNT(DISTINCT invoice_no) FROM cancelled_transactions), 0) * 100, 2) AS order_cancellation_rate_pct,
    ROUND((SELECT SUM(cancellation_value) FROM cancelled_transactions) /
        NULLIF((SELECT SUM(revenue) FROM sales_transactions), 0) * 100, 2) AS cancellation_value_pct;


-- monthly sales vs cancellations
SELECT
    sales.invoice_year_month,
    sales.completed_orders,
    sales.gross_sales,
    COALESCE(cancel.cancelled_orders, 0) AS cancelled_orders,
    COALESCE(cancel.cancellation_value, 0) AS cancellation_value,
    ROUND(sales.gross_sales - COALESCE(cancel.cancellation_value, 0), 2) AS adjusted_sales,
    CASE
        WHEN sales.invoice_year_month = '2011-12' THEN 'Partial month through December 9'
        ELSE 'Full month'
    END AS period_status
FROM (
    SELECT invoice_year_month, COUNT(DISTINCT invoice_no) AS completed_orders, ROUND(SUM(revenue), 2) AS gross_sales
    FROM sales_transactions
    GROUP BY invoice_year_month
) AS sales
LEFT JOIN (
    SELECT invoice_year_month, COUNT(DISTINCT invoice_no) AS cancelled_orders, ROUND(SUM(cancellation_value), 2) AS cancellation_value
    FROM cancelled_transactions
    GROUP BY invoice_year_month
) AS cancel
    ON sales.invoice_year_month = cancel.invoice_year_month
ORDER BY sales.invoice_year_month;


-- month over month growth, dec 2011 excluded (partial month)
WITH monthly_sales AS (
    SELECT invoice_year_month, ROUND(SUM(revenue), 2) AS gross_sales
    FROM sales_transactions
    WHERE invoice_year_month < '2011-12'
    GROUP BY invoice_year_month
)
SELECT
    invoice_year_month,
    gross_sales,
    ROUND((gross_sales - LAG(gross_sales) OVER (ORDER BY invoice_year_month)) /
        NULLIF(LAG(gross_sales) OVER (ORDER BY invoice_year_month), 0) * 100, 2) AS month_over_month_growth_pct
FROM monthly_sales
ORDER BY invoice_year_month;


-- country performance
SELECT
    sales.country,
    sales.completed_orders,
    sales.known_customers,
    sales.gross_sales,
    COALESCE(cancel.cancelled_orders, 0) AS cancelled_orders,
    COALESCE(cancel.cancellation_value, 0) AS cancellation_value,
    ROUND(sales.gross_sales - COALESCE(cancel.cancellation_value, 0), 2) AS adjusted_sales,
    ROUND(sales.gross_sales / NULLIF(sales.completed_orders, 0), 2) AS average_order_value
FROM (
    SELECT
        country,
        COUNT(DISTINCT invoice_no) AS completed_orders,
        COUNT(DISTINCT CASE WHEN customer_id <> -1 THEN customer_id END) AS known_customers,
        ROUND(SUM(revenue), 2) AS gross_sales
    FROM sales_transactions
    GROUP BY country
) AS sales
LEFT JOIN (
    SELECT country, COUNT(DISTINCT invoice_no) AS cancelled_orders, ROUND(SUM(cancellation_value), 2) AS cancellation_value
    FROM cancelled_transactions
    GROUP BY country
) AS cancel
    ON sales.country = cancel.country
ORDER BY adjusted_sales DESC;


-- top products (excludes service/fee stock codes)
SELECT
    stock_code,
    MAX(description) AS product_description,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT invoice_no) AS orders,
    ROUND(SUM(revenue), 2) AS gross_sales
FROM sales_transactions
WHERE stock_code REGEXP '^[0-9]+[A-Za-z]*$'
GROUP BY stock_code
ORDER BY gross_sales DESC
LIMIT 20;


-- products with the most cancellations
SELECT
    stock_code,
    MAX(description) AS product_description,
    COUNT(DISTINCT invoice_no) AS cancelled_orders,
    SUM(cancelled_quantity) AS cancelled_units,
    ROUND(SUM(cancellation_value), 2) AS cancellation_value
FROM cancelled_transactions
WHERE stock_code REGEXP '^[0-9]+[A-Za-z]*$'
GROUP BY stock_code
ORDER BY cancellation_value DESC
LIMIT 20;


-- customer value segments, unknown customers (-1) excluded
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS completed_orders,
        SUM(quantity) AS units_purchased,
        ROUND(SUM(revenue), 2) AS total_revenue,
        ROUND(SUM(revenue) / NULLIF(COUNT(DISTINCT invoice_no), 0), 2) AS average_order_value,
        MIN(DATE(invoice_date)) AS first_purchase_date,
        MAX(DATE(invoice_date)) AS last_purchase_date
    FROM sales_transactions
    WHERE customer_id <> -1
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_summary.*,
        NTILE(4) OVER (ORDER BY total_revenue) AS revenue_quartile
    FROM customer_summary
)
SELECT
    customer_id,
    completed_orders,
    units_purchased,
    total_revenue,
    average_order_value,
    first_purchase_date,
    last_purchase_date,
    CASE
        WHEN revenue_quartile = 4 THEN 'High Value'
        WHEN revenue_quartile = 3 THEN 'Upper Mid Value'
        WHEN revenue_quartile = 2 THEN 'Lower Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM ranked_customers
ORDER BY total_revenue DESC
LIMIT 100;


-- known vs anonymous customer revenue
SELECT
    CASE WHEN customer_id = -1 THEN 'Anonymous Customer' ELSE 'Known Customer' END AS customer_type,
    COUNT(*) AS transaction_lines,
    COUNT(DISTINCT invoice_no) AS completed_orders,
    ROUND(SUM(revenue), 2) AS gross_sales,
    ROUND(SUM(revenue) / (SELECT SUM(revenue) FROM sales_transactions) * 100, 2) AS revenue_share_pct
FROM sales_transactions
GROUP BY CASE WHEN customer_id = -1 THEN 'Anonymous Customer' ELSE 'Known Customer' END
ORDER BY gross_sales DESC;
