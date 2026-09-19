SELECT 
cid,
cntry
FROM
bronze.erp_loc_a101;


SELECT  *
FROM
silver.crm_cust_info;


-- cid column have '-' , which is different fom the cid column in crm_cust_info, so we will transform it

SELECT 
REPLACE(cid, '-', '') AS cid,
cntry
FROM
bronze.erp_loc_a101;

-- transformation check
SELECT 
REPLACE(cid, '-', '') AS cid,
cntry
FROM
bronze.erp_loc_a101
WHERE cid NOT IN (SELECT  cid FROM silver.crm_cust_info);



-- quality check 1
SELECT 
REPLACE(cid, '-', '') AS cid,
cntry
FROM
silver.erp_loc_a101;