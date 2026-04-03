use adidb;
select * from EcommerceData;

------ Revenue analysis

-- Which categories and brands generate the highest revenue?

select
Category,
Brand,
round(sum(TotalAmount),2) TotalRevenue
from EcommerceData
group by Category, Brand
order by TotalRevenue desc;

-- What is monthly and weekly revenue trend

--- Monthly revenue trend
select
Year,
Month,
round(sum(TotalAmount), 2) TotalRevenue
from EcommerceData
group by Year, Month
order by Year, Month

---- weekly revenue trend

select
Day,
round(sum(TotalAmount), 2) TotalRevenue
from EcommerceData
group by Day
order by TotalRevenue desc


-- Which product are high revenue but low quantity(premium products)?

select
Product,
round(sum(TotalAmount),2) TotalReveue,
count(Quantity) totalQuantity
from EcommerceData
group by Product
order by TotalReveue desc

----Customer Satisfaction Analysis

-- Which product/Category has low ratings but high sales

---product has low ratings but high sales

select 
distinct Product,
round(avg(Rating),2) ratn,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by Product
order by totRev desc;

select distinct Product from EcommerceData;

---Category has low ratings but high sales

select 
Category,
round(avg(Rating), 2) ratn,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by Category
order by totRev desc;
---- Which product/Category has low ratings but high sales

select 
Product,
Category,
round(avg(Rating), 2) ratn,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by Product, Category
order by totRev desc;

-- Is there a relationship between price and rating?

----1st Method
select
case
	when Price < 1000 then 'Low Price'
	when Price between 1000 and 5000 then 'Medium Price'
	else 'High Price'
	End  as priceRange,
	count(*) totalOrders,
	round(avg(Rating),2) rtn
from EcommerceData
group by case
	when Price < 1000 then 'Low Price'
	when Price between 1000 and 5000 then 'Medium Price'
	else 'High Price'
	End 
order by rtn desc

-- 2nd Method

select
distinct Product,
round(Price,2) Price,
round(avg(Rating), 2) avgRtn
from EcommerceData
group by Product, Price
order by avgRtn desc

-- Which platform has the best and worst ratings?

select
distinct Platform,
round(Avg(Rating),2) rating
from EcommerceData
group by platform

-- OR

select
distinct Platform,
count(orderid) totOrders,
round(Avg(Rating),2) rating
from EcommerceData
group by platform
order by rating desc;

----- Platform performance

--Which platform contributs the most revenue

select 
Platform,
round(sum(TotalAmount),2) TotalRevenue,
count(*) totalOrders,
ROUND(AVG(Rating),2) AvgRtn
from EcommerceData
group by Platform
order by TotalRevenue desc;

-- Which platform has better customer satisfaction?
select
Platform,
count(*) totalOrders,
ROUND(AVG(Rating),2) AvgRtn
from EcommerceData
group by Platform
order by AvgRtn desc

-- Are certain products performing better on specific platform?

select
Platform,
Product,
count(*) totalOrders,
round(sum(TotalAmount), 2) TotRev,
round(avg(Rating), 2) AvgRtn,
ROW_NUMBER() over(partition by Platform order by round(sum(TotalAmount), 2) desc) rank
from EcommerceData
group by Platform, Product
having round(avg(Rating), 2) > 3
order by Platform, TotRev desc;

With Product_Rank as(
select
Platform,
Product,
count(*) totalOrders,
round(sum(TotalAmount), 2) TotRev,
round(avg(Rating), 2) AvgRtn,
Row_Number() over(partition by Platform order by round(sum(TotalAmount), 2) desc) rank
from EcommerceData
group by Platform, Product
)
select * from Product_Rank where rank <=3;

------Geographic Insight
-- Which cities generate the highest revenue?

select 
City,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by City
order by totRev desc;

-- Do some cities prefer specific categories or brands?
With City_Preference as(
select 
City,
Category,
Brand,
round(sum(TotalAmount),2) totRev,
round(avg(Rating),2) AvgRtn,
ROW_NUMBER() over(partition by City order by round(sum(TotalAmount),2) desc) rank
from EcommerceData
group by City,Category,Brand
)

select * from City_Preference where rank = 1

-- Are rating lower in certain cities;
select 
City,
count(*) totalOrders,
round(sum(TotalAmount),2) totRev,
round(avg(Rating),2) AvgRtn
from EcommerceData
group by City
order by AvgRtn desc;

----- Time Analysis
--Which day of the week has highest sales ?

select
Day,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by Day
order by totRev desc;

-- Are weekends driving more revenue

select
Week_analysis,
round(sum(TotalAmount),2) totRev
from EcommerceData
group by Week_analysis;

--Monthly trend:Growth or decline

with Monthly_data as (
select
year(OrderDate) year,
month(OrderDate) month,
round(sum(TotalAmount),2) TotalRevenue
from EcommerceData
group by year(OrderDate),
month(OrderDate)
)

select 
year,
month,
TotalRevenue,
Round(lag(TotalRevenue) over(order by year, month),2) previousMonth,
Round((TotalRevenue-lag(TotalRevenue) over(order by year, month))*100/
lag(TotalRevenue) over(order by year, month),2) growthPercentage
from Monthly_data;

-- 