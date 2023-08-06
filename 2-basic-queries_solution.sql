/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #2 - Basic Queries

*******************************************************************************
******************************************************************************/

/****************************************
  Select
  - https://www.mysqltutorial.org/mysql-select-statement-query-data.aspx
****************************************/

-- Use superstore database
use superstore;
show databases;

select database();

-- Select all columns from table
select *
from customers;

-- Select certain columns from table
select CustomerID
from customers;

select CustomerID,
       CustomerName,
       CustomerSegment
from customers;

-- Filter first 5 rows
select *
from customers
limit 5;

-- Show Table schema
describe orders;
-- Date: 'YYYY-MM-DD'
-- Datetime: 'YYYY-MM-DD hh:mm:ss'

-- Filter by condition
select *
from orders
where OrderQuantity <= 3;

select *
from orders
where OrderQuantity > 3;

select *
from orders
where OrderQuantity != 3;

select *
from orders
where OrderPriority = 'Critical';

select *
from orders
where OrderPriority > 'Critical';

/****************************************
  EXERCISE
****************************************/

-- 1. Look at the first 5 rows of the customers, products, and returns tables
select *
from customers
limit 5;

select *
from products
limit 5;

select *
from returns
limit 5;

-- 2. Which products have a `ProductBaseMargin` greater than 0.8?
select *
from products
where ProductBaseMargin > 0.8;

-- 3. What is the CustomerId and CustomerSegment of `Erin Smith`?
select CustomerID,
       CustomerSegment
from customers
where CustomerName = 'Erin Smith';

-------------------------------------------------------------------------------
/****************************************
  More Filtering (WHERE)
  https://www.mysqltutorial.org/mysql-where/
****************************************/

-- Filter by multiple conditions
select *
from orders
where OrderPriority = 'Critical' or OrderPriority = 'High';

-- AND: both conditions have to be True for the row to be returned
-- OR: at least one is True

select *
from orders
where OrderPriority = 'Critical' and Profit >= 5000;

-- Filter by similar values
-- Wildcard is %
select *
from orders
where ShipMode = 'Express Air' or
      ShipMode = 'Regular Air';

select *
from orders
where ShipMode LIKE '%Air%';

select *
from orders
where ShipMode LIKE '%Air';

select *
from orders
where ShipMode LIKE 'Air%';

-- Filter by multiple values
select *
from orders
where OrderQuantity = 3 or
      OrderQuantity = 6 or
      OrderQuantity = 9;

select *
from orders
where OrderQuantity in (3, 6, 9);

-- Filter by values within specific range
select *
from orders
where OrderQuantity >=3 and OrderQuantity <= 9;

select *
from orders
where OrderQuantity between 3 and 9;
-- BETWEEN: inclusive


-- Filter NULL values
select *
from orders
where ShipMode is NULL;

-- To get values that are not NULL
select *
from orders
where ShipMode is not NULL;

/****************************************
  EXERCISE
****************************************/

-- 1a. Select all the printers (Hint: ProductName contains "Printer")
--    that have a BaseMargin greater than 0.4 and less than 0.6
select *
from products
where ProductBaseMargin > 0.4 and
      ProductBaseMargin < 0.6 and
      ProductName like '%Printer%';

-- 1b. Select all the printers (Hint: ProductName contains "Printer")
--    that have a BaseMargin greater than or equal 0.4 and less than or equal to 0.6
select *
from products
where ProductBaseMargin between 0.4 and 0.6 and
      ProductName like '%Printer%';

-- 2. Which customers are from Ontario, Quebec, or British Columbia?
select *
from customers
where Province in ('Ontario', 'Quebec', 'British Columbia');

-- 3. Which customers are NOT from Ontario, Quebec, or British Columbia?
select *
from customers
where Province not in ('Ontario', 'Quebec', 'British Columbia');

-------------------------------------------------------------------------------
/*****************************************
  Sorting Query Results
  - https://www.mysqltutorial.org/mysql-order-by/
*****************************************/

-- Sort table by column
select *
from orders
order by OrderQuantity;
-- ASC is the default sorting order

-- Sort table in descending order
select *
from orders
order by OrderQuantity DESC;

-- Sort table by multiple columns
select *
from orders
order by OrderQuantity DESC,
         Discount ASC;

select OrderQuantity,
       Discount
from orders
order by OrderQuantity DESC,
         Discount ASC;

select OrderQuantity,
       Discount
from orders
order by 1 DESC,
         2 ASC;

/****************************************
  EXERCISE
****************************************/

-- 1. Which 3 Products from the "Furniture" category have the
--    highest ProductBaseMargin?
select *
from products
where ProductCategory = 'Furniture'
order by ProductBaseMargin DESC
limit 3;

-------------------------------------------------------------------------------
/*****************************************
  Distinct/Count
  - https://www.mysqltutorial.org/mysql-distinct.aspx
*****************************************/

-- Select unique values
select distinct ShipMode
from orders;

-- Counting rows
select count(*)
from orders;

-- Example
create table example(PersonId int);
insert into example(PersonId) values (1), (3), (null);
select * from example;

-- Special; counts over all columns and include null values in the count
select count(*) from example;

-- Count on a specific column will not count the NULL
select count(PersonId) from example;

-- Number of customers that have ordered by "Express Air"
select count(distinct(CustomerID))
from orders
where ShipMode = 'Express Air';

/****************************************
  EXERCISE
****************************************/

-- 1. How many types of "Status" are in the returns table?
select count(distinct Status)
from returns;

-- 2. How many customers from Ontario are small Businesses?
select count(distinct(CustomerID))
from customers
where Province = 'Ontario' and CustomerSegment = 'Small Business';

-- 3. How many unique ProductSubCategories are there?
select count(distinct ProductSubCategory)
from products;
