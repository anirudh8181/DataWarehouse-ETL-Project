
SELECT column_name
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'bronze' 
  AND table_name = 'erp_cust_az12';

-- describe columns
DESCRIBE bronze.erp_cust_az12;


TRUNCATE TABLE silver.erp_cust_az12;

-- insert script
INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 , LENGTH(cid))
     ELSE cid
END AS cid,  
CASE WHEN bdate > CURDATE()  THEN NULL
     ELSE bdate
END AS bdate,  
CASE 
     WHEN UPPER(TRIM(gen)) IN ('M' , 'MALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Male'
     ELSE 'n/a'
END AS gen     
FROM bronze.erp_cust_az12;


DESCRIBE silver.erp_cust_az12;

