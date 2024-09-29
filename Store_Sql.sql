use superstore;
SELECT 
    *
FROM
    superstore.super_data;

-- Profit segment,category wise
SELECT 
    segment,category, ROUND((SUM(profit)/(select sum(profit) from super_data))*100,2) AS "NRR%"
FROM
    super_data
GROUP BY segment,category;

-- Category wise profit and loss
with cte1 as (
select category,round(sum(sales),2) as Total_Sales,(select sum(profit) from super_data d where profit>0 and d.category=s.category) as Total_profit,
(select sum(profit) from super_data d where profit<=0 and d.category=s.category) as Total_loss,count(Postal_Code) as Total_deliver_Loc
 from super_data s group by category),
 cte2 as (
 SELECT category, Total_sales,round((Total_profit/Total_Sales)*100,2) as "Profit%",round((Total_loss/Total_Sales)*100,2) as "Loss%",Total_deliver_loc
 from cte1)
 select * from cte2;
 
 -- YOY revenue
 select YR,round(((revenue-lag(revenue) over(order by YR))/lag(revenue) over(order by YR))*100,2) as "Revenue Growth Rate%",profit,
 round(Revenue,0) as Revenue from (
 select extract(year from order_date) AS YR,sum(sales) as Revenue,sum(profit) as profit from super_data GROUP BY YR) t1 ;
 
 -- Total regional customer
 
SELECT 
    Region, COUNT(order_id) AS Total_orders
FROM
    (SELECT 
        region, order_id, SUM(sales) AS total_rev
    FROM
        super_data
    GROUP BY region , order_id) d1
GROUP BY region;
-- customer Life Time Value 
SELECT 
    *
FROM
    super_data;
SELECT 
    ROUND(AVG(sales), 2) AS CLV
FROM
    (SELECT 
        customer_id, SUM(sales) AS sales
    FROM
        super_data
    GROUP BY customer_id) t2;
 
 -- category contribution in revenue
SELECT 
    segment,
    category,
    sub_category,
    ROUND((SUM(profit) / (SELECT 
                    SUM(profit)
                FROM
                    super_data)) * 100,
            2) AS NRR_percent,
    concat(min(discount)*100,"-",max(discount)*100) AS Discount_Range,
    sum(quantity) as Quantity
FROM
    super_data
GROUP BY segment , category , sub_category;

-- Total SKU's in different category

SELECT 
    Category, sub_category, COUNT(DISTINCT product_id) AS SKU
FROM
    super_data
GROUP BY category , sub_Category;

-- Top customers who buys mostly;

select customer_name, round(sum(sales),0) as Total_order_Value from super_data group by customer_name;

-- order frequency by category
with cte as (
select category,sub_category,order_Date,lead(order_Date) over(partition by category,sub_category order by order_Date) as Next_order_Date from super_data),
cte2 as (
select category,sub_category,datediff(next_order_Date,order_Date) as order_freq from cte)
select category,sub_category,round(avg(order_freq),2) as Order_freq_in_days from cte2 group by category,sub_Category;