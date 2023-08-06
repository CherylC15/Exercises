/*****************************************
# Advanced SQL Topics (Tutorial Solution)
# - Views
# - Indexing
# - CRUD
# - JOIN
# - Primary Keys/Foreign Keys

# Designed by WeCloudData
*****************************************/


# show variables like "local_infile";
SET GLOBAL local_infile = 'ON';
# show variables like "secure_file_priv";


/****************************************
			Tutorial Data Preparation
*****************************************/

-- Employee data
--   1. Download the employee-data-analysis.zip from LMS and unzip
--   2. From command line, navigate to employee-data-analysis folder
--   3. Run `mysql -u root -p < employees.sql` to load the database


DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;
USE employees;

DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries,
                     employees,
                     departments;

CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,
    hire_date   DATE            NOT NULL,
    PRIMARY KEY (emp_no)
);
describe employees;

CREATE TABLE salaries (
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
)
;


load data local infile '/Users/cherylchien/Documents/Bootcamp/1109/sql-advanced-topics/employees_employees.tsv'
into table employees
character set 'latin1'
fields terminated by '\t'
Enclosed by '"'
lines terminated by '\n'
;

truncate salaries;
load data local infile '/Users/cherylchien/Documents/Bootcamp/1109/sql-advanced-topics/employees_salaries.tsv'
into table salaries
character set 'latin1'
fields terminated by '\t'
enclosed by '"'
lines terminated by '\n'
;

select * from salaries limit 5;

/****************************************
			Creating Views 
*****************************************/

# A view is nothing but a query.
# It's a virtual table that's defined by a query.
# View is useful for
#   - Limiting the visibility of columns (via select) or rows (via where) to just those pertinent to a task
#   - Combining rows (via union) and or columns (via join) from multiple tables into one logical table.
#   - Aggregating rows (via Group BY and Having) into a more distinct presentation pulled from a table with finer detail.
#   - Renaming or decoding either columns (using AS) or rows (using JOIN, IF, CASE or Oracle's DECODE).
#   - Combing any of the above with security settings, access can be locked down to ensure a user only has access to what they are authorized.

use employees;

create view employees.salaries_vw
as 
select x.*, y.birth_date
from
  salaries x
  inner join employees y
  on x.emp_no = y.emp_no
;

show create view salaries_vw;

explain
select  * from salaries_vw limit 50;




/**************************************************
			CRUD:  INSERT/UPDATE/DELETE
***************************************************/

###################
# INSERT
###################


# INSERT new records
create database if not exists test;
use test;

create table users (
    ID int,
    Name varchar(10)
);

truncate users;
insert into users (ID, Name) values
  (1, 'Patrck'),
  (2, 'Albert'),
  (3, 'Maria'),
  (4, 'Darwin'),
  (5, 'Elizabeth')
;

create table likes (
  UID int,
  Hobby varchar(10)
);

truncate likes;
insert into likes values
  (3, 'Stars'),
  (1, 'Climbing'),
  (1, 'Code'),
  (6, 'Rugby'),
  (4, 'Apples')
;

select * from users limit 5;


-- replicate a table schema
create table likes_2 like likes;

describe likes_2;

-- insert data from another table
insert into likes_2
select *
from likes;

-- check results
select * from likes_2;

truncate likes_2;
select *  from likes_2;

insert into likes_2
select *
from likes;


##################
# Update
##################

-- change Hobby='Code' to Hobby='Coding'
UPDATE likes_2
SET
    Hobby = 'Coding'
WHERE
    UID =1 and Hobby = 'Code';

select * from likes_2;

# DELETE
/* drop and recreate */
truncate table likes_2;

/* delete operations */
delete from likes
where UID = 1;

select * from likes;


truncate likes;
select *  from likes;
describe likes;

drop table likes;
select * from likes; -- expect table not exist error


### Join exercises
-- recrate deleted tables
create table likes (
  UID int,
  Hobby varchar(10)
);

