create database ecommerce;
use ecommerce;
select * from olist_geolocation;
select * from olist_order_items;
select * from olist_order_payments;
select * from olist_order_reviews;
select * from olist_orders_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * from product_category_name_translation;
select * from olist_customers_dataset;

#Total revenue generated from orders placed on weekdays vs weekends
SELECT
  CASE 
    WHEN DAYOFWEEK(oi.shipping_limit_date) IN (1, 7) THEN 'WEEKEND'
    ELSE 'WEEKDAY'
  END AS day_type,
  SUM(op.payment_value) AS total_amount
FROM olist_order_items oi
RIGHT JOIN olist_order_payments op
  ON oi.order_id = op.order_id
GROUP BY
  CASE 
    WHEN DAYOFWEEK(oi.shipping_limit_date) IN (1, 7) THEN 'WEEKEND'
    ELSE 'WEEKDAY'
  END;
  
#Number of Orders with review score 5 and payment type as credit card.
SELECT
  COUNT(DISTINCT op.order_id) AS total_orders,
  op.payment_type,ROUND(SUM(OP.payment_value),2) TOTAL_VALUE
FROM olist_order_payments op
LEFT JOIN olist_order_reviews r
  ON op.order_id = r.order_id
WHERE op.payment_type = 'credit_card'
GROUP BY
  op.payment_type,
  r.review_score;
  
  #Average number of days taken to hand over an order to the carrier after approval
  SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_carrier_date, order_approved_at)), 2)
    AS avg_carrier_delay_days
FROM olist_orders_dataset
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND DATEDIFF(order_delivered_carrier_date, order_approved_at) >= 0;


#Most frequently used payment methods
SELECT
  payment_type,
  COUNT(DISTINCT order_id) AS total_orders
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;

#Seller Distribution by City
SELECT
  seller_city,
  COUNT(*) AS total_sellers
FROM olist_sellers_dataset
GROUP BY seller_city
ORDER BY total_sellers DESC
LIMIT 5;

#Number of Sellers by State
SELECT seller_state, COUNT(*) AS sellers
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY sellers DESC;

#Orders with the Highest Number of Payments
SELECT 
    order_id,
    COUNT(*) AS number_of_payments,
    SUM(payment_value) AS total_payment
FROM olist_order_payments
GROUP BY order_id
ORDER BY number_of_payments DESC, total_payment DESC
LIMIT 10;

#Delivered vs Non Delivered orders
SELECT 
    order_status, 
    COUNT(*) AS orders
FROM olist_orders_dataset
GROUP BY order_status;

#Top 5 States with Maximum Sellers
WITH seller_state_count AS (
    SELECT 
        s.seller_state,
        COUNT(s.seller_id) AS total_sellers
    FROM olist_sellers_dataset s
    GROUP BY s.seller_state
)
SELECT *
FROM seller_state_count
ORDER BY total_sellers DESC
LIMIT 5;

#Average Delivery Delays
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) 
    AS avg_delivery_delay
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

#Monthly Order Trend
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(*) AS orders
FROM olist_orders_dataset
GROUP BY month
ORDER BY month;

#Repeated Customers
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

#Average Customer Review Score
SELECT 
    ROUND(AVG(review_score), 2) AS average_review_score
FROM olist_order_reviews;



