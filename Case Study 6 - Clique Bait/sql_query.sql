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

-- Results:

avg_cookies|
-----------+
       3.56|
    

