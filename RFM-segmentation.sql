--to fix: reduce the amount of tables!

--Customer segmentation using RFM to predict loyalty

--Monetary Value: which customers spend the most?


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
CREATE TABLE monetary_value as(
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

SELECT max(payment_value) - min(payment_value) as divident
FROM monetary_value;

-- we find that the divident is 13644.08

--Normalized ranking based on Monetary Value
CREATE TABLE normalized_monetaryvaluerank AS (
SELECT cust_unique_id ,(payment_value/13664.08) as "mv_rank"
FROM monetary_value
ORDER BY "Rank by Monetary Value" desc);

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
CREATE TABLE rank_by_frequency AS(
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
order by repeat_orders desc);

ALTER TABLE rank_by_frequency ALTER COLUMN repeat_orders TYPE float4;
ALTER TABLE rank_by_frequency RENAME repeat_orders TO frequency;


-- we find that the divident is 14
SELECT max(frequency) - min(frequency) AS divident
FROM rank_by_frequency;

--Normalized ranking based on Frequency**
CREATE TABLE normalized_frequencyrank AS (
SELECT cust_unique_id ,(frequency/14) AS "Rank by Frequency"
FROM rank_by_frequency
ORDER BY frequency_rank desc);


--R(ecency): customers that recently purchased from Olist. 

SELECT 
	customer.cust_unique_id, orders.purchase_time
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
WHERE orders.order_status <> 'canceled'
AND orders.order_status <> 'unavailable'
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

CREATE TABLE time_normalization as (
SELECT cust_unique_id, extract(epoch FROM (tim - '00:00:00'))/60 AS "time_after_12"
FROM rank_by_recency);

-- create table of mm time normalization **
CREATE TABLE mm_time_normalization AS (
SELECT cust_unique_id,time_after_12/1439.9833333333333333 AS "normalized_time"
FROM time_normalization);


--do some manipulating to get the number of days after 2016-09-04, the earliest date recorded.
SELECT dat - timestamp '2016-09-04' as "days_after_min",cust_unique_id 
FROM rank_by_recency

CREATE TABLE date_normalization AS(
SELECT cust_unique_id,dat - timestamp '2016-09-04' AS "days_after_min"
FROM rank_by_recency);

--min max normalization of date**
CREATE TABLE mm_normalization_date AS(
SELECT cust_unique_id,seconds/62985600.000000 AS "normalized_date" from (
SELECT cust_unique_id,extract(epoch FROM days_after_min) AS "seconds" --this is in seconds
FROM date_normalization) as dtable);

--create a table combining both normalized date and time **
create table date_time as(
SELECT 
	mm_time_normalization.cust_unique_id, normalized_date, normalized_time
FROM mm_time_normalization 
INNER JOIN mm_normalization_date  
	ON mm_time_normalization.cust_unique_id = mm_normalization_date.cust_unique_id
GROUP BY mm_time_normalization.cust_unique_id,mm_normalization_date.normalized_date,mm_time_normalization.normalized_time);

--finally! normalized 
CREATE TABLE normalized_recencyrank AS (
SELECT cust_unique_id,(normalized_date + normalized_time)/2 as "recency"
FROM date_time
ORDER BY Recency DESC);
 
CREATE TABLE rfm_ranking_separated AS(
SELECT
normalized_recencyrank.cust_unique_id, normalized_recencyrank.recency_rank, 
	normalized_frequencyrank.frequency_rank, normalized_monetaryvaluerank.mv_rank
FROM normalized_frequencyrank   
INNER JOIN normalized_monetaryvaluerank   
	ON normalized_monetaryvaluerank .cust_unique_id = normalized_frequencyrank .cust_unique_id	
INNER JOIN normalized_recencyrank  
	ON normalized_recencyrank .cust_unique_id = normalized_frequencyrank .cust_unique_id);

CREATE TABLE rfm_ranking AS(
SELECT rfm_ranking_separated.cust_unique_id, (rfm_ranking_separated.recency_rank +
	rfm_ranking_separated.frequency_rank + rfm_ranking_separated.mv_rank)/3 as "rfm_rank"
FROM rfm_ranking_separated
ORDER BY rfm_rank DESC);
	
