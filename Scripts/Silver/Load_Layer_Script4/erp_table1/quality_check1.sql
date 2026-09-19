
-- inspect erp tabe 1
SELECT 
cid,
bdate,
gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.crm_cust_info;


SELECT 
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

--  no reason why we have 'NAS' as prefix in cid column data, so let's handle it

SELECT 
cid,
bdate,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 , LENGTH(cid))
     ELSE cid
END AS cid,     
gen
FROM bronze.erp_cust_az12;



-- cross  check after removing
SELECT 
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 , LENGTH(cid))
     ELSE cid
END AS cid,  
bdate,   
gen
FROM bronze.erp_cust_az12
WHERE cid NOT IN(SELECT DISTINCT cst_key FROM silver.crm_cust_info);



-- qaulity check1 
SELECT * FROM silver.erp_cust_az12;