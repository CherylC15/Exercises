show databases;
use sakila;
show tables;
select * from actor;

# Movie Analysis - Airbnb

#################################################################################
# Assignment Due Date: Jul 13 @ 06pm                                            #
# Try to answer question in one query, multi-solution and comments are welcome! #
#################################################################################

# Manage a chain of Movie Rental Stores
# Introduction
# -Data: Dataset download link: https://weclouddata.s3.amazonaws.com/datasets/movie_rental_sakila.zip
# In this project, you will write more advanced queries on a database designed to resemble a real-world database system - MySQL’s Sakila Sample Database.
# The development of the Sakila sample database began in early 2005. Early designs were based on the database used in the Dell whitepaper (Three Approaches to MySQL Applications on Dell PowerEdge Servers).
# The Sakila sample database is designed to represent a DVD rental store. The Sakila sample database still borrows film and actor names from the Dell sample database.

# Problem Description
# You’re writing SQL to manage a chain of movie rental stores, for example,
# -Track the inventory level and determine whether the rental can happen
# -Manage customer information and identify loyalty customers
# -Monitor customers’ owing balance and find overdue DVDs

# This project can be considered as a typical retail-related business case, because it has the main metrics you can find in any retailer’s real database, such Walmart, Shoppers, Loblaws, Amazon...

# Key Metrics:
# -Production information (in this project, it is the film)
# -Sales information
# -Inventory information
# -Customer behavior information
########################################################################################################################
# Exercise 1
# 1. Before doing any exercise, you should explore the data first.
# -For Exercise 1, we will focus on the product, which is the film (DVD) in this project.
# -Please explore the product-related tables (actor, film_actor, film, language, film_category, category) by using SELECT * – Do not forget to limit the number of records

# Use table FILM to solve questions as below:
# 1.What is the largest rental_rate for each rating?
select * from film limit 5;
select distinct rating, max(rental_rate)
from film
group by rating
order by rating desc;

# 2.How many films in each rating category?
select * from film limit 5;
select rating, count(film_id)
from film
group by rating;

# 3.Create a new column film_length to segment different films by length:
# -length < 60 then ‘short’; length < 120 then standard’; length >=120 then ‘long’, then count the number of films in each segment.
select case when length < 60 then 'short'
            when length >= 120 then 'long'
            else 'standard' end as film_length,
count(*)
from film
group by film_length;

# Use table ACTOR to solve questions as below:
# 1.Which actors have the last name ‘Johansson’
select first_name, last_name
from actor
where last_name ='Johansson';

# 2.How many distinct actors’ last names are there?
select count(distinct last_name)
from actor;

# 3.Which last names are not repeated? Hint: use COUNT() and GROUP BY and HAVING
select last_name, count(last_name)
from actor
group by last_name
having count(last_name) =1

# 4.Which last names appear more than once?
select last_name, count(last_name)
from actor
group by last_name
having count(last_name) >1;

# Use table FILM_ACTOR to solve questions as below:
# 1.Count the number of actors in each film, order the result by the number of actors with descending order
describe film_actor;
select * from film_actor limit 10;
select film_id, count(actor_id)
from film_actor
group by film_id
order by count(actor_id) desc;

# 2.How many films each actor played in?
select actor_id, count(distinct film_id)
from film_actor
group by actor_id;

########################################################################################################################
# Exercise 2 (for after the Joins & Unions lecture):
# 1.Before doing any exercise, you should explore the data first.
# -For Exercise 1, we will focus on the product, which is the film (DVD) in this project.
# -Please explore the product-related tables (actor, film_actor, film, language, film_category, category) by using SELECT * – Do not forget to limit the number of records;
# 2.Find language name for each film by using table Film and Language;
select film_id, l.name
from film left join language l on l.language_id = film.language_id;

# 3.In table Film_actor, there are actor_id and film_id columns.
# I want to know the actor name for each actor_id, and film tile for each film_id. Hint: Use multiple table Inner Join
select f.title, a.first_name, a.last_name
from film_actor inner join actor a on film_actor.actor_id = a.actor_id
                inner join film f on film_actor.film_id = f.film_id;

# 4.In table Film, there are no category information. I want to know which category each film belongs to.
# Hint: use table film_category to find the category id for each film and then use table category to get category name
select f.title, c.name category
from film f inner join film_category fc on f.film_id = fc.film_id
          inner join category c on fc.category_id = c.category_id;

# 5.Select films with rental_rate > 2. Select films with rating G, PG-13 or PG. Present both results as one combine table.
select film_id, title
from film
where rental_rate > 2 and rating in ('G', 'PG-13', 'PG');

########################################################################################################################
# Exercise 3:
# Let’s look at sales first:
describe rental;
select * from rental limit 5;
select distinct month(rental_date) from rental;
# The rental table contains one row for each rental of each inventory item with information about who rented what item, when it was rented, and when it was returned
# The rental table refers to the inventory, customer, and staff tables and is referred to by the payment table
# Rental_id: A surrogate primary key that uniquely identifies the rental

