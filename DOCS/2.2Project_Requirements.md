# 🚀 Project Requirements

## Building the Data Warehouse (Data Engineering)

### Objective

Develop a modern data warehouse using **SQL Server** to consolidate sales data, enabling analytical reporting and informed decision-making.

### Specifications

- **Data Sources:** Import data from two source systems (**ERP** and **CRM**) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historization of data is not required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.




The image shows **four major data architectures** used by organizations to store, manage, and analyze data. They represent the evolution of data management over time.


                 Data Architectures
                        │
     ┌────────────┬────────────┬────────────┬────────────┐
     │            │            │            │
Data Warehouse  Data Lake  Data Lakehouse  Data Mesh


---

# 1. Data Warehouse

### What is it?

A **Data Warehouse** is a centralized repository that stores **structured, cleaned, and transformed** data from multiple sources for reporting and business intelligence.

Think of it as a **well-organized library** where every book is categorized before being placed on the shelf.

### Characteristics

* Stores structured data
* Data is cleaned before loading
* Optimized for SQL queries
* High performance for analytics
* Follows schema (tables, columns, relationships)

### Architecture


ERP
      \
CRM ---> ETL ---> Data Warehouse ---> Reports
      /
Excel


### Example

Company Sales

| Order ID | Customer | Product | Revenue |
| -------- | -------- | ------- | ------- |
| 101      | John     | Laptop  | 1200    |
| 102      | Alice    | Mouse   | 25      |

Business users create dashboards like:

* Total Sales
* Monthly Revenue
* Top Customers
* Product Performance

### Advantages

* Fast analytics
* High-quality data
* Easy reporting
* Consistent data

### Disadvantages

* Doesn't handle unstructured data well
* ETL can take time
* Storage is expensive

---

# 2. Data Lake

### What is it?

A **Data Lake** stores **all types of data** in their original (raw) format.

Nothing needs to be cleaned before storing.

Think of it as a **huge lake** where everything is dumped.

* CSV
* Images
* Videos
* JSON
* PDFs
* Audio
* Logs

Everything goes into one place.

### Architecture


ERP
CRM
Logs
Images
Videos
IoT
      ↓
   Data Lake


### Characteristics

* Raw data
* Cheap storage
* Huge scalability
* Structured + Semi-structured + Unstructured

### Example

Amazon stores:

* Customer reviews
* Images
* Clickstream logs
* Purchase history
* Videos

All inside a Data Lake.

### Advantages

* Very flexible
* Cheap
* Can store anything

### Disadvantages

* Data can become messy
* Slower analytics
* Data quality issues

---

# 3. Data Lakehouse

### What is it?

A **Data Lakehouse** combines the best features of both:

* Data Warehouse
* Data Lake

It stores raw data like a lake but provides warehouse-like performance and reliability.

Think of it as:


Data Lake
      +
Data Warehouse
      =
Data Lakehouse


### Architecture


          Raw Data
              │
      Data Lake Storage
              │
    Metadata + ACID Tables
              │
      SQL Analytics


### Characteristics

* Stores all data types
* Supports SQL
* ACID transactions
* Better governance
* Faster analytics

### Popular Technologies

* Delta Lake
* Apache Iceberg
* Apache Hudi
* Databricks

### Advantages

* One platform
* Lower cost
* Good performance
* Supports machine learning and BI

### Disadvantages

* More complex than a traditional warehouse
* Requires modern tools

---

# 4. Data Mesh

### What is it?

A **Data Mesh** is **not a storage technology**. It is an **organizational approach** where each business domain owns and manages its own data.

Instead of one central data team managing everything:


Finance Team
Owns Finance Data

HR Team
Owns HR Data

Sales Team
Owns Sales Data

Marketing Team
Owns Marketing Data


Each team publishes its data as a **data product** that others can use.

### Traditional Architecture


Finance
HR
Sales
Marketing
      │
      ▼
Central Data Team
      │
      ▼
Warehouse


Problem:

* Bottlenecks
* Slow development
* Central team overload

---

### Data Mesh


Finance ─┐
HR ──────┼── Share Data Products
Sales ───┤
Marketing┘


Each domain manages:

* Pipelines
* Data quality
* Documentation
* APIs

### Advantages

* Scales well
* Faster development
* Domain experts own the data
* Better accountability

### Disadvantages

* Requires strong governance
* More coordination between teams

---

# Quick Comparison

| Feature                  | Data Warehouse        | Data Lake        | Data Lakehouse    | Data Mesh                  |
| ------------------------ | --------------------- | ---------------- | ----------------- | -------------------------- |
| Stores Structured Data   | ✅                     | ✅                | ✅                 | Depends                    |
| Stores Unstructured Data | ❌                     | ✅                | ✅                 | Depends                    |
| Data Quality             | High                  | Low              | High              | Domain-specific            |
| SQL Analytics            | Excellent             | Limited          | Excellent         | Depends                    |
| Machine Learning         | Limited               | Excellent        | Excellent         | Excellent                  |
| Cost                     | High                  | Low              | Medium            | Varies                     |
| Main Purpose             | Business Intelligence | Raw Data Storage | Unified Analytics | Organizational Scalability |

---

# When to Use Each

* **Data Warehouse:** Best for business reporting, dashboards, and SQL analytics on clean, structured data.
* **Data Lake:** Best for storing large volumes of raw data for data science, machine learning, or future processing.
* **Data Lakehouse:** Best when you want a single platform for both BI and machine learning, supporting structured and unstructured data.
* **Data Mesh:** Best for large organizations where multiple business domains need to own and manage their own data independently.

---

## Evolution of Data Architectures


Traditional Databases
          │
          ▼
Data Warehouse
          │
          ▼
Data Lake
          │
          ▼
Data Lakehouse
          │
          ▼


**Key point:** The first three (Data Warehouse, Data Lake, and Data Lakehouse) are **data storage and processing architectures**. **Data Mesh** is different—it is an **organizational and architectural philosophy** that defines how data ownership and governance are distributed across teams, rather than a specific storage system.
