select * from weekly_sales;
CREATE TABLE clean_weekly_sales AS
SELECT
  week_date,
  week(week_date) AS week_number,
  month(week_date) AS month_number,
  year(week_date) AS calendar_year,
  region,
  platform,
  CASE
    WHEN segment = 'null' THEN 'Unknown'
    ELSE segment
    END AS segment,
  CASE
    WHEN right(segment, 1) = '1' THEN 'Young Adults'
    WHEN right(segment, 1) = '2' THEN 'Middle Aged'
    WHEN right(segment, 1) IN ('3', '4') THEN 'Retirees'
    ELSE 'Unknown'
    END AS age_band,
  CASE
    WHEN left(segment, 1) = 'C' THEN 'Couples'
    WHEN left(segment, 1) = 'F' THEN 'Families'
    ELSE 'Unknown'
    END AS demographic,
  customer_type,
  transactions,
  sales,
  ROUND(
      sales / transactions,
      2
   ) AS avg_transaction
FROM weekly_sales;
select * from clean_weekly_sales limit 10;

## Data Exploration

## 1.Which week numbers are missing from the dataset?

create table seq100
(x int not null auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x + 50 from seq100;
select * from seq100;

create table seq52 as (select x from seq100 limit 52);
select distinct x as week_day from seq52 where x not in(select distinct week_number from clean_weekly_sales); 

select distinct week_number from clean_weekly_sales;

## 2.How many total transactions were there for each year in the dataset?
SELECT
  calender_year,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales group by calender_year;

## 3.What are the total sales for each region for each month?
select month_number,region,
sum(sales) as total_sales
from clean_weekly_sales
group by month_number,region;

## 4.What is the total count of transactions for each platform
select platform,
sum(transactions) as total_transaction
from clean_weekly_sales
group by platform;

## 5.What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_sales as(
select month_number,calender_year,platform,
sum(sales) as monthly_sales
from clean_weekly_sales
group by month_number,calender_year,platform
)
select month_number,calender_year,
round(100*max(case when platform = 'retail' then monthly_sales else null end)/sum(monthly_sales),2) as retail_percentage,
round(100*max(case when platform = 'shopify' then monthly_sales else null end)/sum(monthly_sales),2) as shopify_percentage
from cte_monthly_sales
group by month_number, calender_year
order by month_number,calender_year;

## 6.What is the percentage of sales by demographic for each year in the dataset?
select calender_year,demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales))
over (partition by demographic),2) as percentage
from clean_weekly_sales
group by calender_year,demographic;

 -- 7.Which age_band and demographic values contribute the most to Retail sales?
 select age_band,demographic,
 sum(sales) as total_sales
 from clean_weekly_sales
 where platform= 'retail'
 group by age_band,demographic
 order by total_sales desc;