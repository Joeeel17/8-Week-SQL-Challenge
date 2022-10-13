# Pizza Runner
## Questions and Answers
### by jaime.m.shaker@gmail.com

###Pizza Metrics

❗ **Note** ❗
The customer_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).
We will create a temporary table where all forms of null will be transformed to null (data type).

#### The orginal table structure.

````sql
SELECT * FROM customer_orders;
````

**Results:**

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
 1|        101|       1|          |      |2020-01-01 18:05:02.000|
2|        101|       1|          |      |2020-01-01 19:00:52.000|
3|        102|       1|          |      |2020-01-02 23:51:23.000|
3|        102|       2|          |      |2020-01-02 23:51:23.000|
4|        103|       1|4         |      |2020-01-04 13:23:46.000|
4|        103|       1|4         |      |2020-01-04 13:23:46.000|
4|        103|       2|4         |      |2020-01-04 13:23:46.000|
5|        104|       1|null      |1     |2020-01-08 21:00:29.000|
6|        101|       2|null      |null  |2020-01-08 21:03:13.000|
7|        105|       2|null      |1     |2020-01-08 21:20:29.000|
8|        102|       1|null      |null  |2020-01-09 23:54:33.000|
9|        103|       1|4         |1, 5  |2020-01-10 11:22:59.000|
10|        104|       1|null      |null  |2020-01-11 18:34:49.000|
10|        104|       1|2, 6      |1, 4  |2020-01-11 18:34:49.000|


````sql
DROP TABLE IF EXISTS new_customer_orders;
CREATE TEMP TABLE new_customer_orders AS (
	SELECT order_id,
		customer_id,
		pizza_id,
		CASE
			WHEN exclusions = ''
			OR exclusions LIKE 'null' THEN null
			ELSE exclusions
		END AS exclusions,
		CASE
			WHEN extras = ''
			OR extras LIKE 'null' THEN null
			ELSE extras
		END AS extras,
		order_time
	FROM customer_orders
);
      
SELECT * FROM new_customer_orders;
````

**Results:**

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
1|        101|       1|          |      |2020-01-01 18:05:02.000|
2|        101|       1|          |      |2020-01-01 19:00:52.000|
3|        102|       1|          |      |2020-01-02 23:51:23.000|
3|        102|       2|          |      |2020-01-02 23:51:23.000|
4|        103|       1|4         |      |2020-01-04 13:23:46.000|
4|        103|       1|4         |      |2020-01-04 13:23:46.000|
4|        103|       2|4         |      |2020-01-04 13:23:46.000|
5|        104|       1|          |1     |2020-01-08 21:00:29.000|
6|        101|       2|          |      |2020-01-08 21:03:13.000|
7|        105|       2|          |1     |2020-01-08 21:20:29.000|
8|        102|       1|          |      |2020-01-09 23:54:33.000|
9|        103|       1|4         |1, 5  |2020-01-10 11:22:59.000|
10|        104|       1|          |      |2020-01-11 18:34:49.000|
10|        104|       1|2, 6      |1, 4  |2020-01-11 18:34:49.000|

**Clean Data**

The runner_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The distance and duration columns have text and numbers.  We will remove the text values and convert to numeric values.
We will convert all 'null' (text) and 'NaN' values in the cancellation column to null (data type).
We will convert the pickup_time (varchar) column to a timestamp data type.

#### The orginal table structure.

````sql
SELECT * FROM runner_orders;
````

**Results:**

order_id|runner_id|pickup_time        |distance|duration  |cancellation           |
--------|---------|-------------------|--------|----------|-----------------------|
1|        1|2020-01-01 18:15:34|20km    |32 minutes|                       |
2|        1|2020-01-01 19:10:54|20km    |27 minutes|                       |
3|        1|2020-01-03 00:12:37|13.4km  |20 mins   |                       |
4|        2|2020-01-04 13:53:03|23.4    |40        |                       |
5|        3|2020-01-08 21:10:57|10      |15        |                       |
6|        3|null               |null    |null      |Restaurant Cancellation|
7|        2|2020-01-08 21:30:45|25km    |25mins    |null                   |
8|        2|2020-01-10 00:15:02|23.4 km |15 minute |null                   |
9|        2|null               |null    |null      |Customer Cancellation  |
10|        1|2020-01-11 18:50:20|10km    |10minutes |null                   |

````sql
DROP TABLE IF EXISTS new_runner_orders;
CREATE TEMP TABLE new_runner_orders AS (
	SELECT order_id,
		runner_id,
		CASE
			WHEN pickup_time LIKE 'null' THEN NULL
			ELSE pickup_time
		END::timestamp AS pickup_time,
		-- Return null value if both arguments are equal
		-- Use regex to match only numeric values and decimal point.
		-- Convert to numeric datatype
		NULLIF(regexp_replace(distance, '[^0-9.]', '', 'g'), '')::NUMERIC AS distance,
		NULLIF(regexp_replace(duration, '[^0-9.]', '', 'g'), '')::NUMERIC AS duration,
		CASE
			WHEN cancellation LIKE 'null'
			OR cancellation LIKE 'NaN'
			OR cancellation LIKE '' THEN NULL
			ELSE cancellation
		END AS cancellation
	FROM runner_orders
);

SELECT * FROM new_runner_orders;
````

