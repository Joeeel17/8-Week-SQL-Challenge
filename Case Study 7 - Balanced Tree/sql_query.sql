/* 
 * Balanced Tree
 * Case Study #7 Questions & Answers
 *  
*/

-- A.  High Level Sales Analysis

-- The first question is asked vaguely.  Although I feel the second answer is the 
-- correct one, the question is somewhat ambiguous so I added a little clarification. jaime.m.shaker@gmail.com 
  
-- 1a. What was the total quantity sold for all products?

SELECT 
	sum(qty) AS total_product_quantity
FROM balanced_tree.sales;

total_product_quantity|
----------------------+
                 45216|
                 
-- 1b. What was the total quantity sold for EACH product?                 

SELECT 
	pd.product_name,
	sum(s.qty) AS total_quantity
FROM 
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY
	total_quantity DESC;

-- Results:

product_name                    |total_quantity|
--------------------------------+--------------+
Grey Fashion Jacket - Womens    |          3876|
Navy Oversized Jeans - Womens   |          3856|
Blue Polo Shirt - Mens          |          3819|
White Tee Shirt - Mens          |          3800|
Navy Solid Socks - Mens         |          3792|
Black Straight Jeans - Womens   |          3786|
Pink Fluro Polkadot Socks - Mens|          3770|
Indigo Rain Jacket - Womens     |          3757|
Khaki Suit Jacket - Womens      |          3752|
Cream Relaxed Jeans - Womens    |          3707|
White Striped Socks - Mens      |          3655|
Teal Button Up Shirt - Mens     |          3646|
         
-- 2a. What is the total generated revenue for all products before discounts?
         
SELECT 
	sum(price * qty) AS gross_revenue
FROM balanced_tree.sales;

-- Results:

gross_revenue|
-------------+
      1289453|

-- 2b. What is the total generated revenue for EACH product before discounts?
       
SELECT 
	pd.product_name,
	sum(s.price * s.qty) AS total_gross_revenue
FROM 
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY 
	total_gross_revenue desc;      
 
-- Results:

product_name                    |total_gross_revenue|
--------------------------------+-------------------+
Blue Polo Shirt - Mens          |             217683|
Grey Fashion Jacket - Womens    |             209304|
White Tee Shirt - Mens          |             152000|
Navy Solid Socks - Mens         |             136512|
Black Straight Jeans - Womens   |             121152|
Pink Fluro Polkadot Socks - Mens|             109330|
Khaki Suit Jacket - Womens      |              86296|
Indigo Rain Jacket - Womens     |              71383|
White Striped Socks - Mens      |              62135|
Navy Oversized Jeans - Womens   |              50128|
Cream Relaxed Jeans - Womens    |              37070|
Teal Button Up Shirt - Mens     |              36460|

-- 3a. What was the total discount amount for all products?

SELECT 
	round(sum((price * qty) * (discount::NUMERIC / 100)), 2) AS total_discounts
FROM balanced_tree.sales;

-- Results:

total_discounts|
---------------+
      156229.14|
       
-- 3b. What is the total discount for EACH product?  I will include total item revenue with 
-- this query.
       
SELECT 
	pd.product_name,
	sum(s.price * s.qty) AS total_item_revenue,
	round(sum((s.price * s.qty) * (s.discount::NUMERIC / 100)), 2) AS total_item_discounts
FROM 
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY 
	total_item_revenue desc; 

-- Results:

product_name                    |total_item_revenue|total_item_discounts|
--------------------------------+------------------+--------------------+
Blue Polo Shirt - Mens          |            217683|            26819.07|
Grey Fashion Jacket - Womens    |            209304|            25391.88|
White Tee Shirt - Mens          |            152000|            18377.60|
Navy Solid Socks - Mens         |            136512|            16650.36|
Black Straight Jeans - Womens   |            121152|            14744.96|
Pink Fluro Polkadot Socks - Mens|            109330|            12952.27|
Khaki Suit Jacket - Womens      |             86296|            10243.05|
Indigo Rain Jacket - Womens     |             71383|             8642.53|
White Striped Socks - Mens      |             62135|             7410.81|
Navy Oversized Jeans - Womens   |             50128|             6135.61|
Cream Relaxed Jeans - Womens    |             37070|             4463.40|
Teal Button Up Shirt - Mens     |             36460|             4397.60|

-- B.  Transaction Analysis

-- 1. How many unique transactions were there?

SELECT
	count(DISTINCT txn_id) AS unique_transactions
FROM
	balanced_tree.sales
	
-- Results:
	
unique_transactions|
-------------------+
               2500|
               
-- 2. What is the average unique products purchased in each transaction?
               







       