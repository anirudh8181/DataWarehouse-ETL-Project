DELIMITER $$

CREATE PROCEDURE load_silver()
BEGIN

    /* ============================================================
       VARIABLE DECLARATIONS
       ============================================================ */

    DECLARE v_start_time         DATETIME(6);
    DECLARE v_step_start_time    DATETIME(6);
    DECLARE v_section_start_time DATETIME(6);

    DECLARE v_step_name VARCHAR(255);

    DECLARE v_error_code CHAR(5);
    DECLARE v_error_message TEXT;


    /* ============================================================
       ERROR HANDLER
       ============================================================ */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET DIAGNOSTICS CONDITION 1
            v_error_code = RETURNED_SQLSTATE,
            v_error_message = MESSAGE_TEXT;

        SELECT '========================================' AS message;
        SELECT CONCAT('ERROR in step: ', v_step_name) AS message;
        SELECT CONCAT('SQLSTATE: ', v_error_code) AS message;
        SELECT CONCAT('Error Message: ', v_error_message) AS message;
        SELECT 'Silver loading FAILED.' AS message;
        SELECT '========================================' AS message;

        RESIGNAL;

    END;


    /* ============================================================
       START SILVER LOADING
       ============================================================ */

    SET v_start_time = NOW(6);

    SELECT '========================================' AS message;
    SELECT 'STARTING SILVER LAYER LOADING' AS message;
    SELECT CONCAT('Start Time: ', v_start_time) AS message;
    SELECT '========================================' AS message;


    /* ============================================================
       SECTION 1 : CRM CUSTOMER
       ============================================================ */

    SET v_section_start_time = NOW(6);

    SELECT '----------------------------------------' AS message;
    SELECT 'SECTION 1: CRM CUSTOMER INFORMATION' AS message;
    SELECT '----------------------------------------' AS message;


    /* STEP 1.1 : TRUNCATE */

    SET v_step_name = 'CRM Customer - Truncate Table';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 1.1: Truncating silver.crm_cust_info...' AS message;

    TRUNCATE TABLE silver.crm_cust_info;

    SELECT CONCAT('STEP 1.1 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* STEP 1.2 : INSERT */

    SET v_step_name = 'CRM Customer - Insert Data';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 1.2: Loading silver.crm_cust_info...' AS message;

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_create_date,
        cst_gndr,
        cst_marital_status
    )

    WITH non_dup AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking

        FROM bronze.crm_cust_info
    )

    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        cst_create_date,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'N/A'
        END AS cst_gndr,

        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'N/A'
        END AS cst_marital_status

    FROM non_dup

    WHERE cst_id IS NOT NULL
      AND ranking = 1;


    SELECT CONCAT('STEP 1.2 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* SECTION DURATION */

    SELECT CONCAT('CRM Customer section completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_section_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;



    /* ============================================================
       SECTION 2 : CRM PRODUCT
       ============================================================ */

    SET v_section_start_time = NOW(6);

    SELECT '----------------------------------------' AS message;
    SELECT 'SECTION 2: CRM PRODUCT INFORMATION' AS message;
    SELECT '----------------------------------------' AS message;


    /* STEP 2.1 : TRUNCATE */

    SET v_step_name = 'CRM Product - Truncate Table';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 2.1: Truncating silver.crm_prd_info...' AS message;

    TRUNCATE TABLE silver.crm_prd_info;

    SELECT CONCAT('STEP 2.1 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* STEP 2.2 : INSERT */

    SET v_step_name = 'CRM Product - Insert Data';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 2.2: Loading silver.crm_prd_info...' AS message;

    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )

    SELECT
        prd_id,

        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,

        prd_nm,

        IFNULL(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        LEAD(CAST(prd_start_dt AS DATE)) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS prd_end_dt

    FROM bronze.crm_prd_info;


    SELECT CONCAT('STEP 2.2 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;

    SELECT CONCAT('CRM Product section completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_section_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;



    /* ============================================================
       SECTION 3 : CRM SALES
       ============================================================ */

    SET v_section_start_time = NOW(6);

    SELECT '----------------------------------------' AS message;
    SELECT 'SECTION 3: CRM SALES INFORMATION' AS message;
    SELECT '----------------------------------------' AS message;


    /* STEP 3.1 : TRUNCATE */

    SET v_step_name = 'CRM Sales - Truncate Table';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 3.1: Truncating silver.crm_sales_details...' AS message;

    TRUNCATE TABLE silver.crm_sales_details;

    SELECT CONCAT('STEP 3.1 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* STEP 3.2 : INSERT */

    SET v_step_name = 'CRM Sales - Insert Data';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 3.2: Loading silver.crm_sales_details...' AS message;

    INSERT INTO silver.crm_sales_details
    (
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
            WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
        END AS sls_due_dt,

        /* SALES */

        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        /* QUANTITY */

        sls_quantity,

        /* PRICE */

        CASE
            WHEN sls_price IS NULL OR sls_price = 0 THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE ABS(sls_price)
        END AS sls_price

    FROM bronze.crm_sales_details;


    SELECT CONCAT('STEP 3.2 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;

    SELECT CONCAT('CRM Sales section completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_section_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;



    /* ============================================================
       SECTION 4 : ERP CUSTOMER
       ============================================================ */

    SET v_section_start_time = NOW(6);

    SELECT '----------------------------------------' AS message;
    SELECT 'SECTION 4: ERP CUSTOMER INFORMATION' AS message;
    SELECT '----------------------------------------' AS message;


    /* STEP 4.1 : TRUNCATE */

    SET v_step_name = 'ERP Customer - Truncate Table';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 4.1: Truncating silver.erp_cust_az12...' AS message;

    TRUNCATE TABLE silver.erp_cust_az12;

    SELECT CONCAT('STEP 4.1 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* STEP 4.2 : INSERT */

    SET v_step_name = 'ERP Customer - Insert Data';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 4.2: Loading silver.erp_cust_az12...' AS message;

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )

    SELECT

        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > CURDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;


    SELECT CONCAT('STEP 4.2 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;

    SELECT CONCAT('ERP Customer section completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_section_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;



    /* ============================================================
       SECTION 5 : ERP LOCATION
       ============================================================ */

    SET v_section_start_time = NOW(6);

    SELECT '----------------------------------------' AS message;
    SELECT 'SECTION 5: ERP CUSTOMER LOCATION' AS message;
    SELECT '----------------------------------------' AS message;


    /* STEP 5.1 : TRUNCATE */

    SET v_step_name = 'ERP Location - Truncate Table';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 5.1: Truncating silver.erp_loc_a101...' AS message;

    TRUNCATE TABLE silver.erp_loc_a101;

    SELECT CONCAT('STEP 5.1 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;


    /* STEP 5.2 : INSERT */

    SET v_step_name = 'ERP Location - Insert Data';
    SET v_step_start_time = NOW(6);

    SELECT 'STEP 5.2: Loading silver.erp_loc_a101...' AS message;

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )

    SELECT

        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;


    SELECT CONCAT('STEP 5.2 completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_step_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;

    SELECT CONCAT('ERP Location section completed in ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_section_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;



    /* ============================================================
       SILVER LOADING COMPLETED
       ============================================================ */

    SELECT '========================================' AS message;
    SELECT 'SILVER LAYER LOADING COMPLETED SUCCESSFULLY' AS message;
    SELECT CONCAT('Total Silver loading duration: ', ROUND(TIMESTAMPDIFF(MICROSECOND, v_start_time, NOW(6)) / 1000000, 3), ' seconds') AS message;
    SELECT CONCAT('End Time: ', NOW(6)) AS message;
    SELECT '========================================' AS message;


END $$

DELIMITER ;


CALL load_silver();

