ALTER TABLE customer
RENAME COLUMN customer_unique_id TO cust_unique_id;

ALTER TABLE customer
RENAME COLUMN customer_id TO cust_id;

ALTER TABLE orders
RENAME COLUMN customer_id TO cust_id;

ALTER TABLE orders
RENAME COLUMN order_purchase_timestamp TO purchase_time;




CREATE TABLE monetary_value AS
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
ORDER BY SUM(payment_value) DESC;

SELECT max(payment_value) - min(payment_value) as divident
FROM monetary_value;

CREATE TABLE normalized_monetaryvaluerank AS 
SELECT cust_unique_id ,(payment_value/13664.08) AS "mv_rank"
FROM monetary_value
ORDER BY "Rank by Monetary Value" DESC;

CREATE TABLE rank_by_frequency AS
SELECT 
    cust_unique_id,
    COUNT(cust_unique_id) as frequency
 FROM customer 
 inner JOIN orders
 	ON orders.cust_id = customer.cust_id
WHERE orders.order_status <> 'canceled'
AND orders.order_status <> 'unavailable'
GROUP BY cust_unique_id
order by frequency desc;

SELECT max(frequency) - min(frequency) AS divident
FROM rank_by_frequency;

CREATE TABLE normalized_frequencyrank AS 
SELECT cust_unique_id ,((frequency-1)/15.0) AS "frequency_rank"
FROM rank_by_frequency
ORDER BY frequency_rank desc;

create table rank_by_recency AS 
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

ALTER TABLE rank_by_recency RENAME purchase_time TO recency;

CREATE TABLE date_normalization AS 
SELECT *, JULIANDAY(recency)-JULIANDAY('2016-09-04 21:15:19') AS "time_after"
FROM rank_by_recency;

SELECT min(time_after),max(time_after)
FROM date_normalization;

CREATE TABLE normalized_recencyrank AS
SELECT cust_unique_id ,((time_after)/728.4941898146644) AS "recency"
FROM date_normalization
ORDER BY recency desc;

ALTER TABLE normalized_recencyrank  RENAME recency TO recency_rank;

CREATE TABLE rfm_ranking_separated AS
SELECT cust_unique_id, (recency_rank +
	frequency_rank + mv_rank)/3 as "rfm_rank"
FROM (
SELECT
normalized_recencyrank.cust_unique_id, normalized_recencyrank.recency_rank, 
	normalized_frequencyrank.frequency_rank, normalized_monetaryvaluerank.mv_rank
FROM normalized_frequencyrank   
INNER JOIN normalized_monetaryvaluerank   
	ON normalized_monetaryvaluerank .cust_unique_id = normalized_frequencyrank .cust_unique_id	
INNER JOIN normalized_recencyrank  
	ON normalized_recencyrank .cust_unique_id = normalized_frequencyrank .cust_unique_id)
ORDER BY rfm_rank DESC;

CREATE TABLE rfm_ranking AS
SELECT cust_unique_id, ROUND(rfm_rank,1) *10 AS "rfm_ranking"
FROM(
SELECT cust_unique_id,
       avg(rfm_rank) as rfm_rank
FROM rfm_ranking_separated
GROUP BY cust_unique_id
ORDER BY rfm_rank DESC);

SELECT COUNT(*)
FROM rfm_ranking;

--champions
CREATE TABLE champions AS
SELECT *
FROM rfm_ranking
WHERE rfm_ranking >=4;

ALTER TABLE champions
ADD segment CHAR NULL;
UPDATE champions SET segment = 'champion';

CREATE TABLE loyal AS
SELECT *
FROM rfm_ranking
WHERE rfm_ranking = 3;

ALTER TABLE loyal
ADD segment CHAR NULL;
UPDATE loyal SET segment = 'loyal';

CREATE TABLE need_attention AS
SELECT *
FROM rfm_ranking
WHERE rfm_ranking = 2;

ALTER TABLE need_attention
ADD segment CHAR NULL;
UPDATE need_attention SET segment = 'needs attention';
  
CREATE TABLE at_risk AS
SELECT *
FROM rfm_ranking
WHERE rfm_ranking = 1;

ALTER TABLE at_risk
ADD segment CHAR NULL;
UPDATE at_risk SET segment = 'at risk';

CREATE TABLE hibernation AS
SELECT *
FROM rfm_ranking
WHERE rfm_ranking = 0;

ALTER TABLE hibernation
ADD segment CHAR NULL;
UPDATE hibernation SET segment = 'hibernation';
