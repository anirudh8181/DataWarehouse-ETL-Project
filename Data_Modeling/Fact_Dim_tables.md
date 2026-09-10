Yes. Let's do that next, **in depth and interview-oriented**.

The key is not just memorizing "fact = numbers, dimension = descriptions." You need to understand **how to identify them, choose the grain, design the keys, and handle real-world scenarios.**

# 1. The Big Picture: Dimensional Modeling

Suppose you're building a warehouse for an e-commerce company.

The business wants to answer:

* How much did we sell?
* Which products sell the most?
* Which customers buy the most?
* Sales by city?
* Sales by month?
* Sales by category?

A dimensional model might look like:

```text
                         dim_customer
                              |
                              |
dim_date ----------- fact_sales ----------- dim_product
                              |
                              |
                         dim_store
```

The central idea is:

```text
FACTS       → What happened?
DIMENSIONS  → Who / What / Where / When / How?
```

---

# 2. What Is a Fact Table?

A **fact table stores measurable business events or processes**.

Examples:

```text
Sales
Orders
Payments
Shipments
Website clicks
Inventory movements
```

For sales:

```text
fact_sales
--------------------------------
sales_key
date_key
customer_key
product_key
store_key
quantity
unit_price
discount
sales_amount
```

The important thing is that a fact table represents **events at a specific grain**.

---

# 3. What Is a Dimension Table?

A dimension table stores the **descriptive/contextual information** used to analyze facts.

For example:

```text
dim_customer
--------------------------------
customer_key
customer_id
first_name
last_name
gender
city
state
country
customer_segment
```

And:

```text
dim_product
--------------------------------
product_key
product_id
product_name
category
subcategory
brand
color
size
```

The fact tells you:

> **What happened?**

The dimension tells you:

> **Who, what, where, when, etc.?**

---

# 4. Real Example

Suppose James buys an iPhone for ₹80,000.

The business event is:

```text
Customer: James
Product: iPhone
Date: Aug 24, 2026
Quantity: 1
Amount: ₹80,000
```

The fact table might store:

| date_key | customer_key | product_key | quantity | sales_amount |
| -------: | -----------: | ----------: | -------: | -----------: |
| 20260824 |          101 |        5001 |        1 |        80000 |

But where do we get:

```text
James
Hyderabad
Apple
iPhone
Electronics
```

from?

From dimensions.

```text
fact_sales
    |
    +---- dim_customer
    |
    +---- dim_product
    |
    +---- dim_date
```

This is the essence of dimensional modeling.

---

# 5. The Most Important Concept: Grain

Before creating a fact table, you should **always define the grain first**.

Grain means:

> **What does exactly one row in this fact table represent?**

Suppose you say:

> One row represents one customer order.

That's one possible grain.

But perhaps an order can contain multiple products.

Example:

```text
Order 1001

iPhone       ₹80,000
AirPods      ₹20,000
MacBook     ₹100,000
```

If your grain is:

> One row per order

you could have:

| order_id | total_amount |
| -------- | -----------: |
| 1001     |       200000 |

But now you lose product-level detail.

Instead, you could define the grain as:

> **One row per product per order.**

Then:

| order_id | product | quantity | amount |
| -------- | ------- | -------: | -----: |
| 1001     | iPhone  |        1 |  80000 |
| 1001     | AirPods |        1 |  20000 |
| 1001     | MacBook |        1 | 100000 |

This is much more useful for detailed analysis.

---

# 6. Grain Determines the Fact Table

This is a very common interview question:

> **How do you decide the grain of a fact table?**

Good answer:

> "I first identify the business process and determine the lowest meaningful level at which the business needs to analyze that process. I then define exactly what one row represents before selecting dimensions and measures."

For example:

```text
Business Process:
Sales

Grain:
One row per product per order

Dimensions:
Customer
Product
Date
Store

Measures:
Quantity
Sales amount
Discount
Cost
```

---

# 7. Types of Fact Tables

This is where interviews get more interesting.

There are **three major fact table types** you should know:

