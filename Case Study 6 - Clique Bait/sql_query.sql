/* 
 * Clique Bait
 * Case Study #6 Questions & Answers
 *  
*/

/*
	2. Digital Analysis
*/

-- 1. How many users are there?

SELECT 
	count(DISTINCT user_id) AS n_users
FROM 
	clique_bait.users;

-- Results:

n_users|
-------+
    500|
    
    
-- How many cookies does each user have on average?

SELECT
	round(avg(n_cookies), 2) AS avg_cookies
from
	(SELECT 
		DISTINCT user_id,
		count(DISTINCT cookie_id) AS n_cookies
	FROM 
		clique_bait.users
	GROUP BY
		user_id) AS tmp

-- Or
		
SELECT
	round(avg(count(DISTINCT cookie_id)) OVER (), 2) AS avg_cookies
FROM 
	clique_bait.users
GROUP BY
	user_id
LIMIT 1;

-- Results:

avg_cookies|
-----------+
       3.56|
       
-- 3. What is the unique number of visits by all users per month?
 
SELECT
	visited_month,
	sum(n_visits) AS total_visits
from
	(SELECT
		DISTINCT cookie_id,
		count(DISTINCT visit_id) AS n_visits,
		extract('month' FROM event_time) AS visited_month
	FROM clique_bait.events
	GROUP BY 
		cookie_id,
		visited_month) AS tmp
GROUP BY 
	visited_month
ORDER BY visited_month;

-- Results:

visited_month|total_visits|
-------------+------------+
          1.0|         876|
          2.0|        1488|
          3.0|         916|
          4.0|         248|
          5.0|          36|
          
-- 4. What is the number of events for each event type?         
	
SELECT
	e.event_type,
	ei.event_name,
	count(e.event_type) AS n_events
FROM
	clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
ON e.event_type = ei.event_type
GROUP BY
	e.event_type,
	ei.event_name
ORDER BY 
	e.event_type
	
-- Results:
	
event_type|event_name   |n_events|
----------+-------------+--------+
         1|Page View    |   20928|
         2|Add to Cart  |    8451|
         3|Purchase     |    1777|
         4|Ad Impression|     876|
         5|Ad Click     |     702|
	
-- 5. What is the percentage of visits which have a purchase event?

SELECT
	round(
		100 * 
			sum(
				CASE 
					WHEN event_type = 3 THEN 1
					ELSE 0
				end)::numeric 
			/ count(DISTINCT visit_id), 2) AS purchase_percentage
FROM 
	clique_bait.events
	
-- Results:

purchase_percentage|
-------------------+
              49.86|
	
	
-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
 
WITH get_counts AS              
	(SELECT
		visit_id,
		-- flag as visit_id having visited checkout page and had page view event.
		sum(
			CASE
				WHEN page_id = 12 AND event_type = 1 
					THEN 1
				ELSE
					0
			END	
		) AS checked_out,
		-- flag as visit_id having made a purchase.
		sum(
			CASE
				WHEN event_type = 3 
					THEN 1
				ELSE
					0
			END	
		) AS purchased
	FROM
		clique_bait.events
	GROUP BY
		visit_id)
	
SELECT
	-- Subtract percentage that did visit and purchase from 100%
	round(100 * (1 - sum(purchased)::numeric / sum(checked_out)), 2) AS visit_percentage
FROM
	get_counts

-- Results:

visit_percentage|
----------------+
           15.50|
           
-- 7. What are the top 3 pages by number of views?
           
SELECT
	e.page_id,
	ph.page_name,
	count(e.page_id) AS n_page
FROM
	clique_bait.events AS e
JOIN
	clique_bait.page_hierarchy AS ph
ON
	e.page_id = ph.page_id
WHERE e.event_type = 1
GROUP BY
	e.page_id,
	ph.page_name
ORDER BY
	n_page DESC
LIMIT 
	3
	
-- Results:

page_id|page_name   |n_page|
-------+------------+------+
      2|All Products|  3174|
     12|Checkout    |  2103|
      1|Home Page   |  1782|
      
