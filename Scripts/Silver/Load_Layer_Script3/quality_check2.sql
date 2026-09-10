-- 2. order date must always be earlier than the shipping date or due date
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

/*

Business rules 

Sales = qauntity * price

negative's , Zeros, Nulls are not Allowed

*/


SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;