```text
1. Transaction Fact
2. Periodic Snapshot Fact
3. Accumulating Snapshot Fact
```

There is also a useful special case:

```text
4. Factless Fact
```

Let's understand each.

---

# 8. Transaction Fact Table

This records **individual business transactions/events**.

Example:

```text
fact_sales
------------------------
order_id
product_key
customer_key
date_key
quantity
sales_amount
```

Every sale/product-line is a row.

Example:

| order_id | product_key | customer_key | quantity | amount |
| -------- | ----------: | -----------: | -------: | -----: |
| O1001    |         501 |          101 |        2 |   5000 |
| O1002    |         502 |          102 |        1 |   3000 |
| O1003    |         501 |          103 |        3 |   7500 |

This is the **most common fact table type**.

### Use when?

You want to capture individual events.

Examples:

```text
Sales
Payments
Orders
Website clicks
Bank transactions
```

---

# 9. Periodic Snapshot Fact

Instead of recording every transaction, you take a **snapshot at regular intervals**.

For example, inventory.

Every day:

```text
Product A → 100 units
Product B → 200 units
Product C → 150 units
```

You could have:

```text
fact_inventory_snapshot
-----------------------
date_key
product_key
warehouse_key
stock_quantity
```

Example:

| date   | product | stock |
| ------ | ------- | ----: |
| Aug 22 | iPhone  |   100 |
| Aug 23 | iPhone  |    85 |
| Aug 24 | iPhone  |    72 |

This answers:

> "What was the inventory level at the end of each day?"

That's a **periodic snapshot**.

Other examples:

```text
Daily account balance
Monthly revenue
Daily inventory
Daily active users
```

---

# 10. Accumulating Snapshot Fact

This is used for **processes that have multiple stages**.

Think about an order:

```text
Order placed
    ↓
Payment
    ↓
Packed
    ↓
Shipped
    ↓
Delivered
```

You might have:

```text
fact_order
----------------------------------
order_key
customer_key
order_date_key
payment_date_key
packed_date_key
shipped_date_key
delivery_date_key
```

As the order progresses, you update the same row.

This allows you to answer:

> How long does it take from order placement to delivery?

Example:

| order | ordered | shipped | delivered |
| ----- | ------- | ------- | --------- |
| O1001 | Aug 20  | Aug 21  | Aug 24    |

This is an **accumulating snapshot fact**.

---

# 11. Factless Fact Table

This one confuses many beginners.

A **factless fact table contains no numeric measures**.

It records that **something happened or a relationship existed**.

Example:

A student attends a class.

```text
fact_student_attendance
-----------------------
student_key
course_key
date_key
```

No:

```text
quantity
amount
price
```

But the row itself represents:

> Student X attended Course Y on Date Z.

Another example:

```text
fact_promotion
-----------------
product_key
store_key
promotion_key
date_key
```

It tells you that a product was under a promotion.

---

# 12. Dimension Tables — More Deeply

Now let's look at dimension types.

You should know:

```text
1. Conformed Dimension
2. Role-Playing Dimension
3. Degenerate Dimension
4. Junk Dimension
5. Slowly Changing Dimension
6. Mini-Dimension
```

The first five are particularly important for interviews.

---

# 13. Conformed Dimension

A **conformed dimension** is a dimension that is shared consistently across multiple fact tables.

Suppose you have:

```text
fact_sales
fact_returns
fact_shipments
```

All three use:

```text
dim_product
```

Then:

```text
              dim_product
               /   |   \
              /    |    \
             ↓     ↓     ↓
        sales   returns shipments
```

The product definition is consistent everywhere.

For example:

```text
product_key = 501
product = iPhone
category = Electronics
```

has the same meaning across all fact tables.

This allows you to compare:

> Sales vs Returns

using the same product dimension.

### Interview answer

> "A conformed dimension is a standardized dimension shared across multiple fact tables or data marts, ensuring consistent definitions and enabling cross-process analysis."

---

# 14. Role-Playing Dimension

