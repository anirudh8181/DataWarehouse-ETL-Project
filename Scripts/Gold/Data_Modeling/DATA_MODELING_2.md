# Part 2 — Additional Data Modeling Concepts

This section expands the topics that were missing or only briefly mentioned in the original notes. It is organized for junior data engineering learning and interviews.

## 30. Functional Dependencies

A **functional dependency** describes a relationship in which one attribute (or a group of attributes) determines another attribute.

Notation:

```text
A → B
```

This means that for every valid value of `A`, there is only one corresponding value of `B`.

Example:

```text
employee_id → employee_name
```

If `employee_id` is unique, it determines the employee's name.

A dependency can involve multiple columns:

```text
(order_id, product_id) → quantity
```

The combination of order and product determines the quantity of that product on the order.

### Why functional dependencies matter

They help us:
- Identify candidate keys.
- Understand partial and transitive dependencies.
- Normalize tables.
- Avoid update anomalies.

**Interview tip:** A functional dependency is a rule about the meaning of the data, not merely a pattern observed in a small sample.

---

## 31. Candidate, Alternate, Composite and Unique Keys

### Candidate key

A **candidate key** is a minimal set of columns that uniquely identifies a row. A table can have more than one candidate key.

Example:

```text
employee
--------------------------------
employee_id | email           | name
--------------------------------
101         | a@example.com   | Asha
102         | b@example.com   | Ravi
```

If both `employee_id` and `email` are guaranteed unique and non-null, each can be a candidate key.

### Primary key

The candidate key selected as the table's main identifier.

### Alternate key

A candidate key that was not selected as the primary key. In practice, it is commonly enforced with a `UNIQUE` constraint.

### Composite key

A key made from two or more columns.

Example:

```text
order_item
------------------------------
order_id | product_id | quantity
------------------------------
1001     | P10        | 2
1001     | P20        | 1
```

The combination `(order_id, product_id)` may identify each line if a product can appear only once per order.

### Unique constraint

A database rule that prevents duplicate values in a column or column combination. Exact treatment of `NULL` in unique constraints varies by database.

### How to choose a key

Choose a key that reliably identifies a record, follows the business rules, and is stable enough for the intended use. A warehouse may use a surrogate key while retaining the source's natural/business key for matching and traceability.

---

## 32. BCNF and Fourth Normal Form (4NF)

The original notes introduce 1NF, 2NF and 3NF. Two additional normal forms are useful to understand.

### Boyce–Codd Normal Form (BCNF)

A relation is in BCNF when, for every non-trivial functional dependency:

```text
X → Y
```

`X` is a superkey.

In simpler terms, every determinant must be able to uniquely identify a row.

BCNF is stricter than 3NF and addresses certain dependency patterns that 3NF can permit.

### Fourth Normal Form (4NF)

4NF addresses **non-trivial multivalued dependencies**. A table should not combine independent multi-valued facts about the same entity when doing so creates unnecessary combinations.

Example: a teacher can teach several subjects and speak several languages, independently.

Problematic design:

```text
teacher | subject | language
--------|---------|---------
T1      | Maths   | English
T1      | Maths   | Hindi
T1      | Science | English
T1      | Science | Hindi
```

If subjects and languages are independent facts, the combinations create redundancy. Separate the facts:

```text
teacher_subject
---------------
teacher | subject

teacher_language
----------------
teacher | language
```

**Practical priority:** Learn 1NF–3NF thoroughly first, then understand what BCNF and 4NF are intended to prevent.

---

## 33. Database Constraints and Referential Integrity

Constraints encode rules that data must follow.

- `PRIMARY KEY`: uniquely identifies each row and does not allow `NULL`.
- `FOREIGN KEY`: requires a referencing value to match an eligible key in the referenced table, subject to the database's null and constraint rules.
- `UNIQUE`: prevents duplicate key values.
- `NOT NULL`: requires a value.
- `CHECK`: validates a condition, such as `quantity >= 0`.
- `DEFAULT`: supplies a value when an insert omits the column, depending on the statement and database behavior.

