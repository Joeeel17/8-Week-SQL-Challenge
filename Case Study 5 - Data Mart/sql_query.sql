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

)







