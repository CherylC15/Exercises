/******************************************************************************
*******************************************************************************

WeCloudData - Data Science Program

Lecture #1 - Create a Database and Tables

*******************************************************************************
******************************************************************************/

/****************************************
  Working with databases
  - Create a superstore database
****************************************/
set global local_infile = 1;
-- List databases
show databases;

-- Drop a database
drop database if exists superstore;

-- Create a database
create database superstore;

-- Select default database;
use superstore;

-- Check which database is selected
select database();

# This is a comment


-------------------------------------------------------------------------------
/****************************************
  Create and load the customer table
****************************************/

-- List tables in a database
show tables;

-- Drop the customers table if it already exists
drop table if exists customers;

-- Create the customer table (an empty table)
create table customers (
  CustomerID int,
  CustomerName varchar(100),
  Province varchar(50),
  Region varchar(30),
  CustomerSegment varchar(20)
);

-- Describe the customer table
-- Display the table details such as data types
describe customers;

-- Clear the data in this table while keeping the table in database
-- to avoid repeated insertion of same data
truncate customers;

-- Load data from a csv file into the table
load data local infile '/Users/cherylchien/Downloads/w0-tutorial/superstore/customers.csv'
into table customers
fields terminated by '\t'
lines terminated by '\n';


-- Check that the data was loaded
select * from customers limit 10;

select count(*) from customers;


-------------------------------------------------------------------------------
/****************************************
  Create and load the orders table
****************************************/

-- Create the orders table (an empty table)
drop table if exists orders;
create table orders (
    OrderID int,
    ProductID int,
    CustomerID int,
    OrderDate date,
    OrderPriority varchar(20),
    OrderQuantity int,
    Sales decimal(15,5),
    Discount decimal(3,2),
    ShipMode varchar(20),
    Profit decimal(15,2),
    UnitPrice decimal(15,2),
    ShippingCost decimal(15,2)
);

-- Clear the data in this table while keeping the table in database
-- to avoid repeated insertion of same data
truncate orders;

-- Load data from a csv file into the table
load data local infile '/Users/cherylchien/Downloads/w0-tutorial/superstore/orders.csv'
into table orders
fields terminated by '\t'
lines terminated by '\n'
;

-- Check that the data was loaded
select * from orders limit 10;


-------------------------------------------------------------------------------
/****************************************
  Create and load the product table
****************************************/

-- Create the product table (an empty table)
drop table if exists products;

create table products (
    ProductID int,
    ProductName varchar(200),
    ProductCategory varchar(20),
    ProductSubCategory  varchar(50),
    ProductContainer varchar(20),
    ProductBaseMargin decimal(4,2)
);

-- Clear the data in this table while keeping the table in database
-- to avoid repeated insertion of same data
truncate products;

-- Load data into the product table
load data local infile '/Users/cherylchien/Downloads/w0-tutorial/superstore/products.csv'
into table products
character set 'latin1'
fields terminated by '\t'
lines terminated by '\n';

-- Check that the data was loaded
select * from products limit 10;


-------------------------------------------------------------------------------
/****************************************
  EXERCISE
****************************************/

-- 1. Create an empty returns table
--    - It will have two columns: `OrderId` and `Status`
--    - Set the appropriate datatypes for the columns based on the csv
drop table if exists returns;

create table returns (
  OrderId int,
  Status varchar(20)
);

-- 2. Load the data into the table from `returns.csv`
-- Load data into the product table

truncate returns;

load data local infile '/Users/cherylchien/Downloads/w0-tutorial/superstore/returns.csv'
into table returns
fields terminated by '\t'
lines terminated by '\n';


-- 3. Check the table to see that the data was loaded correctly
select * from returns;