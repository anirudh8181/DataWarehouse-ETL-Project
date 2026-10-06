

SELECT column_name
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'silver' 
  AND table_name = 'crm_sales_details';
  
 -- view the data 
SELECT 
sd.sls_ord_num,
sd.sls_prd_key,
sd.sls_cust_id,
sd.sls_order_dt,
sd.sls_ship_dt, 
sd.sls_due_dt,
sd.sls_price,
sd.sls_quantity,
sd.sls_sales
FROM silver.crm_sales_details sd;


-- building fact table: use the dimension's surrogate key instead of IDs to easily connect facts with dimensions


-- joining gold view's along with silver as the golde views's have surrogate key
SELECT 
sd.sls_ord_num,
sd.sls_prd_key,  -- can be combined
sd.sls_cust_id,  -- can be combined
sd.sls_order_dt,
sd.sls_ship_dt, 
sd.sls_due_dt,
sd.sls_price,
sd.sls_quantity,
sd.sls_sales
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;


SELECT 
sd.sls_ord_num,
pr.product_key, -- replaced sith surrogate key of dim_products
cu.customer_key, -- replaced sith surrogate key of dim_customers
sd.sls_order_dt,
sd.sls_ship_dt, 
sd.sls_due_dt,
sd.sls_price,
sd.sls_quantity,
sd.sls_sales
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;





-- rename the columns	and sort the columns into logical groups to improve readbility 	
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key AS product_key, 
cu.customer_key AS customer_key, 
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date, 
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity	,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;


-- create the view
CREATE VIEW gold.fact_sales AS 
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key AS product_key, 
cu.customer_key AS customer_key, 
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date, 
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity	,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;






SELECT * FROM gold.fact_sales;


-- quality check for fact sales

-- foreign key Integrity (Dimensions)


SELECT  *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;


SELECT  *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL;




  