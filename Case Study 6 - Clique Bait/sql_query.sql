/* 
 * Clique Bait
 * Case Study #6 Questions & Answers
 *  
*/

-- A. Digital Analysis

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
      
    
          
           

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

