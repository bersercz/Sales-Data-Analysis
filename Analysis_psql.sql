select * from sales_dash
select * from walmart


--1 What is the total revenue generatd by male vs. Female customers.

select 
	gender,
	SUM(purchase_amount) as total_revenue
	from sales_dash
	group by 1


--2 Which customers used a discount but sill spent more then the average purchase amount.

select 
	customer_id,
	purchase_amount
	from sales_dash
	where 
		discount_applied = 'Yes' and purchase_amount >= (select avg(purchase_amount) from sales_dash)

--3 Which top 5 products with the highest average review rating.

select 
	item_purchased,
	round(avg(review_rating::numeric),2)
	from sales_dash
	group by 1
	order by 2 desc
	limit 5


--4 Compare the average purchase amounts between standard and Express Shipping.

select 
	shipping_type,
	Round(avg(purchase_amount::numeric),2) as Avg_Amount
	from sales_dash
	where shipping_type in ('Express', 'Standard')
	group by 1


--5 Compare the average spend and total revenue between subscribers and non-subscribers.

select 
	subscription_status,
	count(customer_id) as total_cust,
	sum(purchase_amount) as total_revenue,
	Round(avg(purchase_amount),2) as avg_spend
	from sales_dash
	group by 1
	order by total_revenue, avg_spend desc;


--6 Which 5 Products have the highest percentage of purchases with discounts applied ?

select
	item_purchased,
	round(100*sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
	from sales_dash
	group by 1
	order by 2 desc
	limit 5


--7 Segment customers into new, returning and loyal based on their total numbers of previous purchases, and show the count of each segment.

with customer_type as (
select 
	customer_id,
	previous_purchases,
	case
		when previous_purchases = 1 then 'New'
		when previous_purchases between 2 and 7 then 'Returning'
		else 'Loyal'
		end as customer_segment
from sales_dash
)
select 
	customer_segment,
	count(*) as "Number of customers"
	from customer_type
	group by customer_segment



--8 What are the top 3 most purchased products within each category ?

with item_counts as (
select
	category,
	item_purchased,
	count(customer_id) as total_orders,
	row_number() over(partition by category order by count(customer_id)desc) as item_rank
	from sales_dash
	group by category, item_purchased
)
select 
	item_rank,
	category,
	item_purchased,
	total_orders
	from item_counts
	where item_rank <= 3


--9 Are customers who are repead buyers (more then 5 previous purchases) also likely to subscribe ?

select
	subscription_status,
	count(customer_id) as buyer
	from sales_dash
	where previous_purchases > '5'
	group by 1

--10 What is the revenue contribution of each age group ?

select 
	age_group,
	sum(purchase_amount)
	from sales_dash
	group by 1
	order by 2
