

SELECT column_name
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'bronze' 
  AND table_name = 'erp_px_cat_g1v2';
  


SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;	

SELECT * FROM  silver.crm_prd_info;

-- all the tables are correctly matched with erp category table and silver crm prod info table


-- check for unwanted spaces

SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat!= TRIM(cat) OR subcat!= TRIM(subcat) OR maintenance!= TRIM(maintenance);

-- data standardization & consistency check

SELECT DISTINCT cat 
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;


-- data quality of this tables is good so no transformation required



TRUNCATE TABLE silver.erp_px_cat_g1v2;

-- load script
INSERT INTO silver.erp_px_cat_g1v2
(id,cat,subcat,maintenance)
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;	


SELECT * FROM silver.erp_px_cat_g1v2;