**Results:**

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------|---------|-----------------------|--------|--------|-----------------------|
1|        1|2020-01-01 18:15:34.000|      20|      32|                       |
2|        1|2020-01-01 19:10:54.000|      20|      27|                       |
3|        1|2020-01-03 00:12:37.000|    13.4|      20|                       |
4|        2|2020-01-04 13:53:03.000|    23.4|      40|                       |
5|        3|2020-01-08 21:10:57.000|      10|      15|                       |
6|        3|                       |        |        |Restaurant Cancellation|
7|        2|2020-01-08 21:30:45.000|      25|      25|                       |
8|        2|2020-01-10 00:15:02.000|    23.4|      15|                       |
9|        2|                       |        |        |Customer Cancellation  |
10|        1|2020-01-11 18:50:20.000|      10|      10|                       |

#### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT
	count(*) AS n_orders
FROM
	new_customer_orders;
````

**Results:**

n_orders|
--------|
14|

#### 2. How many unique customer orders were made?

````sql
SELECT count(DISTINCT order_id) AS n_orders
FROM new_customer_orders;
````

**Results:**

n_orders|
--------|
10|


#### 3. How many successful orders were delivered by each runner?

1. Count only completed orders.

````sql
SELECT runner_id,
	count(order_id) AS n_orders
FROM new_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY n_orders DESC;
````

**Results:**

runner_id|n_orders|
---------|--------|
1|       4|
2|       3|
3|       1|

#### 4. How many of each type of pizza was delivered?

1. Join the pizza_names table to customer_orders to count pizza types.
2. Join runner_order to count number of completed deliveries.
3. Filter out any cancelled orders.

````sql
SELECT p.pizza_name,
	count(c.*) AS n_pizza_type
FROM new_customer_orders AS c
	JOIN pizza_names AS p ON p.pizza_id = c.pizza_id
	JOIN new_runner_orders AS r ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY p.pizza_name
ORDER BY n_pizza_type DESC;
````

**Results:**

pizza_name|n_pizza_type|
----------|------------|
Meatlovers|           9|
Vegetarian|           3|

#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

1. Use a case statement to get the sum total of all meat_lovers pizzas ordered.
2. Use a case statement to get the sum total of all vegetarian pizzas ordered.
3. Group by customer_id
4. Order by customer_id  in ascending order.

````sql
SELECT customer_id,
	sum(
		CASE
			WHEN pizza_id = 1 THEN 1
			ELSE 0
		END
	) AS meat_lovers,
	sum(
		CASE
			WHEN pizza_id = 2 THEN 1
			ELSE 0
		END
	) AS vegetarian
FROM new_customer_orders
GROUP BY customer_id
ORDER BY customer_id;
````

**Results:**

customer_id|meat_lovers|vegetarian|
-----------|-----------|----------|
101|          2|         1|
102|          2|         1|
103|          3|         1|
104|          3|         0|
105|          0|         1|

#### 6. What was the maximum number of pizzas delivered in a single order?

1. Create a CTE and join the customer_orders tables to the runners_order table.
2. Get all completed orders and group by customer_id.
3. Select max order count from cte.

````sql
WITH cte_order_count AS (
	SELECT c.order_id,
		count(c.pizza_id) AS n_orders
	FROM new_customer_orders AS c
		JOIN new_runner_orders AS r ON c.order_id = r.order_id
	WHERE r.cancellation IS NULL
	GROUP BY c.order_id
)
SELECT max(n_orders) AS max_n_orders
FROM cte_order_count;
````

**Results:**

max_n_orders|
------------|
3|

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

1. Join the customer_orders tables to the runners_order table.
2. Use case statements to get the total sum for changes (Extras or exclusions) in delivered pizzas.
3. Group by customer_id

````sql
SELECT c.customer_id,
	sum(
		CASE
			WHEN c.exclusions IS NOT NULL
			OR c.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS has_changes,
	sum(
		CASE
			WHEN c.exclusions IS NULL
			OR c.extras IS NULL THEN 1
			ELSE 0
		END
	) AS no_changes
FROM new_customer_orders AS c
	JOIN new_runner_orders AS r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
````

**Results:**

customer_id|has_changes|no_changes|
-----------|-----------|----------|
101|          0|         2|
102|          0|         3|
103|          3|         3|
104|          2|         2|
105|          1|         1|

#### 8. How many pizzas were delivered that had both exclusions and extras?

1. Join the customer_orders tables to the runners_order table.
2. Use case statements to get total sum for changes (Extras AND exclusions) in delivered pizza.

````sql
SELECT sum(
		CASE
			WHEN c.exclusions IS NOT NULL
			and c.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS n_pizzas
FROM new_customer_orders AS c
	JOIN new_runner_orders AS r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;
````

**Results:**

n_pizzas|
--------|
1|

#### 9. What was the total volume of pizzas ordered for each hour of the day?

1. Extract the Hour from the order_time timestamp.
2. Get the total count.
3. Group by the hour.

````sql
SELECT extract(
		hour
		FROM order_time::timestamp
	) AS hour_of_day,
	count(*) AS n_pizzas
FROM new_customer_orders
WHERE order_time IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;
````

**Results:**

hour_of_day|n_pizzas|
-----------|--------|
11.0|       1|
13.0|       3|
18.0|       3|
19.0|       1|
21.0|       3|
23.0|       3|

#### 10. What was the volume of orders for each day of the week?

1. Extract the day from the order_time timestamp.
2. Get the total count.
3. Group by the day of the week.

````sql
SELECT to_char(order_time, 'Day') AS day_of_week,
	count(*) AS n_pizzas
FROM new_customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;
````

**Results:**

day_of_week|n_pizzas|
-----------|--------|
Friday     |       1|
Saturday   |       5|
Thursday   |       3|
Wednesday  |       5|

###Runner and Customer Experience

#### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)