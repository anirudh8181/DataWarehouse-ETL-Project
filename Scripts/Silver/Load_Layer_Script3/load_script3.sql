
TRUNCATE silver.crm_sales_details;

-- since the sls_due_date, sls_order_date and sls_ship_date are DATE TIME fields we have to change it from INT --> DATETIME during insert

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,

    -- Sales
    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    -- Quantity
    sls_quantity,

    -- Price
    CASE
        WHEN sls_price IS NULL OR sls_price = 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price

FROM bronze.crm_sales_details;








