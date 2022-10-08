/* 
 * Fresh Segments
 * Case Study #8 Questions & Answers
 *  
*/

-- A.  Data Exploration and Cleansing

-- 1.  Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

SELECT * FROM fresh_segments.interest_metrics ORDER BY ranking LIMIT 5;

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------+-----+----------+-----------+-----------+-----------+-------+------------------+
9     |2018 |09-2018   |6218       |       4.61|       2.84|      1|             99.87|
10    |2018 |10-2018   |6218       |       6.39|       3.37|      1|             99.88|
7     |2018 |07-2018   |32486      |      11.89|       6.19|      1|             99.86|
8     |2018 |08-2018   |6218       |       5.52|       2.84|      1|             99.87|
11    |2018 |11-2018   |6285       |       7.56|       3.48|      1|             99.89|

-- Alter the length of the varchar
ALTER TABLE fresh_segments.interest_metrics ALTER column month_year type varchar(15);
-- Convert data to date format
UPDATE fresh_segments.interest_metrics
SET month_year = to_date(month_year, 'MM-YYYY');
-- Alter table column type to date
ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE date
USING month_year::date;

SELECT * FROM fresh_segments.interest_metrics ORDER BY ranking LIMIT 5;

-- Results:

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------+-----+----------+-----------+-----------+-----------+-------+------------------+
10    |2018 |2018-10-01|6218       |       6.39|       3.37|      1|             99.88|
11    |2018 |2018-11-01|6285       |       7.56|       3.48|      1|             99.89|
9     |2018 |2018-09-01|6218       |       4.61|       2.84|      1|             99.87|
8     |2018 |2018-08-01|6218       |       5.52|       2.84|      1|             99.87|
12    |2018 |2018-12-01|41548      |      10.46|       4.42|      1|              99.9|

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT
	month_year,
	count(*) as month_year_count
FROM
	fresh_segments.interest_metrics
GROUP BY
	month_year
ORDER BY 
	month_year ASC NULLS first
	
-- Results:
	
month_year|month_year_count|
----------+----------------+
          |            1194|
2018-07-01|             729|
2018-08-01|             767|
2018-09-01|             780|
2018-10-01|             857|
2018-11-01|             928|
2018-12-01|             995|
2019-01-01|             973|
2019-02-01|            1121|
2019-03-01|            1136|
2019-04-01|            1099|
2019-05-01|             857|
2019-06-01|             824|
2019-07-01|             864|
2019-08-01|            1149|

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics

/*
 * How to handle missing values?  There are different ways to handle missing values.  We can fill missing values with
 *  
 * 1. Mean, Median or Mode.
 * 		- Numerical Data: Mean/Median
 * 		- Categorical Data: Mode
 * 2. Backfill/ForwardFill (Using the previous or next value)
 * 3. Interpolate. To infer value from datapoints and/or patterns.
 * 
 * However, if it is not possible to replace, then you must
 * 
 * 4.  Remove missing values.
 * 
 * If the removal percentage if high, this could be unacceptable as it may produce unreliable results.
 * For this exercise, the null values will be removed as we are unable to accurately apply a date to the records.
 * 
 */

-- Let's check the initial NULL count.

SELECT
	count(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

-- Results:

null_count|
----------+
      1194|

-- Delete records with null values and recheck the count.

DELETE
FROM 
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

SELECT
	count(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

-- Results:

null_count|
----------+
         0|

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
         
select         
	(SELECT
		count(interest_id) AS n_metrics_ids
	FROM
		fresh_segments.interest_metrics
	WHERE NOT EXISTS 
	(
		SELECT 
			id 
		FROM 
			fresh_segments.interest_map
		WHERE
			fresh_segments.interest_metrics.interest_id::numeric = fresh_segments.interest_map.id	
	)) AS not_in_map,	
	(SELECT
		count(id) AS n_map_ids
	FROM
		fresh_segments.interest_map
	WHERE NOT EXISTS 
	(
		SELECT 
			interest_id 
		FROM 
			fresh_segments.interest_metrics
		WHERE
			fresh_segments.interest_metrics.interest_id::numeric = fresh_segments.interest_map.id	
	)) AS not_in_metric

-- Results:
	
not_in_map|not_in_metric|
----------+-------------+
         0|            7|
         
-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table (check for duplicates/unique keys)

-- 5a. What is the number of records?

SELECT 
	count(*) AS n_id
FROM
	fresh_segments.interest_map;

-- Results:

n_id|
----+
1209|

-- 5b. Check for difference in the number of unique id's?

WITH check_count AS 
(
	SELECT 
		id,
		count(*) AS n_id
	FROM
		fresh_segments.interest_map
	GROUP BY 
		id
)
SELECT
	n_id,
	count(*)
FROM
	check_count
GROUP BY
	n_id
	
-- Results: (This verifies that the id's are unique)
	
n_id|count|
----+-----+
   1| 1209|
   
-- 6.  What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where 
-- interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns 
-- from fresh_segments.interest_map except from the id column.
	
/*
 * All values of interest_id from interest_metrics are also in interest_map.
 * All id's in interest_map are unique.
 * 
 * Am inner join or left join would work in this scenario.
 * 
 */	

SELECT
	m1.*,
	interest_name,
	interest_summary,
	created_at,
	last_modified
FROM
	fresh_segments.interest_metrics AS m1
LEFT JOIN 
	fresh_segments.interest_map AS m2
ON
	m1.interest_id::numeric = m2.id
WHERE 
	m1.interest_id = '21246';

-- Results:

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|interest_name                   |interest_summary                                     |created_at             |last_modified          |
------+-----+----------+-----------+-----------+-----------+-------+------------------+--------------------------------+-----------------------------------------------------+-----------------------+-----------------------+
4     |2019 |2019-04-01|21246      |       1.58|       0.63|   1092|              0.64|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
3     |2019 |2019-03-01|21246      |       1.75|       0.67|   1123|              1.14|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
2     |2019 |2019-02-01|21246      |       1.84|       0.68|   1109|              1.07|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
1     |2019 |2019-01-01|21246      |       2.05|       0.76|    954|              1.95|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
12    |2018 |2018-12-01|21246      |       1.97|        0.7|    983|              1.21|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
11    |2018 |2018-11-01|21246      |       2.25|       0.78|    908|              2.16|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
10    |2018 |2018-10-01|21246      |       1.74|       0.58|    855|              0.23|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
9     |2018 |2018-09-01|21246      |       2.06|       0.61|    774|              0.77|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
8     |2018 |2018-08-01|21246      |       2.13|       0.59|    765|              0.26|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
7     |2018 |2018-07-01|21246      |       2.26|       0.65|    722|              0.96|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|

-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 

WITH check_when_created AS (
	SELECT
		m1.*,
		interest_name,
		interest_summary,
		created_at,
		last_modified
	FROM
		fresh_segments.interest_metrics AS m1
	LEFT JOIN 
		fresh_segments.interest_map AS m2
	ON
		m1.interest_id::numeric = m2.id
)
SELECT
	count(*) AS n_records
FROM
	check_when_created
WHERE
	month_year < created_at;

-- Results:

n_records|
---------+
      188|


-- 7.a Do you think these values are valid and why?

/*
 * These records are valid because when we adjusted the month_date column, we rolled it back to the start
 * of the month. As long as the month_year month is equal to or greater than created, the record is valid.
 *  
 */

-- B.  Interest Analysis
      
-- 1.  Which interests have been present in all month_year dates in our dataset?












