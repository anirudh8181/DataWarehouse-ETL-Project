
SELECT column_name
FROM INFORMATION_SCHEMA.columns
WHERE table_schema = 'silver' 
  AND table_name = 'crm_prd_info';
  
SELECT 
cat_id,
dwh_create_date,
prd_cost,
prd_id,
prd_key,
prd_line,
prd_nm,
prd_start_dt,
prd_end_dt 
FROM  silver.crm_prd_info;

-- FILTER OUT ALL HISTORICAL DATA , SO PUT NULL CHECK FOR prd_end_date
SELECT 
cat_id,
dwh_create_date,
prd_cost,
prd_id,
prd_key,
prd_line,
prd_nm,
prd_start_dt,
prd_end_dt 
FROM  silver.crm_prd_info
WHERE prd_end_dt IS NULL;



-- join the crm and erp products table (Use a left join because crm is the source table)



SELECT 
pn.cat_id,
pn.prd_cost,
pn.pnd_id,
pn.prd_key,
pn.prd_line,
pn.prd_nm,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance 
FROM  silver.crm_prd_info pn
LEFT JOIN silver.erp_cust_az12 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;


-- checking we have deuplicate with prd_key
SELECT prd_key, COUNT(*) FROM
(
SELECT 
pn.cat_id,
pn.prd_cost,
pn.prd_id,
pn.prd_key,
pn.prd_line,
pn.prd_nm,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance 
FROM  silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL
) t
GROUP BY prd_key
HAVING count(*) > 1;


-- rename the columns
SELECT 
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance AS Maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM  silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;



-- is this table...dimension vs FACT ?
-- Ans: Dimension

-- create a surrogate key for data warehouse and create a view

CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY prd_id, prd_key ) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance AS Maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM  silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;


SELECT *  FROM gold.dim_products;


  
  
  