truncate likes;
insert into likes values
  (3, 'Stars'),
  (1, 'Climbing'),
  (1, 'Code'),
  (6, 'Rugby'),
  (4, 'Apples')
;

select u.ID, u.Name, Hobby
  from users u
  inner join likes l
  on u.ID  =  l.UID
;

select u.ID, u.Name, Hobby
  from users u
  left outer join likes l
  on u.ID  =  l.UID
;

select u.ID, u.Name, Hobby
  from users u
  left outer join likes l
  on u.ID  =  l.UID
union
select u.ID, u.Name, Hobby
  from users u
  right outer join likes l
  on u.ID  =  l.UID
;


/**************************************************
			          INDEXING
**************************************************/

##########################################
#  1. Optimizing the employee salary table
#      - 1.1 Index performance on WHERE filter
#      - 1.2 Index performance on INSERT
#      - 1.3 Index performance on JOIN
##########################################

# switch to employees database
use employees;

# display tables
show tables;



##########################################
#  1.1 Index performance on WHERE filter
##########################################

# check out the salaries table
select * from salaries limit 5;

# describe table
describe salaries; -- table salaries has (emp_no, from_date) as primary key

# show table create statement to find index and constraints
show create table salaries;

# show index
show index from salaries;

select * from salaries where emp_no = 10001;
select emp_no from salaries where salary = 50000;

#  explain table and see if your query is actually use index
explain select emp_no from salaries where salary = 50000;
explain select emp_no from salaries where salary > 100000;
-- The key field will tell us if any indexes are used, and the rows field will tell us how many rows were examined to get the result.
-- The above output shows key: NULL for both queries because salary column is not indexed.  The value of the rows field (2839089) tell us that MySQL is doing a full table scan.

# creating an index

alter table salaries ADD INDEX salary (salary);
describe salaries;
show index from salaries;

# explain the where clause again
explain select emp_no from salaries where salary = 50000;

-- Notice the dramatic improvement here.  The rows examined has dropped to 69 which is the number of results matching our condition.
explain select emp_no from salaries where salary > 100000;

/*
It's important to know that creating indexes introduces a performance penalty for write operations (INSERT, UPDATE, and DELETE).   Each time the rows in a table are modified, any related indexes are updated automatically.   For this reason, it's important to avoid create indexes on columns that don't provide any value.

Indexing Best Practice
- Index columns that JOIN with other tables
- Index columns used frequently in the WHERE clause
- Don't create unnecessary indexes because they waste space and add execution time for MySQL to determine which one to use.
- Drop the indexes prior to bulk INSERT/UPDATE/DELETE operations and re-add them afterwards to improve speed
*/


##########################################
#      - 1.2 Index performance on INSERT
##########################################

# create salaries_index table by copying schema from salaries table
create table salaries_index like salaries;
describe salaries_index;

# create a salaries_noindex by copying schema from salaries table and
# dropping index and primary key
create table salaries_noindex like salaries;
describe salaries_noindex;

alter table salaries_noindex drop index salary, drop primary key;
describe salaries_noindex;


# insert salaries data into both tables above and observe the performance difference
insert into salaries_noindex
select *
from salaries; -- 12s

insert into salaries_index
select *
from salaries; -- 28s



##########################################
#  1.3 Index performance on JOIN
##########################################

# 1.3.1 - table preparation
-- create the nonindex version of employees and salaries tables
create table employees_noindex like employees;
alter table employees_noindex drop primary key;
describe employees_noindex;
insert into employees_noindex select * from employees;

describe employees_noindex;
select count(*) from employees_noindex;
select * from employees limit 5;

describe salaries;
select count(*) from salaries;
select * from salaries where emp_no=10003;

# 1.3.2 - join two tables that are indexed
show index from salaries;
show index from employees;

drop table if exists tmp;
create table tmp as
select x.*, y.birth_date
from
  salaries x
  inner join employees y
  on x.emp_no = y.emp_no
; -- took 19s

