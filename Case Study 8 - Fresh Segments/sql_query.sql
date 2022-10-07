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