Example:

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_total DECIMAL(12, 2) CHECK (order_total >= 0),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
```

Foreign-key actions can define what happens when a referenced row is updated or deleted:

- `RESTRICT` / `NO ACTION`: prevent or reject a change that violates the relationship; details depend on the database.
- `CASCADE`: propagate an update or delete to referencing rows.
- `SET NULL`: set the referencing foreign key to `NULL`, if allowed.

**Data engineering note:** Analytical warehouses sometimes enforce fewer physical constraints for performance or platform-specific reasons. The same integrity rules should still be checked through ingestion tests, validation queries or the warehouse's supported constraint mechanisms.

---

## 34. ER Diagrams, Optionality and Weak Entities

An **Entity–Relationship (ER) diagram** represents entities, their attributes and the relationships between them.

Example:

```text
CUSTOMER 1 ───────── 0..N ORDER
```

This can mean a customer may have zero or many orders, while each order is associated with one customer. The exact meaning depends on the business rules.

### Cardinality vs. optionality

- **Cardinality** describes how many related instances can exist: one-to-one, one-to-many or many-to-many.
- **Optionality** describes whether participation is required or optional.

Examples:
- An order must have a customer: mandatory participation.
- A customer may not have placed an order yet: optional participation in the order relationship.

### Weak entity

A weak entity cannot be uniquely identified by its own attributes alone and depends on an owning entity for identification.

Example: an order line may be identified by `(order_id, line_number)` rather than by `line_number` alone.

### Identifying relationship

A relationship in which the parent's key participates in identifying the child entity.

These ideas help translate business rules into primary keys, foreign keys, nullability and uniqueness constraints.

---

## 35. Insert, Update and Delete Anomalies

Poorly designed tables can cause anomalies.

Consider a table that stores order data and repeats customer information on every order.

### Update anomaly

A customer's city appears in 20 rows. If the customer moves, all 20 rows must be updated. Missing one creates inconsistent data.

### Insert anomaly

You cannot add a new customer until the customer places an order, because the table requires order details.

### Delete anomaly

Deleting a customer's last order accidentally deletes the only stored copy of the customer's details.

### How normalization helps

Separate independent entities into related tables, such as `customer`, `orders` and `order_item`. This reduces duplication and allows each fact to be maintained in an appropriate place.

---

# Dimensional Modeling in More Detail

## 36. The Three Main Fact Table Types

Fact table design starts by defining the business process and grain.

### Transaction fact table

Stores one row per individual event or transaction.

Example: one row per product line on an order.

```text
order_id | product_id | order_date | quantity | sales_amount
```

Useful for detailed analysis and tracing individual events.

### Periodic snapshot fact table

Stores a snapshot of a process at regular intervals, such as one row per account per day or one row per product per month.

```text
snapshot_date | account_id | closing_balance
```

Useful for questions such as daily balances, month-end inventory or weekly account status.

### Accumulating snapshot fact table

Stores a process that moves through defined milestones. A row is created and then updated as the process progresses.

```text
order_id | order_date | packed_date | shipped_date | delivered_date
```

Useful for order fulfillment, loan applications and claims processing. Because milestones are updated over time, this pattern differs from an immutable transaction-event table.

### Choosing among them

- Individual events → transaction fact.
- State at regular points in time → periodic snapshot.
- Progress through a lifecycle → accumulating snapshot.

A solution may use more than one fact table for the same business process.

---

## 37. Factless Fact Tables

A **factless fact table** records that an event occurred or that a relationship existed, without requiring a numeric measure.

Example: student attendance.

```text
date_key | student_key | class_key
```

The existence of a row records attendance. The number of attendance events can be calculated with `COUNT(*)`.

Another example is eligibility or coverage: which customers were eligible for a promotion on a given date, even if they did not purchase anything.

**Important:** A missing row can have different meanings. It may mean that an event did not occur, that data has not arrived, or that the event was not recorded. Define this explicitly.

---

## 38. Multiple Fact Tables and Fact-to-Fact Joins

Suppose there are two facts:

```text
fact_sales
----------
date_key
product_key
sales_amount
```

```text
fact_returns
------------
date_key
product_key
return_amount
```

Both may connect to shared dimensions such as date and product. These shared dimensions let you compare sales and returns at a compatible grain.

### Why direct fact-to-fact joins can be dangerous

If one product has three sales rows and two return rows for the join keys, joining the raw facts on those keys can produce six rows. Measures can be duplicated and totals inflated.

### Safer pattern

1. Identify the grain of each fact.
2. Aggregate each fact to the same comparison grain.
3. Join the aggregated results through the shared dimensional keys.

Example:

```sql
WITH sales_by_day_product AS (
    SELECT date_key, product_key, SUM(sales_amount) AS sales
    FROM fact_sales
    GROUP BY date_key, product_key
),
returns_by_day_product AS (
    SELECT date_key, product_key, SUM(return_amount) AS returns
    FROM fact_returns
    GROUP BY date_key, product_key
)
SELECT
    s.date_key,
    s.product_key,
    s.sales,
    COALESCE(r.returns, 0) AS returns
