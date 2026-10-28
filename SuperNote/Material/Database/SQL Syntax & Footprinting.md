---
tags:
  - Database
  - SQL
  - MSSQL
  - MySQL
  - Footprinting
  - Material
---
## Function
> **Structured Query Language (SQL)** is the standard language used to interact with Relational Database Management Systems (RDBMS). In penetration testing and footprinting, knowing the core query hierarchy allows an attacker or auditor to enumerate server databases, uncover hidden tables, and extract sensitive credentials without breaking application logic.

---
## Database Hierarchy Analogy
```text
[ Database Server ]       ➔ The entire warehouse (MSSQL / MySQL / PostgreSQL)
        │
   [ Database ]           ➔ Specific filing cabinet (e.g., 'master', 'accounts')
        │
     [ Table ]            ➔ Folders/binders inside cabinet (e.g., 'devsacc', 'users')
        │
  [ Columns & Rows ]      ➔ Individual sheets & data fields (e.g., 'username', 'password')
```

---
## Standard Footprinting Workflow (Step-by-Step)

### Step 1: List All Databases on Server
* **MSSQL:**
  ```sql
  SELECT name FROM sys.databases;
  ```
* **MySQL:**
  ```sql
  SHOW DATABASES;
  ```

---

### Step 2: Select/Switch to Target Database
* **MSSQL & MySQL:**
  ```sql
  USE <database_name>;
  ```
  *Example:* `USE accounts;`

---

### Step 3: Enumerate Tables Inside the Database
* **MSSQL (ANSI Standard):**
  ```sql
  SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;
  -- or query system tables directly:
  SELECT name FROM sys.tables;
  ```
* **MySQL:**
  ```sql
  SHOW TABLES;
  -- or:
  SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE();
  ```

---

### Step 4: Enumerate Column Names & Data Types
* **MSSQL:**
  ```sql
  SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '<table_name>';
  -- or use built-in stored procedure:
  EXEC sp_columns <table_name>;
  ```
* **MySQL:**
  ```sql
  DESCRIBE <table_name>;
  -- or:
  SHOW COLUMNS FROM <table_name>;
  ```

---

### Step 5: Dump and Filter Data (`SELECT`)

#### Dump all records and columns:
```sql
SELECT * FROM <table_name>;
```
*(The asterisk `*` acts as a wildcard representing all columns).*

#### Dump specific columns only:
```sql
SELECT username, password FROM <table_name>;
```

#### Filter specific records using `WHERE`:
```sql
-- Search by exact match:
SELECT * FROM <table_name> WHERE username = 'HTB';

-- Search using partial wildcard (LIKE %...%):
SELECT * FROM <table_name> WHERE username LIKE '%admin%';
```

> [!CAUTION] SQL String Literal Rule
> In SQL, text values must **always be enclosed in single quotes** (`'HTB'`). If you omit quotes, the database treats the word as a **column name**, returning an error such as `Invalid column name 'HTB'`.

---
## Pentester CLI Cheatsheet (Remote Execution)

### 1. Via `crackmapexec smb` + `sqlcmd` (MSSQL on Windows):
```bash
# List databases:
crackmapexec smb <IP> -u 'Administrator' -p '<PASS>' -x 'sqlcmd -E -Q "SELECT name FROM sys.databases"'

# List tables in a database:
crackmapexec smb <IP> -u 'Administrator' -p '<PASS>' -x 'sqlcmd -E -d <DB> -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"'

# Query filtered data (notice double single quotes '' for SQL string inside bash):
crackmapexec smb <IP> -u 'Administrator' -p '<PASS>' -x 'sqlcmd -E -d <DB> -Q "SELECT * FROM <TABLE> WHERE name = ''HTB''"'
```

### 2. Via `mysql` CLI Client (MySQL on Port 3306):
```bash
mysql -u <user> -p'<pass>' -h <target_ip> -e "SHOW DATABASES; USE <db>; SHOW TABLES; SELECT * FROM <table>;"
```

---
## Related Source : 
[[CPTS/Footprinting/Footprinting Lab - Medium|Footprinting Lab - Medium]], [[crackmapexec]], [[MSSQL]], [[MySQL]]
