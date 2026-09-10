/*

Data cardinality means how many unique values exist in a column, or how many records in one table relate to records in another table.

In data engineering/database discussions, you’ll usually encounter it in two ways:

 1. Column cardinality

Cardinality = number of distinct/unique values in a column.

Example:

| customer_id | gender |
| ----------- | ------ |
| 101         | Male   |
| 102         | Female |
| 103         | Male   |
| 104         | Male   |
| 105         | Female |

 customer_id → cardinality = 5 because there are 5 unique IDs.
 gender → cardinality = 2 because there are only Male and Female.

So:

> High cardinality → many unique values
> Low cardinality → few unique values

Examples:

 Email → high cardinality
 Customer ID → high cardinality
 Gender → low cardinality
 Country → relatively low cardinality

---

 2. Relationship cardinality

This describes how records in two tables are related.

For example, in your Sales Data Warehouse project:


Customer
   |
   | 1
   |
   | many
   ↓
Sales


One customer can have many sales.

That's a 1-to-many (1:N) relationship.

Common types:

| Cardinality | Meaning     | Example            |
| ----------- | ----------- | ------------------ |
| 1:1         | One → One   | Person → Passport  |
| 1:N         | One → Many  | Customer → Orders  |
| N:1         | Many → One  | Orders → Customer  |
| N:N         | Many → Many | Students → Courses |

 In your ETL/DWH example

Suppose:


crm_cust_info
----------------
cst_id
101
102
103


and


sales_details
----------------
sls_cst_id
101
101
101
102
102
103


The relationship is:


crm_cust_info        sales_details
   Customer              Sales
      1                    N
      |                    |
      └────────────────────┘
             cst_id


Customer 101 has 3 sales, customer 102 has 2 sales, and customer 103 has 1 sale.

So the relationship cardinality is 1:N.

Easy way to remember:

> Column cardinality = "How many unique values?"
> Relationship cardinality = "How many records can relate to each other?"



*/

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- converting abbrevations and cardinality check

WITH non_dup AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
    FROM bronze.crm_cust_info
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
CASE WHEN cst_gndr = 'F' THEN 'FEMALE'
	WHEN cst_gndr = 'M' THEN 'MALE'
    ELSE 'N/A'
END AS cst_gndr    
FROM non_dup
WHERE cst_id IS NOT NULL AND ranking = 1;

-- if lowers case of f/m exists
WITH non_dup AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
    FROM bronze.crm_cust_info

)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_marital_status,
--     cst_gndr,
    cst_create_date,
CASE WHEN UPPER(cst_gndr) = 'F' THEN 'FEMALE'
	WHEN UPPER(cst_gndr) = 'M' THEN 'MALE'
    ELSE 'N/A'
END AS cst_gndr    
FROM non_dup
WHERE cst_id IS NOT NULL AND ranking = 1;

-- if gender column f/m have space we have clean it
WITH non_dup AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
    FROM bronze.crm_cust_info

)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_marital_status,
--     cst_gndr,
    cst_create_date,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'N/A'
END AS cst_gndr    
FROM non_dup
WHERE cst_id IS NOT NULL AND ranking = 1;




-- do the same transformation for martial status
WITH non_dup AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
    FROM bronze.crm_cust_info

)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_create_date,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'N/A'
END AS cst_gndr,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'N/A'
END AS cst_marital_status    
FROM non_dup
WHERE cst_id IS NOT NULL AND ranking = 1;