FROM sales_by_day_product s
LEFT JOIN returns_by_day_product r
    ON r.date_key = s.date_key
   AND r.product_key = s.product_key;
```

This example reports sales rows with matching returns. If return-only combinations must also appear, use a full outer join where supported, or construct a union of the key sets and join both aggregates to it.

---

## 39. Header-Level vs. Line-Item Facts

An order may have one header and several line items.

```text
order_header
------------
order_id
customer_id
order_total

order_item
----------
order_id
product_id
quantity
line_amount
```

The header grain is one row per order. The line-item grain is one row per product line within an order.

If `order_total` is repeated on every order-item row, summing it over line items overcounts the order total.

**Rule:** Store and aggregate measures at the grain at which they are valid. If order-level and line-level metrics are both needed, preserve their different grains or allocate values using a clearly defined business rule.

---

## 40. Conformed Dimensions

A **conformed dimension** has consistent meaning and compatible definitions across multiple fact tables or data marts.

Example:

```text
fact_sales ─────┐
                ├──── dim_date
fact_inventory ─┘
```

Both facts use the same date dimension and the same interpretation of its keys and attributes.

A shared customer dimension could support sales, support and subscription reporting.

### Benefits

- Enables cross-process reporting.
- Reduces conflicting definitions.
- Encourages reuse.
- Supports consistent business metrics.

A dimension is not truly conformed merely because two tables happen to have similar column names. Their keys, business meaning, attribute definitions and governance must be aligned.

---

## 41. Role-Playing Dimensions

One dimension can serve multiple roles in a fact table.

Example:

```text
fact_orders
-----------
order_date_key
ship_date_key
delivery_date_key
```

All three keys may reference the same `dim_date`, but each has a different meaning.

Example query:

```sql
SELECT
    order_date.calendar_date AS order_date,
    ship_date.calendar_date AS ship_date
FROM fact_orders f
JOIN dim_date order_date
    ON f.order_date_key = order_date.date_key
LEFT JOIN dim_date ship_date
    ON f.ship_date_key = ship_date.date_key;
```

Role-playing dimensions avoid duplicating the date dimension while making each relationship explicit. In a BI semantic layer, expose clear role names so users know which date they are analyzing.

---

## 42. Junk Dimensions

A **junk dimension** groups miscellaneous low-cardinality flags and indicators that do not deserve separate dimensions.

Example:

```text
dim_order_flags
---------------
flag_key
is_gift
is_expedited
payment_review_flag
```

The fact table stores `flag_key` rather than repeatedly storing several small flags.

Use this pattern when the flags form a meaningful combination and the design improves usability. Do not put unrelated high-cardinality attributes into a junk dimension.

---

## 43. Degenerate Dimensions

A **degenerate dimension** is a business identifier stored directly in a fact table without a separate dimension table.

Example:

```text
fact_sales
----------
order_number
customer_key
product_key
sales_amount
```

`order_number` may be retained for drill-through, reconciliation or tracing back to the source order. If it has no additional descriptive attributes, a separate `dim_order` may not be useful.

A degenerate dimension is not the same as a surrogate key: the former is a business identifier retained in the fact, while the latter is a generated identifier used to identify a row or dimension version.

---

## 44. Outrigger Dimensions

An **outrigger dimension** is a dimension referenced by another dimension.

Example:

```text
fact_sales → dim_customer → dim_geography
```

Here, customer references a geography dimension instead of storing every geography attribute directly.

This can reduce duplication but introduces additional joins. For many conventional star schemas, a denormalized customer dimension is simpler. Choose based on reuse, governance, complexity and query needs.

---

## 45. Hierarchies and Drill-Down

A hierarchy defines levels through which users can aggregate or explore data.

Examples:

```text
Geography:
Country → State → City → Store

Product:
Department → Category → Subcategory → Product

