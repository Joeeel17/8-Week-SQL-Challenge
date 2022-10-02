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
	pd.product_name;

-- Results:

product_name                    |total_quantity|
--------------------------------+--------------+
White Tee Shirt - Mens          |          3800|
Navy Solid Socks - Mens         |          3792|
Grey Fashion Jacket - Womens    |          3876|
Navy Oversized Jeans - Womens   |          3856|
Pink Fluro Polkadot Socks - Mens|          3770|
Khaki Suit Jacket - Womens      |          3752|
Black Straight Jeans - Womens   |          3786|
White Striped Socks - Mens      |          3655|
Blue Polo Shirt - Mens          |          3819|
Indigo Rain Jacket - Womens     |          3757|
Cream Relaxed Jeans - Womens    |          3707|
Teal Button Up Shirt - Mens     |          3646|
         
-- 2. What is the total generated revenue for all products before discounts?
         
SELECT 
	sum(price) AS gross_revenue
FROM balanced_tree.sales

-- Results:

gross_revenue|
-------------+
       429290|