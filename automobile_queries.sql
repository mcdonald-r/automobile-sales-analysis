-- DATA EXPLORATION 

-- All column names in the data set
SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'auto_sales_data';

-- Displays the first 10 rows of the dataset
select * from auto_sales_data limit 10;

-- Returns all the different status messages
select distinct "STATUS" from auto_sales_data;

-- Returns the count of sales by the size of the order
select "DEALSIZE",  count("DEALSIZE") from auto_sales_data
group by "DEALSIZE";

-- Returns the date range the orders are pulled from
select min("ORDERDATE") as first_order_date, max("ORDERDATE") as last_order_date
from auto_sales_data;

-- DATA QUALITY CHECK

-- Returns all rows that contain a null value in any of its columns
select * from auto_sales_data
where "PRICEEACH" is null
	or "ORDERLINENUMBER" is null
	or "MSRP" is null
	or "SALES" is null
	or "QUANTITYORDERED" is null
	or "DAYS_SINCE_LASTORDER" is null
	or "ORDERNUMBER" is null
	or "ADDRESSLINE1" is null
	or "CITY" is null
	or "POSTALCODE" is null
	or "COUNTRY" is null
	or "CONTACTLASTNAME" is null
	or "CONTACTFIRSTNAME" is null
	or "DEALSIZE" is null
	or "ORDERDATE" is null
	or "STATUS" is null
	or "PRODUCTLINE" is null
	or "PRODUCTCODE" is null
	or "CUSTOMERNAME" is null
	or "PHONE" is null;

-- Returns orders that contain missing or duplicate line numbers
select "ORDERNUMBER", count(*) AS total_rows, max("ORDERLINENUMBER") AS max_line_number
from auto_sales_data
group by "ORDERNUMBER"
having count("ORDERLINENUMBER") <> count(distinct "ORDERLINENUMBER");

-- Returns orders where quantity ordered multiplied by he price of each is off from the sales number by more than $0.01
select * from auto_sales_data
where abs(("QUANTITYORDERED" * "PRICEEACH") - "SALES") > 0.01;

-- DATA ANALYSIS

-- Breaks down the order count, total sales, and percent of total sales by status message
select "STATUS", count("ORDERNUMBER") as order_count, sum("SALES") as total_sales, 
	round((sum("SALES") / sum(sum("SALES")) over ())::numeric * 100, 2) as percent_of_total_sales
from auto_sales_data
group by "STATUS" 
order by percent_of_total_sales desc;

-- Breaks down the order count, total sales, and percent of total sales by completed orders, at-risk orders, and 
-- orders that are still being processed
select case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') then 'At-Risk'
	when "STATUS" in ('Shipped', 'Resolved') then 'Completed'
	when "STATUS" = 'In Process' then 'Processing'
	else 'Other'
end as status_category, count("ORDERNUMBER") as order_count, sum("SALES") AS total_sales,
	round((sum("SALES") / sum(sum("SALES")) over ())::numeric * 100, 2) as percent_of_total_sales
from auto_sales_data
group by status_category
order by percent_of_total_sales desc;

-- Breaks down by country the distribution of where these problematic orders are happening geographically
select "COUNTRY", count("ORDERNUMBER") as order_count, sum("SALES") as total_sales_at_risk,
	round((sum("SALES") / sum(sum("SALES")) over ())::numeric * 100, 2) as percent_of_total_sales_at_risk
from auto_sales_data
where "STATUS" in ('Cancelled', 'Disputed', 'On Hold')
group by "COUNTRY"
order by percent_of_total_sales_at_risk desc;

-- Compares a country's at risks sales to their completed sales total and calculates what percent of their sales
-- are at risk
select "COUNTRY", sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) as at_risk_sales, 
sum(case when "STATUS" in ('Shipped', 'Resolved') 
	then "SALES" else 0 end) as completed_sales, 
round((sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) / sum("SALES"))::numeric * 100, 2) as at_risk_percentage 
from auto_sales_data 
group by "COUNTRY"
having round((sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) / sum("SALES"))::numeric * 100, 2) > 0
order by at_risk_percentage desc;

-- Customers who have at risk orders displaying total sales at risk and how many orders are at risk
select "CUSTOMERNAME", sum("SALES") as total_sales, count("ORDERNUMBER") as total_at_risk_orders
from auto_sales_data
where "STATUS" in ('Cancelled', 'Disputed', 'On Hold')
group by "CUSTOMERNAME"
order by total_sales desc;

-- Compares a customer's at risks sales to their completed sales total and calculates what percent of their sales
-- are at risk
select "CUSTOMERNAME", sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) as at_risk_sales, 
sum(case when "STATUS" in ('Shipped', 'Resolved') 
	then "SALES" else 0 end) as completed_sales, 
round((sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) / sum("SALES"))::numeric * 100, 2) as at_risk_percentage 
from auto_sales_data 
group by "CUSTOMERNAME"
having round((sum(case when "STATUS" in ('Cancelled', 'Disputed', 'On Hold') 
	then "SALES" else 0 end) / sum("SALES"))::numeric * 100, 2) > 0
order by at_risk_percentage desc;

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

-- SCRATCH WORK

-- All rows that contain On Hold, Disputed, or Cancelled STATUS messages
select * from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');

-- Sales per year
select SUM("SALES"), EXTRACT(YEAR FROM "ORDERDATE") as "YEAR" from auto_sales_data
where "STATUS" in ('Shipped', 'Resolved')
group by "YEAR";
 