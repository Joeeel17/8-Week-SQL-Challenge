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
-- I believe this is another oddly worded question.  I interpret this question to ask
-- "What is the average NUMBER OF unique items purchased per transaction?"

SELECT
	round(avg(unique_item)) AS avg_number_of_items
FROM
	(SELECT
		count(DISTINCT s.prod_id) unique_item
	FROM
		balanced_tree.sales AS s
	GROUP BY
		s.txn_id) AS tmp;

-- Results:
		
avg_number_of_items|
-------------------+
                  6|
                  
-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

WITH get_revenue AS (
	SELECT
		txn_id,
		round(sum((price * qty) * (1 - discount::NUMERIC / 100)), 2) AS revenue
	FROM
		balanced_tree.sales
	GROUP BY
		txn_id
)
SELECT
	percentile_disc(0.25) WITHIN GROUP (ORDER BY revenue) AS "25th_percentile",
	percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS "50th_percentile",
	percentile_disc(0.75) WITHIN GROUP (ORDER BY revenue) AS "75th_percentile"
FROM
	get_revenue;

-- Results:

25th_percentile|50th_percentile|75th_percentile|
---------------+---------------+---------------+
         326.18|         441.00|         572.75|

-- 4. What is the average discount value per transaction?

WITH get_avg_discount AS (
	SELECT
		txn_id,
		round(sum((price * qty) * (discount::NUMERIC / 100)), 2) AS discount
	FROM
		balanced_tree.sales
	GROUP BY
		txn_id
)
SELECT
	round(avg(discount), 2) avg_discount
FROM
	get_avg_discount;

-- Results:

avg_discount|
------------+
       62.49|
       
-- 5. What is the percentage split of all transactions for members vs non-members?
                  
SELECT
	round(100 * (SELECT count(DISTINCT txn_id) FROM balanced_tree.sales WHERE member = 't')::numeric / count(DISTINCT txn_id), 2) AS member_percentage,
	round(100 * (SELECT count(DISTINCT txn_id) FROM balanced_tree.sales WHERE member = 'f')::numeric / count(DISTINCT txn_id), 2) AS non_member_percentage
FROM
	balanced_tree.sales
	
member_percentage|non_member_percentage|
-----------------+---------------------+
            60.20|                39.80|
                  
 -- OR
 
SELECT
	member,
	-- The over clause allows us to nest aggregate functions
	round(100 * (count(DISTINCT txn_id) / sum(count(DISTINCT txn_id)) OVER()), 2) AS percentage_distribution
FROM
	balanced_tree.sales
GROUP BY
	member

-- Results:
	
member|percentage_distribution|
------+-----------------------+
false |                  39.80|
true  |                  60.20|
                  
-- 6. What is the average revenue for member transactions and non-member transactions?

SELECT
	CASE
		WHEN member = 't' THEN 'Member'
		ELSE 'Non-Member'
	END AS membership_status,
	round(avg(revenue), 2) AS avg_revenue
from
	(SELECT
		txn_id,
		member,
		round(sum((price * qty) * (1 - discount::NUMERIC / 100)), 2) AS revenue
	FROM
		balanced_tree.sales
	GROUP BY
		txn_id,
		member) AS tmp
GROUP BY
	member
	
-- Results:
	
membership_status|avg_revenue|
-----------------+-----------+
Non-Member       |     452.01|
Member           |     454.14|
                  
-- C.  Transaction Analysis                  
                  
-- 1. What are the top 3 products by total revenue before discount?

SELECT
	pd.product_name,
	sum(s.price * s.qty) AS total_revenue
FROM
	balanced_tree.sales AS s
JOIN
	balanced_tree.product_details AS pd ON pd.product_id = s.prod_id
GROUP BY
	pd.product_name
ORDER BY
	total_revenue DESC
LIMIT 3;

-- Results:

product_name                |total_revenue|
----------------------------+-------------+
Blue Polo Shirt - Mens      |       217683|
Grey Fashion Jacket - Womens|       209304|
White Tee Shirt - Mens      |       152000|

-- 2. What is the total quantity, revenue and discount for each segment?

SELECT
	pd.segment_id,
	pd.segment_name,
	sum(s.qty) AS total_quantity,
	sum(s.price * s.qty) AS gross_revenue,
	round(sum((s.price * s.qty) * (s.discount::NUMERIC / 100)), 2) AS total_discounts,
	round(sum((s.price * s.qty) * (1 - discount::NUMERIC / 100)), 2) AS total_revenue
FROM
	balanced_tree.product_details AS pd
JOIN
	balanced_tree.sales AS s ON s.prod_id = pd.product_id
GROUP BY
	pd.segment_id,
	pd.segment_name
	
-- Results:
	
segment_id|segment_name|total_quantity|gross_revenue|total_discounts|total_revenue|
----------+------------+--------------+-------------+---------------+-------------+
         4|Jacket      |         11385|       366983|       44277.46|    322705.54|
         6|Socks       |         11217|       307977|       37013.44|    270963.56|
         5|Shirt       |         11265|       406143|       49594.27|    356548.73|
         3|Jeans       |         11349|       208350|       25343.97|    183006.03|

-- 3. What is the top selling product for each segment?

