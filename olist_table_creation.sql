   
CREATE DATABASE olist_db
    WITH 
    OWNER = amadeayinata
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE TABLE customer (
	cust_id VARCHAR(32) UNIQUE NOT NULL,
	cust_unique_id VARCHAR(32) NOT NULL,
	cust_zipcode TEXT NOT NULL,
	cust_city TEXT NOT NULL, 
    cust_state CHAR(2) NOT null,
    PRIMARY KEY(cust_id));
   
CREATE TABLE orders (
	order_id VARCHAR(32) UNIQUE NOT NULL,
	cust_id VARCHAR(32) NOT NULL,
	order_status TEXT,
	purchase_time TIMESTAMP,
	time_approved TIMESTAMP, 
	order_delivered_carrier_date TIMESTAMP, 	
	order_delivered_customer_date TIMESTAMP, 	
    order_estimated_delivery_date TIMESTAMP,
    PRIMARY KEY(order_id),
   	FOREIGN KEY(cust_id)references customer(cust_id));
  
CREATE TABLE seller (
	seller_id VARCHAR(32) UNIQUE NOT NULL,
	seller_zipcode INT NOT NULL,
	seller_city TEXT NOT NULL,
	seller_state CHAR(2) NOT NULL,
	PRIMARY KEY(seller_id)); 

 CREATE TABLE product (
	product_id VARCHAR(32) UNIQUE NOT NULL,
	product_category TEXT NOT NULL,
	product_name_length NUMERIC,
	product_description_length NUMERIC,
	product_photos_qty NUMERIC,
	product_weight_g NUMERIC,
	product_length_cm NUMERIC,
	product_height_cm NUMERIC,
	product_width_cm NUMERIC,
	PRIMARY KEY(product_id));

CREATE TABLE shipment_data (
	shipment_id VARCHAR(64) UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	product_id VARCHAR(32) NOT NULL,
	seller_id VARCHAR(32) NOT NULL,
	num_items INT,
	shipping_limit_date TIMESTAMP,
	price NUMERIC,
	freight_value NUMERIC,
	PRIMARY KEY(shipment_id),
	FOREIGN KEY(order_id)references orders(order_id),
	FOREIGN KEY(product_id)references product(product_id),
    FOREIGN KEY(seller_id)references seller(seller_id));
   
  CREATE TABLE reviews (
	review_id VARCHAR(32) UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	review_score INT,
	review_comment_title TEXT,
	review_comment_message TEXT, 
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP,
	PRIMARY KEY(review_id),
    FOREIGN KEY(order_id)references orders(order_id));
   
 CREATE TABLE payment (
	payment_id INT UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	payment_sequential INT,
	payment_type TEXT,
	payment_installments INT, 
    payment_value NUMERIC,
    PRIMARY KEY(payment_id),
    FOREIGN KEY(order_id)references orders(order_id));
