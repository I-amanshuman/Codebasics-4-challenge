-- Q1 --
select *
from gdb023.dim_customer
where customer = "Atliq Exclusive"
and region = "APAC";


-- Q2 --
with 
	cte1 as(
	select count(distinct(product_code)) as unique_products_2020 
    from gdb023.fact_sales_monthly
	where fiscal_year = "2020"),
	cte2 as(
	select count(distinct(product_code)) as unique_products_2021
    from gdb023.fact_sales_monthly
	where fiscal_year = "2021")

select unique_products_2020, unique_products_2021, 
((unique_products_2021 - unique_products_2020)/unique_products_2020)*100 as percentage_chg
from cte1, cte2;


-- Q3 --
select count(distinct(product_code)) as product_count, segment
from gdb023.dim_product
group by segment
order by 1 desc;


-- Q4 --
with 
	cte1 as(
	select count(distinct(fsm.product_code)) as unique_products_2020, dp.segment as segment2020
    from gdb023.fact_sales_monthly fsm join gdb023.dim_product dp 
    on fsm.product_code=dp.product_code
	where fiscal_year = "2020"
    group by segment),
	cte2 as(
	select count(distinct(fsm.product_code)) as unique_products_2021, dp.segment as segment2021
    from gdb023.fact_sales_monthly fsm join gdb023.dim_product dp 
    on fsm.product_code=dp.product_code
	where fiscal_year = "2021"
    group by segment)

select unique_products_2020, unique_products_2021, cte2.segment2021, (unique_products_2021-unique_products_2020) as difference
from cte1 join cte2
on cte1.segment2020 = cte2.segment2021
group by cte2.segment2021
order by difference desc;

-- Q5--
with cte3 as
	(select dp.product, dp.product_code, (fmc.manufacturing_cost) as manufacturing_cost
	from gdb023.dim_product dp join gdb023.fact_manufacturing_cost fmc on
	dp.product_code = fmc.product_code
    order by 3 desc
	)
    
(select product, product_code, manufacturing_cost
from cte3
order by 3 desc
limit 5)
UNION
(select product, product_code, manufacturing_cost
from cte3
order by 3 asc
limit 5);
   
-- Q6 --
select pid.customer_code, dc.customer, round(avg(pid.pre_invoice_discount_pct)*100, 2) as average_disc_pct
from gdb023.fact_pre_invoice_deductions pid join gdb023.dim_customer dc on
pid.customer_code = dc.customer_code
where pid.fiscal_year = "2021" AND dc.market = "India"
group by 1, 2
order by 3 desc
limit 5;  


-- Q7 --
select concat(monthname(fsm.date), " ", year(fsm.date)) as Month_Year, (fsm.fiscal_year) as Fiscal_Year,  sum(fsm.sold_quantity*fgp.gross_price) as Gross_Sales_Amount
from gdb023.fact_sales_monthly fsm join gdb023.fact_gross_price fgp
on fsm.product_code = fgp.product_code join gdb023.dim_customer dc
on fsm.customer_code = dc.customer_code
where dc.customer = "Atliq Exclusive"
group by 1,2
order by 2;


-- Q8 --
with temp as
(
select *,
CASE
	WHEN month(date) BETWEEN 9 AND 11 THEN "Q1"
    WHEN month(date) = 12 OR (month(date) BETWEEN 1 AND 2) THEN "Q2"
    WHEN month(date) BETWEEN 3 AND 5 THEN "Q3"
    ELSE "Q4"
END as Qtr
from gdb023.fact_sales_monthly
)
select Qtr as Quarter, sum(sold_quantity) as total_sold_quantity
from temp
where fiscal_year = "2020"
group by 1
order by 2 desc;


-- Q8 modified --
with temp as
(
select *,
CASE
	WHEN month(date) BETWEEN 9 AND 11 THEN CONCAT(" Q1 ", monthname(date))
    WHEN month(date) = 12 OR (month(date) BETWEEN 1 AND 2) THEN CONCAT(" Q2 ", monthname(date))
    WHEN month(date) BETWEEN 3 AND 5 THEN CONCAT(" Q3 ", monthname(date))
    ELSE CONCAT(" Q4 ", monthname(date))
END as Qtr
from gdb023.fact_sales_monthly
)
select Qtr as Quarter, sum(sold_quantity) as total_sold_quantity
from temp
where fiscal_year = "2020"
group by 1;


-- Q9 --
with cte1 as(
select dc.channel, sum((gp.gross_price*fsm.sold_quantity))/1000000 as gross_sales_mln  
from gdb023.fact_sales_monthly fsm join gdb023.dim_customer dc
on fsm.customer_code = dc.customer_code join
gdb023.fact_gross_price gp on
fsm.product_code = gp.product_code
group by 1)

select channel, gross_sales_mln, 
(gross_sales_mln/(select sum(gross_sales_mln) from cte1))*100 as percentage
from cte1
order by 3 desc;

-- Q10 --
with temp as
	(select dp.division, dp.product_code, dp.product, sum(fsm.sold_quantity) as total_quantity_sold,
	rank() over(partition by dp.division order by sum(fsm.sold_quantity) desc) rank_order														
	from gdb023.fact_sales_monthly fsm join gdb023.dim_product dp
	on fsm.product_code = dp.product_code
	where fsm.fiscal_year = "2021"
	group by 1,2,3)
    
    select *
    from temp 
    where rank_order <=3








   																													