Sometimes the same dimension is used for **different purposes**.

The classic example is `dim_date`.

Your order fact might have:

```text
order_date_key
ship_date_key
delivery_date_key
```

All three point to the same `dim_date`.

```text
                    dim_date
                   /    |    \
                  /     |     \
                 ↓      ↓      ↓
          order_date ship_date delivery_date
                  \     |     /
                   fact_order
```

The dimension is playing three different roles.

Therefore:

> **Role-playing dimension = the same physical dimension used multiple times in different logical roles.**

This is another common interview question.

---

# 15. Degenerate Dimension

This is an interesting one.

Sometimes you have a business identifier that doesn't deserve its own dimension table.

Example:

```text
fact_sales
----------------------------
sales_key
order_number
customer_key
product_key
date_key
sales_amount
```

`order_number` is descriptive/business information.

But suppose there are no other useful order attributes.

You don't necessarily create:

```text
dim_order
```

just to store:

```text
order_number
```

Instead, you keep `order_number` directly in the fact table.

That's a **degenerate dimension**.

### Interview definition:

> A degenerate dimension is a dimension attribute, typically a business transaction identifier, stored directly in the fact table without a separate dimension table.

Examples:

```text
order_number
invoice_number
ticket_number
transaction_number
```

---

# 16. Junk Dimension

Imagine your fact has many small flags:

```text
is_online
is_gift
is_first_purchase
is_promotion
payment_type
customer_type
```

Creating separate dimensions for every tiny attribute would be ridiculous.

Instead, you can combine them into a **junk dimension**.

Example:

```text
dim_junk
----------------------------
junk_key
is_online
is_gift
is_first_purchase
payment_type
customer_type
```

Then:

```text
fact_sales
----------
junk_key
```

This keeps the fact table cleaner.

### Interview definition:

> A junk dimension combines miscellaneous low-cardinality flags and attributes into a single dimension.

---

# 17. Slowly Changing Dimension

Now connect this with what we just discussed about surrogate keys.

A dimension can change over time.

Example:

```text
Customer
C101
Hyderabad
```

Later:

```text
C101
Bangalore
```

If the business needs history, we use **SCD Type 2**.

Dimension:

| customer_key | customer_id | city      | start_date | end_date   | current |
| -----------: | ----------- | --------- | ---------- | ---------- | ------- |
|            1 | C101        | Hyderabad | 2025-01-01 | 2026-08-23 | N       |
|            2 | C101        | Bangalore | 2026-08-24 | NULL       | Y       |

Notice:

```text
customer_id = C101
```

is the same.

But:

```text
customer_key = 1
customer_key = 2
```

identifies two historical versions.

---

# 18. Why Fact Tables Use Surrogate Keys

This is extremely important.

Suppose:

```text
dim_customer
```

contains:

| customer_key | customer_id | city      |
| -----------: | ----------- | --------- |
|            1 | C101        | Hyderabad |
|            2 | C101        | Bangalore |

Now:

```text
fact_sales
```

contains:

| sale_id | customer_key | amount |
| ------- | -----------: | -----: |
| S001    |            1 |   5000 |
| S002    |            2 |   7000 |

The first sale happened while the customer was in Hyderabad.

The second happened after moving to Bangalore.

If you used only:

```text
customer_id = C101
```

you wouldn't know which historical version the sale belonged to.

That's why:

```text
Fact → surrogate key → specific dimension version
```

is so important.

---

# 19. Measures

Fact tables usually contain **measures**.

Examples:

```text
quantity
sales_amount
discount_amount
cost_amount
profit
```

You need to understand three types.

### Additive

Can be summed across all dimensions.

```text
sales_amount
quantity
```

### Semi-additive

Can be summed across some dimensions but not all.

Classic example:

```text
account_balance
inventory_level
```

You can aggregate across customers, but summing inventory across dates usually doesn't make sense.

### Non-additive

Cannot meaningfully be summed.

```text
percentage
ratio
margin %
unit price
```

For example:

