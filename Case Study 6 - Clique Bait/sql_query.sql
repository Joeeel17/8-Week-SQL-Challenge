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
    