WITH top_ranking AS         
(
	SELECT
		pd.segment_id,
		pd.segment_name,
		pd.product_name,
		sum(qty) AS total_quantity,
		rank() OVER (PARTITION BY pd.segment_id ORDER BY sum(qty) desc) AS rnk
	FROM
		balanced_tree.product_details AS pd
	JOIN
		balanced_tree.sales AS s ON s.prod_id = pd.product_id
	GROUP BY
		pd.segment_id,
		pd.segment_name,
		pd.product_name
)
SELECT
	segment_id,
	segment_name,
	product_name AS top_ranking_products,
	total_quantity
FROM 
	top_ranking
WHERE
	rnk = 1
	
-- Results:
	
segment_id|segment_name|top_ranking_products         |total_quantity|
----------+------------+-----------------------------+--------------+
         3|Jeans       |Navy Oversized Jeans - Womens|          3856|
         4|Jacket      |Grey Fashion Jacket - Womens |          3876|
         5|Shirt       |Blue Polo Shirt - Mens       |          3819|
         6|Socks       |Navy Solid Socks - Mens      |          3792|

-- 4. What is the total quantity, revenue and discount for each category?

SELECT
	pd.category_id,
	pd.category_name,
	sum(s.qty) AS total_quantity,
	sum(s.price * s.qty) AS gross_revenue,
	round(sum((s.price * s.qty) * (s.discount::NUMERIC / 100)), 2) AS total_discounts,
	round(sum((s.price * s.qty) * (1 - discount::NUMERIC / 100)), 2) AS total_revenue
FROM
	balanced_tree.product_details AS pd
JOIN
	balanced_tree.sales AS s ON s.prod_id = pd.product_id
GROUP BY
	pd.category_id,
	pd.category_name

-- Results:
	
category_id|category_name|total_quantity|gross_revenue|total_discounts|total_revenue|
-----------+-------------+--------------+-------------+---------------+-------------+
          2|Mens         |         22482|       714120|       86607.71|    627512.29|
          1|Womens       |         22734|       575333|       69621.43|    505711.57|
          
-- 5. What is the top selling product for each category?
          
WITH top_ranking AS         
(
	SELECT
		pd.category_id,
		pd.category_name,
		pd.product_name,
		sum(qty) AS total_quantity,
		rank() OVER (PARTITION BY pd.category_id ORDER BY sum(qty) desc) AS rnk
	FROM
		balanced_tree.product_details AS pd
	JOIN
		balanced_tree.sales AS s ON s.prod_id = pd.product_id
	GROUP BY
		pd.category_id,
		pd.product_name,
		pd.category_name
)
SELECT
	category_id,
	category_name,
	product_name AS top_ranking_products,
	total_quantity
FROM 
	top_ranking
WHERE
	rnk = 1
          
-- Results:
	
category_id|category_name|top_ranking_products        |total_quantity|
-----------+-------------+----------------------------+--------------+
          1|Womens       |Grey Fashion Jacket - Womens|          3876|
          2|Mens         |Blue Polo Shirt - Mens      |          3819|

-- 6. What is the percentage split of revenue by product for each segment?

SELECT
	segment_id,
	segment_name,
	product_id,
	product_name,
	total_revenue,
	round(100 * (total_revenue / sum(total_revenue)OVER(PARTITION BY segment_id)), 2) AS revenue_percentage
FROM
     (SELECT
		pd.segment_id,
		pd.segment_name,
		pd.product_id,
		pd.product_name,
		round(sum((s.price * s.qty) * (1 - discount::NUMERIC / 100)), 2) AS total_revenue
	FROM
		balanced_tree.product_details AS pd
	JOIN
		balanced_tree.sales AS s ON s.prod_id = pd.product_id
	GROUP BY 
		pd.product_id,
		pd.product_name,
		pd.segment_id,
		pd.segment_name
	ORDER BY
		segment_id) AS tmp

-- Results:
		
segment_id|segment_name|product_id|product_name                    |total_revenue|revenue_percentage|
----------+------------+----------+--------------------------------+-------------+------------------+
         3|Jeans       |e83aa3    |Black Straight Jeans - Womens   |    106407.04|             58.14|
         3|Jeans       |c4a632    |Navy Oversized Jeans - Womens   |     43992.39|             24.04|
         3|Jeans       |e31d39    |Cream Relaxed Jeans - Womens    |     32606.60|             17.82|
         4|Jacket      |9ec847    |Grey Fashion Jacket - Womens    |    183912.12|             56.99|
         4|Jacket      |72f5d4    |Indigo Rain Jacket - Womens     |     62740.47|             19.44|
         4|Jacket      |d5e9a6    |Khaki Suit Jacket - Womens      |     76052.95|             23.57|
         5|Shirt       |5d267b    |White Tee Shirt - Mens          |    133622.40|             37.48|
         5|Shirt       |2a2353    |Blue Polo Shirt - Mens          |    190863.93|             53.53|
         5|Shirt       |c8d436    |Teal Button Up Shirt - Mens     |     32062.40|              8.99|
         6|Socks       |2feb6b    |Pink Fluro Polkadot Socks - Mens|     96377.73|             35.57|
         6|Socks       |f084eb    |Navy Solid Socks - Mens         |    119861.64|             44.24|
         6|Socks       |b9a74d    |White Striped Socks - Mens      |     54724.19|             20.20|



                  
                  
                  
       