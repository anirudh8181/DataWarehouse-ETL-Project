
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