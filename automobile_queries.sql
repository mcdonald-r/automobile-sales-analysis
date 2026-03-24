-- ============================================================
-- DATA EXPLORATION
-- ============================================================

-- All column names in the dataset
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'auto_sales_data';

-- Displays the first 10 rows of the dataset
SELECT *
FROM auto_sales_data
LIMIT 10;

-- Returns all the different status messages
SELECT DISTINCT "STATUS"
FROM auto_sales_data;

-- Returns the count of sales by the size of the order
SELECT
    "DEALSIZE",
    COUNT("DEALSIZE") AS deal_count
FROM auto_sales_data
GROUP BY "DEALSIZE";

-- Returns the date range the orders are pulled from
SELECT
    MIN("ORDERDATE") AS first_order_date,
    MAX("ORDERDATE") AS last_order_date
FROM auto_sales_data;


-- ============================================================
-- DATA QUALITY CHECK
-- ============================================================

-- Returns all rows that contain a null value in any of its columns
SELECT *
FROM auto_sales_data
WHERE "PRICEEACH" IS NULL
    OR "ORDERLINENUMBER" IS NULL
    OR "MSRP" IS NULL
    OR "SALES" IS NULL
    OR "QUANTITYORDERED" IS NULL
    OR "DAYS_SINCE_LASTORDER" IS NULL
    OR "ORDERNUMBER" IS NULL
    OR "ADDRESSLINE1" IS NULL
    OR "CITY" IS NULL
    OR "POSTALCODE" IS NULL
    OR "COUNTRY" IS NULL
    OR "CONTACTLASTNAME" IS NULL
    OR "CONTACTFIRSTNAME" IS NULL
    OR "DEALSIZE" IS NULL
    OR "ORDERDATE" IS NULL
    OR "STATUS" IS NULL
    OR "PRODUCTLINE" IS NULL
    OR "PRODUCTCODE" IS NULL
    OR "CUSTOMERNAME" IS NULL
    OR "PHONE" IS NULL;

-- Returns orders that contain missing or duplicate line numbers
SELECT
    "ORDERNUMBER",
    COUNT(*) AS total_rows,
    MAX("ORDERLINENUMBER") AS max_line_number
FROM auto_sales_data
GROUP BY "ORDERNUMBER"
HAVING COUNT("ORDERLINENUMBER") <> COUNT(DISTINCT "ORDERLINENUMBER");

-- Returns orders where quantity ordered multiplied by the price of each is off from the sales number by more than $0.01
SELECT *
FROM auto_sales_data
WHERE ABS(("QUANTITYORDERED" * "PRICEEACH") - "SALES") > 0.01;


-- ============================================================
-- DATA ANALYSIS
-- ============================================================

-- Breaks down the order count, total sales, and percent of total sales by status message
SELECT
    "STATUS",
    COUNT("ORDERNUMBER") AS order_count,
    SUM("SALES") AS total_sales,
    ROUND((SUM("SALES") / SUM(SUM("SALES")) OVER ())::NUMERIC * 100, 2) AS percent_of_total_sales
FROM auto_sales_data
GROUP BY "STATUS"
ORDER BY percent_of_total_sales DESC;

-- Breaks down the order count, total sales, and percent of total sales by completed orders, at-risk orders, and
-- orders that are still being processed
SELECT
    CASE
        WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold') THEN 'At-Risk'
        WHEN "STATUS" IN ('Shipped', 'Resolved') THEN 'Completed'
        WHEN "STATUS" = 'In Process' THEN 'Processing'
        ELSE 'Other'
    END AS status_category,
    COUNT("ORDERNUMBER") AS order_count,
    SUM("SALES") AS total_sales,
    ROUND((SUM("SALES") / SUM(SUM("SALES")) OVER ())::NUMERIC * 100, 2) AS percent_of_total_sales
FROM auto_sales_data
GROUP BY status_category
ORDER BY percent_of_total_sales DESC;

-- Breaks down by country the distribution of where these problematic orders are happening geographically
SELECT
    "COUNTRY",
    COUNT("ORDERNUMBER") AS order_count,
    SUM("SALES") AS total_sales_at_risk,
    ROUND((SUM("SALES") / SUM(SUM("SALES")) OVER ())::NUMERIC * 100, 2) AS percent_of_total_sales_at_risk
FROM auto_sales_data
WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
GROUP BY "COUNTRY"
ORDER BY percent_of_total_sales_at_risk DESC;

-- Compares a country's at-risk sales to their completed sales total and calculates what percent of their sales
-- are at risk
SELECT
    "COUNTRY",
    SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold') THEN "SALES" ELSE 0 END) AS at_risk_sales,
    SUM(CASE WHEN "STATUS" IN ('Shipped', 'Resolved') THEN "SALES" ELSE 0 END) AS completed_sales,
    ROUND((SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
        THEN "SALES" ELSE 0 END) / SUM("SALES"))::NUMERIC * 100, 2) AS at_risk_percentage
FROM auto_sales_data
GROUP BY "COUNTRY"
HAVING ROUND((SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
    THEN "SALES" ELSE 0 END) / SUM("SALES"))::NUMERIC * 100, 2) > 0
ORDER BY at_risk_percentage DESC;

