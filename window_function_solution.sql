# part1
use superstore;

# q1
select * from orders;

# for each customer, we need to find the total of each order
# look at only customer's first order
# only count the customers whose first order exceed 3000

# step3: count number of customers that satisfy the conditions
select count(distinct CustomerID) as numOfCustomer
from (
# step2: order the purchases
         select *,
                row_number() over (partition by CustomerID order by OrderDate) as numOfPurchase
         from (
# step1: create a table with the total of each order of each customer
                  select CustomerID,
                         OrderID,
                         OrderDate,
                         sum(Sales) as orderTotal
                  from orders
                  group by CustomerID, OrderID, OrderDate
                  ) as sub1
         ) as sub2
where numOfPurchase=1
and orderTotal>3000;

# q2

select *
from orders;

select *
from products;

# find the total of each productSubCategory according to orders table
# rank the productSubCategory within each product Category
# filter only the top 3 most ordered

# step3: show desiered output
select *
from (
# step2: rank the subCategory in each category
select *,
       rank() over (partition by ProductCategory order by Sales desc) as ranking
from (
# step1: create a total for each productSubCategory
select ProductCategory,
       ProductSubCategory,
       sum(OrderQuantity) as Sales
from products
inner join orders
on orders.ProductID=products.ProductID
group by ProductCategory, ProductSubCategory) as sub1) as sub2
where ranking<=3;

#q3

select * from orders;

select *
from orders
order by CustomerID,OrderID,OrderDate

# use lead to create nextPurchaseDate column
# calculate the difference between first and second purchase
# filter out the day difference bigger than 30 days

# step5: count number of customers
select count(distinct CustomerID) as numOfCustomers
from (

# step4: calculate difference between purchase date of purchase 1 and 2
    select *, datediff(nextPurchaseDate, OrderDate) as daysDifference
    from (

# step3: create a nextPurchaseDate column using lead
    select *, lead (OrderDate) over (partition by CustomerID) as nextPurchaseDate
    from (

# step2: create a numPurchase column for customer
    select *, row_number () over (partition by CustomerID order by OrderDate) as numPurchases
    from (

# step1: combine each order and each customer
    select CustomerID, OrderID, OrderDate
    from orders
    group by CustomerID, OrderID, OrderDate) as sub1) as sub2) as sub3
    where numPurchases = 1
    ) as sub4
where daysDifference<30;

#q4:
# cumulative sum of each customer and find out when they would reach a total spending of $5000+

select * from orders;

# step4: desired output

select numPurchase,
       count(distinct CustomerID) as numCustomers
from (

# step3: filter out the LTV <5000, and count num of time LTV >5000
         select *,
                row_number() over (partition by CustomerID order by OrderDate) as numTimeLTVGreater5000
         from (
# step2: the cumulative spending (LTV) of each customer and create a numPurchase column
                  select *,
                         row_number() over (partition by CustomerID order by OrderDate) as numPurchase,
                         sum(total)
                             over (partition by CustomerID rows between unbounded preceding and current row ) as LTV
                  from (
# step1: find the total of each order of each customer
                           select CustomerID,
                                  OrderID,
                                  OrderDate,
                                  sum(Sales) as total
                           from orders
                           group by CustomerID, OrderID, OrderDate) as sub1) as sub2
         where LTV > 5000) as sub3
where numTimeLTVGreater5000=1
group by numPurchase
order by numPurchase;

# part2

# q1
use classicmodels;

select * from orderdetails;
select * from products;

# step4: find numofOrders with more an 50% revenue
select productLine,
       count(distinct orderNumber) as numOfOrders
from (

# step3: find the percentage of sales by vintage or classic cars
select *,
       subTotal/orderTotal as Percent
from (

# step2: find the total of each order
select *,
       sum(subtotal) over (partition by orderNumber) as orderTotal
from (

# step1: find the revenue of each product in each order
select orderNumber,
       productCode,
       productLine,
       quantityOrdered*priceEach as subtotal
from products
inner join orderdetails using(productCode)) as sub1
) as sub2
where productLine in ('Vintage Cars','Classic Cars')) as sub3
where Percent>0.5
group by productLine;

# q2

# YOY = (current year revenue - previous year revenue ) / previous year revenue *100
select *
from orders

select *
from orderdetails;

# step 3: YOY
select *,
       (currentYearRevenue - previousYearRevenue) / previousYearRevenue *100 as YOY
from (

# step 2: create previousYearRevenue column
select *,
       lag(currentYearRevenue) over() as previousYearRevenue
from (

# step 1: find yearly revenue
         select year(orderDate)                  as orderYear,
                sum(quantityOrdered * priceEach) as currentYearRevenue
         from orders
                  inner join orderdetails o on orders.orderNumber = o.orderNumber
         group by year(orderDate)) as sub1) as sub2;


