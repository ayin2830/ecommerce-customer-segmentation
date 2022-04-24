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

 ALTER TABLE monetary_value
 ADD monetary_rank  CHAR NULL;
 
UPDATE monetary_value SET monetary_rank = 1
WHERE payment_value > 1000;

UPDATE monetary_value SET monetary_rank = 2
WHERE payment_value < 1000
AND payment_value > 500;

UPDATE monetary_value SET monetary_rank = 3
WHERE payment_value < 500
AND payment_value > 100;

UPDATE monetary_value SET monetary_rank = 4
WHERE payment_value < 200
AND payment_value >= 100;

UPDATE monetary_value SET monetary_rank = 5
WHERE payment_value < 100;


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

ALTER TABLE frequency
ADD frequency_rank  CHAR NULL;

UPDATE frequency SET frequency_rank = 1
WHERE frequency > 5;

UPDATE frequency SET frequency_rank = 2
WHERE frequency = 4 
OR frequency = 5

UPDATE frequency SET frequency_rank = 3
WHERE frequency = 3;

UPDATE frequency SET frequency_rank = 4
WHERE frequency = 2;

UPDATE frequency SET frequency_rank = 5
WHERE frequency = 1;

CREATE TABLE rank_by_recency AS 
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

CREATE TABLE recency AS 
SELECT *, JULIANDAY(recency)-JULIANDAY('2016-09-04 21:15:19') AS "time_after"
FROM rank_by_recency;
UPDATE recency SET recency_rank = 1
WHERE time_after >=640;

UPDATE recency SET recency_rank = 2
WHERE time_after > 550 AND time_after < 640;

UPDATE recency SET recency_rank = 3
WHERE time_after > 460 AND time_after <= 550;

UPDATE recency SET recency_rank = 4
WHERE time_after > 370 AND time_after <= 460;

UPDATE recency SET recency_rank = 5
WHERE time_after <= 370;

CREATE TABLE segmented AS
SELECT cust_unique_id, recency, frequency_rank, monetary, recency || frequency_rank || monetary AS 'rfm_rank', payment_value
FROM (
SELECT f.cust_unique_id, f.frequency_rank, r.recency_rank AS recency, m.monetary_rank AS monetary, m.payment_value 
FROM frequency f 
INNER JOIN recency r
	ON f.cust_unique_id = r.cust_unique_id 
INNER JOIN monetary_value m 
	ON m.cust_unique_id =f.cust_unique_id))
GROUP BY cust_unique_id;

ALTER TABLE segmented
  ADD segment CHAR NULL;

UPDATE segmented SET segment = 'Recent low potential spenders'
WHERE rfm_rank LIKE '144'
OR rfm_rank LIKE '244'
OR rfm_rank = '143'
OR rfm_rank = '243';



UPDATE segmented SET segment = 'Loyal'
WHERE rfm_rank LIKE '_1_'
OR rfm_rank LIKE '_2_';


UPDATE segmented SET segment = 'Big spenders'
WHERE rfm_rank LIKE '__1'


SELECT COUNT(*) --Users who used to spend a lot and often who has not purchased in a long time = 0. 
FROM segmented 
WHERE rfm_rank LIKE '422'
OR rfm_rank LIKE '522'
OR rfm_rank LIKE '412'
OR rfm_rank LIKE '421'
OR rfm_rank LIKE '512'
OR rfm_rank LIKE '521';


UPDATE segmented SET segment = 'General'
WHERE rfm_rank LIKE '33_'
OR rfm_rank LIKE '34_'
OR rfm_rank LIKE '32_';


UPDATE segmented SET segment = 'About to sleep'
WHERE rfm_rank LIKE '4__'


UPDATE segmented SET segment = 'Lost'
WHERE rfm_rank LIKE '5__'

UPDATE segmented SET segment = 'Recent high potential '
WHERE rfm_rank LIKE '1_1'
OR rfm_rank LIKE '2_2'
OR rfm_rank LIKE '2_1'
OR rfm_rank LIKE '1_2';


UPDATE segmented SET segment = 'Lost high spenders'
WHERE rfm_rank LIKE '5_1'
OR rfm_rank LIKE '5_2';

SELECT COUNT(*) --Needs attention
FROM segmented 
WHERE rfm_rank LIKE '1_3'
OR rfm_rank LIKE '1_2'
OR rfm_rank LIKE '1_1'
OR rfm_rank LIKE '2_3'
OR rfm_rank LIKE '2_2'
OR rfm_rank LIKE '2_3';


UPDATE final_segmentation SET segment = 'Needs attention'
WHERE rfm_ranking LIKE '1_3'
OR rfm_ranking LIKE '1_2'
OR rfm_ranking LIKE '1_1'
OR rfm_ranking LIKE '2_3'
OR rfm_ranking LIKE '2_2'
OR rfm_ranking LIKE '2_3';


CREATE TABLE final_segmentation AS
SELECT *, min(rfm_ranking) AS rfm_rank ----we have some duplicate customers with different rfm ranks, so we will get the min(most recent) entry. 
FROM final_rank 
GROUP BY cust_unique_id;

ALTER TABLE final_segmentation DROP COLUMN rfm_ranking;

