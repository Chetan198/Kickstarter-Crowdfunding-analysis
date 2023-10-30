create table customers(customer_id varchar(100),
customer_unique_id varchar(100),
customer_zip_code_prefix int,
customer_city varchar(100),
customer_state varchar(100));

drop table order_reviews;

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv"
into table customers
fields terminated by","
lines terminated by"\n"
ignore 1 rows;


create table sellers(seller_id varchar(100),
seller_zip_code_prefix int,
seller_city varchar(100),
seller_state varchar(100));

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv"
into table sellers
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table orders(order_id varchar(100),
customer_id	varchar(100),
order_status varchar(100),
order_purchase_timestamp date,
order_approved_at date,
order_delivered_carrier_date date,
order_delivered_customer_date date,
order_estimated_delivery_date date);

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv"
into table orders
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table products(product_id varchar(100),
product_category_name varchar(100),
product_name_lenght int,
product_description_lenght int,
product_photos_qty int,
product_weight_g int,
product_length_cm int,
product_height_cm int,
product_width_cm int);


load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv"
into table products
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

 create table order_reviews(review_id varchar(100),
 order_id varchar(100),
review_score int,
review_creation_date date,
review_answer_timestamp date);

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv"
into table order_reviews
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table order_payments( order_id varchar(100),	
payment_sequential int,
payment_type varchar(100),
payment_installments int,
payment_value double);

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv"
into table order_payments
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table order_items(order_id varchar(100),
order_item_id int,
product_id varchar(100),
seller_id varchar(100),
shipping_limit_date date,
price double,
freight_value double);

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv"
into table order_items
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table geolocation(geolocation_zip_code_prefix int,
geolocation_lat int,
geolocation_lng int,
geolocation_city varchar(100),
geolocation_state varchar(100));

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv"
into table geolocation
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

create table cat_translation(product_category_name varchar(100),
product_category_name_english varchar(100));

load data infile"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv"
into table cat_translation
fields terminated by","
lines terminated by"\n"
ignore 1 rows;

alter table orders
drop column weekday_or_weekend ;

#OLIST DATA ANALYSIS
#KPI 1 weekend vs weekday payment statistics
Select 
    If(weekday(o.order_purchase_timestamp) < 5, 'Weekday', 'Weekend') AS `Day_type`,
    floor(SUM(p.payment_value)) AS `Total_Payment_Value`
from orders o
join order_payments p
	on o.order_id = p.order_id
group by `Day_type`;


#KPI 2 # of orders for credit card as payment type and review score '5'
select  r.review_score,p.payment_type, count(r.order_id) as no_of_orders
from order_reviews r
join order_payments p
	on r. order_id = p.order_id
    where review_score=5 and payment_type='credit_card';

# KPI 3  Average delivery days for product category names
select avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)) as avg_delivery_days
from orders o
join  order_items i
	on o.order_id = i.order_id
join products pr
    on i.product_id = pr.product_id   
where product_category_name = 'pet_shop';

# KPI 4  Average price and payments for the sellers city 'Sao paulo'
Select floor(avg(i.price)) AS average_price, floor(avg(p.payment_installments*p.payment_value)) AS average_payment
from order_items i
join order_payments p
	on i.order_id = p.order_id 
join sellers s
	on i.seller_id = s.seller_id 
where seller_city = 'sao paulo';

#KPI 5  Relation between average shipping days and review scores
Select r.review_score, round(avg(Datediff(o.order_delivered_customer_date, o.order_purchase_timestamp))) as avg_shipping_days
from orders o
join order_reviews r 
	on o.order_id = r.order_id
group by review_score
order by review_score;



