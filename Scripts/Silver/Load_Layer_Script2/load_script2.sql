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
    prd_id,
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