# 1.How many rentals (basically, the sales volume) happened from 2005-05 to 2005-08? Hint: use date between '2005-05-01' and '2005-08-31';
select count(rental_id)
from rental
where rental_date between '2005-05-01' and '2005-08-31';

# 2.I want to see the rental volume by month. Hint: you need to use substring function to create a month column, e.g.
select  count(rental_id), year(rental_date) yr, month(rental_date) mth
from rental
group by yr, mth;

# 3.Rank the staff by total rental volumes for all time period. I need the staff’s names, so you have to join with staff table
SET @row_number = 0;
select first_name, last_name, count(rental_id)
from rental left join staff s on s.staff_id = rental.staff_id
group by s.staff_id
order by count(rental_id) desc;

# How about inventory? (Provide separate scripts for each question below).
# 4.Create the current inventory level report for each film in each store?
# -The inventory table has the inventory information for each film at each store
# --inventory_id - A surrogate primary key used to uniquely identify each item in inventory, so each inventory id means each available film.
select * from inventory limit 10;
select film_id, count(*), store_id
from inventory
group by film_id, store_id;

# 5.When you show the inventory level to your manager, you manager definitely wants to know the film name. Please add film name for the inventory report.
# -Tile column in film table is the film name
# -Should you use left join or inner join? – this depends on how you want to present your result to your manager, so there is no right or wrong answer
# -Which table should be your base table if you want to use left join?
select i.film_id, f.title, count(i.film_id), i.store_id
from inventory i left join film f on f.film_id = i.film_id
group by film_id, store_id;

# 6.After you show the inventory level again to your manager, you manager still wants to know the category for each film. Please add the category for the inventory report.
# -Name column in category table is the category name
# -You need to join film, category, inventory, and film_category
select fc.film_id, f.title, c.name, count(i.film_id) as InventoryLevel, i.store_id
from film f left join inventory i on f.film_id = i.film_id
            left join film_category fc on f.film_id = fc.film_id
            left join category c on fc.category_id = c.category_id
group by 1,5;

-- this is incompatible with sql_mode=only_full_group_by
-- https://stackoverflow.com/questions/23921117/disable-only-full-group-by
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT f.title as film_name,
       f.film_id,
       c.name as category,
       i.store_id,
       COUNT(i.film_id) as num_of_stock
FROM film as f LEFT JOIN inventory as i
    ON i.film_id=f.film_id
LEFT JOIN film_category as fc
    ON f.film_id=fc.film_id
LEFT JOIN category as c
    ON fc.category_id=c.category_id
GROUP BY 2,4;

# 7.Your manager is happy now, but you need to save the query result to a table, just in case your manager wants to check again, and you may need the table to do some analysis in the future.
# -Use CREATE statement to create a table called as inventory_rep
drop table if exists inventory_rep;

create table inventory_rep (
    film_id int,
    title varchar(30),
    Category varchar(20),
    InventoryLevel int,
    store_od int
);

insert into inventory_rep
select fc.film_id, f.title, c.name, count(i.film_id) as InventoryLevel, i.store_id
from film f left join inventory i on f.film_id = i.film_id
            left join film_category fc on f.film_id = fc.film_id
            left join category c on fc.category_id = c.category_id
group by 1,5;


# 8.Use your report to identify the film which is not available in any store, and the next step will be to notice the supply chain team to add the film into the store
SELECT film_id
FROM
 (
   SELECT film_id
   FROM film f
   UNION ALL
   SELECT film_id
   FROM inventory i
)  sub
GROUP BY film_id
HAVING COUNT(*) = 1;

# Let’s look at Revenue:
# -The payment table records each payment made by a customer, with information such as the amount and the rental being paid for. Let us consider the payment amount as revenue and ignore the receivable revenue part
# -rental_id: The rental that the payment is being applied to. This is optional because some payments are for outstanding fees and may not be directly related to a rental – which means it can be null;

# 9.How much revenues made from 2005-05 to 2005-08 by month?
describe payment;
select * from payment limit 5;
select year(payment_date) yr, month(payment_date) mth, sum(amount)
from payment
where year(payment_date)=2005 and month(payment_date) between 5 and 8
group by yr, mth;

# 10.How much revenues made from 2005-05 to 2005-08 by each store?
select year(payment_date) yr, month(payment_date) mth, s.staff_id as store, sum(amount)
from rental r left join payment on payment.rental_id = r.rental_id
              left join staff s on payment.staff_id = s.staff_id
where year(payment_date)=2005 and month(payment_date) between 5 and 8
group by yr, mth, s.staff_id;

# 11.Say the movie rental store wants to offer unpopular movies for sale to free up shelf space for newer ones.
# Help the store to identify unpopular movies by counting the number of rental times for each film.
# Provide the film id, film name, category name so the store can also know which categories are not popular.
# Hint: count how many times each film was checked out and rank the result by ascending order.
-- count rental time, order by count asc
select f.film_id, f.title, c.name as Category, count(r.inventory_id) as RentalCount
from rental r left join inventory i on r.inventory_id = i.inventory_id
              left join film f on f.film_id = i.film_id
              left join film_category fc on f.film_id = fc.film_id
              left join category c on fc.category_id = c.category_id
group by i.film_id
order by RentalCount;