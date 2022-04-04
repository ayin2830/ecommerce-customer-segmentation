--the sector that brings in most customers/ most customers buy... 
SELECT product_category_name_english as "Product Category",
 COUNT(order_id) as "Total Orders"
FROM (SELECT 
	shipment_data.order_id, shipment_data.product_id, shipment_data.seller_id, shipment_data.shipment_id,
	product.product_category,
	product_translation.product_category_name_english 
FROM shipment_data
INNER JOIN product 
	ON shipment_data.product_id = product.product_id
INNER JOIN product_translation 
	ON product.product_category = product_translation.product_category) as dtable
GROUP BY  product_category_name_english
ORDER BY COUNT(order_id) DESC;


--next, find which sector brings in most revenue.
SELECT product_category_name_english , SUM(payment_value) as "Total Revenue"
FROM (select 
	shipment_data.order_id, shipment_data.product_id, shipment_data.seller_id, shipment_data.shipment_id,
	product.product_category,
	product_translation.product_category_name_english,
	payment.payment_value
from shipment_data
inner join product 
	on shipment_data.product_id = product.product_id
inner join product_translation 
	on product.product_category = product_translation.product_category
inner join payment 
	on payment.order_id = shipment_data.order_id) as dtable
GROUP BY  product_category_name_english
ORDER BY SUM(payment_value) DESC;

  





