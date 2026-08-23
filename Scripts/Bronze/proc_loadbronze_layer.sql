 /*
===============================================================================
BRONZE LAYER LOAD SCRIPT
Source -> Bronze
===============================================================================

Purpose:
    Loads raw CSV data into the Bronze layer.

Features:
    - Batch execution tracking
    - Debug / progress messages
    - Table-level execution timing
    - Row-count validation
    - LOAD DATA INFILE warnings
    - Success / failure status
    - Persistent execution logging

Important:
    LOAD DATA INFILE cannot be executed inside a MySQL stored procedure.
    Therefore this file must be executed as a normal SQL script.

===============================================================================
*/


/*
===============================================================================
1. INITIALIZATION
===============================================================================
*/

SET @batch_start_time = NOW();

SET @batch_id = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SELECT '============================================================' AS message;
SELECT '              STARTING BRONZE LAYER LOAD' AS message;
SELECT '============================================================' AS message;

SELECT CONCAT(
    '>> Batch ID: ',
    @batch_id
) AS message;

SELECT CONCAT(
    '>> Batch Start Time: ',
    @batch_start_time
) AS message;


/*
===============================================================================
2. CRM TABLES
===============================================================================
*/

SELECT '------------------------------------------------------------' AS message;
SELECT '                     LOADING CRM TABLES' AS message;
SELECT '------------------------------------------------------------' AS message;


/*
===============================================================================
2.1 CRM CUSTOMER INFORMATION
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.crm_cust_info' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'

INTO TABLE bronze.crm_cust_info

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @cst_id,
    @cst_key,
    @cst_firstname,
    @cst_lastname,
    @cst_marital_status,
    @cst_gndr,
    @cst_create_date
)

SET
    cst_id             = NULLIF(@cst_id, ''),
    cst_key            = NULLIF(@cst_key, ''),
    cst_firstname      = NULLIF(@cst_firstname, ''),
    cst_lastname       = NULLIF(@cst_lastname, ''),
    cst_marital_status = NULLIF(@cst_marital_status, ''),
    cst_gndr           = NULLIF(@cst_gndr, ''),
    cst_create_date    = NULLIF(@cst_create_date, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.crm_cust_info;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.crm_cust_info
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.crm_cust_info loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
2.2 CRM PRODUCT INFORMATION
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.crm_prd_info' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.crm_prd_info;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'

INTO TABLE bronze.crm_prd_info

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @prd_id,
    @prd_key,
    @prd_nm,
    @prd_cost,
    @prd_line,
    @prd_start_dt,
    @prd_end_dt
)

SET
    prd_id       = NULLIF(@prd_id, ''),
    prd_key      = NULLIF(@prd_key, ''),
    prd_nm       = NULLIF(@prd_nm, ''),
    prd_cost     = NULLIF(@prd_cost, ''),
    prd_line     = NULLIF(@prd_line, ''),
    prd_start_dt = NULLIF(@prd_start_dt, ''),
    prd_end_dt   = NULLIF(@prd_end_dt, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.crm_prd_info;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.crm_prd_info
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.crm_prd_info loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
2.3 CRM SALES DETAILS
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.crm_sales_details' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.crm_sales_details;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'

INTO TABLE bronze.crm_sales_details

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @sls_ord_num,
    @sls_prd_key,
    @sls_cust_id,
    @sls_order_dt,
    @sls_ship_dt,
    @sls_due_dt,
    @sls_sales,
    @sls_quantity,
    @sls_price
)

SET
    sls_ord_num  = NULLIF(@sls_ord_num, ''),
    sls_prd_key  = NULLIF(@sls_prd_key, ''),
    sls_cust_id  = NULLIF(@sls_cust_id, ''),
    sls_order_dt = NULLIF(@sls_order_dt, ''),
    sls_ship_dt  = NULLIF(@sls_ship_dt, ''),
    sls_due_dt   = NULLIF(@sls_due_dt, ''),
    sls_sales    = NULLIF(@sls_sales, ''),
    sls_quantity = NULLIF(@sls_quantity, ''),
    sls_price    = NULLIF(@sls_price, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.crm_sales_details;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.crm_sales_details
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.crm_sales_details loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
3. ERP TABLES
===============================================================================
*/

