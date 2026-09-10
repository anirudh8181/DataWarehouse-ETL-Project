
-- check data
SELECT * FROM 
bronze.crm_prd_info;


-- check for Nulls or Dupicates in Primary key
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING count(*) > 1 OR prd_id IS NULL;


SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

-- extract substring
SELECT
    prd_id,
    prd_key,
    SUBSTRING(prd_key, 1, 5) AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;


-- Extrcating first part (cat_id ) from prod_key (transformation-1)
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id, -- REPLACE(column_name, 'old_value', 'new_value')
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

-- cheecking non existint cat_id
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' ) AS cat_id, -- REPLACE(column_name, 'old_value', 'new_value')
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' ) NOT IN 
(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);


-- Extrcating last part (cat_id ) from prod_key (transformation-2)
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

SELECT sls_prd_key FROM bronze.crm_sales_details;

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LENGTH(prd_key)) NOT IN
(SELECT sls_prd_key FROM bronze.crm_sales_details WHERE sls_prd_key LIKE 'FK');


SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LENGTH(prd_key)) IN
(SELECT sls_prd_key FROM bronze.crm_sales_details);



-- check for unwanted spaces

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm!= TRIM(prd_nm);

-- check for negative numbers/ cost and NULLs
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- handling null values 
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0) AS prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


-- Data standardization and consitency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;



SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a' 
    END AS prd_line,    
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;


-- check for invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;




SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a' 
    END AS prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
FROM bronze.crm_prd_info;


-- cast prd_start_date as Proper Date
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a' 
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
FROM bronze.crm_prd_info;

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-','_' )AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0) AS prd_cost,
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a' 
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    LEAD(CAST(prd_start_dt AS DATE)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)- INTERVAL 1 DAY AS prd_end_dt 
FROM bronze.crm_prd_info;


-- modify the table creation ddl

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(50),
    prd_cost        INT,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO	silver.crm_prd_info(
    prd_id ,         
    cat_id ,         
    prd_key,       
    prd_nm ,         
    prd_cost,        
    prd_line,      
    prd_start_dt,   
    prd_end_dt  
 )   
SELECT
    -- Product ID: kept as it is from the Bronze table
    prd_id,

    -- Extract category ID and replace '-' with '_'
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

    -- Extract the product-specific part of prd_key
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,

    -- Product name: kept as it is
    prd_nm,

    -- Replace NULL product cost with 0
    IFNULL(prd_cost, 0) AS prd_cost,

    -- Convert product-line codes into meaningful names
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'n/a'
    END AS prd_line,

    -- Convert the value into DATE datatype
    CAST(prd_start_dt AS DATE) AS prd_start_dt,

    -- Get the next start date for the same product and subtract one day
    LEAD(CAST(prd_start_dt AS DATE)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS prd_end_dt

-- Get raw product data from Bronze layer
FROM bronze.crm_prd_info;













