/* 
 * Data Bank
 * Case Study #4 Questions
 *  
*/

-- A. Customer Nodes Exploration
 
-- 1. How many unique nodes are there on the Data Bank system?

SELECT
	sum(n_nodes) AS total_nodes
FROM
	(
	SELECT
		region_id,
		count(DISTINCT node_id) AS n_nodes
	FROM
		customer_nodes
	GROUP BY
		region_id) AS tmp

-- Results:

total_nodes|
-----------+
         25|
      
-- 2. What is the number of nodes per region? 

SELECT
	r.region_name,
	count(DISTINCT cn.node_id) AS node_count
FROM
	customer_nodes AS cn
JOIN regions AS r
ON
	r.region_id = cn.region_id
GROUP BY
	r.region_name;
	
-- Results:

region_name|node_count|
-----------+----------+
Africa     |         5|
America    |         5|
Asia       |         5|
Australia  |         5|
Europe     |         5|

-- 3. How many customers are allocated to each region?

SELECT
	r.region_name,
	count(DISTINCT cn.customer_id) AS customer_count
FROM
	customer_nodes AS cn
JOIN regions AS r
ON
	r.region_id = cn.region_id
GROUP BY
	r.region_name;

-- Results:

region_name|customer_count|
-----------+--------------+
Africa     |           102|
America    |           105|
Asia       |            95|
Australia  |           110|
Europe     |            88|

-- 4. How many days on average are customers reallocated to a different node?
-- Note that we will exlude data from any record with 9999 end date.
-- Note that we will NOT count when the node does not change from one start date to another.

SELECT
	CEIL(avg(end_date - start_date)) AS rounded_up,
	round(avg(end_date - start_date), 1) AS avg_days,
	floor(avg(end_date - start_date)) AS rounded_down
FROM
	(
	SELECT
		customer_id,
		node_id,
		start_date,
		end_date,
		LAG(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_node
	FROM
		customer_nodes
	WHERE 
		EXTRACT(YEAR FROM end_date) != '9999'
	ORDER BY
		customer_id,
		start_date) AS tmp
WHERE
	prev_node != node_id

-- Results:
	
rounded_up|avg_days|rounded_down|
----------+--------+------------+
        15|    14.6|          14|
        
-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH perc_reallocation AS (        
	SELECT
		region_name,
		PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY end_date - start_date) AS "50th_perc",
		PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY end_date - start_date) AS "80th_perc",
		PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY end_date - start_date) AS "95th_perc"
	FROM
		(
		SELECT
			r.region_name,
			cn.customer_id,
			cn.node_id,
			cn.start_date,
			cn.end_date,
			LAG(cn.node_id) OVER (PARTITION BY cn.customer_id ORDER BY cn.start_date) AS prev_node
		FROM
			customer_nodes AS cn
		JOIN regions AS r
		ON r.region_id = cn.region_id
		WHERE 
			EXTRACT(YEAR FROM cn.end_date) != '9999'
		ORDER BY
			cn.customer_id,
			cn.start_date) AS tmp
	WHERE
		prev_node != node_id 
	GROUP BY 
		region_name
)

SELECT
	region_name,
	ceil("50th_perc") AS median,
	ceil("80th_perc") AS "80th_percentile",
	ceil("95th_perc") AS "95th_percentile"
FROM
	perc_reallocation
        
-- Results:

region_name|median|80th_percentile|95th_percentile|
-----------+------+---------------+---------------+
Africa     |  15.0|           23.0|           28.0|
America    |  15.0|           23.0|           27.0|
Asia       |  14.0|           23.0|           27.0|
Australia  |  16.0|           23.0|           28.0|
Europe     |  15.0|           24.0|           28.0|
        

-- B. Customer Transactions

-- 1. What is the unique count and total amount for each transaction type? 

SELECT
	DISTINCT txn_type AS transaction_type,
	count(*) AS transaction_count,
	sum(txn_amount) AS total_transactions
FROM
	customer_transactions
GROUP BY 
	txn_type

-- OR
        
SELECT 
	DISTINCT txn_type AS transaction_type,
	count(
		CASE
			WHEN txn_type = 'purchase' THEN 1
			WHEN txn_type = 'withdrawal' THEN 1
			WHEN txn_type = 'deposit' THEN 1
			ELSE null
		END 
	) AS transaction_count,
	sum(
		CASE
			WHEN txn_type = 'purchase' THEN txn_amount
			WHEN txn_type = 'withdrawal' THEN txn_amount
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE 0	
		END 
	) AS total_transactions
FROM
	customer_transactions
GROUP BY transaction_type
	
-- Results:

transaction_type|transaction_count|total_transactions|
----------------+-----------------+------------------+
deposit         |             2671|           1359168|
purchase        |             1617|            806537|
withdrawal      |             1580|            793003|

-- 2. What is the average total historical deposit counts and amounts for all customers?

SELECT
	round(avg(deposits_count)) AS avg_deposit_count,
	round(avg(total_deposit_amount)) AS avg_deposit_amount
from
	(SELECT
		customer_id,
		count(*) AS deposits_count,
		avg(txn_amount) AS total_deposit_amount
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY
		customer_id) AS tmp

-- Results:
		
avg_deposit_count|avg_deposit_amount|
-----------------+------------------+
                5|               509|

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

SELECT
	transaction_month,
	count(customer_id) AS customer_count
from
	(SELECT
		DISTINCT customer_id,
		date_part('month', txn_date) AS transaction_month,
		count(
			CASE
				WHEN txn_type = 'purchase' THEN 1
				ELSE null
			END  
		) AS purchase_count,
		count(
			CASE
				WHEN txn_type = 'withdrawal' THEN 1
				ELSE null
			END  
		) AS withdrawal_count,
		count(
			CASE
				WHEN txn_type = 'deposit' THEN 1
				ELSE null
			END  
		) AS deposit_count
	FROM customer_transactions
	GROUP BY
		customer_id,
		transaction_month) AS tmp
WHERE deposit_count > 1
AND (purchase_count >= 1
OR withdrawal_count >= 1)
GROUP BY transaction_month
ORDER BY transaction_month

-- Results:

transaction_month|customer_count|
-----------------+--------------+
              1.0|           168|
              2.0|           181|
              3.0|           192|
              4.0|            70|
              
-- 4. What is the closing balance for each customer at the end of the month?

WITH deposits AS (
	SELECT
		DISTINCT customer_id,
		date_part('month', txn_date) AS month,
		sum(txn_amount) AS total_deposits
	FROM
		customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY 
		customer_id,
		month
),
withdrawals AS (
	SELECT
		DISTINCT customer_id,
		date_part('month', txn_date) AS month,
		sum(txn_amount) AS total_withdrawals
	FROM
		customer_transactions
	WHERE txn_type = 'withdrawal'
	OR txn_type = 'purchase'
	GROUP BY 
		customer_id,
		month
)

SELECT
	d.customer_id,
	d.month
FROM deposits AS d
ORDER BY 
	d.customer_id,
	d.month

    