SELECT '============================================================' AS message;
SELECT '                     LOADING ERP TABLES' AS message;
SELECT '============================================================' AS message;


/*
===============================================================================
3.1 ERP LOCATION
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.erp_loc_a101' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loc_a101.csv'

INTO TABLE bronze.erp_loc_a101

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @cid,
    @cntry
)

SET
    cid   = NULLIF(@cid, ''),
    cntry = NULLIF(@cntry, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.erp_loc_a101;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.erp_loc_a101
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.erp_loc_a101 loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
3.2 ERP CUSTOMER
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.erp_cust_az12' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_az12.csv'

INTO TABLE bronze.erp_cust_az12

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @cid,
    @bdate,
    @gen
)

SET
    cid   = NULLIF(@cid, ''),
    bdate = NULLIF(@bdate, ''),
    gen   = NULLIF(@gen, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.erp_cust_az12;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.erp_cust_az12
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.erp_cust_az12 loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
3.3 ERP PRODUCT CATEGORY
===============================================================================
*/

SET @start_time = NOW();

SELECT '------------------------------------------------------------' AS message;
SELECT '>> TABLE: bronze.erp_px_cat_g1v2' AS message;
SELECT '>> STEP: Truncating table' AS message;

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT '>> STEP: Loading CSV data' AS message;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/px_cat_g1v2.csv'

INTO TABLE bronze.erp_px_cat_g1v2

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 LINES

(
    @id,
    @cat,
    @subcat,
    @maintenance
)

SET
    id          = NULLIF(@id, ''),
    cat         = NULLIF(@cat, ''),
    subcat      = NULLIF(@subcat, ''),
    maintenance = NULLIF(@maintenance, '');


SELECT '>> STEP: Checking LOAD DATA warnings' AS message;

SHOW WARNINGS;

SELECT '>> STEP: Validating row count' AS message;

SELECT COUNT(*) AS loaded_rows
FROM bronze.erp_px_cat_g1v2;

SET @row_count = (
    SELECT COUNT(*)
    FROM bronze.erp_px_cat_g1v2
);

SET @end_time = NOW();

SELECT CONCAT(
    '>> SUCCESS: bronze.erp_px_cat_g1v2 loaded successfully',
    ' | Rows: ',
    @row_count,
    ' | Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
) AS message;


/*
===============================================================================
4. FINAL SUMMARY
===============================================================================
*/

SET @batch_end_time = NOW();

SELECT '============================================================' AS message;
SELECT '              BRONZE LAYER LOAD COMPLETED' AS message;
SELECT '============================================================' AS message;

SELECT CONCAT(
    '>> Batch ID: ',
    @batch_id
) AS message;

SELECT CONCAT(
    '>> Batch Start Time: ',
    @batch_start_time
) AS message;

SELECT CONCAT(
    '>> Batch End Time: ',
    @batch_end_time
) AS message;

SELECT CONCAT(
    '>> Total Load Duration: ',
    TIMESTAMPDIFF(
        SECOND,
        @batch_start_time,
        @batch_end_time
    ),
    ' seconds'
) AS message;

SELECT '>> STATUS: SUCCESS' AS message;

SELECT '============================================================' AS message;




	
-- test the loaded data

SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count
FROM bronze.crm_cust_info

UNION ALL

SELECT 'crm_prd_info', COUNT(*)
FROM bronze.crm_prd_info

UNION ALL

SELECT 'crm_sales_details', COUNT(*)
FROM bronze.crm_sales_details

UNION ALL

SELECT 'erp_loc_a101', COUNT(*)
FROM bronze.erp_loc_a101

UNION ALL

SELECT 'erp_cust_az12', COUNT(*)
FROM bronze.erp_cust_az12

UNION ALL

SELECT 'erp_px_cat_g1v2', COUNT(*)
FROM bronze.erp_px_cat_g1v2;