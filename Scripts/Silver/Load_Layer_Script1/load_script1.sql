-- TRUNCATE TABLE silver.crm_cust_info;


INSERT INTO silver.crm_cust_info
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_create_date,
    cst_gndr,
    cst_marital_status
)
WITH non_dup AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS ranking
    FROM bronze.crm_cust_info
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_create_date,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'N/A'
    END AS cst_gndr,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status

FROM non_dup
WHERE cst_id IS NOT NULL
  AND ranking = 1;
  
  
  
  -- quality checks after loading into silver layer
 
-- 1 
SELECT cst_id,COUNT(*)
FROM 
silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
  
  
 -- 2 
SELECT cst_firstname
FROM 
silver.crm_cust_info
WHERE cst_firstname!=TRIM(cst_firstname);

SELECT cst_lastname
FROM 
silver.crm_cust_info
WHERE cst_lastname!=TRIM(cst_lastname);

-- 3
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
  