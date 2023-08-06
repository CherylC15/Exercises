/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #5 - Window Functions

*******************************************************************************
******************************************************************************/

/********************************
  Create Database/Tables
********************************/

drop database if exists windowdb;
-- Create windowdb database
create database windowdb;

use windowdb;

-- Create a sales table
drop table if exists sales;

create table sales (
  name varchar(50),
  month int,
  sales int
);

truncate sales;

insert into sales
values
  ('james', 1, 200),
  ('james', 2, 300),
  ('james', 3, 400),
  ('james', 4, 150),
  ('james', 5, 100),
  ('james', 6, 200),
  ('james', 7, 350),
  ('james', 8, 300),
  ('james', 9, 400),
  ('james', 10, 200),
  ('james', 11, 250),
  ('james', 12, 350),
  ('kelly', 1, 400),
  ('kelly', 2, 300),
  ('kelly', 3, 500),
  ('kelly', 4, 250),
  ('kelly', 5, 450),
  ('kelly', 6, 300),
  ('kelly', 7, 300),
  ('kelly', 8, 350),
  ('kelly', 9, 400),
  ('kelly', 10, 300),
  ('kelly', 11, 250),
  ('kelly', 12, 350);

select * from sales;

/*****************************************
  Window Function Introduction
*****************************************/

/*
The keyword `OVER` signals that this is a `window function`, as opposed to a `grouped aggregate function`.

- The empty parentheses after `OVER` is a window specification.
- In this simple example it is empty `()` this means default to aggregating the window function over all rows in the result sets.
*/

select sum(sales)
from sales;

select name, month, sales, sum(sales) over () as total
from sales;



/****************************************
  Window - Partitioning
*****************************************/

-- Get total sales for each salesperson
select name, sum(sales)
from sales
group by name;

-- Partition by sales rep, aggregation over each window
select *, sum(sales) over (partition by name) as total_sales_per_person
from sales;

-- Get total sales for each month
select month, sum(sales)
from sales
group by month;

-- Partition by month, aggregation over each window
select *, sum(sales) over (partition by month) as total_sales_per_month
from sales;

/****************************************
  Window - ORDER BY
*****************************************/

-- Cumulative sum of sales for james
select *
from sales
where name = 'James';

use windowdb;
-- Calculate cumulative sum of sales for the sales reps by applying order by to each window
select *, sum(sales) over (partition by name order by month) as running_total
from sales;


/****************************************
  EXERCISE
****************************************/

use superstore;

-- 1. Calculate the cumulative sum of sales by month for the year of 2011
-- Filter out for orders that occurred in 2011
-- Find the total sales for each month
-- Get the cumulative sales from Jan to Dec
select month,
       total_sales,
       sum(total_sales) over (order by month) as running_total
from (select month(OrderDate) as month,
        sum(sales) as total_sales
from orders
where year(OrderDate) = 2011
group by month
order by month) as subquery;

-- 2. Calculate the cumulative sum of sales by month for EACH YEAR
select yr,
       month,
       total_sales,
       sum(total_sales) over (partition by yr order by yr, month) as running_total
from (select year(OrderDate) as yr,
             month(OrderDate) as month,
             sum(sales) as total_sales
      from orders
      group by yr, month
      order by yr, month) as subquery;

-- Cannot use window function alone (without subquery) because it will
-- give us the month's total sales in each row (d/t there being orders
-- on multiple days in that month
    -- If you do try this way, there's the nuance that you need distinct on year
    -- to make it return just one row
-- This method might not work every time
select distinct year(OrderDate),
                month(OrderDate),
                -- sum(sales), -- <- cannot include this as there would be a discrepancy in number of rows
                sum(sales) over (partition by year(OrderDate)
                    order by month(OrderDate)) as running_total
from orders;

-- To address the problem of sum(sales) from above, you could have another window
-- function to calculate the running_total
SELECT DISTINCT MONTH( OrderDate) month,
                YEAR( OrderDate) year,
       SUM(Sales) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)),
       SUM(Sales) OVER (PARTITION BY YEAR( OrderDate) ORDER BY MONTH( OrderDate)) running_total
FROM orders;

/****************************************
  Movable Windows
*****************************************/

use windowdb;

-- Define the window frame
-- Calculating the running total
select name, month, sales,
       sum(sales) over (order by month
           rows between unbounded preceding and current row) as moving_window
from sales
where name = 'James';

-- ROWS BETWEEN N PRECEDING AND N FOLLOWING
select name, month, sales,
       sum(sales) over (order by month
           rows between 1 preceding and 1 following) as moving_window
