
SELECT column_name
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'bronze' 
  AND table_name = 'erp_loc_a101';
  
  
DESCRIBE bronze.erp_loc_a101;  




TRUNCATE  TABLE silver.erp_loc_a101;

-- insert script
INSERT INTO silver.erp_loc_a101(cid,cntry)
SELECT 
REPLACE(cid, '-', '') AS cid,
CASE 
     WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry     
FROM
bronze.erp_loc_a101;