Time:
Year → Quarter → Month → Day
```

### Drill-down and roll-up

- **Drill-down:** move from a summary to more detail, such as year → month.
- **Roll-up:** aggregate detailed data to a higher level, such as city → state.

Hierarchies need valid business rules. For example, if a product can belong to multiple categories, a simple single-parent hierarchy may not accurately represent the relationship.

---

## 46. Date and Time Dimensions

A date dimension stores useful calendar attributes so reports do not need to repeatedly derive them from timestamps.

Example:

```text
dim_date
--------
date_key
calendar_date
day
month
month_name
quarter
year
day_of_week
is_weekend
is_holiday
fiscal_period
```

### Calendar vs. fiscal periods

A fiscal year may start in a month other than January. A date dimension can map each calendar date to the organization's fiscal year, fiscal quarter and fiscal period.

### Multiple date meanings

Orders, shipments and payments may each have a different date. These roles should be modeled explicitly, usually using role-playing date relationships.

### Time zones

For global systems, define how source timestamps are interpreted and stored, including UTC conversion, local business time and daylight-saving behavior. A date key alone may not preserve all the required timestamp detail.

---

## 47. Mini-Dimensions and Rapidly Changing Attributes

Some dimension attributes change much more frequently than others.

Example: a customer dimension contains relatively stable profile information, but customer segmentation or risk band changes frequently.

A **mini-dimension** can separate a group of rapidly changing attributes into its own dimension.

```text
dim_customer
------------
customer_key
customer_id
name
country

dim_customer_profile
--------------------
profile_key
segment
risk_band
income_band
```

The fact or a customer-version record can reference the appropriate profile key, depending on the chosen design.

### Why use one?

- Limits growth in a very large SCD Type 2 dimension.
- Separates frequently changing classifications from stable descriptive attributes.
- Can make analysis of historical classifications easier.

The trade-off is additional modeling and joins. It is not necessary for every dimension.

---

# Historical Data and Change Management

## 48. SCD Types 3, 4 and 6

The original notes explain SCD Types 0, 1 and 2. These are additional approaches.

### SCD Type 3 — limited history

Stores the current value and one previous value in the same row.

```text
customer_id | current_city | previous_city
------------|--------------|--------------
101         | Bangalore    | Hyderabad
```

Useful when only a limited amount of previous state is required. It does not preserve an unlimited sequence of historical changes.

### SCD Type 4 — separate history table

The current record is kept in one table, and historical versions are kept separately.

```text
customer_current
----------------
customer_id
city

