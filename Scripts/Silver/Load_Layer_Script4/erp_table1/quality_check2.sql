
--  Identify out of range dates
SELECT DISTINCT
  bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > CURDATE();


-- birth date transformation
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 , LENGTH(cid))
     ELSE cid
END AS cid,  
CASE WHEN bdate > CURDATE()  THEN NULL
     ELSE bdate
END AS bdate,  
gen
FROM bronze.erp_cust_az12;




-- qaulity check 2
SELECT DISTINCT
  bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate >