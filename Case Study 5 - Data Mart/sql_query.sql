/* 
 * Data Mart
 * Case Study #5 Questions
 *  
*/

-- 1. Data Cleansing Steps

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


DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
	-- We must not only convert to date type, we must also change the datestyle
	-- or we get  'ERROR: date/time field value out of range'
	to_date(week_date, 'dd/mm/yy') AS week_day,
	date_part('week', to_date(week_date, 'dd/mm/yy')) AS week_number,
	date_part('month', to_date(week_date, 'dd/mm/yy')) AS month_number,
	date_part('year', to_date(week_date, 'dd/mm/yy')) AS calendar_year,
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
2020-08-31|       36.0|         8.0|       2020.0|ASIA  |Retail  |C3     |Retirees    |Couples     |      120631| 3656163|               30.00|
2020-08-31|       36.0|         8.0|       2020.0|ASIA  |Retail  |F1     |Young Adults|Families    |       31574|  996575|               31.00|
2020-08-31|       36.0|         8.0|       2020.0|USA   |Retail  |null   |unknown     |unknown     |      529151|16509610|               31.00|
2020-08-31|       36.0|         8.0|       2020.0|EUROPE|Retail  |C1     |Young Adults|Couples     |        4517|  141942|               31.00|
2020-08-31|       36.0|         8.0|       2020.0|AFRICA|Retail  |C2     |Middle Aged |Couples     |       58046| 1758388|               30.00|
2020-08-31|       36.0|         8.0|       2020.0|CANADA|Shopify |F2     |Middle Aged |Families    |        1336|  243878|              182.00|
2020-08-31|       36.0|         8.0|       2020.0|AFRICA|Shopify |F3     |Retirees    |Families    |        2514|  519502|              206.00|
2020-08-31|       36.0|         8.0|       2020.0|ASIA  |Shopify |F1     |Young Adults|Families    |        2158|  371417|              172.00|
2020-08-31|       36.0|         8.0|       2020.0|AFRICA|Shopify |F2     |Middle Aged |Families    |         318|   49557|              155.00|
2020-08-31|       36.0|         8.0|       2020.0|AFRICA|Retail  |C3     |Retirees    |Couples     |      111032| 3888162|               35.00|






