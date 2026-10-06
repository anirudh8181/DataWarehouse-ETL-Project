



![alt text](image.png)



In a **star schema**, the relationship is usually:

> **One Dimension → Many Fact rows**

The **fact table is in the center**, and dimension tables surround it.

### Example

Suppose we have:

```text
             dim_customer
                  |
                  |
dim_product ---- fact_sales ---- dim_date
                  |
                  |
             dim_store
```

### 1. Fact table

`fact_sales` contains **business events/measures**:

| sales_key | customer_key | product_key | date_key | quantity | amount |
| --------: | -----------: | ----------: | -------: | -------: | -----: |
|         1 |          101 |         501 | 20260101 |        2 |    500 |
|         2 |          101 |         502 | 20260101 |        1 |    300 |
|         3 |          102 |         501 | 20260102 |        5 |   1250 |

### 2. Dimension table

`dim_customer` describes the customer:

| customer_key | customer_id | customer_name |
| -----------: | ----------- | ------------- |
|          101 | C001        | Rahul         |
|          102 | C002        | Arun          |

Notice:

```text
dim_customer
customer_key = 101
       ↓
fact_sales
       ↓
multiple rows can have customer_key = 101
```

So the relationship is:

```text
dim_customer
     1
     |
     |
     N
fact_sales
```

Meaning **one customer can have many sales**.

---

### Why does the fact table contain the dimension key?

The fact table stores **foreign keys** pointing to dimensions:

```text
fact_sales
   |
   +-- customer_key → dim_customer
   |
   +-- product_key  → dim_product
   |
   +-- date_key     → dim_date
```

These keys allow you to answer questions such as:

> "How much did Rahul spend?"

You join:

```sql
SELECT
    c.customer_name,
    SUM(f.amount) AS total_sales
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_name;
```

---

### Important concept

The **dimension does not normally point to the fact**.

Think of it as:

```text
DIMENSION                         FACT

Customer  ────────────────→  Sales
   1                            many

Product   ────────────────→  Sales
   1                            many

Date      ────────────────→  Sales
   1                            many
```

The **foreign key physically lives in the fact table**.

So in a typical star schema:

**Dimension = descriptive information**

**Fact = transactions/events + measurements**

**Relationship = Dimension 1 → Fact Many**

And this is why your earlier query:

```sql
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
```

works: `fact_sales.customer_key` references `dim_customers.customer_key`.