-- 8. What is the number of views and cart adds for each product category?
      
SELECT
	ph.product_category,
	sum(
		CASE
			WHEN e.event_type = 1 THEN 1
			ELSE 0
		END	
	) AS page_views,
	sum(
		CASE
			WHEN e.event_type = 2 THEN 1
			ELSE 0
		END	
	) AS add_to_cart
FROM
	clique_bait.page_hierarchy AS ph
JOIN 
	clique_bait.events AS e
ON
	e.page_id = ph.page_id
WHERE
	ph.product_category IS NOT null
GROUP BY
	ph.product_category
ORDER BY 
	page_views DESC
	
-- Results:
	
product_category|page_views|add_to_cart|
----------------+----------+-----------+
Shellfish       |      6204|       3792|
Fish            |      4633|       2789|
Luxury          |      3032|       1870|
      
-- 9. What are the top 3 products by purchases?

WITH get_purchases AS (
	SELECT
		visit_id
	FROM
		clique_bait.events
	WHERE
		event_type = 3
)	
SELECT
	ph.page_name,
	sum(
		CASE
			WHEN e.event_type = 2 THEN 1
			ELSE 0
		END	
	) AS top_3_purchased
FROM
	clique_bait.page_hierarchy AS ph
JOIN 
	clique_bait.events AS e
ON
	e.page_id = ph.page_id
JOIN
	get_purchases AS gp
ON
	e.visit_id = gp.visit_id 
WHERE
	ph.product_category IS NOT NULL
AND
	ph.page_name NOT in('1','2','12','13')
AND
	gp.visit_id = e.visit_id
GROUP BY
	ph.page_name
ORDER BY
	top_3_purchased DESC
LIMIT 3
	
-- Results:

page_name|top_3_purchased|
---------+---------------+
Lobster  |            754|
Oyster   |            726|
Crab     |            719|
	
/*
	3. Product Funnel Analysis	

	Using a single SQL query - create a new output table which has the following details:

	How many times was each product viewed?
	How many times was each product added to cart?
	How many times was each product added to a cart but not purchased (abandoned)?
	How many times was each product purchased?	
*/	

CREATE TEMP TABLE product_info AS 
(
	WITH product_viewed AS 
	(
		SELECT
			ph.page_id,
			sum(
				CASE
					WHEN event_type = 1 THEN 1
					ELSE 0
				END
			 ) AS n_page_views,
			 sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			 ) AS n_added_to_cart
		FROM
			page_hierarchy AS ph
		JOIN
			events AS e
		ON ph.page_id = e.page_id
		WHERE
			ph.product_id IS NOT NULL
		GROUP BY
			ph.page_id
	),
	product_purchased AS 
	(		
		SELECT
			e.page_id,
			sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			 ) AS purchased_from_cart
		FROM
			page_hierarchy AS ph
		JOIN
			events AS e
		ON ph.page_id = e.page_id
		WHERE
			ph.product_id IS NOT NULL
		AND
			exists(
				SELECT
					visit_id
				FROM
					clique_bait.events
				WHERE
					event_type = 3
				AND
					e.visit_id = visit_id
			)
		AND
			ph.page_id NOT IN (1,2,12,13)
		GROUP BY
			e.page_id	
	),
	product_abandoned AS 
	(		
		SELECT
			e.page_id,
			sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			 ) AS abandoned_in_cart
		FROM
			page_hierarchy AS ph
		JOIN
			events AS e
		ON ph.page_id = e.page_id
		WHERE
			ph.product_id IS NOT NULL
		AND
			NOT exists(
				SELECT
					visit_id
				FROM
					clique_bait.events
				WHERE
					event_type = 3
				AND
					e.visit_id = visit_id
			)
		AND
			ph.page_id NOT IN (1,2,12,13)
		GROUP BY
			e.page_id	
	)
	SELECT
		ph.page_id,
		ph.page_name,
		ph.product_category,
		pv.n_page_views,
		pv.n_added_to_cart,
		pp.purchased_from_cart,
		pa.abandoned_in_cart
	FROM
		page_hierarchy AS ph
	JOIN
		product_viewed AS pv ON pv.page_id = ph.page_id
	JOIN
		product_purchased AS pp ON pp.page_id = ph.page_id
	JOIN
		product_abandoned AS pa ON pa.page_id = ph.page_id
);

