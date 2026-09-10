-- 3 check Data conistency: Between Sales, Quantity and Price

SELECT  DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS	NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0  OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- apply transformation

/*

Rules
If Sales is negative, zero, or NULL, derive Sales using Quantity × Price.
If Price is zero or NULL, calculate Price using Sales ÷ Quantity.
If Price is negative, convert it to a positive value.

*/

SELECT  DISTINCT
sls_quantity,
sls_sales AS old_sls_sales,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!= sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_sales <=0   THEN sls_sales/NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price  
FROM bronze.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS	NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0  OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- combine the whole transformation
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN  sls_order_dt = 0 OR LENGTH(sls_order_dt)!=8 THEN NULL
      ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
END AS sls_order_dt,      
CASE WHEN  sls_ship_dt = 0 OR LENGTH(sls_ship_dt)!=8 THEN NULL
      ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
END AS sls_ship_dt,      
CASE WHEN  sls_due_dt = 0 OR LENGTH(sls_due_dt)!=8 THEN NULL
      ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
END AS sls_due_dt, 
sls_quantity,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!= sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_sales <=0   THEN sls_sales/NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price  
FROM crm_sales_details;




-- switch to silver layer

SELECT  DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS	NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0  OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price;