customer_history
----------------
customer_id
city
valid_from
valid_to
```

Useful when the current-state lookup should be simple while history is retained separately. Implementations vary in how they store the current version and history boundaries.

### SCD Type 6 — hybrid approach

A hybrid pattern combines aspects of Types 1, 2 and 3. One common implementation retains historical rows (Type 2), maintains a current-value attribute across historical versions (Type 1-style behavior), and exposes previous-value information (Type 3-style behavior).

SCD Type 6 is not implemented identically in every organization. Document which attributes are overwritten and which preserve history.

---

## 49. Effective Dating and Temporal Modeling

Effective dating records when a value is considered valid in the business domain.

Example:

```text
customer_id | city      | valid_from | valid_to
------------|-----------|------------|------------
101         | Hyderabad | 2025-01-01 | 2026-04-01
101         | Bangalore | 2026-04-01 | NULL
```

A common convention is that `valid_from` is inclusive and `valid_to` is exclusive. Under this convention, the first row is valid from 1 January 2025 up to, but not including, 1 April 2026.

This avoids overlapping boundary dates.

### Business time vs. system time

- **Business/valid time:** when the fact was true in the real world.
- **System/transaction time:** when the database learned or recorded the fact.

A bitemporal design tracks both. This is useful when a change is reported late or a past value must be corrected while preserving what the system previously knew.

Always define date-boundary conventions, time zones and correction behavior.

---

## 50. Late-Arriving Dimensions

A fact may arrive before its dimension record.

Example: a sales transaction references customer `C1001`, but the customer details have not arrived yet.

Common approaches:

1. Create an **inferred member** with the known business key and placeholder attributes.
2. Load the fact with the inferred dimension's surrogate key.
3. When the real dimension data arrives, update the inferred record or apply the warehouse's versioning policy.
4. Validate that the fact now resolves to the correct dimension record.

The correct treatment depends on whether the arriving details describe the same historical version or a later version of the dimension.

---

## 51. Early-Arriving Facts and Inferred Members

An **early-arriving fact** is a fact that arrives before all the descriptive information needed for its dimensional relationships is available.

An **inferred member** is a placeholder dimension row created using the limited information available, often just the business key and technical metadata.

Example:

```text
customer_key | customer_id | customer_name
-------------|-------------|--------------
9001         | C1001       | Unknown
```

Later, the placeholder may be enriched with the actual customer attributes.

Do not confuse an inferred member with an unknown or not-applicable member:
- **Inferred:** the real entity is known to exist, but details have not arrived yet.
- **Unknown:** the relationship should exist, but the entity cannot currently be identified.
- **Not applicable:** the relationship genuinely does not apply.

The warehouse should define distinct handling for these cases.

---

## 52. Historical Corrections and Backdated Changes

Suppose a customer moved to Bangalore on 1 March, but the warehouse learns about the move on 20 March.

The model must distinguish:
- The date the move became effective.
- The date the warehouse learned about it.
- Whether prior reports should be corrected.
- Whether the previous version must remain auditable.

For an ordinary Type 2 dimension, the historical effective dates may be corrected. For stricter audit requirements, tracking both valid time and system time may be necessary.

### Practical safeguards

- Keep a reliable business key.
- Define effective-date boundaries.
- Prevent overlapping current versions where the business rule permits only one.
- Reprocess affected facts if the surrogate-key assignment or historical attribution must change.
- Record correction metadata when auditability is required.

---

# Warehouse Architecture and Modeling Approaches

## 53. Kimball vs. Inmon

These are influential approaches to enterprise data warehousing.

### Kimball approach

Often described as bottom-up:
- Build dimensional models around business processes.
- Publish data marts with conformed dimensions.
- Integrate the marts through shared dimensions and consistent definitions.

### Inmon approach

Often described as top-down:
- Establish an enterprise-wide, integrated data warehouse, traditionally normalized.
- Derive subject-oriented analytical marts from that foundation.

### How to compare them

| Consideration | Kimball-style approach | Inmon-style approach |
|---|---|---|
| Main emphasis | Dimensional models and business processes | Enterprise integration and centralized warehouse |
| Typical presentation | Facts and dimensions | Integrated enterprise model, traditionally normalized |
| Integration | Conformed dimensions and shared definitions | Central integrated warehouse |
| Strength | Business-friendly analytics | Enterprise-wide consistency and integration |
| Trade-off | Requires careful coordination across marts | Central modeling can require more upfront work |

Real-world architectures can combine these ideas. Neither approach is universally best; requirements, governance, existing systems and delivery constraints matter.

---

## 54. Data Vault 2.0

Data Vault is a modeling approach designed to integrate data from multiple source systems and retain historical change information.

Its three core structures are:

### Hubs

Store unique business keys for core business concepts.

```text
hub_customer
------------
customer_hk
customer_business_key
load_date
record_source
```

### Links

Represent relationships or business associations between hubs.

```text
link_order_customer
-------------------
link_hk
order_hk
customer_hk
load_date
record_source
```

### Satellites

Store descriptive attributes and their history for a hub or link.

```text
sat_customer_details
--------------------
customer_hk
customer_name
city
load_date
record_source
```

The exact columns and hash-key conventions depend on the implementation.

### Why use Data Vault?

- Integrates multiple sources.
- Retains historical changes and source lineage.
- Can accommodate evolving source structures.
- Separates business keys, relationships and descriptive history.

### Trade-offs

It creates more tables and usually requires additional transformation to produce analyst-friendly dimensional models. A common architecture loads source data into a Data Vault and publishes dimensional marts for reporting.

---

## 55. One Big Table (OBT) and Wide Tables

An **OBT** combines many attributes into one wide analytical table, often by joining facts and dimensions ahead of time.

Example:

```text
sales_analytics
---------------
order_id
order_date
customer_name
customer_city
product_name
product_category
quantity
sales_amount
```

### Advantages

- Simple for many downstream queries.
- Reduces repeated joins.
- Can suit particular BI, reporting or machine-learning workloads.

### Trade-offs

- Repeats descriptive attributes.
- Can make historical attribute handling harder.
- May increase storage and refresh costs.
- Can create ambiguity when measures have different grains.

An OBT should be designed around a clearly defined grain. It does not automatically replace the underlying normalized or dimensional model.

---

## 56. Anchor Modeling

Anchor modeling is a modeling approach designed for data that changes frequently and needs detailed history.

It typically separates:
- **Anchors:** stable identities of business objects.
- **Attributes:** properties of those objects.
- **Ties:** relationships between objects.
- **Historized attributes and ties:** records of changes over time.

It can support flexible schema evolution and historical tracking, but may involve many tables and joins.

**Learning priority:** Understand the purpose and basic structure first. For many junior data engineering roles, relational and dimensional modeling are more immediately important.

---

## 57. Data Marts and Enterprise Data Warehouses

### Enterprise data warehouse (EDW)

An integrated analytical data environment intended to support multiple business areas with consistent data.

### Data mart

A subject-oriented analytical dataset, such as:
- Sales mart.
- Finance mart.
- Inventory mart.
- Customer support mart.

A data mart can be built directly from source data or derived from a broader warehouse.

### Important design principle

Separate data marts do not automatically provide consistent reporting. Shared definitions, conformed dimensions, key mapping and governance are needed when metrics must be compared across business areas.

---

## 58. Lakehouse Modeling

A lakehouse combines data-lake-style storage with capabilities used for analytical data management, such as transactional table formats, schema enforcement and scalable SQL analytics.

Common modeling choices include:
- Raw source-aligned tables.
- Cleaned and standardized tables.
- Curated dimensional tables or wide analytical tables.
- File/table formats that support updates, schema evolution and reliable reads.

The exact capabilities depend on the storage format and platform.

A lakehouse does not require one specific modeling style. You can use dimensional models, normalized integration models, Data Vault, wide tables or combinations of them.

---

## 59. Medallion Architecture

Medallion architecture organizes data into progressively refined layers.

```text
Bronze → Silver → Gold
```

### Bronze

Raw or minimally processed source data, retained for traceability and replay where appropriate.

### Silver

Cleaned, standardized, validated and integrated data. Typical work includes deduplication, type conversion, key standardization and handling invalid records.

### Gold

Business-ready models, aggregates and data products. These may include fact tables, dimension tables, data marts, KPI tables or wide analytical datasets.

### How it relates to data modeling

Medallion layers describe the refinement and organization of data. Dimensional modeling defines the structure of a particular analytical model. For example, a Gold layer may contain a star schema with `fact_sales`, `dim_customer` and `dim_product`.

Not every implementation must use exactly three layers, and layer names alone do not guarantee data quality.

---

## 60. Semantic Layer and Metrics Modeling

A **semantic layer** presents business-friendly concepts on top of underlying data models.

For example, it can define:
- Revenue.
- Active customer.
- Order count.
- Gross margin.
- Customer retention.

It specifies how measures are calculated, which dimensions can filter them, and how tables relate.

### Why it matters

Without shared definitions, two dashboards may calculate “revenue” differently. A semantic layer helps standardize calculations and make them reusable.

A good metric definition documents:
- Business meaning.
- Formula.
- Grain.
- Time period and date role.
- Filters and exclusions.
- Currency and unit.
- Treatment of nulls, returns and cancellations.
- Owner and validation rules.

A semantic layer complements a well-designed physical data model; it does not fix incorrect grain or duplicated measures underneath.

---

# Physical Modeling and Query Performance

## 61. Index Design

Indexes help databases locate rows without scanning an entire table in every case.

### Composite indexes

An index on `(customer_id, order_date)` may help queries filtering by `customer_id`, and often queries filtering by both columns. Whether it helps a query filtering only by `order_date` depends on the database and index design.

Column order matters because many database engines use the leftmost prefix of a composite index.

### Covering indexes

An index is covering for a query when it contains the columns needed to satisfy that query without requiring additional table-row lookups, depending on the engine.

### Clustered vs. nonclustered indexes

These terms are database-specific. In systems that support them, a clustered index influences how table data is organized, while a nonclustered index is a separate lookup structure.

**Trade-off:** Indexes can improve reads but consume storage and add work to inserts, updates and deletes. Columnar cloud warehouses often use different optimization mechanisms instead of conventional OLTP-style indexes.

---

## 62. Partitioning, Sharding and Distribution

These techniques organize or distribute data, but they are not interchangeable.

### Partitioning

Divides one logical table into partitions according to a rule, such as a date range.

Example:

```text
sales_2025_01
sales_2025_02
sales_2025_03
```

These labels illustrate monthly partitions; actual partitioning is typically defined by the database rather than by creating unrelated tables.

Partition pruning can let the engine skip partitions that cannot match a query.

### Sharding

Splits data across multiple database instances or nodes. It introduces complexity around routing, joins, transactions and rebalancing.

### Distribution

In a distributed analytical warehouse, data may be distributed across compute nodes using a chosen distribution key or strategy.

### Choosing a strategy

Consider:
- Common filter columns.
- Data volume and growth.
- Data skew.
- Join patterns.
- Retention requirements.
- Platform-specific constraints.

Partitioning by a date does not automatically improve every query. The query must benefit from skipping partitions, and the partition design must suit the workload.

---

## 63. Row Storage, Columnar Storage and Data Layout

### Row-oriented storage

Stores fields for a row together and often suits workloads that retrieve or update individual records.

### Columnar storage

Stores data organized by columns or column groups. It often benefits analytical queries that scan a few columns across many rows and aggregate large datasets.

### Data layout

Analytical systems may improve performance through:
- Partition pruning.
- Sorting or clustering.
- Compression.
- File sizing.
- Data skipping or statistics.

These features vary by database, table format and cloud platform. A logical model describes the business structure; physical layout optimizes how the system stores and reads it.

---

## 64. Materialized Views and Aggregate Tables

A normal view stores a query definition and evaluates it when queried, subject to the database's implementation. A **materialized view** persists query results and refreshes them according to the platform's rules.

An **aggregate table** stores precomputed summaries, such as monthly sales by product category.

Example:

```text
monthly_sales
-------------
month_key
category_key
total_sales
order_count
```

### Benefits

- Faster repeated reporting.
- Less repeated aggregation.
- Potentially lower query compute costs.

### Trade-offs

- Extra storage.
- Refresh and maintenance costs.
- Risk of stale results.
- Need for clearly defined grain and aggregation rules.

Never sum pre-aggregated values across dimensions where they are not additive, such as summing daily account balances across dates.

---

# Practical Modeling and Production Engineering

## 65. Business Requirements and Source-to-Target Mapping

Before designing tables, identify the business questions and the data needed to answer them.

For each target field, document:

| Item | Example |
|---|---|
| Target column | `sales_amount` |
| Source field | `order_line.net_amount` |
| Transformation | Convert to standard currency and decimal type |
| Grain | One order line |
| Null handling | Reject or quarantine missing required amounts |
| Validation | Reconcile totals against the source |
| Owner | Sales data product team |

This mapping clarifies where each attribute originates, how it is transformed and how it should be validated.

---

## 66. Data Profiling and Domain Discovery

**Data profiling** examines actual source data before and during modeling.

Check:
- Row counts.
- Null and blank rates.
- Duplicate candidate keys.
- Distinct-value counts.
- Minimums, maximums and distributions.
- Invalid formats and out-of-domain values.
- Relationship coverage between parent and child records.
- Unexpected changes over time.

For example, a column named `customer_id` may not be unique in the source, despite its name. Profiling helps determine whether it is a true key, a composite key component or merely an attribute.

A sample is useful for exploration, but important assumptions should be validated against representative data and source-system rules.

---

## 67. Data Contracts and Schema Evolution

A **data contract** documents expectations between a producer and consumers of a dataset.

It may define:
- Column names and data types.
- Required and optional fields.
- Key and uniqueness expectations.
- Allowed values.
- Freshness and delivery expectations.
- Ownership and compatibility rules.

### Schema evolution

A source schema may change by adding, removing, renaming or changing a column's type.

Treat changes according to their compatibility:
- Adding an optional column may be backward-compatible.
- Removing or renaming a required column may break consumers.
- Changing a type can cause failures or silent data loss.

Use versioning, automated checks, explicit migrations and consumer-impact analysis. The exact policy depends on the platform and contract system.

---

## 68. Master Data Management (MDM)

MDM helps establish consistent, governed identities for core business entities across systems.

Example:

```text
CRM customer_id = C101
ERP customer_id = 9007
```

These identifiers may represent the same real-world customer. An MDM or entity-resolution process can determine whether they should map to one enterprise customer identity.

### Related concepts

- Business-key matching.
- Duplicate detection.
- Survivorship rules for conflicting attributes.
- Golden records.
- Cross-reference mappings between source and enterprise IDs.

A warehouse surrogate key alone does not solve entity resolution. The business must determine which source records refer to the same entity.

---

## 69. Data Lineage and Impact Analysis

**Data lineage** records where data came from and how it was transformed.

Example:

```text
Source orders
     ↓