-- Customers who have at-risk orders displaying total sales at risk and how many orders are at risk
SELECT
    "CUSTOMERNAME",
    SUM("SALES") AS total_sales,
    COUNT("ORDERNUMBER") AS total_at_risk_orders
FROM auto_sales_data
WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
GROUP BY "CUSTOMERNAME"
ORDER BY total_sales DESC;

-- Compares a customer's at-risk sales to their completed sales total and calculates what percent of their sales
-- are at risk
SELECT
    "CUSTOMERNAME",
    SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold') THEN "SALES" ELSE 0 END) AS at_risk_sales,
    SUM(CASE WHEN "STATUS" IN ('Shipped', 'Resolved') THEN "SALES" ELSE 0 END) AS completed_sales,
    ROUND((SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
        THEN "SALES" ELSE 0 END) / SUM("SALES"))::NUMERIC * 100, 2) AS at_risk_percentage
FROM auto_sales_data
GROUP BY "CUSTOMERNAME"
HAVING ROUND((SUM(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
    THEN "SALES" ELSE 0 END) / SUM("SALES"))::NUMERIC * 100, 2) > 0
ORDER BY at_risk_percentage DESC;

-- Breaks down each customer's at-risk orders by category to specify what types of problems are happening repeatedly
-- with their orders
SELECT
    "CUSTOMERNAME",
    COUNT("ORDERNUMBER") AS total_at_risk_orders,
    SUM(CASE WHEN "STATUS" = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN "STATUS" = 'Disputed' THEN 1 ELSE 0 END) AS disputed,
    SUM(CASE WHEN "STATUS" = 'On Hold' THEN 1 ELSE 0 END) AS on_hold,
    SUM("SALES") AS total_at_risk_sales
FROM auto_sales_data
WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
GROUP BY "CUSTOMERNAME"
HAVING COUNT("ORDERNUMBER") > 1
ORDER BY total_at_risk_orders DESC;

-- Shows a count of each product line's at-risk deals, broken down by small, medium, and large
SELECT
    "PRODUCTLINE",
    SUM(CASE WHEN "DEALSIZE" = 'Small' THEN 1 ELSE 0 END) AS small_deals,
    SUM(CASE WHEN "DEALSIZE" = 'Medium' THEN 1 ELSE 0 END) AS medium_deals,
    SUM(CASE WHEN "DEALSIZE" = 'Large' THEN 1 ELSE 0 END) AS large_deals,
    COUNT("ORDERNUMBER") AS total_at_risk_orders,
    ROUND(SUM("SALES")::NUMERIC, 2) AS total_at_risk_revenue
FROM auto_sales_data
WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
GROUP BY "PRODUCTLINE"
ORDER BY total_at_risk_orders DESC;

-- Displays each product line's average at-risk order, average completed order, and the difference between those
-- two numbers
SELECT
    "PRODUCTLINE",
    ROUND(AVG(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold') THEN "SALES" END)::NUMERIC, 2) AS avg_at_risk_order,
    ROUND(AVG(CASE WHEN "STATUS" IN ('Shipped', 'Resolved') THEN "SALES" END)::NUMERIC, 2) AS avg_completed_order,
    ROUND((AVG(CASE WHEN "STATUS" IN ('Shipped', 'Resolved') THEN "SALES" END)
        - AVG(CASE WHEN "STATUS" IN ('Cancelled', 'Disputed', 'On Hold') THEN "SALES" END))::NUMERIC, 2) AS avg_order_difference
FROM auto_sales_data
GROUP BY "PRODUCTLINE"
ORDER BY avg_at_risk_order DESC;

-- Expresses at risk orders and total at risks sales, by month
WITH monthly_at_risk AS (
    SELECT
        EXTRACT(MONTH FROM TO_DATE("ORDERDATE", 'DD/MM/YYYY')) AS month_number,
        TO_CHAR(TO_DATE("ORDERDATE", 'DD/MM/YYYY'), 'Month') AS month_name,
        COUNT("ORDERNUMBER") AS at_risk_order_count,
        SUM("SALES") AS total_at_risk_sales,
        ROUND(AVG("SALES")::NUMERIC, 2) AS avg_order_value
    FROM auto_sales_data
    WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
    GROUP BY month_number, month_name
)
SELECT
    month_name,
    at_risk_order_count,
    total_at_risk_sales,
    avg_order_value
FROM monthly_at_risk
ORDER BY month_number;

-- Expresses at risk orders and total at risks sales, by quarter
WITH quarterly_at_risk AS (
    SELECT
        EXTRACT(QUARTER FROM TO_DATE("ORDERDATE", 'DD/MM/YYYY')) AS quarter_number,
        TO_CHAR(TO_DATE("ORDERDATE", 'DD/MM/YYYY'), 'YYYY-Q') AS quarter_label,
        COUNT("ORDERNUMBER") AS at_risk_order_count,
        SUM("SALES") AS total_at_risk_sales,
        ROUND(AVG("SALES")::NUMERIC, 2) AS avg_order_value
    FROM auto_sales_data
    WHERE "STATUS" IN ('Cancelled', 'Disputed', 'On Hold')
    GROUP BY quarter_number, quarter_label
)
SELECT
    quarter_label,
    at_risk_order_count,
    total_at_risk_sales,
    avg_order_value
FROM quarterly_at_risk
ORDER BY quarter_label;