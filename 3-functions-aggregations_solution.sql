/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #3 - Functions, Aggregations, Group by, Case when

*******************************************************************************
******************************************************************************/

-- Use superstore database
use superstore;

/****************************************
  String Functions
  - https://www.mysqltutorial.org/mysql-string-functions/
  - https://dev.mysql.com/doc/refman/8.0/en/string-functions.html
****************************************/


-- Convert CustomerName to uppercase
select CustomerName, upper(CustomerName)
from customers;
-- upper is a function built into sql

-- Rename (alias)
select CustomerName, upper(CustomerName) as CapitalizedCustomerName
from customers;

-- Find distinct years from orders using substr
-- substr(column_name, starting_index, length)
select distinct substr(OrderDate, 1, 4)
from orders;

-- Replace double quotes with nothing
-- replace(column_name, from: what we want to change from, to: what we want to change to)
select ProductName, replace(ProductName, '"', '') as ProductNameWithoutQuotations
from products;

-- Remove leading and trailing double quotes from ProductName
-- TRIM( [[LEADING | TRAILING | BOTH }] [remstr: character to remove] FROM ] str )
select ProductName,
       trim(both '"' from ProductName)
from products;

/***********************************
  Date and Time Functions
  - https://www.mysqltutorial.org/mysql-time/
************************************/

-- Common date functions
select OrderDate,
       year(OrderDate),
       month(OrderDate),
       day(OrderDate),
       dayofweek(OrderDate), -- 1 = Sunday
       dayname(OrderDate)
from orders;

-- Find distinct years from orders using datetime function
select distinct year(OrderDate)
from orders;

/****************************************
  EXERCISE
****************************************/
-- 1. Which order made in 2010 has the highest sales? (HINT: use order by)
select *
from orders
where year(OrderDate) = 2010
order by Sales DESC
limit 1;


-- 2. Which day of week was the biggest sales order made?
select Sales, OrderID, dayofweek(OrderDate), dayname(OrderDate)
from orders
order by Sales desc
limit 1;

select dayofweek(orderdate)
from orders
order by sales desc limit 1;

SELECT OrderID,dayofweek(OrderDate),Sales
FROM orders
ORDER BY Sales DESC
LIMIT 1;

select dayofweek(OrderDate) from orders order by Sales desc limit 1;

-------------------------------------------------------------------------------
/***********************************
  Aggregation Functions
  - https://www.mysqltutorial.org/mysql-aggregate-functions.aspx
***********************************/

-- Common aggregation functions
select count(Sales),
       sum(Sales),
       max(Sales),
       min(Sales),
       avg(Sales)
from orders;

select
       Sales, -- This line should give error because there is a mismatch between the # of rows
              -- in Sales and the # of rows in the columns with aggregated functions
       count(Sales),
       sum(Sales),
       max(Sales),
       min(Sales),
       avg(Sales)
from orders;

/***********************************
  Group by
  - https://www.mysqltutorial.org/mysql-group-by.aspx
***********************************/
-- GROUP BY arranges rows with the same values into groups

-- Which Shipping Mode has the highest average order shipping cost?
select distinct ShipMode
from orders;

select avg(ShippingCost) as AvgCostExpressAir
from orders
where ShipMode = 'Express Air';

select avg(ShippingCost) as AvgCostRegularAir
from orders
where ShipMode = 'Regular Air';

select avg(ShippingCost) as AvgCostTruck
from orders
where ShipMode = 'Delivery Truck';

-- Solution (for above question) using group by
select ShipMode, avg(ShippingCost) as AvgShippingCost
from orders
group by ShipMode
order by AvgShippingCost DESC
limit 1;


-- Which year generated the largest total sales?
select year(OrderDate), sum(Sales) as total_sales
from orders
group by year(OrderDate)
order by total_sales DESC
limit 1;

-- Total order quantity and sales by year and month
select year(OrderDate),
       month(OrderDate),
       sum(OrderQuantity),
       sum(Sales)
from orders
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate);


-- What is the biggest customer segment?
select CustomerSegment, count(*) as SizeOfCustomerSegment
from customers
group by CustomerSegment
order by SizeOfCustomerSegment DESC
limit 1;


