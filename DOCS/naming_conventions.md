# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Stored Procedure](#stored-procedure-naming-conventions)
---

## **General Principles**

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved words as object names.

## **Table Naming Conventions**

### **Bronze Rules**
- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**  
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).  
  - `<entity>`: Exact table name from the source system.  
  - Example: `crm_customer_info` → Customer information from the CRM system.

### **Silver Rules**
- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**  
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).  
  - `<entity>`: Exact table name from the source system.  
  - Example: `crm_customer_info` → Customer information from the CRM system.

### **Gold Rules**
- All names must use meaningful, business-aligned names for tables, starting with the category prefix.
- **`<category>_<entity>`**  
  - `<category>`: Describes the role of the table, such as `dim` (dimension) or `fact` (fact table).  
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `customers`, `products`, `sales`).  
  - Examples:
    - `dim_customers` → Dimension table for customer data.  
    - `fact_sales` → Fact table containing sales transactions.  

#### **Glossary of Category Patterns**

| Pattern     | Meaning                           | Example(s)                              |
|-------------|-----------------------------------|-----------------------------------------|
| `dim_`      | Dimension table                  | `dim_customer`, `dim_product`           |
| `fact_`     | Fact table                       | `fact_sales`                            |
| `agg_`      | Aggregated table                 | `agg_customers`, `agg_sales_monthly`    |

## **Column Naming Conventions**

### **Surrogate Keys**  
- All primary keys in dimension tables must use the suffix `_key`.
- **`<table_name>_key`**  
  - `<table_name>`: Refers to the name of the table or entity the key belongs to.  
  - `_key`: A suffix indicating that this column is a surrogate key.  
  - Example: `customer_key` → Surrogate key in the `dim_customers` table.
  
### **Technical Columns**
- All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.
- **`dwh_<column_name>`**  
  - `dwh`: Prefix exclusively for system-generated metadata.  
  - `<column_name>`: Descriptive name indicating the column's purpose.  
  - Example: `dwh_load_date` → System-generated column used to store the date when the record was loaded.
 
## **Stored Procedure**

- All stored procedures used for loading data must follow the naming pattern:
- **`load_<layer>`**.
  
  - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
  - Example: 
    - `load_bronze` → Stored procedure for loading data into the Bronze layer.
    - `load_silver` → Stored procedure for loading data into the Silver layer.


These are the three most important table types in a **data warehouse**. They are designed differently from OLTP databases because their goal is **analytics**, not transaction processing.

Think of a supermarket.

Every time someone buys something, the sale is recorded.

* **Fact table** → The sales transactions
* **Dimension tables** → Information about customers, products, stores, dates
* **Aggregate tables** → Pre-calculated summaries like monthly sales

Let's understand each one.

---

# 1. Fact Table

A **fact table** stores **measurable business events**.

It usually contains:

* Numeric values (facts/measures)
* Foreign keys to dimension tables

Example:

### fact_sales

| sale_id | date_key | product_key | customer_key | store_key | quantity | sales_amount |
| ------- | -------- | ----------- | ------------ | --------- | -------- | ------------ |
| 101     | 20260801 | 15          | 210          | 5         | 2        | 1200         |
| 102     | 20260801 | 18          | 175          | 5         | 1        | 500          |
| 103     | 20260802 | 15          | 220          | 3         | 4        | 2400         |

Notice:

The important columns are

* quantity
* sales_amount

These are called **measures** because they can be summed, averaged, counted, etc.

The other columns are keys pointing to dimensions.

---

### Questions answered by Fact tables

* Total sales?
* Average revenue?
* Number of orders?
* Total quantity sold?

Example

```sql
SELECT SUM(sales_amount)
FROM fact_sales;
```

---

# 2. Dimension Table

A dimension table stores **descriptive information**.

It answers:

> "Tell me more about this product/customer/store/date."

Example:

### dim_product

| product_key | product_name | category    | brand    |
| ----------- | ------------ | ----------- | -------- |
| 15          | Laptop       | Electronics | Dell     |
| 18          | Mouse        | Accessories | Logitech |

---

### dim_customer

| customer_key | customer_name | city    | gender |
| ------------ | ------------- | ------- | ------ |
| 210          | Rahul         | Chennai | M      |
| 175          | Priya         | Mumbai  | F      |

---

### dim_store

| store_key | store_name   | state      |
| --------- | ------------ | ---------- |
| 5         | Phoenix Mall | Tamil Nadu |
| 3         | Forum Mall   | Karnataka  |

---

### dim_date