from sales
where name = 'James';

/****************************************
  EXERCISE
****************************************/

-- Calculate moving average sales (1 preceding, 1 following)
select name, month, sales,
       avg(sales) over (order by month
           rows between 1 preceding and 1 following) as moving_window
from sales
where name = 'James';

-- Calculate the moving average of total sales per month for each year
-- 1. Calculate the total_sales per month for each year
-- 2. Calculate moving average on it (2 preceding, 2 following)
use superstore;

select yr,
       month,
       total_sales,
       avg(total_sales) over (partition by yr order by month
           rows between 2 preceding and 2 following) as moving_average
from (select year(OrderDate) as yr,
             month(OrderDate) as month,
             sum(sales) as total_sales
      from orders
      group by yr, month
      order by yr, month) as subquery;

/****************************************
  Special Window Functions
*****************************************/

use windowdb;
-- Try running the remaining functions to see what they do
-- Change the name of the column to what you think it does

-- ROW_NUMBER()
select
  name,
  sales,
  month,
  row_number() over (
    partition by name
    order by sales desc
  ) as thing
from sales;

-- RANK()
select
  name,
  sales,
  month,
  rank() over (
    partition by name
    order by sales desc
  ) as thing
from sales;

-- DENSE_RANK()
select
  name,
  sales,
  month,
  dense_rank() over (
    partition by name
    order by sales desc
  ) as thing
from sales;

-- LEAD()
select
  name,
  sales,
  month,
  lead(sales) over (
    partition by name
    order by sales desc
  ) as thing
from sales;

-- LAG()
select
  name,
  sales,
  month,
  lag(sales) over (
    partition by name
    order by sales desc
  ) as thing
from sales;

-- NTILE()
select
  name,
  sales,
  month,
  ntile(7) over (
    partition by name
    order by sales asc
  ) as thing
from sales;

select
  name,
  sales,
  month,
  ntile(4) over (
    partition by name
    order by month asc
  ) as thing
from sales;

/****************************************
  EXERCISE
****************************************/

-- 1. Calculate average sales by quarter for each salesperson
-- What you might need, in no particular order:
    -- Ntile
    -- Window function
    -- groupby
    -- subquery

-- Expected Output:
-- Name, quarter, avg(sales)
-- james, 1, 300
-- james, 2, 150
-- ...
-- kelly, 4, 300

select *
from sales;

select name, quarter, avg(sales)
from(select name,
            ntile(4) over (partition by name order by month) as quarter,
            sales
     from sales) as subquery
group by name, quarter;



/****************************************
  EXERCISE - Interview Question
****************************************/

drop database if exists retail;

create database retail;
use retail;

create table retail.retail_promo (
  user_id int,
  transaction_id int,
  order_date date,
  order_sales float,
  coupon_activation char(1)
);

truncate retail.retail_promo;

insert into retail.retail_promo (user_id, transaction_id, order_date, order_sales, coupon_activation)
values
  (1, 485948, '2018-01-02', 20.89, 'N'),
  (1, 217493, '2018-01-03', 10.11, 'Y'),
       -- (1, 23, '2018-01-04', 10.11, 'Y'), -- In the case if there was a user who activated the coupon twice in a row
  (1, 732164, '2018-01-05', 10.00, 'N'),
  (1, 327146, '2018-01-10', 15.34, 'N'),
  (2, 483938, '2018-01-01', 17.89, 'Y'),
  (2, 347683, '2018-01-06', 10.00, 'N'),
  (3, 458792, '2018-01-06', 5.00, 'N'),
  (3, 112893, '2018-01-07', 15.34, 'Y');

select * from retail_promo;

/*
Company X launched a marketing campaign. Customers were given coupons that they
can use in the future trips. The marketing team wants to know how many users
actually made purchases after coupon activation.
*/

-- Hint: Use the lead() window function
select count(*)
from (select user_id, order_date, coupon_activation,
       lead(coupon_activation) over (partition by user_id
           order by order_date) as lead_coupon_activation
from retail_promo) as subquery
where coupon_activation = 'Y' and lead_coupon_activation is not NULL;

-- In the case if there was a user who activated the coupon twice in a row
select count(distinct user_id)
from (select user_id, order_date, coupon_activation,
       lead(coupon_activation) over (partition by user_id
           order by order_date) as lead_coupon_activation
from retail_promo) as subquery
where coupon_activation = 'Y' and lead_coupon_activation is not NULL;