/****************************************
  EXERCISE
****************************************/

-- 1. Which Product Sub Category has the highest average product base margin?
SELECT
       ProductSubCategory,
       avg(ProductBaseMargin)
FROM products
GROUP BY ProductSubCategory
ORDER BY avg(ProductBaseMargin) DESC
LIMIT 1;

-- 2. Which province has largest number of Home Office customers?
select Province, count(distinct CustomerID) as numberofcustomers
from customers
where CustomerSegment = 'Home Office'
group by Province
order by numberofcustomers desc
limit 1;

-- 3. Which customers placed most orders in a given month between
--    2011 and 2012?
SELECT CustomerID,
       DATE_FORMAT(OrderDate, '%Y-%m') order_month,
       COUNT(distinct OrderID) num_orders
FROM orders
WHERE YEAR(OrderDate) IN (2011, 2012)
GROUP BY 1, 2
ORDER BY 3 DESC;

SELECT CustomerID,
       DATE_FORMAT(OrderDate, '%Y-%m') order_month,
       COUNT(distinct OrderID) num_orders
FROM orders
WHERE YEAR(OrderDate) IN (2011, 2012)
GROUP BY CustomerID, order_month
ORDER BY order_month DESC;



/****************************************
  Having
  - https://www.mysqltutorial.org/mysql-having.aspx
****************************************/

-- Find customers who placed at least 5 orders in 2011
select CustomerID,
       count(distinct OrderID) as num_orders
from orders
where year(OrderDate) = 2011
group by CustomerID
having num_orders >= 5;

/****************************************
  EXERCISE
****************************************/

-- 1. Which provinces have at least 50 "Corporate" customers?
SELECT Province,
       count(CustomerSegment) as num_segment
FROM customers
WHERE CustomerSegment = 'Corporate'
GROUP BY Province
HAVING num_segment >= 50;

select Province, count(*) as corporatecustomercount
from customers
where CustomerSegment = 'Corporate'
group by Province
having corporatecustomercount >= 50
order by corporatecustomercount DESC;

-- 2. Which month of which year had total sales less than $200,000?
select month(OrderDate),
       year(OrderDate),
       sum(Sales) as total_sales
from orders
group by month(OrderDate), year(OrderDate)
having total_sales < 200000;


-------------------------------------------------------------------------------

/*****************************************
  CASE WHEN
*****************************************/

-- Case when
-- Indent for easier readability (Syntax style)
select ShipMode,
       case
            when ShipMode = 'Delivery Truck'
                then 'Yes'
                else 'No'
       end as DeliveredByTruck
from orders;

-- Case when with multiple conditions
-- Want to divide into 3 categories
-- Can divide ShippingTiers into:
-- -- low: < 50, mid: 50-100, high: 100+
select ShippingCost,
       case when ShippingCost>0 and ShippingCost<50 then 'Low'
            when ShippingCost<=100 then 'mid'
            when ShippingCost>100 then 'high'
            else 'others'
       end as ShippingCost
from superstore.orders;

/****************************************
  EXERCISE
****************************************/

-- 1. Query the orders table and create a column called is_priority_critical
--    with values yes or no depending on whether OrderPriority is 'critical'
select OrderPriority,
       case
            when OrderPriority = 'Critical'
                then 'Yes'
                else 'No'
       end as is_priority_critical
from orders;

-- 2. Create a table from orders with two columns: OrderDate and financial_quarter
-- where the values of financial_quarter are:
-- 'First Quarter` for months 1-3,
-- 'Second Quarter` for months 4-6
-- etc.
SELECT OrderDate,
       CASE
           WHEN QUARTER( OrderDate) = 1 THEN 'First Quarter'
           WHEN QUARTER( OrderDate) = 2 THEN 'Second Quarter'
           WHEN QUARTER( OrderDate) = 3 THEN 'Third Quarter'
           ELSE 'Fourth Quarter'
       END financial_quarter
FROM orders;