| date_key | date      | month  | year | weekday  |
| -------- | --------- | ------ | ---- | -------- |
| 20260801 | 01-Aug-26 | August | 2026 | Saturday |

---

Dimension tables contain attributes used for:

* filtering
* grouping
* reporting

Example:

```sql
SELECT p.category,
       SUM(f.sales_amount)
FROM fact_sales f
JOIN dim_product p
ON f.product_key = p.product_key
GROUP BY p.category;
```

Output

| Category    | Sales |
| ----------- | ----- |
| Electronics | 3600  |
| Accessories | 500   |

The fact table stores the numbers; the dimension table provides the descriptive labels.

---

# Relationship

```
               dim_customer
                     |
                     |
dim_product ---- fact_sales ---- dim_store
                     |
                     |
                 dim_date
```

This is called a **Star Schema** because the fact table is at the center with dimensions around it.

---

# 3. Aggregate Table

Sometimes the fact table contains **billions of rows**.

Suppose management asks:

> Monthly sales for the last 5 years.

Reading billions of rows every time is expensive.

Instead, we create an **aggregate table** that stores pre-computed summaries.

Example:

### agg_monthly_sales

| month  | year | category    | total_sales |
| ------ | ---- | ----------- | ----------- |
| August | 2026 | Electronics | 12000000    |
| August | 2026 | Accessories | 2500000     |

Instead of computing this every time from the fact table:

```sql
SELECT d.month,
       p.category,
       SUM(f.sales_amount)
FROM fact_sales f
JOIN dim_date d
ON f.date_key=d.date_key
JOIN dim_product p
ON f.product_key=p.product_key
GROUP BY d.month,p.category;
```

we can simply query:

```sql
SELECT *
FROM agg_monthly_sales;
```

Much faster.

---

# Why Aggregate Tables Exist

Suppose

```
fact_sales

3 Billion rows
```

Query

```sql
SELECT SUM(sales_amount)
FROM fact_sales;
```

might take several seconds or minutes.

Instead

```
agg_daily_sales

365 rows
```

Now

```sql
SELECT total_sales
FROM agg_daily_sales;
```

returns almost instantly.

This is why BI dashboards often use aggregate tables.

---

# Real Data Warehouse Example

Suppose Amazon records every purchase.

## Fact

```
fact_orders
```

| order_id | customer_key | product_key | quantity | amount |
| -------- | ------------ | ----------- | -------- | ------ |
| 1001     | 11           | 23          | 2        | 1500   |

---

## Dimensions

### dim_customer

| customer_key | name    | city    |
| ------------ | ------- | ------- |
| 11           | Anirudh | Chennai |

---

### dim_product

| product_key | product_name | category    |
| ----------- | ------------ | ----------- |
| 23          | Laptop       | Electronics |

---

### dim_date

| date_key | month  | year |
| -------- | ------ | ---- |
| 20260801 | August | 2026 |

---

### Aggregate

```
agg_monthly_orders
```

| month  | category    | total_orders | total_sales |
| ------ | ----------- | ------------ | ----------- |
| August | Electronics | 45000        | 6.8 Crore   |

---

# Comparison

| Feature  | Fact Table                           | Dimension Table            | Aggregate Table           |
| -------- | ------------------------------------ | -------------------------- | ------------------------- |
| Stores   | Business events                      | Descriptive data           | Pre-computed summaries    |
| Contains | Numeric measures + foreign keys      | Attributes                 | Summarized metrics        |
| Rows     | Very large                           | Small to medium            | Much smaller              |
| Updates  | Frequent (or periodic ETL loads)     | Occasional                 | Built from fact tables    |
| Purpose  | Analytics at the most detailed level | Add business context       | Speed up reporting        |
| Example  | Sales transactions                   | Products, Customers, Dates | Monthly sales by category |

---

## How they work together

Imagine a customer buys **2 Dell laptops for ₹1,20,000** on **1-Aug-2026**.

* **Fact table (`fact_sales`)** records the event:

  * Product = 15
  * Customer = 210
  * Date = 20260801
  * Quantity = 2
  * Sales Amount = 120000

* **Dimension tables** explain those IDs:

  * Product 15 → Dell Laptop, Electronics
  * Customer 210 → Rahul, Chennai
  * Date 20260801 → 1-Aug-2026, Saturday

* **Aggregate table** might already contain:

  * August 2026, Electronics → Total Sales = ₹12,000,000

A dashboard showing "Monthly Electronics Sales" can read the aggregate table for speed, while a drill-down into individual purchases uses the fact table joined with the dimension tables.
