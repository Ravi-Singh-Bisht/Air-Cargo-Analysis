use aircargo;
# 1)ER Diagram

Alter table customer 
ADD primary key (customer_id);

Alter table routes
ADD primary key (route_id);

Alter table ticket_details
Add foreign key (customer_id) references customer(customer_id);

Alter table passengers
Add Foreign Key (customer_id) references customer(customer_id),
Add Foreign Key (route_id) references routes(route_id);

# 2)Create route detail table  and Check Contraint Distance and Flight number (Not Null)

CREATE TABLE `routes` (
  `route_id` int NOT NULL,
  `flight_num` int DEFAULT NULL,
  `origin_airport` text,
  `destination_airport` text,
  `aircraft_id` text,
  `distance_miles` int DEFAULT NULL,
  PRIMARY KEY (`route_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Alter table routes
Add Check (flight_num is not null),
Add Check (distance_miles >0);

/* 3)Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. 
Take data  from the passengers_on_flights table. */

select P.Customer_ID,P.route_ID,C.first_name,C.last_name from passengers as P
left join customer as C
on P.customer_id = C.customer_id
where route_id between 01 and 25;

/* 4)Write a query to identify the number of passengers and total revenue in business class from 
the ticket_details table. */

Select Count(Customer_id) as Total_Passengers,Sum(price_per_ticket * no_of_tickets) as Total_Revenue 
from ticket_details
where class_id = "Bussiness";

/* 5)Write a query to display the full name of the customer by extracting the first name and last 
name from the customer table; */

Select Concat(First_Name," ",Last_Name) as Full_Name from Customer;

/* 6) Write a query to extract the customers who have registered and booked a ticket. Use data 
from the customer and ticket_details tables. */

Select T.customer_id,T.class_id,C.First_Name,C.Last_Name from 
ticket_details as T Left Join Customer as C
on T.customer_id = C.customer_id;

/*7)Write a query to identify the customer’s first name and last name based on their customer ID 
and brand (Emirates) from the ticket_details table */

Select T.Customer_ID,C.First_Name,C.Last_Name From
Ticket_Details as T Left join Customer as C
on T.customer_id = C.customer_Id
where T.brand = "Emirates";


/* 8)Write a query to identify the customers who have travelled by Economy Plus class using 
Group By and Having clause on the passengers_on_flights table. */

Select P.customer_id,C.First_Name,C.Last_Name,P.class_ID from 
passengers as P Left join Customer as C
on P.customer_ID = C.Customer_ID
Group By 1,2,3
Having P.Class_ID = "Economy Plus";

# 9)Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table. 

Select Sum(price_per_ticket) as Total_Revenue,
IF(Sum(price_per_ticket)>10000,"Revenue Crossed 100000","Revenue Does not Crossed 10000") as Info 
from ticket_details; 

# 10)Write a query to create and grant access to a new user to perform operations on a database.

Create user ravibisht@localhost;
Grant all on aircargo.* to ravibisht@localhost;

/*  11) Write a query to find the maximum ticket price for each class using window functions on the 
ticket_details table. */

Select class_id,price_per_ticket,
Max(Price_Per_ticket) Over (partition by Class_ID)
from ticket_details;
-- Alternative Method:
Select distinct Class_ID ,Price_per_Ticket as Max_Price from (
Select *,
Rank() over (partition by Class_ID Order by price_per_ticket DESC) as Max_Rank
from ticket_details) ticket_details
where Max_Rank=1;

/* 12)Write a query to extract the passengers whose route ID is 4 by improving the speed and 
performance of the passengers_on_flights table. */

Select R.Route_ID,C.First_Name,C.Last_Name,R.distance_miles,P.travel_date
From Routes as R Left join Passengers as P
on R.route_ID = P.Route_ID
Join Customer As C
Using (Customer_ID)
Where R.Route_ID= 4
Order by distance_miles;

# 13)For the route ID 4, write a query to view the execution plan of the passengers_on_flights table

Select C.First_Name,C.Last_Name,P.aircraft_ID,P.depart,P.arrival,P.flight_num,P.travel_date
From Routes as R Left join Passengers as P
on R.route_ID = P.Route_ID
Join Customer As C
Using (Customer_ID)
Where R.Route_ID= 4
Order by distance_miles;

/* 14. Write a query to calculate the total price of all tickets booked by a customer across different 
aircraft IDs using rollup function. */

Select aircraft_id ,Sum(Price_Per_ticket) as Total_Price
from ticket_details
Group by aircraft_ID with rollup ;

# 15)Write a query to create a view with only business class customers along with the brand of airlines. 

Create view luxury as
Select T.Customer_ID,C.First_name,C.Last_Name,T.Class_ID,T.Brand
from ticket_details as T Left Join Customer as C
on T.Customer_ID = C.Customer_ID
Where T.Class_ID = "Bussiness";

Select * from luxury;

/* 16)Write a query to create a stored procedure to get the details of all passengers flying between  a range of routes defined 
in run time. Also, return an error message if the table doesn't exist----CREATION OF STORED PROCEDURE QUERY-.  */

Delimiter $$
Create Procedure Range_Routes(In R1 int ,In R2 int)
BEGIN
Select C.Customer_ID,R.*,C.First_Name,C.Last_Name from 
Routes as R Left join Passengers as P
on R.Route_ID = P.Route_ID
Join Customer as C
Using (Customer_ID)
Where R.Route_ID Between R1 and R2;
END $$

Delimiter $
Call Range_Routes(4,10);

/* 17)Write a query to create a stored procedure that extracts all the details from the routes table 
where the travelled distance is more than 2000 miles */

Delimiter $$
Create Procedure Travel_Distance()
BEGIN
Select * from Routes 
where distance_miles>2000;
END $$

Delimiter $
Call Travel_Distance()

/* 18)Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500,
and long-distance travel (LDT) for >6500. */

Delimiter $$
Create Procedure Distance_Catagory()
BEGIN
Select *,
Case
When Distance_Miles >=0 and Distance_miles<=2000 Then "Short Distance Travel"
When Distance_Miles >2000 and Distance_miles<=6500 Then "Intermediate Distance Travel"
Else "long Distance Travel"
end as Distance_Catagory
from Routes;
END $$

Delimiter $
Call Distance_Catagory()

/* 19)Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the 
specific class using a stored function in stored procedure on the ticket_details table. 
Condition: • If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No */

Delimiter $$
Create Function Complimentary(Class_ID varchar(40))
Returns varchar(20)
Deterministic
Begin
Declare Comp_service varchar(20);
IF Class_ID ="Bussiness" or Class_ID ="Economy Plus" Then
Set Comp_service = "Yes";
Else
Set Comp_service = "No";
End IF;
Return (Comp_service);
End $$

Delimiter $
Select p_Date,Customer_id,Class_id,Complimentary(Class_ID) from ticket_details;

# 20)Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.

Delimiter $$
Create Procedure First_Record()
Begin
Declare a varchar(20);
Declare b varchar(20);
Declare c int;
Declare Cursor_1 cursor for Select First_Name,Last_Name,Customer_ID from Customer
where Last_Name= "Scott";
Open Cursor_1;
Fetch Cursor_1 into a,b,c;
Select a as First_Name,b as Last_Name,c as Customer_ID;
CLose cursor_1;
End $$

Delimiter ;
Call First_record()