SELECT OrderDate,
       CASE
           WHEN month( OrderDate) between 1 and 3 THEN 'First Quarter'
           WHEN month( OrderDate) between 4 and 6 THEN 'Second Quarter'
           WHEN month( OrderDate) between 7 and 9 THEN 'Third Quarter'
           ELSE 'Fourth Quarter'
       END financial_quarter
FROM orders;

-------------------------------------------------------------------------------
/*********************************
  Pivot Tables with Case When
*********************************/

-- Display the years as columns, the months as rows,
-- and the order counts as values
select
    month(OrderDate) as mth,
    sum(case when year(OrderDate)=2009 then 1 else 0 end) as order_2009,
    sum(case when year(OrderDate)=2010 then 1 else 0 end) as order_2010,
    sum(case when year(OrderDate)=2011 then 1 else 0 end) as order_2011,
    sum(case when year(OrderDate)=2012 then 1 else 0 end) as order_2012
from orders
group by mth
order by mth;

-- Same information as a groupby
select
    year(OrderDate) as yr,
    month(OrderDate) as mth,
    count(*)
from orders
group by yr, mth
order by yr, mth;


-- Replace the year 2009 with 1 and all other years as 0
select
    year(OrderDate),
    case when year(OrderDate)=2009 then 1 else 0 end
from orders;

-- Sum up these values to get the count of orders for 2009
select
    sum(case when year(OrderDate)=2009 then 1 else 0 end)
from orders;

-- Display the years as columns and the order counts as values
select
    sum(case when year(OrderDate)=2009 then 1 else 0 end) as order_2009,
    sum(case when year(OrderDate)=2010 then 1 else 0 end) as order_2010,
    sum(case when year(OrderDate)=2011 then 1 else 0 end) as order_2011,
    sum(case when year(OrderDate)=2012 then 1 else 0 end) as order_2012
from orders;


-- How many orders are there per year?
select year(OrderDate),
       count(*)
from orders
group by year(OrderDate);

-- How many orders are there per month?
select month(OrderDate),
       count(*)
from orders
group by month(OrderDate);


-- Aggregate by Sales instead of Order Count
select
    sum(case when year(OrderDate)=2009 then Sales else 0 end) as order_2009,
    sum(case when year(OrderDate)=2010 then Sales else 0 end) as order_2010,
    sum(case when year(OrderDate)=2011 then Sales else 0 end) as order_2011,
    sum(case when year(OrderDate)=2012 then Sales else 0 end) as order_2012
from orders;

select * from orders;

/****************************************
  EXERCISE
****************************************/

-- 1. Is there a combination of OrderPriority and Shipmode that loses money?
-- Hint: Create a table with the total profits for each combination of
-- OrderPriority and Shipmode:
-- (Low, Regular Air, total profit)
-- (Low, Express Air, total profit)
-- (Low, Delivery Truck, total profit)
-- etc.
select * from orders;

select
    OrderPriority,
    ShipMode,
    sum(Profit) as TotalProfits
from orders
group by OrderPriority, ShipMode;

-- 2. Display the same information as a pivot table

select
    OrderPriority,
    sum(case when ShipMode = 'Regular Air' then Profit else 0 end) as RegularAir,
    sum(case when ShipMode = 'Express Air' then Profit else 0 end) as ExpressAir,
    sum(case when ShipMode = 'Delivery Truck' then Profit else 0 end) as DeliveryTruck
from orders
group by OrderPriority;

SELECT ShipMode,
       IF( AVG( IF( OrderPriority = 'low', Profit, NULL)) > 0, '-', 'PROBLEM') AS lowPrio,
       IF( AVG( IF( OrderPriority = 'medium', Profit, NULL)) > 0, '-', 'PROBLEM')  AS midPrio,
       IF( AVG( IF( OrderPriority = 'high', Profit, NULL)) > 0, '-', 'PROBLEM')  AS highPrio,
       IF( AVG( IF( OrderPriority = 'critical', Profit, NULL)) > 0, '-', 'PROBLEM')  AS critPrio,
       IF( AVG( IF( OrderPriority = 'not specified', Profit, NULL)) > 0, '-', 'PROBLEM')  AS noSpecPrio
FROM orders
GROUP BY ShipMode;