Silver orders
     ↓
fact_sales
     ↓
Monthly revenue dashboard
```

Lineage helps answer:
- Which source fields contributed to a metric?
- What breaks if a column is renamed?
- Which reports depend on a table?
- Where did an unexpected value originate?

Lineage may be captured at table, column, transformation or job level. More detailed lineage generally provides more useful impact analysis but may require additional instrumentation.

---

## 70. Data Quality Rules

Data quality rules should reflect the business meaning of the model.

Common dimensions of quality include:

- **Completeness:** required values are present.
- **Uniqueness:** key columns have no unintended duplicates.
- **Validity:** values follow the expected type, format or allowed domain.
- **Consistency:** related fields and tables agree.
- **Referential integrity:** foreign-key references resolve appropriately.
- **Timeliness:** data arrives within the expected time.
- **Reconciliation:** totals and counts agree with trusted sources or control totals.

Example checks:

```sql
-- Check for duplicate order IDs where one row per order is expected.
SELECT order_id, COUNT(*) AS row_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

```sql
-- Find orders whose customer key is not present in the customer table.
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

The second check must be adjusted if missing or inferred dimension members are valid in the design.

A good data quality framework defines what happens when a check fails: block the load, quarantine rows, warn an owner or accept the data with documented exceptions.

---

## 71. Incremental Loads, Upserts and CDC

### Full load

Reloads the complete target dataset. It is straightforward but may be expensive for large datasets.

### Incremental load

Processes only new or changed records, using a suitable mechanism such as a watermark, change log or source-provided sequence.

### Upsert

Inserts records that do not exist and updates matching records, according to a defined key and change policy.

### Change Data Capture (CDC)

Captures source changes, often including inserts, updates and deletes. CDC can use database logs, timestamps, change tables or other platform mechanisms.

### Modeling questions to answer

- What uniquely identifies a source record?
- How are deletes represented?
- Can changes arrive out of order?
- How are retries made safe?
- How are duplicate events detected?
- Is the target a current-state table or a history-preserving table?
- How are corrections and replay handled?

Incremental processing is not only a pipeline concern. Key design, change semantics, history policy and idempotency all affect the data model.

---

## 72. Event Time vs. Ingestion Time

An event may happen at one time but arrive in the data platform later.

- **Event time:** when the event occurred according to the source or business definition.
- **Ingestion time:** when the platform received or ingested the event.
- **Processing time:** when a processing system handled it.

Example: a purchase occurs at 10:00, reaches the warehouse at 10:07 and is processed at 10:09.

Keeping these times distinct helps with late-arriving data, latency monitoring, reprocessing and time-based analysis.

Define the authoritative timestamp for business reporting. Ingestion time should not silently replace event time when the question is about when the business event occurred.

---

## 73. PII, Privacy and Data Governance

Data modeling decisions can affect privacy and compliance.

Identify:
- Personally identifiable information (PII).
- Sensitive business attributes.
- Who is permitted to access each field.
- Retention and deletion requirements.
- Masking or tokenization needs.
- Whether downstream tables need the original value at all.

Possible controls include:
- Collecting only necessary attributes.
- Restricting access by role.
- Masking values in development and analytics.
- Applying retention and deletion policies.
- Keeping sensitive attributes separate where appropriate.

Privacy requirements should be considered during model design rather than added only after the tables have been built.

---

# Additional Interview Practice Questions

Use these to check whether you can apply the concepts rather than only define them.

1. What is the difference between a candidate key and a primary key?
2. How do functional dependencies help identify normalization problems?
3. What does BCNF address that 3NF may not fully prevent?
4. How would you model an order header and multiple order lines?
5. When would you choose a transaction fact over a periodic snapshot?
6. Why can joining two fact tables inflate totals?
7. What makes a dimension conformed?
8. What is the difference between a junk dimension and a degenerate dimension?
9. How would you handle a fact arriving before its dimension?
10. When would a Type 2 SCD be preferable to Type 1?
11. What is the difference between valid time and system time?
12. When might Data Vault be appropriate?
13. How does medallion architecture relate to dimensional modeling?
14. What is the difference between partitioning and sharding?
15. How would you model and validate incremental changes from a source system?
16. What quality checks would you apply to a new fact table?
17. How would you respond to a breaking schema change in a source?
18. How can a semantic layer prevent inconsistent KPI definitions?
19. What does data lineage help you investigate?
20. How should privacy and retention requirements affect a data model?

---

# Suggested Study Order

For a junior data engineering role, prioritize the concepts as follows:

1. Functional dependencies, keys, constraints and normalization.
2. Grain, fact table types, dimension design and safe joins.
3. SCDs, effective dating, late-arriving data and CDC.
4. Source-to-target mapping, profiling and data quality.
5. Kimball, Inmon, Data Vault and medallion architecture.
6. Indexes, partitioning, storage layout and aggregate tables.
7. Contracts, lineage, semantic modeling and governance.
8. Anchor modeling and other specialized approaches.

**Final principle:** Always begin a model by clarifying the business process, the meaning of one row (grain), the keys and relationships, and the history requirements. Only then choose the schema and physical implementation.
