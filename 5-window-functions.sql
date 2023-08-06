/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #5 - Window Functions

*******************************************************************************
******************************************************************************/

/********************************
  Create Database/Tables
********************************/
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
select *,
       sum(sales) over() as Total
from sales;

/****************************************
  Window - Partitioning
*****************************************/

-- Get total sales for each salesperson
 SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select *
from sales
group by name;

-- Partition by sales rep, aggregation over each window
select *, sum(sales) over(partition by name) as total_sales_per_person
from sales;

-- Get total sales for each month
select month, sum(sales)
from sales
group by month;

-- Partition by month, aggregation over each window
select *, sum(sales) over(partition by month) as monthly_total
from sales;
/****************************************
  Window - ORDER BY
*****************************************/

-- Cumulative sum of sales for james
select *
from sales
where name= 'James';

-- Calculate cumulative sum of sales for the sales reps by applying order by to each window
select *,
       sum(sales) over(partition by name order by month) as sum_name
from sales;

/****************************************
  EXERCISE
****************************************/
use superstore;
-- 1. Calculate the cumulative sum of sales by month for the year of 2011
-- filter only 2011
-- get monthly total sale
-- cumulative sum
select *,
       sum(monthly_total) over (order by mth) as cumulate_sum
from (
select month(OrderDate) as mth,
       sum(sales) as monthly_total
from orders
where year(OrderDate)=2011
group by mth) as sub;
-- 2. Calculate the cumulative sum of sales by month for EACH YEAR
select *,
       sum(monthly_total) over (partition by yr order by mth) as cumulate_sum
from (
select year(OrderDate) yr,
       month(OrderDate) as mth,
       sum(sales) as monthly_total
from orders
group by mth) as sub;
/****************************************
  Movable Windows
*****************************************/
use windowdb;
-- Define the window frame
select *,
       sum(sales) over(partition by name) as sales_per_person
from sales;

-- Equivalent to
select *,
       sum(sales) over(partition by name rows between unbounded preceding and unbounded following) as sales_per_person
from sales;

-- Running total
select *,
       sum(sales) over(partition by name order by month) as runnung_total
from sales;

-- Equivalent to
select *,
       sum(sales) over(partition by name rows between unbounded preceding and current row ) as runnung_total
from sales;

-- Average 3 months sale
select *,
       avg(sales) over(partition by name rows between 1 preceding and 1 following) as 3_mth_avg
from sales
order by month;
/****************************************
  EXERCISE
****************************************/

-- Calculate moving average sales (1 preceding, 1 following)> The first and the last row of the result will not be correct

-- Calculate the moving average of total sales per month for each year
use superstore;
-- The orderdate is recorded as each day, so need to group by yr and mth
select year(OrderDate) as yr,
       month(OrderDate) as mth,
       sum(sales) as monthly_total
from orders
group by yr, mth
order by yr, mth;
-- calculate running avg sales
select *,
       avg(monthly_total) over(partition by yr rows between unbounded preceding and current row) as monthly_avg
from (select year(OrderDate) as yr,
       month(OrderDate) as mth,
       sum(sales) as monthly_total
from orders
group by yr, mth
order by yr, mth) as sub;
/****************************************
  Special Window Functions
*****************************************/

use windowdb;

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

-- Try running the remaining functions to see what they do
-- Change the name of the column to what you think it does

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
  month,
  sales,
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
select count(distinct user_id)
from (
select *,
       lead(coupon_activation) over (partition by user_id order by order_date) as lead_coupon_activation
from retail_promo) as sub
where coupon_activation = 'Y' and lead_coupon_activation is not null;

-- Use lag()
select count(distinct user_id)
from (
select *,
       lag(coupon_activation) over (partition by user_id order by order_date) as got_A_coupon
from retail_promo) as sub
where got_A_coupon = 'Y';