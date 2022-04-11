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
	ON payment.order_id = shipment_data.order_id) AS dtable
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
GROUP BY customer.cust_unique_id, payment.payment_value
ORDER BY SUM(payment_value) DESC;

--F(requency): repurchasing customers/ how often a customer makes a purchase 

--Frequency by customer unique id
SELECT 
    cust_unique_id,
    COUNT(cust_unique_id) as repeat_orders
FROM
    customer
GROUP BY cust_unique_id
HAVING COUNT(cust_unique_id) > 1
order by repeat_orders desc;


--R(ecency) which customers recently purchased something?

--Recency by customer_unique_id
SELECT 
	customer.cust_unique_id, orders.purchase_time
FROM shipment_data
INNER JOIN orders 
	ON shipment_data.order_id = orders.order_id
INNER JOIN customer 
	ON orders.cust_id = customer.cust_id
GROUP BY customer.cust_unique_id, orders.purchase_time
ORDER BY orders.purchase_time DESC;
 
	
