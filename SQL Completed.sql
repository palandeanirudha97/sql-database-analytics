use classicmodels;
-- Q1 SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- a.	Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
select * from employees;
SELECT 
    employeeNumber, firstName, lastName
FROM
    employees
WHERE
    JobTitle = 'sales Rep'
        AND reportsTo = 1102;
        
-- b.	Show the unique productline values containing the word cars at the end from the products table.

SELECT 
    *
FROM
    productlines;
SELECT 
    productline
FROM
    Productlines
WHERE
    productline LIKE ('%cars');
    
/*Q2. CASE STATEMENTS for Segmentation

. a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
                        "North America" for customers from USA or Canada
                        "Europe" for customers from UK, France, or Germany
                        "Other" for all remaining countries
     Select the customerNumber, customerName, and the assigned region as "CustomerSegment".
     */
     
select * from customers;

select Customername,Customernumber,
case 
when country IN("USA","Canada") then "north america"
when country IN("UK", "France", "Germany") then "europe"
else "Other"
end as CustomerSegment
from Customers;

/* Group By with Aggregation functions and Having clause, Date and Time functions

a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders
*/
select * from orderdetails;
SELECT 
    productcode, SUM(quantityOrdered) AS Total_ordered
FROM
    orderdetails
GROUP BY productCode
ORDER BY Total_ordered DESC
LIMIT 10;

/*  b.Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each 
month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order. (Refer Payments table). */
select * from payments;
SELECT 
    MONTHNAME(paymentDate) AS month_name,
    COUNT(checkNumber) AS num_payments
FROM 
    Payments
GROUP BY 
    MONTHNAME(paymentDate)
HAVING 
    COUNT(checkNumber) > 20
ORDER BY 
    num_payments DESC;
    
/*
Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

Create a new database named and Customers_Orders and add the following tables as per the description

a.	Create a table named Customers to store customer information. Include the following columns:

customer_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
first_name: This should be a VARCHAR(50) to store the customer's first name.
last_name: This should be a VARCHAR(50) to store the customer's last name.
email: This should be a VARCHAR(255) set as UNIQUE to ensure no duplicate email addresses exist.
phone_number: This can be a VARCHAR(20) to allow for different phone number formats.

Add a NOT NULL constraint to the first_name and last_name columns to ensure they always have a value.

b.	Create a table named Orders to store information about customer orders. Include the following columns:

    	order_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
customer_id: This should be an integer referencing the customer_id in the Customers table  (FOREIGN KEY).
order_date: This should be a DATE data type to store the order date.
total_amount: This should be a DECIMAL(10,2) to store the total order amount.
     	
Constraints:
a)	Set a FOREIGN KEY constraint on customer_id to reference the Customers table.
b)	Add a CHECK constraint to ensure the total_amount is always a positive value.
*/

create database Customers_Orders;
use Customers_Orders;
create table customers
(
customer_id int primary key auto_increment,
first_name VARCHAR(50) not null,
last_name VARCHAR(50) not null, 
email VARCHAR(255) UNIQUE key,
phone_number VARCHAR(20)
);
select * from customers;
desc Customers;

create table Orders
(
order_id int Primary key auto_increment,
customer_id int,
order_date DATE,
total_amount DECIMAL(10,2),
foreign key(customer_id)  references Customers(customer_id)
);
select * from Orders;
desc orders;


/*Q5. JOINS
a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
*/

use classicmodels;
select * from customers;
select * from orders;

select 
c.country,
count(o.orderNumber) as order_count
from customers c
join orders o 
on c.customerNumber = o.customerNumber
group by c.country
order by order_count desc
limit 5;

/*Q6. SELF JOIN
a. Create a table project with below fields.


●	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
●	FullName: varchar(50) with no null values
●	Gender : Values should be only ‘Male’  or ‘Female’
●	ManagerID: integer 
*/

create table project
(
EmployeeID int PRIMARY KEY AUTO_INCREMENT,
FullName varchar(50) not null ,
Gender enum("Male","Female"),
ManagerID int
);
insert into project
(FullName,Gender,ManagerID)
values
("Pranaya","Male",3),
("Priyanka","Female",1),
("Preety","Female",null),
("Anurag","Male",1),
("Sambit","male",1),
("Rajesh","male",3),
("Hina","female",3);

select * from project;
select 
p1.fullname as manager_name,
p2.fullname as emp_name
from project p1
join project p2
on p1.employeeID =  p2.managerID
order by Manager_name asc;

/*Q7. DDL Commands: Create, Alter, Rename
a. Create table facility. Add the below fields into it.
●	Facility_ID
●	Name
●	State
●	Country
i) Alter the table by adding the primary key and auto increment to Facility_ID column.
ii) Add a new column city after name with data type as varchar which should not accept any null values.
*/

create table facility
(
Facility_ID int,
Name varchar(50),
State varchar(50),
Country varchar(50)
);

