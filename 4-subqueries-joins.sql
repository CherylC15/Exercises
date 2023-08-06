/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #4 - Subqueries, Joins

*******************************************************************************
******************************************************************************/

/********************************
  Create Database/Tables
********************************/

-- List databases
show databases;
-- Drop a database
drop database if exists company;
-- Create a database
create database company;
-- Select default database
use company;
-- Check selected database
select database();
-- Create employee table
create table employee (
    employee_id varchar(1),
    team varchar(10),
    salary int
);
-- Check table created
show tables;
-- Insert data to employee table
insert into employee
values
  ('a', 'red', 80),
  ('b', 'red', 75),
  ('c', 'red', 110),
  ('d', 'green', 80),
  ('e', 'green', 80),
  ('f', 'blue', 50),
  ('g', 'blue', 200);

-- Show employee table
select * from employee;
truncate employee;
-- Create hobby table
create table hobby (
  employee_id varchar(1),
  hobby varchar(20)
);

-- Insert data to hobby table
insert into hobby
values
  ('b', 'soccer'),
  ('e', 'cooking'),
  ('g', 'knitting'),
  ('h', 'music');
select * from hobby;

-- Create hire table
create table hire (
  employee_id varchar(1),
  hire_date int
);

-- Insert data to hire table
insert into hire
values
  ('a', 2011),
  ('b', 2015),
  ('c', 2017),
  ('d', 2017),
  ('e', 2016),
  ('f', 2017);

-- Create review table
create table review (
  name varchar(1),
  performance int
);

-- Insert data to review table
insert into review
values
  ('a', 10),
  ('b', 10),
  ('c', 9),
  ('d', 10),
  ('e', 5),
  ('f', 9);

-- Check database/tables
select * from hobby;
select * from hire;
select * from review;
-------------------------------------------------------------------------------
/*********************************
  Subqueries
*********************************/

-- What is the average number of employees for each team?
-- 1. find team size
select team, count(*)
from employee
group by team;
-- 2. find the average
select avg(teamsize)
from (
select team, count(*) teamsize
from employee
group by team) as subquery;

-- Which employee(s) had the highest performance score?
select name from review
where performance = 10;

select name, performance
from review
    where performance in  (select max(performance)from review);

-- Multiple nested subquery
-- What is the average salary of employees with the highest performance score?
select avg(salary)
from employee
where employee_id in (select name, performance
from review
where performance in (select max(performance) from review));


/****************************************
  EXERCISE
****************************************/
use superstore;
-- 1. What was the total Sales loss due to returned products?
select sum(Sales)
from orders
where orders.OrderID in (select OrderId from returns);

-- 2. What is the highest single day total sales number?
select max(totalsales)
from (select OrderDate, sum(Sales) as totalsales
from orders
group by OrderDate) as sub;
-------------------------------------------------------------------------------
/*********************************
  Joins
*********************************/
-- What are joins and why do we need them?

use company;

-- Inner join
select *
from employee inner join hobby h on employee.employee_id = h.employee_id;

-- Left join
select *
from employee left join hobby h on employee.employee_id = h.employee_id;
-- Right join
select *
from employee right join hobby h on employee.employee_id = h.employee_id;

-- Union (Full outer join)
select *
from employee left join hobby h on employee.employee_id = h.employee_id
union
select *
from hobby left join employee e on hobby.employee_id = e.employee_id;

-- Inner join by default
use company;
select *
from employee join hobby h on employee.employee_id = h.employee_id;

-- Using, if join columns are the same name
select *
from employee join hobby using(employee_id);
-- Use alias to simplify query


/****************************************
        Exercise
 ***************************************/

-- 1. Create a summary table that has 3 columns:
--    employee_id, team, and hire_date

-- 2. Create a summary table that has 4 columns:
--    employee_id, team, hire_date and performance
-- HINT: just add the second join after the first in the same query

-- 3. What is the average performance score for each team?
-- Create a summary table of team, employee_id, and performance
select team, avg(performance) avg_performance
from employee e join review r on e.employee_id=r.name
group by performance, team;