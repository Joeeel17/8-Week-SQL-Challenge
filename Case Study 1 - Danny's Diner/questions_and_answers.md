# Danny's Diner
## Questions and Answers
### by jaime.m.shaker@gmail.com


#### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT 
	s.customer_id AS c_id,
	SUM(m.price) AS total_spent
FROM 
	sales AS s
JOIN
	 menu AS m 
ON s.product_id = m.product_id
GROUP BY 
	c_id
ORDER BY 
	total_spent DESC;
````

**Results:**

c_id|total_spent|
----|-----------|
A   |         76|
B   |         74|
C   |         36|

#### 2. How many days has each customer visited the restaurant?

````sql
SELECT 
	customer_id AS c_id,
	COUNT(DISTINCT order_date) AS n_days
FROM sales
GROUP BY customer_id
ORDER BY n_days DESC;
````

**Results:**

c_id|n_days|
----|------|
B   |     6|
A   |     4|
C   |     2|


#### 3. What was the first item from the menu purchased by each customer?

1. Create a CTE and join the sales and menu tables.
2. Use the row_number window function to give a unique row number to every item purchased by the customer.
3. Order the items by the order_date
4.  Select customer_id and product_name for every item where the row_number is '1'

````sql
WITH cte_first_order AS
(
	SELECT
		s.customer_id AS c_id,
		m.product_name,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date, s.product_id) AS rn
	FROM 
		sales AS s
	JOIN 
		menu AS m 
	ON s.product_id = m.product_id
)
SELECT 
	c_id,
	product_name
FROM 
	cte_first_order
WHERE 
	rn = 1
````

**Results:**

c_id|product_name|
----|------------|
A   |sushi       |
B   |curry       |
C   |ramen       |

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT 
	m.product_name,
	COUNT(s.product_id) AS n_purchased
FROM 
	menu AS m
JOIN 
	sales AS s 
ON 
	m.product_id = s.product_id
GROUP BY 
	m.product_name
ORDER BY 
	n_purchased DESC
LIMIT 1
````

**Results:**

product_name|n_purchased|
------------|-----------|
ramen       |          8|

#### 5. Which item was the most popular for each customer?

1. Create a CTE and join the sales and menu tables.
2. Use the rank window function to rank every item purchased by the customer.
3. Order the items by the numbers or times purchase  in descending order (highest to lowest).
4.  Select 'everything' for every item where the rank is '1'.

````sql
WITH cte_most_popular AS
(
	SELECT 
		s.customer_id AS c_id,
		m.product_name AS p_name,
		RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(m.product_id) DESC) AS rnk
	FROM 
		sales AS s
	JOIN 
		menu AS m
	ON 
		s.product_id = m.product_id
	GROUP BY 
		c_id,
		p_name
)
SELECT 
	*
FROM 
	cte_most_popular
WHERE 
	rnk = 1;
````

**Results:**

c_id|p_name|rnk|
----|------|---|
A   |ramen |  1|
B   |sushi |  1|
B   |curry |  1|
B   |ramen |  1|
C   |ramen |  1|

❗ **Note** customer_id: **B** had a tie with all three items on the menu.