SELECT * FROM product_info;

-- Results:

page_id|page_name     |product_category|n_page_views|n_added_to_cart|purchased_from_cart|abandoned_in_cart|
-------+--------------+----------------+------------+---------------+-------------------+-----------------+
      3|Salmon        |Fish            |        1559|            938|                711|              227|
      4|Kingfish      |Fish            |        1559|            920|                707|              213|
      5|Tuna          |Fish            |        1515|            931|                697|              234|
      6|Russian Caviar|Luxury          |        1563|            946|                697|              249|
      7|Black Truffle |Luxury          |        1469|            924|                707|              217|
      8|Abalone       |Shellfish       |        1525|            932|                699|              233|
      9|Lobster       |Shellfish       |        1547|            968|                754|              214|
     10|Crab          |Shellfish       |        1564|            949|                719|              230|
     11|Oyster        |Shellfish       |        1568|            943|                726|              217|

-- Additionally, create another table which further aggregates the data for the above points but this time for each 
-- product category instead of individual products.

DROP TABLE IF EXISTS category_info;
CREATE TEMP TABLE category_info AS (
	SELECT
		product_category,
		sum(n_page_views) AS total_page_view,
		sum(n_added_to_cart) AS total_added_to_cart,
		sum(purchased_from_cart) AS total_purchased,
		sum(abandoned_in_cart) AS total_abandoned
	FROM
		product_info
	GROUP BY
		product_category
);

SELECT * FROM category_info;
	
-- Results:

product_category|total_page_view|total_added_to_cart|total_purchased|total_abandoned|
----------------+---------------+-------------------+---------------+---------------+
Luxury          |           3032|               1870|           1404|            466|
Shellfish       |           6204|               3792|           2898|            894|
Fish            |           4633|               2789|           2115|            674|
	
-- Use your 2 new output tables - answer the following questions:	

-- 1. Which product had the most views, cart adds and purchases?
	
WITH rankings AS 
(
	SELECT
		page_name,
		RANK() OVER (ORDER BY n_page_views DESC) AS most_page_views,
		RANK() OVER (ORDER BY n_added_to_cart DESC) AS most_cart_adds,
		RANK() OVER (ORDER BY purchased_from_cart DESC) AS most_purchased
	FROM
		product_info
)
SELECT
	page_name,
	'Most Viewed' AS product
FROM
	rankings
WHERE 
	most_page_views = 1
UNION
SELECT
	page_name,
	'Most Added' AS product
FROM
	rankings
WHERE 
	most_cart_adds = 1
UNION
SELECT
	page_name,
	'Most Purchased' AS product
FROM
	rankings
WHERE 
	most_purchased = 1
	
-- Results:

page_name|product       |
---------+--------------+
Oyster   |Most Viewed   |
Lobster  |Most Added    |
Lobster  |Most Purchased|
	
-- 2. Which product was most likely to be abandoned?

SELECT
	page_name
from
	(SELECT
		page_name,
		abandoned_in_cart
	FROM
		product_info
	ORDER BY
		abandoned_in_cart DESC
	LIMIT 1) AS tmp
	
-- Results:

page_name     |
--------------+
Russian Caviar|

-- Initially I read the question as "Which is the most abandoned product".  However, the question is
-- asking which product is 'most likely' to be abandoned.  So we must check which item has the highest
-- probability of being viewed and abandoned.

SELECT
	page_name,
	-- Subtract difference from the largest purchased item
	100 - round(100 * purchased_from_cart::NUMERIC / n_added_to_cart, 2) AS abandoned_ratio
FROM
	product_info
ORDER BY 
	abandoned_ratio DESC
LIMIT 1

-- Results:

page_name     |abandoned_ratio|
--------------+---------------+
Russian Caviar|          26.32|
	

