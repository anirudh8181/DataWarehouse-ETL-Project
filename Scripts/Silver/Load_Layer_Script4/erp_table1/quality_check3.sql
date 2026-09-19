

-- Data standardization & consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


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


TRUNCATE TABLE silver.erp_cust_az12;