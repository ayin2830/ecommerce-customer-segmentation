--Customer segmentation using RFM to predict loyalty

--Monetary Value: which customers spend the most?

--Monetary Value by Category
SELECT product_category_name_english , SUM(payment_value) AS "Total Revenue"
FROM (SELECT 
	shipment_data.order_id, shipment_data.product_id, shipment_data.seller_id, shipment_data.shipment_id,
	product.product_category,
	product_translation.product_category_name_english,
	payment.payment_value
FROM shipment_data
INNER JOIN product 
	ON shipment_data.product_id = product.product_id
INNER JOIN product_translation 
	ON product.product_category = product_translation.product_category
INNER JOIN payment 
	ON payment.order_id = shipment_data.order_id
WHERE orders.order_status <> 'canceled'
AND orders.order_status <> 'unavailable') AS dtable
GROUP BY  product_category_name_english
ORDER BY SUM(payment_value) DESC;

--Monetary value by unique customer id
SELECT 
	customer.cust_unique_id, payment.payment_value
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
INNER JOIN payment 
	ON payment.order_id = shipment_data.order_id
WHERE orders.order_status <> 'canceled'
AND orders.order_status <> 'unavailable'
GROUP BY customer.cust_unique_id, payment.payment_value
ORDER BY SUM(payment_value) DESC;

--Minmax normalization formula: x-min(x)/max(x)-min(x)

--We are using minmax normalization to rank monetary value, frequency and recency on the same scale (from 0 to 1). 

--Let's create a table from the select query above to make things easier. 
create table monetary_value as(
SELECT 
	customer.cust_unique_id, payment.payment_value
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
INNER JOIN payment 
	ON payment.order_id = shipment_data.order_id
where orders.order_status <> 'canceled'
and orders.order_status <> 'unavailable'
GROUP BY customer.cust_unique_id, payment.payment_value
ORDER BY SUM(payment_value) desc);

select max(payment_value) - min(payment_value) as divident
from monetary_value;

-- we find that the divident is 13644.08

--Normalized ranking based on Monetary Value
select cust_unique_id ,(payment_value/13664.08) as "Rank by Monetary Value"
from monetary_value
order by "Rank by Monetary Value" desc;
--F(requency): repurchasing customers/ how often a customer makes a purchase 

--Frequency by customer unique id
SELECT 
    cust_unique_id,
    COUNT(cust_unique_id) as repeat_orders
 FROM customer 
 inner JOIN orders
 	ON orders.cust_id = customer.cust_id
WHERE orders.order_status <> 'canceled'
AND orders.order_status <> 'unavailable'
GROUP BY cust_unique_id
HAVING COUNT(cust_unique_id) > 1
ORDER BY repeat_orders DESC;

--Minmax normalization

--again, let's create a table from the above query to make things easier. 
create table rank_by_frequency as(
SELECT 
    cust_unique_id,
    COUNT(cust_unique_id) as repeat_orders
 from customer 
 inner join orders
 	on orders.cust_id = customer.cust_id
where orders.order_status <> 'canceled'
and orders.order_status <> 'unavailable'
GROUP BY cust_unique_id
HAVING COUNT(cust_unique_id) > 1
order by repeat_orders desc);

ALTER TABLE rank_by_frequency ALTER COLUMN repeat_orders TYPE float4;
ALTER TABLE rank_by_frequency RENAME repeat_orders TO frequency;


-- we find that the divident is 14
select max(frequency) - min(frequency) as divident
from rank_by_frequency;

--Normalized ranking based on Frequency**
select cust_unique_id ,(frequency/14) as "Rank by Frequency"
from rank_by_frequency
order by "Rank by Frequency" desc;


--R(ecency): customers that recently purchased from Olist. 

SELECT 
	customer.cust_unique_id, orders.purchase_time
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
where orders.order_status <> 'canceled'
and orders.order_status <> 'unavailable'
GROUP BY customer.cust_unique_id, orders.purchase_time
ORDER BY orders.purchase_time DESC;


--Minmax normalization with Timestamps
--my approach: 
--1.SPLITTING the timestamp into two columns (date and time).
--2.MANIPULATING DATE to give the number of days after the earliest date 2016-09-04, MANIPULATING TIME to give time after 00:00. 
--3.Normalize the manipulated values using the min-max normalization formula. 

--again, we are creating a table out of the query above to make things easier. 
create table rank_by_recency as (SELECT 
	customer.cust_unique_id, orders.purchase_time
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
where orders.order_status <> 'canceled'
and orders.order_status <> 'unavailable'
GROUP BY customer.cust_unique_id, orders.purchase_time
ORDER BY orders.purchase_time DESC);

ALTER TABLE rank_by_recency RENAME purchase_time TO recency;

--splitting the timestamp into two columns: date and time

ALTER TABLE rank_by_recency ADD COLUMN dat date;
ALTER TABLE rank_by_recency ADD COLUMN tim time;

UPDATE rank_by_recency
SET
    dat = recency::date,
    tim = recency::time;

ALTER TABLE rank_by_recency DROP COLUMN recency;

--tricky part! min max normalization on datestamps :(

--do some manipulating to get the number of minutes after 00:00

create table time_normalization as (
SELECT cust_unique_id, extract(epoch from (tim - '00:00:00'))/60 as "time_after_12"
FROM rank_by_recency);

-- create table of mm time normalization **
create table mm_time_normalization as (
select cust_unique_id,time_after_12/1439.9833333333333333 as "normalized_time"
from time_normalization);


--do some manipulating to get the number of days after 2016-09-04, the earliest date recorded.
select dat - timestamp '2016-09-04' as "days_after_min",cust_unique_id 
from rank_by_recency

create table date_normalization as(
select cust_unique_id,dat - timestamp '2016-09-04' as "days_after_min"
from rank_by_recency);

--min max normalization of date**
create table mm_normalization_date as(
select cust_unique_id,seconds/62985600.000000 as "normalized_date" from (
select cust_unique_id,extract(epoch from days_after_min) as "seconds" --this is in seconds
from date_normalization) as dtable);

--create a table combining both normalized date and time **
create table date_time as(
SELECT 
	mm_time_normalization.cust_unique_id, normalized_date, normalized_time
FROM mm_time_normalization 
INNER JOIN mm_normalization_date  
	ON mm_time_normalization.cust_unique_id = mm_normalization_date.cust_unique_id
group by mm_time_normalization.cust_unique_id,mm_normalization_date.normalized_date,mm_time_normalization.normalized_time);

--finally! normalized 
select cust_unique_id,(normalized_date + normalized_time)/2 as "recency"
from date_time
order by Recency DESC;
 
	
