CREATE DATABASE olist_db
    WITH 
    OWNER = amadeayinata
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE TABLE customer (
	cust_id serial PRIMARY KEY,
	cust_unique_id INT UNIQUE NOT NULL,
	cust_zipcode INT not null,
	cust_city CHAR not null, 
    cust_state CHAR not null);
   
CREATE TABLE geolocation (
	geolocation_zip_code SERIAL PRIMARY KEY ,
	geolocation_lat INT not null,
	geolocation_lng INT NOT NULL,
	geolocation_city CHAR not null, 
    geolocation_state CHAR not null);
 
CREATE TABLE orders (
	order_id SERIAL PRIMARY KEY,
	cust_id INT not null,
	order_status CHAR,
	purchase_time TIMESTAMP not null,
	payment_time TIMESTAMP not null, 
	time_approved TIMESTAMP not null, 
	time_delivered_to_logistics TIMESTAMP not null, 	
	time_delivered_to_cust TIMESTAMP not null, 	
    est_date_delivered TIMESTAMP not null,
   	foreign key(cust_id)references customer(cust_id));

 
CREATE TABLE payment (
	payment_id SERIAL PRIMARY KEY ,
	cust_id INT not null,
	payment_sequential INT not null,
	payment_type CHAR NOT NULL,
	payment_installments INT not null, 
    payment_value DECIMAL not null,
    foreign key(cust_id)references customer(cust_id));
   
CREATE TABLE product (
	product_id SERIAL PRIMARY KEY ,
	product_category CHAR not null);
  
 CREATE TABLE geolocation (
	geolocation_zip_code SERIAL PRIMARY KEY ,
	geolocation_lat DECIMAL UNIQUE not null,
	geolocation_lng DECIMAL UNIQUE  NOT NULL,
	geolocation_city CHAR not null, 
    geolocation_state CHAR not null);
   
 ALTER TABLE customer 
   ADD CONSTRAINT fk_zipcode
   FOREIGN KEY (cust_zipcode) 
   REFERENCES geolocation(geolocation_zip_code);
  
  CREATE TABLE seller (
	seller_id SERIAL PRIMARY KEY ,
	seller_zipcode INT not null,
	seller_city CHAR not null,
	seller_state CHAR NOT NULL,
    foreign key(seller_zipcode)references geolocation(geolocation_zip_code));
  
  CREATE TABLE shipment_data (
	shipment_id SERIAL PRIMARY KEY ,
	order_id INT unique not null,
	product_id INT UNIQUE not null,
	seller_id INT UNIQUE NOT NULL,
	no_items INT not null,
	shipping_limit_date TIMESTAMP not null,
	price DECIMAL not null,
	freight_value DECIMAL not null,
	foreign key(order_id)references orders(order_id),
	foreign key(product_id)references product(product_id),
    foreign key(seller_id)references seller(seller_id));
  
 
   CREATE TABLE reviews (
	review_id SERIAL PRIMARY KEY ,
	order_id INT unique not null,
	review_score INT NOT NULL,
	review_comment_title CHAR,
	review_comment_message CHAR, 
	review_creation_date TIMESTAMP not null,
	review_answer_timestamp TIMESTAMP not null,
    foreign key(order_id)references orders(order_id));