desc facility;
alter table facility
Modify facility_ID int auto_increment primary key;
desc facility;
 Alter table facility
 add column city varchar(70) not null after name;
 
 /*Q8. Views in SQL
a. Create a view named product_category_sales that provides insights into sales performance by product category. This view should
 include the following information:
productLine: The category name of the product (from the ProductLines table).

total_sales: The total revenue generated by products within that category (calculated by summing the orderDetails.quantity * orderDetails.priceEach 
for each product in the category).

number_of_orders: The total number of orders containing products from that category.

(Hint: Tables to be used: Products, orders, orderdetails and productlines)*/
use classicmodels;
SELECT * FROM product_category_sales;
/*Q9. Stored Procedures in SQL with parameters

a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
Tables: Customers, Payments*/
select * from customers;
select * from payments;
USE `classicmodels`;
DROP procedure IF EXISTS `get_country_payments`;

USE `classicmodels`;
DROP procedure IF EXISTS `classicmodels`.`get_country_payments`;
;

DELIMITER $$
USE `classicmodels`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_country_payments`(x int,y varchar(50))
BEGIN
select 
x as "year",
y as "country",
concat(sum(p.amount)/1000,1,`K`) as `total amount`
from payments p
join 
customers c on p.customerNumber - c.customerNumber
Where
Year(p.paymentDate) = x
And c.country = y
Group by 
Year(p.paymentDate),c.country;
END$$

DELIMITER ;
;


CALL Get_country_payments(2003,"USA");
call get_Country_payments(2003,"France");

/*
Q10. Window functions - Rank, dense_rank, lead and lag
a) Using customers and orders tables, rank the customers based on their order frequency
*/
select * from customers;
select * from orders;

/*Q13. TRIGGERS
Create the table Emp_BIT. Add below fields in it.
●	Name
●	Occupation
●	Working_date
●	Working_hours

Insert the data as shown in below query.
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  
 
Create before insert trigger to make sure any new value of Working_hours, 
if it is negative, then it should be inserted as positive.
*/
drop table emp_bit;
create table emp_bit
(
name varchar(50),
occupation varchar(50),
working_date date,
working_hours int
);

insert into emp_bit
values 
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', -10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', -14),  
('Brayden', 'Teacher', '2020-10-04', -12),  
('Antonio', 'Business', '2020-10-04', 11);
select * from emp_bit;
 DROP TRIGGER IF EXISTS `classicmodels`.`emp_bit_BEFORE_INSERT`;

DELIMITER $$
USE `classicmodels`$$
CREATE DEFINER = CURRENT_USER TRIGGER `classicmodels`.`emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW
BEGIN
if new.working_hours < 0 then 
set new.Working_hours = abs(new.working_hours);
end if;

END$$
DELIMITER ;


truncate emp_bit;
select * from emp_bit;
insert into emp_bit 
values 
("sandy", "Lawyer", "2020-10-3" , -9);

/*Q10. Window functions - Rank, dense_rank, lead and lag
a) Using customers and orders tables, rank the customers based on their order frequency*/

use classicmodels;
select * from customers;
select * from orders;

SELECT Customer_Name,Order_Count,
DENSE_RANK() OVER (ORDER BY Order_Count DESC) AS order_frequency_rnk
FROM (SELECT c.customerName AS Customer_Name, 
COUNT(o.orderNumber) AS Order_Count
FROM customers c JOIN 
orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName) AS Rank_column
ORDER BY Order_Count DESC;

/*b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change.
 Format the YoY values in no decimals and show in % sign.*/
 
 select year (orderdate) year, monthname(orderdate) Month,
 Count(ordernumber) "Total order",
concat(round(((count(ordernumber)-lag(count(ordernumber),1,0) over())/(lag(count(ordernumber),1,0) over())*100),0),"%" ) as "% YOY change"
From Orders
group by month, Year
order by Year(orderdate) asc;

/*Q11.Subqueries and their applications

a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.
*/
Select productline,Count(buyprice) as Total
From products 
where buyprice > (select avg(buyprice) from products)
group by productline
order by Total desc;

/*Q12.ERROR HANDLING in SQL*/
drop table if exists emp_eh;
create table emp_eh
(
EmpID int primary key,
EmpName varchar(50),
EmailAddress varchar(100)
);
insert into emp_eh
values
(1, "Sanjili Kanhere" , "sanjilikanhere8868@gmail.com")

USE `classicmodels`;
DROP procedure IF EXISTS `emp_eh`;

DELIMITER $$
USE `classicmodels`$$
CREATE PROCEDURE `emp_eh` (P_EmpID int,P_EmpName varchar(50), P_Emailid varchar(100))
BEGIN
Declare exit handler for sqlexception
begin
Select 'Error occurred' as Message;
end;
insert into emp_eh(EmpID, EmpName, Emailaddress)
values (P_EmpID, P_EmpName, P_Emailid);
Select 'Insert successful' as message;
END$$

DELIMITER ;
truncate emp_eh;
call emp_eh(1,"Sanjili Kanhere", "sanjilikanhere8868@gmail.com");
call emp_eh(2,"Viratkohli", "Viratkohli5@gmail.com");

select * from emp_eh;