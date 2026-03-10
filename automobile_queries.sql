-- DATA EXPLORATION 

-- All column names in the data set
SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'auto_sales_data';

-- Displays the first 10 rows of the dataset
select * from auto_sales_data limit 10;

-- Returns all the different status messages
select distinct STATUS from auto_sales_data;

-- Returns the count of sales by the size of the order
select "DEALSIZE",  count("DEALSIZE") from auto_sales_data
group by "DEALSIZE";

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

-- DATA ANALYSIS

-- All rows that contain On Hold, Disputed, or Cancelled STATUS messages
select * from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');

-- Total amount of SALES currently not being executed or have been cancelled
select SUM("SALES") from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');

select * from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');

-- Sales per year
select SUM("SALES"), EXTRACT(YEAR FROM "ORDERDATE") as "YEAR" from auto_sales_data
where "STATUS" in ('Shipped', 'Resolved')
group by "YEAR";
 