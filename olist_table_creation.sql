CREATE DATABASE olist_db
    WITH 
    OWNER = amadeayinata
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE TABLE geolocation (
	zipcode INT UNIQUE NOT NULL,
	geolocation_city CHAR NOT NULL, 
    geolocation_state CHAR(2) NOT NULL,
    PRIMARY KEY(zipcode));

CREATE TABLE customer (
	cust_id VARCHAR(32) UNIQUE NOT NULL,
	cust_unique_id VARCHAR(32) NOT NULL,
	cust_zipcode INT NOT NULL,
	cust_city CHAR NOT NULL, 
    cust_state CHAR(2) NOT null,
    PRIMARY KEY(cust_id),
    FOREIGN KEY(cust_zipcode)references geolocation(zipcode));
   
CREATE TABLE orders (
	order_id VARCHAR(32) UNIQUE NOT NULL,
	cust_id VARCHAR(32) NOT NULL,
	order_status CHAR,
	purchase_time TIMESTAMP NOT NULL,
	time_approved TIMESTAMP NOT NULL, 
	order_delivered_carrier_date TIMESTAMP NOT NULL, 	
	order_delivered_customer_date TIMESTAMP NOT NULL, 	
    order_estimated_delivery_date TIMESTAMP NOT NULL,
    PRIMARY KEY(order_id),
   	FOREIGN KEY(cust_id)references customer(cust_id));

 CREATE TABLE product (
	product_id VARCHAR(32) UNIQUE NOT NULL,
	product_category CHAR NOT NULL,
	PRIMARY KEY(product_id));

  CREATE TABLE seller (
	seller_id VARCHAR(32) UNIQUE NOT NULL,
	seller_zipcode INT NOT NULL,
	seller_city CHAR NOT NULL,
	seller_state CHAR(2) NOT NULL,
	PRIMARY KEY(seller_id),
    FOREIGN KEY(seller_zipcode)references geolocation(zipcode));
 
CREATE TABLE shipment_data (
	shipment_id INT UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	product_id VARCHAR(32) NOT NULL,
	seller_id VARCHAR(32) NOT NULL,
	num_items INT NOT NULL,
	shipping_limit_date TIMESTAMP NOT NULL,
	price DECIMAL NOT NULL,
	freight_value DECIMAL NOT NULL,
	PRIMARY KEY(shipment_id),
	FOREIGN KEY(order_id)references orders(order_id),
	FOREIGN KEY(product_id)references product(product_id),
    FOREIGN KEY(seller_id)references seller(seller_id));
  
CREATE TABLE reviews (
	review_id VARCHAR(32) UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	review_score INT NOT NULL,
	review_comment_title CHAR,
	review_comment_message CHAR, 
	review_creation_date TIMESTAMP NOT NULL,
	review_answer_timestamp TIMESTAMP NOT NULL,
	PRIMARY KEY(review_id),
    FOREIGN KEY(order_id)references orders(order_id));

 CREATE TABLE payment (
	payment_id INT UNIQUE NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	payment_sequential INT NOT NULL,
	payment_type CHAR NOT NULL,
	payment_installments INT NOT NULL, 
    payment_value DECIMAL NOT NULL,
    PRIMARY KEY(payment_id),
    FOREIGN KEY(order_id)references orders(order_id));