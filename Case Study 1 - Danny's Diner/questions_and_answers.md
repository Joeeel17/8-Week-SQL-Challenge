# Danny's Diner
## Questions and Answers
### by jaime.m.shaker@gmail.com


#### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id AS c_id,
	SUM(m.price) AS total_spent
FROM sales AS s
	JOIN menu AS m ON s.product_id = m.product_id
GROUP BY c_id
ORDER BY total_spent DESC;
````

**Results:**

c_id|total_spent|
----|-----------|
A   |         76|
B   |         74|
C   |         36|

#### 2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id AS c_id,
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
WITH cte_first_order AS (
	SELECT s.customer_id AS c_id,
		m.product_name,
		ROW_NUMBER() OVER (
			PARTITION BY s.customer_id
			ORDER BY s.order_date,
				s.product_id
		) AS rn
	FROM sales AS s
		JOIN menu AS m ON s.product_id = m.product_id
)
SELECT c_id,
	product_name
FROM cte_first_order
WHERE rn = 1
````

**Results:**

c_id|product_name|
----|------------|
A   |sushi       |
B   |curry       |
C   |ramen       |

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT m.product_name,
	COUNT(s.product_id) AS n_purchased
FROM menu AS m
	JOIN sales AS s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY n_purchased DESC
LIMIT 1;
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
WITH cte_most_popular AS (
	SELECT s.customer_id AS c_id,
		m.product_name AS p_name,
		RANK() OVER (
			PARTITION BY customer_id
			ORDER BY COUNT(m.product_id) DESC
		) AS rnk
	FROM sales AS s
		JOIN menu AS m ON s.product_id = m.product_id
	GROUP BY c_id,
		p_name
)
SELECT *
FROM cte_most_popular
WHERE rnk = 1;
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

#### 6. Which item was purchased first by the customer after they became a member?

1. Create a CTE and join the sales and menu tables to the members table.
2. Use the rank window function to rank every item purchased by the customer.
3. Order the items by the numbers or times purchase in ascending order (lowest to highest).
4. Filter the results to orders made after the join date.
5. Select customer and product where rank = '1'.

````sql
WITH cte_first_member_purchase AS (
	SELECT m.customer_id AS p,
		m2.product_name AS product,
		RANK() OVER (
			PARTITION BY m.customer_id
			ORDER BY s.order_date
		) AS rnk
	FROM members AS m
		JOIN sales AS s ON s.customer_id = m.customer_id
		JOIN menu AS m2 ON s.product_id = m2.product_id
	WHERE s.order_date >= m.join_date
)
SELECT customer,
	product
FROM cte_first_member_purchase
WHERE rnk = 1;
````

**Results:**

customer|product|
--------|-------|
A       |curry  |
B       |sushi  |

#### 7. Which item was purchased just before the customer became a member?

1. Create a CTE and join the sales and menu tables to the members table.
2. Use the rank window function to rank every item purchased by the customer.
3. Order the items by the numbers or times purchase in descending order (highest to lowest).
4. Filter the results to orders made before the join date.
5. Select customer and product where rank = '1'.

````sql
WITH cte_last_nonmember_purchase AS (
	SELECT m.customer_id AS customer,
		m2.product_name AS product,
		RANK() OVER (
			PARTITION BY m.customer_id
			ORDER BY s.order_date DESC
		) AS rnk
	FROM members AS m
		JOIN sales AS s ON s.customer_id = m.customer_id
		JOIN menu AS m2 ON s.product_id = m2.product_id
	WHERE s.order_date < m.join_date
)
SELECT customer,
	product
FROM cte_last_nonmember_purchase
WHERE rnk = 1;
````

**Results:**

customer|product|
--------|-------|
A       |sushi  |
A       |curry  |
B       |sushi  |

#### 8. What is the total items and amount spent for each member before they became a member?

1. Create a CTE and join the sales and menu tables to the members table.
2. Get the customer_id, total number of items and the total amount spent.
3. Filter the results to orders made before the join date.
4. Group by the customer id.

````sql
WITH cte_total_nonmember_purchase AS (
	SELECT m.customer_id AS customer,
		COUNT(m2.product_id) AS total_items,
		SUM(m2.price) AS total_spent
	FROM members AS m
		JOIN sales AS s ON s.customer_id = m.customer_id
		JOIN menu AS m2 ON s.product_id = m2.product_id
	WHERE s.order_date < m.join_date
	GROUP BY customer
)
SELECT *
FROM cte_total_nonmember_purchase
ORDER BY customer;
````

**Results:**

customer|total_items|total_spent|
--------|-----------|-----------|
A       |          2|         25|
B       |          3|         40|

#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

1. Create a CTE and join the sales and menu tables to the members table.
2. Use a case statement inside of the sum function to calculate total points including 2x multiplier.
3. Filter the results to orders made before the join date.
4. Group by the customer id.

````sql
WITH cte_total_member_points AS (
	SELECT m.customer_id AS customer,
		SUM(
			CASE
				WHEN m2.product_name = 'sushi' THEN (m2.price * 20)
				ELSE (m2.price * 10)
			END
		) AS member_points
	FROM members AS m
		JOIN sales AS s ON s.customer_id = m.customer_id
		JOIN menu AS m2 ON s.product_id = m2.product_id
	GROUP BY customer
)
SELECT *
FROM cte_total_member_points
````

**Results:**

customer|member_points|
--------|-------------|
A       |          860|
B       |          940|

#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

1. Create a CTE and join the sales and menu tables to the members table.
2. Use a case statement inside of the sum function to calculate total points including 2x multiplier.
3. If the order is after membship or within the 6 days after membership then use the 2x multiplier on all items. Else, only on sushi.
4. Filter the results to orders made in Jan 2021.
5. Group by the customer id.

````sql
WITH cte_jan_member_points AS (
	SELECT m.customer_id AS customer,
		SUM(
			CASE
				WHEN s.order_date < m.join_date THEN 
					CASE
						WHEN m2.product_name = 'sushi' THEN (m2.price * 20)
						ELSE (m2.price * 10)
					END
				WHEN s.order_date > (m.join_date + 6) THEN 
					CASE
						WHEN m2.product_name = 'sushi' THEN (m2.price * 20)
						ELSE (m2.price * 10)
					END
				ELSE (m2.price * 20)
			END
		) AS member_points
	FROM members AS m
		JOIN sales AS s ON s.customer_id = m.customer_id
		JOIN menu AS m2 ON s.product_id = m2.product_id
	WHERE s.order_date <= '2021-01-31'
	GROUP BY customer
)
SELECT *
FROM cte_jan_member_points
ORDER BY customer;
````

**Results:**

customer|member_points|
--------|-------------|
A       |         1370|
B       |          820|