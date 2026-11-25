
CREATE TABLE Sales_Analysis (
    Order_ID PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(100),
    Region VARCHAR(50),
    City VARCHAR(100),
    Segment VARCHAR(100),
    Channel VARCHAR(100),
    Category VARCHAR(100),
    Subcategory VARCHAR(50),
    Product_ID VARCHAR(100),
    Quantity DECIMAL(10,2),
    Unit_Price_INR DECIMAL(12,2),
    Discount DECIMAL(12,2),
    Sales_INR DECIMAL(12,2),
    Discount_Amount_INR DECIMAL(12,2),
    Net_Sales_INR DECIMAL(12,2),
    Cost_INR DECIMAL(12,2),
    Profit_INR DECIMAL(12,2),
    Shipping_Days INT,
    Returned VARCHAR(10),
    Customer_Satisfaction INT,
    Payment_Method VARCHAR(50)
);

Select * from Sales_Analysis;

-----Data Cleaning

Alter Table Sales_Analysis Alter Column Order_ID type VARCHAR(20);

------ Count total rows
Select count(*) as total_count_order_id 
from Sales_Analysis;

------- Check column names and data types
DESCRIBE Sales_Analysis;

SELECT *
FROM Sales_Analysis
WHERE Order_Date IS NULL
   OR Customer_ID IS NULL
   OR Region IS NULL
   OR City IS NULL
   OR Segment IS NULL
   OR Channel IS NULL
   OR Category IS NULL
   OR Subcategory IS NULL
   OR Product_ID IS NULL
   OR Quantity IS NULL
   OR Unit_Price_INR IS NULL
   OR Discount IS NULL
   OR Sales_INR IS NULL
   OR Discount_Amount_INR IS NULL
   OR Net_Sales_INR IS NULL
   OR Cost_INR IS NULL
   OR Profit_INR IS NULL
   OR Shipping_Days IS NULL
   OR Returned IS NULL
   OR Customer_Satisfaction IS NULL
   OR Payment_Method IS NULL;

-----Find All Unique Regions in the Sales Table.

SELECT DISTINCT Region
FROM Sales_Analysis;

---
CREATE TABLE Sales_Analysis_Backup AS
SELECT *
FROM Sales_Analysis;

-----
SELECT Order_ID,Sales_INR,
Sum(Sales_INR)
	over(partition by Region
	order by Order_Date)as running_Sales
	from Sales_Analysis;
	
------Calculate Running Sales for Every Order.

SELECT
    Order_ID,
    Order_Date,
    Region,
    Sales_INR,
    SUM(Sales_INR) OVER (
        PARTITION BY Region
        ORDER BY Order_Date, Order_ID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS Running_Sales
FROM Sales_Analysis;

-----Query using ROW_NUMBER()
SELECT Region
FROM (
    SELECT
        Region,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY Region
        ) AS rn
    FROM Sales_Analysis
) AS Ranked_Regions
WHERE rn = 1;

---------Assign row numbers to all orders.
select Order_ID,
    Order_Date,
    Region,
    Sales_INR,
	row_number() over(Order by Order_ID)
	as row_number
	FROM Sales_Analysis;

------Rank all orders based on sales (highest first).

select Order_ID,
    Order_Date,
    Sales_INR,
	rank() over(order by Order_ID desc)as
	Sales_INR 
	FROM Sales_Analysis;
	
------Find dense rank of each order based on profit.

select Order_ID,
    Order_Date,
    profit_INR,
	dense_rank() over(order by Order_ID desc)as
	profit_INR 
	FROM Sales_Analysis;	

-----Calculate total sales for each category.
select Order_ID,
        Category,
		sales_INR,
		SUM(sales_INR) OVER(PARTITION BY sales_INR)AS
		TOTAL_sales_INR
		FROM Sales_Analysis;

-------Count total orders placed by each customer.
SELECT
    Order_ID,
    Customer_ID,
    COUNT(*) OVER (
        PARTITION BY Customer_ID
    ) AS Customer_Total_Orders
FROM Sales_Analysis;

--------12. Calculate average customer satisfaction by region.

SELECT
    Order_ID,
    Customer_Satisfaction,                
    ROUND(
        AVG(Customer_Satisfaction) OVER (
            PARTITION BY Region
        ), 3                                --NOTE:- ROUND(value, 3) → 3 decimal places.---
    ) AS Customer_Total_Satisfaction
FROM Sales_Analysis;

-----Calculate running sales for all orders.
SELECT
    Order_ID,
    Order_Date,
    Sales_INR,
    SUM(Sales_INR) OVER (
        ORDER BY Order_Date, Order_ID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS Running_Sales
FROM Sales_Analysis;

----Find previous order sales using LAG.
select Order_ID,
       Order_Date,
	   sales_INR,
		LAG(sales_INR) OVER(ORDER BY sales_INR, Order_Date)AS
		TOTAL_sales_INR
		FROM Sales_Analysis;

-----alculate the difference between current and previous sales.
SELECT
    Order_ID,
    Sales_INR,
    LAG(Sales_INR) OVER (
        ORDER BY Order_Date, Order_ID
    ) AS Previous_Sales,
    Sales_INR - LAG(Sales_INR) OVER (
        ORDER BY Order_Date, Order_ID
    ) AS Sales_Difference
FROM Sales_Analysis;
	
-----Divide orders into 4 sales groups using NTILE.
SELECT
    Order_ID,
    Sales_INR,
    NTILE(10) OVER (
        ORDER BY Sales_INR DESC
    ) AS Sales_Group
FROM Sales_Analysis;