/* 
 * Data Mart
 * Case Study #5 Questions
 *  
*/

/*
	1. Data Cleansing Steps
*/

-- Lets take a look at the first 10 records to see what we have.

SELECT * FROM weekly_sales
LIMIT 10;

-- Results

week_date|region|platform|segment|customer_type|transactions|sales   |
---------+------+--------+-------+-------------+------------+--------+
31/8/20  |ASIA  |Retail  |C3     |New          |      120631| 3656163|
31/8/20  |ASIA  |Retail  |F1     |New          |       31574|  996575|
31/8/20  |USA   |Retail  |null   |Guest        |      529151|16509610|
31/8/20  |EUROPE|Retail  |C1     |New          |        4517|  141942|
31/8/20  |AFRICA|Retail  |C2     |New          |       58046| 1758388|
31/8/20  |CANADA|Shopify |F2     |Existing     |        1336|  243878|
31/8/20  |AFRICA|Shopify |F3     |Existing     |        2514|  519502|
31/8/20  |ASIA  |Shopify |F1     |Existing     |        2158|  371417|
31/8/20  |AFRICA|Shopify |F2     |New          |         318|   49557|
31/8/20  |AFRICA|Retail  |C3     |New          |      111032| 3888162|

-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
-- Step 1. Convert the week_date to a DATE format.
-- Step 2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc...
-- Step 3. Add a month_number with the calendar month for each week_date value as the 3rd column.
-- Step 4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values.
-- Step 5. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
--
--segment	age_band
-- 1	Young Adults
-- 2	Middle Aged
-- 3 or 4	Retirees

-- Step 6. Add a new demographic column using the following mapping for the first letter in the segment values:
--
-- segment	demographic
--   C	     Couples
--   F	     Families

-- Step 7. Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns.
-- Step 8. Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record.

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
	-- We must not only convert to date type, we must also change the datestyle
	-- or we get  'ERROR: date/time field value out of range'
	to_date(week_date, 'dd/mm/yy') AS week_day,
	date_part('week', to_date(week_date, 'dd/mm/yy'))::int AS week_number,
	date_part('month', to_date(week_date, 'dd/mm/yy'))::int AS month_number,
	date_part('year', to_date(week_date, 'dd/mm/yy'))::int AS calendar_year,
	region,
	platform,
	CASE 
		WHEN segment IS NOT NULL OR segment <> 'null' THEN segment
		ELSE 'unknown'
	END AS segment,
	CASE 
		WHEN substring(segment, 2, 1) = '1' THEN 'Young Adults'
		WHEN substring(segment, 2, 1) = '2' THEN 'Middle Aged'
		WHEN substring(segment, 2, 1) = '3' OR substring(segment, 2, 1) = '4'  THEN 'Retirees'
		ELSE 'unknown'
	END AS age_band,
	CASE 
		WHEN substring(segment, 1, 1) = 'C' THEN 'Couples'
		WHEN substring(segment, 1, 1) = 'F' THEN 'Families'
		ELSE 'unknown'
	END AS demographics,
	transactions,
	sales,
	round(sales / transactions, 2) AS average_transactions
FROM weekly_sales
);

SELECT * FROM clean_weekly_sales 
LIMIT 10;

-- Results:

week_day  |week_number|month_number|calendar_year|region|platform|segment|age_band    |demographics|transactions|sales   |average_transactions|
----------+-----------+------------+-------------+------+--------+-------+------------+------------+------------+--------+--------------------+
2020-08-31|         36|           8|         2020|ASIA  |Retail  |C3     |Retirees    |Couples     |      120631| 3656163|               30.00|
2020-08-31|         36|           8|         2020|ASIA  |Retail  |F1     |Young Adults|Families    |       31574|  996575|               31.00|
2020-08-31|         36|           8|         2020|USA   |Retail  |null   |unknown     |unknown     |      529151|16509610|               31.00|
2020-08-31|         36|           8|         2020|EUROPE|Retail  |C1     |Young Adults|Couples     |        4517|  141942|               31.00|
2020-08-31|         36|           8|         2020|AFRICA|Retail  |C2     |Middle Aged |Couples     |       58046| 1758388|               30.00|
2020-08-31|         36|           8|         2020|CANADA|Shopify |F2     |Middle Aged |Families    |        1336|  243878|              182.00|
2020-08-31|         36|           8|         2020|AFRICA|Shopify |F3     |Retirees    |Families    |        2514|  519502|              206.00|
2020-08-31|         36|           8|         2020|ASIA  |Shopify |F1     |Young Adults|Families    |        2158|  371417|              172.00|
2020-08-31|         36|           8|         2020|AFRICA|Shopify |F2     |Middle Aged |Families    |         318|   49557|              155.00|
2020-08-31|         36|           8|         2020|AFRICA|Retail  |C3     |Retirees    |Couples     |      111032| 3888162|               35.00|


/*
	2. Data Exploration
*/

-- 1. What day of the week is used for each week_date value?

SELECT
	DISTINCT date_part('dow', week_day)::int AS day_of_week,
	to_char(week_day, 'Day') AS day_of_week_name
FROM clean_weekly_sales;

-- Results:

day_of_week|day_of_week_name|
-----------+----------------+
          1|Monday          |
        
-- 2. What range of week numbers are missing from the dataset?

-- Using a recursive cte        
       
WITH RECURSIVE week_count AS (
	SELECT
		1 AS week_num
	UNION ALL
	SELECT week_num + 1
	FROM week_count
	WHERE week_num < 52
)

SELECT week_num AS missing_weeks
FROM week_count 
WHERE week_num NOT IN (SELECT DISTINCT week_number FROM clean_weekly_sales);

-- Or using generate_series function

SELECT
	*
FROM
	generate_series(1, 52) AS missing_weeks
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		clean_weekly_sales
	WHERE
		missing_weeks = week_number);
	
-- Results:
	
missing_weeks|
-------------+
            1|
            2|
            3|
            4|
            5|
            6|
            7|
            8|
            9|
           10|
           11|
           12|
           37|
           38|
           39|
           40|
           41|
           42|
           43|
           44|
           45|
           46|
           47|
           48|
           49|
           50|
           51|
           52|

-- 3. How many total transactions were there for each year in the dataset?

SELECT 
	calendar_year,
	sum(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
        
-- Results:

calendar_year|total_transactions|
-------------+------------------+
         2018|         346406460|
         2019|         365639285|
         2020|         375813651|
         
-- 4. What is the total sales for each region for each month?
        
SELECT 
	region,
	calendar_year,
	month_number,
	sum(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 
	region,
	calendar_year,
	month_number
ORDER BY calendar_year, month_number, region;

-- Results:  Only showing the first month of 2018 of all regions

region       |calendar_year|month_number|total_sales|
-------------+-------------+------------+-----------+
AFRICA       |         2018|           3|  130542213|
ASIA         |         2018|           3|  119180883|
CANADA       |         2018|           3|   33815571|
EUROPE       |         2018|           3|    8402183|
OCEANIA      |         2018|           3|  175777460|
SOUTH AMERICA|         2018|           3|   16302144|
USA          |         2018|           3|   52734998|


        
        
        
        



