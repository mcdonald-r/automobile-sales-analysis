-- Quick summary view of the dataset
select * from auto_sales_data limit 10;

-- What are the different STATUS messages
select distinct "STATUS" from auto_sales_data;

-- All rows that contain On Hold, Disputed, or Cancelled STATUS messages
select * from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');

-- Total amount of SALES currently not being executed or have been cancelled
select SUM("SALES") from auto_sales_data
where "STATUS" in ('On Hold', 'Disputed', 'Cancelled');