```text
SUM(profit_margin)
```

usually doesn't make sense.

---

# 20. A Complete Sales Warehouse

Now let's put everything together.

### Dimension: Customer

```text
dim_customer
--------------------------------
customer_key PK
customer_id
first_name
last_name
city
state
country
customer_segment
start_date
end_date
is_current
```

### Dimension: Product

```text
dim_product
--------------------------------
product_key PK
product_id
product_name
category
subcategory
brand
price
```

### Dimension: Date

```text
dim_date
--------------------------------
date_key PK
full_date
day
month
quarter
year
```

### Fact: Sales

```text
fact_sales
--------------------------------
sales_key PK
order_number
date_key FK
customer_key FK
product_key FK
quantity
unit_price
discount_amount
sales_amount
```

The model becomes:

```text
                         dim_customer
                              |
                              |
                              |
dim_date ----------- fact_sales ----------- dim_product
                              |
                              |
                           Measures
```

---

# 21. How to Design a Fact Table in an Interview

Suppose the interviewer says:

> **"Design a sales data warehouse."**

Don't immediately start writing tables.

Walk through this process:

### Step 1 — Identify the business process

```text
Sales
```

### Step 2 — Identify the grain

```text
One row per product per order
```

### Step 3 — Identify dimensions

```text
Customer
Product
Date
Store
Promotion
```

### Step 4 — Identify measures

```text
Quantity
Sales amount
Discount
Cost
```

### Step 5 — Identify keys

```text
Surrogate dimension keys
```

### Step 6 — Consider history

```text
Customer → SCD Type 2
Product → perhaps Type 1 or Type 2 depending on business requirements
```

That is a **much stronger interview approach** than simply drawing a star schema.

---

# 22. The Mental Model You Should Remember

Whenever you see a business process, think:

```text
              BUSINESS PROCESS
                     ↓
                   GRAIN
                     ↓
          ┌──────────┴──────────┐
          ↓                     ↓
     DIMENSIONS              FACTS
   Who/What/Where/When      Measurements
          ↓                     ↓
   Customer/Product/Date    Quantity
   Store/Promotion          Revenue
                            Discount
```

And remember:

> **Grain comes first.**

Not dimensions.

Not measures.

**Grain first.**

---

# 23. Interview Cheat Sheet

| Concept                | Remember                                 |
| ---------------------- | ---------------------------------------- |
| Fact                   | Business event/process                   |
| Dimension              | Descriptive context                      |
| Grain                  | What one fact row represents             |
| Transaction fact       | Individual events                        |
| Periodic snapshot      | State at regular intervals               |
| Accumulating snapshot  | Process with milestones                  |
| Factless fact          | Event/relationship without measures      |
| Conformed dimension    | Shared across fact tables                |
| Role-playing dimension | Same dimension used in different roles   |
| Degenerate dimension   | Business identifier kept in fact         |
| Junk dimension         | Miscellaneous low-cardinality attributes |
| Surrogate key          | Warehouse-generated key                  |
| Natural key            | Business/source identifier               |
| SCD Type 1             | Overwrite                                |
| SCD Type 2             | Preserve history                         |
| Additive measure       | Can sum everywhere                       |
| Semi-additive          | Can sum across some dimensions           |
| Non-additive           | Cannot meaningfully sum                  |

---

## The next level you should master

The concepts above are the **foundation**. For interviews, I'd go next into **a complete real-world sales data model and design it from scratch**.

We'll take something like:

```text
CRM Customer
ERP Customer
CRM Product
ERP Product
Sales
```

and go step-by-step:

```text
Source tables
      ↓
Identify business process
      ↓
Define grain
      ↓
Identify dimensions
      ↓
Identify facts
      ↓
Choose natural/surrogate keys
      ↓
Handle SCD Type 2
      ↓
Build Star Schema
      ↓
Write the SQL DDL
      ↓
Test the model with real queries
```

That will connect **exactly to the CRM/ERP → Bronze → Silver → Gold project you've been working on** and make the theory much easier to retain.
