


-- 1.check for invalid dates ( date can't be negative, zero's cannot be casted as dates)
SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt < 0;

SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0;

--  date's having length greater then 8/ also date should not be greater than boundary
SELECT 
NULLIF(sls_order_dt,0) AS sls_order_date
FROM bronze.crm_sales_details
WHERE LENGTH(sls_order_dt)!= 8 OR sls_order_dt > 20500101 OR sls_order_dt <  19000101;

DESC crm_sales_details;

-- let's handle the invalide dates
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN  sls_order_dt = 0 OR LENGTH(sls_order_dt)!=8 THEN NULL
      ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
END AS sls_order_dt,      
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM crm_sales_details;




--  check for shipping data
SELECT 
NULLIF(sls_ship_dt,0) AS sls_ship_date
FROM bronze.crm_sales_details
WHERE sls_ship_dt <=0 OR  LENGTH(sls_ship_dt)!= 8 OR sls_ship_dt > 20500101 OR sls_ship_dt <  19000101; 

-- still apply the transformation for shipping date incase any future cases
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
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM crm_sales_details;


--  check for due data
SELECT 
NULLIF(sls_due_dt,0) AS sls_due_date
FROM bronze.crm_sales_details
WHERE sls_due_dt <=0 OR  LENGTH(sls_due_dt)!= 8 OR sls_due_dt > 20500101 OR sls_due_dt <  19000101; 


-- apply transformation for due date
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
sls_sales,
sls_quantity,
sls_price
FROM crm_sales_details;



-- switch to silver layer


-- check for order date
SELECT 
NULLIF(sls_order_dt,0) AS sls_order_date
FROM silver.crm_sales_details
WHERE LENGTH(sls_order_dt)!= 8 OR sls_order_dt > 20500101 OR sls_order_dt <  19000101; 


--  check for shipping data
SELECT 
NULLIF(sls_ship_dt,0) AS sls_ship_date
FROM silver.crm_sales_details
WHERE sls_ship_dt <=0 OR  LENGTH(sls_ship_dt)!= 8 OR sls_ship_dt > 20500101 OR sls_ship_dt <  19000101;



--  check for due data
SELECT 
NULLIF(sls_due_dt,0) AS sls_due_date
FROM silver.crm_sales_details
WHERE sls_due_dt <=0 OR  LENGTH(sls_due_dt)!= 8 OR sls_due_dt > 20500101 OR sls_due_dt <  19000101;