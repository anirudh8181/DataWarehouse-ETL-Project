# 🏛️ SQL Data Warehouse Project

A complete, from-scratch **MySQL Data Warehouse** built on the **Medallion Architecture** (Bronze → Silver → Gold), consolidating CRM and ERP data into a clean, analytics-ready **Star Schema**.

![MySQL](https://img.shields.io/badge/Database-MySQL%208.0-4479A1?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-336791)
![Architecture](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-CD7F32)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## 📖 Overview

This project simulates a real-world data engineering workflow: raw CSV exports from two independent source systems (**CRM** and **ERP**) are ingested, cleaned, integrated, and modeled into a business-friendly **star schema** ready for BI tools, dashboards, and ad-hoc analytics.

It is built entirely in **MySQL** and is designed as both a working data warehouse and a **learning reference** — every layer is documented with the reasoning behind each design decision.

### Objective

> Build a modern data warehouse that consolidates sales data from CRM and ERP source systems, resolves data quality issues, and exposes a single, consistent data model for analytical reporting.

---

## 🏗️ Architecture

The warehouse follows the **Medallion Architecture**, with each layer serving a distinct purpose:

```text
┌────────────┐      ┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│  Source     │      │    BRONZE     │      │    SILVER     │      │     GOLD      │
│  Systems    │ ───► │  Raw Layer    │ ───► │ Cleansed Layer│ ───► │ Business Layer│
│ CRM · ERP   │      │ (as-is load)  │      │ (standardized)│      │ (star schema) │
└────────────┘      └───────────────┘      └───────────────┘      └───────────────┘
   CSV files           bronze.*                silver.*            gold.dim_* / fact_*
                                                                           │
                                                                           ▼
                                                                 BI / Reporting / Analytics
```

| Layer | Purpose | Contents |
|-------|---------|----------|
| 🥉 **Bronze** | Raw ingestion, no transformation | Exact copies of source CSVs (`crm_cust_info`, `crm_prd_info`, `crm_sales_details`, `erp_loc_a101`, `erp_cust_az12`, `erp_px_cat_g1v2`) |
| 🥈 **Silver** | Cleansing, standardization, deduplication, type/format fixes | Cleaned CRM & ERP tables with consistent keys and formats |
| 🥇 **Gold** | Business-ready, dimensional model | `dim_customers`, `dim_products`, `fact_sales` (Star Schema) |

### ⭐ Gold Layer — Star Schema

```text
                 dim_customers
                       │
                       │
   dim_products ── fact_sales
```

`fact_sales` sits at the center, surrounded by conformed dimension tables — optimized for fast, simple analytical queries.

---

## 📂 Repository Structure

```text
SQL_DWH_Project/
│
├── datasets/                      # Raw source CSV files
│   ├── source_crm/                # cust_info, prd_info, sales_details
│   └── source_erp/                # CUST_AZ12, LOC_A101, PX_CAT_G1V2
│
├── Scripts/
│   ├── DDL_init.sql               # Creates Bronze / Silver / Gold databases
│   │
│   ├── Bronze/
│   │   ├── bronze_ddl.sql         # Bronze table definitions
│   │   ├── proc_loadbronze_layer.sql  # LOAD DATA INFILE ingestion script
│   │   └── test_load.sql
│   │
│   ├── Silver/
│   │   ├── ddl_silver.sql         # Silver table definitions
│   │   ├── load_silver_procedure.sql  # Stored procedure: load_silver
│   │   └── Load_Layer_Script*/    # Iterative dev scripts + data quality checks
│   │
│   └── Gold/
│       ├── dim_customers.sql      # Customer dimension view
│       ├── dim_products.sql       # Product dimension view
│       ├── fact_sales.sql         # Sales fact view
│       └── data_catalog.md        # Column-level documentation
│
└── DOCS/                          # Concept notes & architecture diagrams
    ├── 1.ETL.md
    ├── 2.1.Naming_conventions.md
    ├── 2.2Project_Requirements.md
    ├── 3.0.DATAWAREHOUSE.md
    ├── 3.2.DATA_ARCHITECTURE.md
    └── ...
```

---

## 🧩 Data Sources

| System | Entity | Format |
|--------|--------|--------|
| CRM | Customer Info | CSV |
| CRM | Product Info | CSV |
| CRM | Sales Details | CSV |
| ERP | Customer (AZ12) | CSV |
| ERP | Location (A101) | CSV |
| ERP | Product Category (G1V2) | CSV |

> Scope: latest snapshot only — historization/SCD tracking is intentionally out of scope.

---

## ⚙️ How It Works

1. **Initialize databases**
   ```sql
   SOURCE Scripts/DDL_init.sql;
   ```
   Creates the `Bronze`, `Silver`, and `Gold` databases.

2. **Load the Bronze layer**
   ```sql
   SOURCE Scripts/Bronze/bronze_ddl.sql;
   SOURCE Scripts/Bronze/proc_loadbronze_layer.sql;
   ```
   > ⚠️ `LOAD DATA INFILE` cannot run inside a stored procedure in MySQL — this script must be executed directly, not called as a procedure. Update the CSV file paths to match your local `secure_file_priv` / uploads directory before running.

3. **Load the Silver layer**
   ```sql
   SOURCE Scripts/Silver/ddl_silver.sql;
   CALL Silver.load_silver();
   ```
   Cleanses, deduplicates, and standardizes the Bronze data.

4. **Build the Gold layer**
   ```sql
   SOURCE Scripts/Gold/dim_customers.sql;
   SOURCE Scripts/Gold/dim_products.sql;
   SOURCE Scripts/Gold/fact_sales.sql;
   ```
   Exposes the final star-schema views for reporting.

5. **Query away** 🎉
   ```sql
   SELECT p.category, SUM(f.sales_amount) AS total_sales
   FROM gold.fact_sales f
   JOIN gold.dim_products p ON f.product_key = p.product_key
   GROUP BY p.category;
   ```

---

## 📐 Naming Conventions

This project follows a strict, documented naming standard (see [`DOCS/2.1.Naming_conventions.md`](DOCS/2.1.Naming_conventions.md)):

- **General**: `snake_case`, English, no reserved SQL words.
- **Bronze / Silver**: `<sourcesystem>_<entity>` (e.g., `crm_cust_info`).
- **Gold**: `<category>_<entity>` (e.g., `dim_customers`, `fact_sales`).
- **Surrogate keys**: `<table_name>_key` (e.g., `customer_key`).
- **Technical/metadata columns**: `dwh_<column_name>` (e.g., `dwh_load_date`).
- **Stored procedures**: `load_<layer>` (e.g., `load_silver`).

---

## 📊 Data Catalog (Gold Layer)

| Table | Description |
|-------|-------------|
| `gold.dim_customers` | Customer details enriched with demographic & geographic data |
| `gold.dim_products` | Product attributes, categories, and pricing |
| `gold.fact_sales` | Transactional sales facts (order, shipping, due dates, quantity, revenue) |

Full column-level definitions: [`Scripts/Gold/data_catalog.md`](Scripts/Gold/data_catalog.md)

---

## ✅ Data Quality & Validation

Every layer includes built-in checks:
- Row-count validation after each load
- `SHOW WARNINGS` checks after `LOAD DATA INFILE`
- Null/duplicate/standardization checks in the Silver layer (see `quality_check*.sql` scripts)
- Execution timing and batch-level logging printed during load

---

## 🛠️ Tech Stack

- **Database**: MySQL 8.0
- **Language**: Pure SQL (DDL, DML, Stored Procedures)
- **Modeling**: Dimensional Modeling / Kimball-style Star Schema
- **Methodology**: Medallion Architecture (Bronze / Silver / Gold)

---

## 📚 Documentation

In-depth conceptual notes live in [`DOCS/`](DOCS/) and alongside each layer's scripts, covering:
- Data Warehouse vs. Data Lake vs. Lakehouse vs. Data Mesh
- ETL vs. ELT
- Facts, Dimensions, and Aggregate tables
- Integration models & surrogate keys
- Layer-by-layer design rationale

---

## 📄 License

This project is open-sourced for learning and portfolio purposes. Feel free to fork, adapt, and build on it.
