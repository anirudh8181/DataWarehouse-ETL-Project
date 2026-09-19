
-- load check
SELECT * FROM 
bronze.crm_cust_info;

SELECT * FROM 
silver.crm_cust_info;

-- quality check / testing - check for nulls or duplicates in primary key

SELECT cst_id,COUNT(*)
FROM 
bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- read the duplicate data

SELECT * FROM 
bronze.crm_cust_info
WHERE cst_id = 29466;

-- if deplicates found assign rankings to them and take the latest entry
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
FROM 
bronze.crm_cust_info
WHERE cst_id = 29466;


SELECT *, 
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
FROM 
bronze.crm_cust_info;

-- finding who are duplicates

WITH temp AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
FROM 
bronze.crm_cust_info
)
SELECT * FROM temp
WHERE ranking!=1;

-- finding non duplicates
WITH non_dup AS (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
FROM 
bronze.crm_cust_info
)
SELECT * FROM non_dup
WHERE cst_id AND ranking=1;