# 1.3.3 - join two tables that are not indexed
drop table if exists tmp_noindex;
create table tmp_noindex as
select x.*, y.birth_date
from
  salaries_noindex x
  inner join employees_noindex y
  on x.emp_no = y.emp_no
; --

explain
select x.*, y.birth_date
from
  salaries x
  inner join employees y
  on x.emp_no = y.emp_no
;


/**************************************************
		    PRIMARY KEY vs FOREIGN KEY
**************************************************/


-- https://www.slashroot.in/primary-key-and-foreign-key-mysql-explained-examples

drop database university;
create database university;
use university;

# Create a table with primary key
drop table if exists students;
create table students (
  s_id INT(10) NOT NULL AUTO_INCREMENT,
  s_firstname VARCHAR(30) NOT NULL,
  s_lastname VARCHAR(30) NOT NULL,
  s_email VARCHAR(40),
  PRIMARY KEY (s_id)
  )
;

insert into students (s_firstname, s_lastname, s_email) values
  ('Shankar', 'Bhat', 'shankar@example.com'),
  ('Venkat', 'Rao', 'venkat@example.com'),
  ('Mohan', 'Nair', 'mohan@example.com'),
  ('Abhijeet', 'Patel', 'abhi@example.com')
;

describe students;
select * from students where s_id = '3';


# Create a table with composite primary key
drop table if exists students;
create table students (
  s_firstname VARCHAR(30) NOT NULL,
  s_lastname VARCHAR(30) NOT NULL,
  s_email VARCHAR(40),
  s_phone BIGINT(10) NOT NULL,
  PRIMARY KEY (s_firstname, s_phone)
);

describe students;

insert into students (s_firstname, s_lastname, s_email, s_phone) values
  ('Shankar', 'Bhat', 'shankar@example.com', 7303075409),
  ('Venkat', 'Rao', 'venkat@example.com', 7404076894),
  ('Mohan', 'Nair', 'mohan@example.com', 7404076892),
  ('Abhijeet', 'Patel', 'abhi@example.com', 7404076991),
  ('Manoj', 'Nair', 'manoj@example.com', 7404076892)
;

describe students;

select * from students where s_firstname='Manoj';


select * from students
where s_firstname='Manoj' and
      s_phone=7404076892
;

# Insert a duplicate primary key will fail
insert into students (s_firstname, s_lastname, s_email, s_phone) values
  ('Manoj', 'Pillai', 'manoj@example.com', 7404076892)
;


# Drop a primary key
describe students;
alter table students drop primary key;

describe students;

# Add primary key to a table
alter table students add primary key (s_firstname, s_phone);
-- alter table students add constraint pk_students primary key (s_firstname, s_phone);

describe students;


drop table if exists courses;
create table courses (
  c_id INT(10) NOT NULL AUTO_INCREMENT,
  c_name VARCHAR(30) NOT NULL,
  PRIMARY KEY (c_id))
;

insert into courses (c_name) values
  ('Computer Science'),
  ('Economics'),
  ('Arts'),
  ('Chemistry'),
  ('Astro Physics')
;

select * from courses;

drop table if exists enrollment;
create table enrollment (
  e_id        int(10) NOT NULL AUTO_INCREMENT,
  e_StudentID integer,
  e_CourseID  integer,
  e_year      year,
  PRIMARY KEY (e_id),
  FOREIGN KEY (e_StudentID) REFERENCES students (s_id)
    ON DELETE CASCADE,
  FOREIGN KEY (e_CourseID) REFERENCES courses (c_id)
    ON DELETE CASCADE
);

describe students;
describe courses;
describe enrollment;



insert into enrollment (e_StudentID, e_CourseID, e_year) values
  (1, 3, 2016),
  (3, 2, 2016),
  (2, 4, 2016),
  (4, 1, 2016)
;

select * from enrollment;

select * from students;

# Trying to insert a row when foreign key doesn't exist in primary key will fail
insert into enrollment (e_StudentID, e_CourseID, e_year)
values (5, 1, 2016);

# Referential Integrity on Delete
delete from students
where s_id = 2;

select * from enrollment;

