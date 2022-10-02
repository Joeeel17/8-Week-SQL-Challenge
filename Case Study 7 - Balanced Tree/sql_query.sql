/* 
 * Balanced Tree
 * Case Study #7 Questions & Answers
 *  
*/

-- A.  High Level Sales Analysis

-- 1. What was the total quantity sold for all products?

SELECT 
	sum(qty) AS total_quantity
FROM balanced_tree.sales

-- Results:

total_quantity|
--------------+
         45216|