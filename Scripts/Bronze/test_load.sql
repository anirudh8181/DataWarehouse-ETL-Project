LOAD DATA INFILE
'C:/ProgramData/Mysql:/Mysql: Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES

(@cst_id, @cst_key, @cst_firstname, @cst_lastname,
 @cst_marital_status, @cst_gndr, @cst_create_date)

SET
    cst_id = NULLIF(@cst_id, ''),
    cst_key = NULLIF(@cst_key, ''),
    cst_firstname = NULLIF(@cst_firstname, ''),
    cst_lastname = NULLIF(@cst_lastname, ''),
    cst_marital_status = NULLIF(@cst_marital_status, ''),
    cst_gndr = NULLIF(@cst_gndr, ''),
    cst_create_date = NULLIF(@cst_create_date, '');
    
    /*
    Sure. This statement has **two parts**:

1. `LOAD DATA INFILE` → reads the CSV and maps its columns.
2. `(@variables) + SET` → temporarily stores the CSV values and then controls how they are inserted into the actual table.

---

 1. `LOAD DATA INFILE`

sql:
LOAD DATA INFILE
'C:/ProgramData/Mysql:/Mysql: Server 8.0/Uploads/cust_info.csv'


This tells Mysql::

> Read data from this CSV file.

Because you're using `LOAD DATA INFILE` rather than `LOAD DATA LOCAL INFILE`, the file must be accessible to the **Mysql: server**, and in your setup it is inside the `secure_file_priv` directory.

---

 2. `INTO TABLE`

sql:
INTO TABLE bronze.crm_cust_info


This tells Mysql: where to put the data.

So:

text:
CSV
 ↓
bronze.crm_cust_info


---

 3. `FIELDS TERMINATED BY ','`

sql:
FIELDS TERMINATED BY ','


This tells Mysql: that the CSV columns are separated by commas.

For example:

text:
101,CST001,John,Doe,Married,M,2024-01-10


Mysql: interprets it as:

text:
101
CST001
John
Doe
Married
M
2024-01-10


---

 4. `ENCLOSED BY '"'`

sql:
ENCLOSED BY '"'


This tells Mysql: that values may be surrounded by double quotes.

For example:

text:
101,"CST001","John","Doe","Married","M","2024-01-10"


Mysql: understands the `"` characters as CSV text: delimiters rather than part of the actual value.

This is especially important if a value contains a comma:

text:
101,"CST001","John","New York, USA","Married","M","2024-01-10"


Without `ENCLOSED BY '"'`, Mysql: could incorrectly interpret the comma inside `"New York, USA"` as another column separator.

---

 5. `LINES TERMINATED BY`

sql:
LINES TERMINATED BY '\r\n'


This tells Mysql: that each record ends with a Windows-style line ending:

text:
\r\n


For example:

text:
101,ABC,John
102,DEF,David
103,GHI,Ravi


Each line is treated as a separate row.

Since you're on Windows, `\r\n` is commonly appropriate.

---

 6. `IGNORE 1 LINES`

sql:
IGNORE 1 LINES


This tells Mysql::

> Skip the first line of the CSV.

Because your first line is probably the header:

text:
cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date


You don't want that inserted into your table.

So:

text:
Header                    ← ignored
101,CST001,John,...       ← loaded
102,CST002,David,...      ← loaded
103,CST003,Ravi,...       ← loaded


---

 Now the important part

You have:

sql:
(@cst_id, @cst_key, @cst_firstname, @cst_lastname,
 @cst_marital_status, @cst_gndr, @cst_create_date)


These are **user-defined variables** used as temporary holding variables.

They are **not your table columns**.

Think of the process like this:

text:
CSV
 │
 │ read one row
 ▼
@cst_id
@cst_key
@cst_firstname
@cst_lastname
@cst_marital_status
@cst_gndr
@cst_create_date
 │
 │ SET / transform
 ▼
Actual table columns


Suppose the CSV contains:

text:
101,CST001,John,Doe,Married,M,2024-01-10


Mysql: initially reads:

text:
@cst_id             = '101'
@cst_key            = 'CST001'
@cst_firstname      = 'John'
@cst_lastname       = 'Doe'
@cst_marital_status = 'Married'
@cst_gndr           = 'M'
@cst_create_date    = '2024-01-10'


Notice that we're using `@variables` instead of directly inserting into the table.

---

 Why do we use `@variables`?

Because we want to **transform the incoming values before inserting them**.

That's what this part does:

sql:
SET
    cst_id = NULLIF(@cst_id, ''),
    cst_key = NULLIF(@cst_key, ''),
    cst_firstname = NULLIF(@cst_firstname, ''),
    cst_lastname = NULLIF(@cst_lastname, ''),
    cst_marital_status = NULLIF(@cst_marital_status, ''),
    cst_gndr = NULLIF(@cst_gndr, ''),
    cst_create_date = NULLIF(@cst_create_date, '');


---

 What does `NULLIF()` do?

The syntax is:

sql:
NULLIF(value1, value2)


It means:

> If `value1 = value2`, return `NULL`; otherwise return `value1`.

For example:

sql:
NULLIF('101', '')


returns:

text:
101


because `'101'` isn't equal to `''`.

But:

sql:
NULLIF('', '')


returns:

text:
NULL


Therefore:

sql:
cst_id = NULLIF(@cst_id, '')


means:

> Take the CSV `cst_id`. If it's empty, insert `NULL`; otherwise insert its actual value.

---

 Why was this necessary?

You previously got:

text:
Error Code: 1366
Incorrect integer value: '' for column 'cst_id'


Because your CSV contained an empty value:

text:
,ABC123,John,...


and Mysql: was trying:

text:
'' → INT


which failed.

With:

sql:
cst_id = NULLIF(@cst_id, '')


it becomes:

text:
'' 
 ↓
NULL
 ↓
cst_id INT


And `NULL` is valid because your column isn't defined as `NOT NULL`.

---

 Complete execution flow

For a CSV row:

text:
101,CST001,John,Doe,Married,M,2024-01-10


Mysql: does approximately:

text:
Step 1: Read CSV
        ↓
101 | CST001 | John | Doe | Married | M | 2024-01-10

Step 2: Put values into temporary variables
        ↓
@cst_id = '101'
@cst_key = 'CST001'
@cst_firstname = 'John'
...

Step 3: Apply SET expressions
        ↓
cst_id = NULLIF('101', '') → 101
cst_key = NULLIF('CST001', '') → CST001
...

Step 4: Insert into table
        ↓
bronze.crm_cust_info


For an empty value:

text:
, CST001, John, ...
   ↑
empty cst_id


the flow is:

text:
@cst_id = ''
     ↓
NULLIF('', '')
     ↓
NULL
     ↓
bronze.crm_cust_info.cst_id = NULL


In one sentence

LOAD DATA INFILE` reads the CSV, the `@variables` temporarily capture each CSV field, and the `SET` clause transforms those fields before inserting them into the actual Bronze table.**

    
    
    */