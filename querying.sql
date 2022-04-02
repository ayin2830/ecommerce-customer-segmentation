CREATE TABLE most_profittable_sector AS( 
SELECT 
	shipment_data.order_id, shipment_data.product_id, shipment_data.seller_id, shipment_data.shipment_id,
	product.product_category,
	product_translation.product_category_name_english 
FROM shipment_data
INNER JOIN product 
	ON shipment_data.product_id = product.product_id
INNER JOIN product_translation 
	ON product.product_category = product_translation.product_category); 


--the sector that brings in most customers/ most customers buy... 
SELECT product_category_name_english,
 COUNT(order_id)
FROM most_profittable_sector
GROUP BY  product_category_name_english
ORDER BY COUNT(order_id) DESC;

