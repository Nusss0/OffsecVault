---
tags:
  - portswigger
  - sqli
  - web-security
---
> Source : [PortSwigger Web Security Academy - SQL Injection](https://portswigger.net/web-security/sql-injection)

# SQL Injection (SQLi) - Overview & Mindset

## Core Concept
> A vulnerability that occurs when user-controlled input is concatenated directly into an SQL query string without proper sanitization or parameterization, allowing an attacker to alter the query's logic or structure.

* **First-Order SQLi:** User input is immediately processed and executed within the same HTTP request.

* **Second-Order SQLi (Stored):** Input is safely stored in the database first, then executed unsafely in a separate request or background workflow that retrieves and embeds that stored data into a raw query.

---

## Detection Workflow (Black-Box Mindset)

Every user-controlled input vector is a potential injection point: **URL parameters, POST body, JSON, XML, HTTP Headers, and Cookies**.

1. **Break Syntax:** Inject `'`, `"`, `\`, or `;` to trigger SQL anomalies or verbose database errors.
2. **Syntax Balancing / Logic Test:**
   * Numeric: `1 AND 1=1` vs `1 AND 1=2`
   * String: `' AND '1'='1` vs `' AND '1'='2`
3. **Time Delay Probe:** Test synchronous response delays (`pg_sleep`, `WAITFOR DELAY`, `SLEEP`).
4. **OAST Probe:** Test out-of-band DNS/HTTP interactions if queries execute asynchronously.

---

## Decision Tree (Choosing Exploitation Technique)

```text
Is query output reflected on the page?
 ├── YES ──> Use UNION Attack (direct extraction)
 └── NO (Blind SQLi)
       ├── Visible response/UI change (e.g. "Welcome back")? ──> Boolean-Based
       ├── Raw DB error message displayed on screen?         ──> Visible Error (CAST)
       ├── App crashes (HTTP 500) when SQL error occurs?     ──> Conditional Error (1/0)
       ├── Silent response & synchronous execution?          ──> Time-Based (Sleep)
       └── Silent response & asynchronous execution?         ──> OAST (DNS Exfiltration)
```

---

## Mitigation (How to Prevent)

1. **Parameterized Queries (Prepared Statements):** Separate query structure from user input so the database treats input strictly as literal data, never executable SQL logic.
   ```java
   PreparedStatement stmt = conn.prepareStatement("SELECT * FROM products WHERE category = ?");
   stmt.setString(1, input);
   ```

2. **Input Whitelisting:** Mandatory for query components that cannot be parameterized (such as table names, column names, or `ORDER BY` sort direction).

---

## Lab Progress Tracker (PortSwigger)

| Lab | Technique | Status |
| :--- | :--- | :--- |
| SQLi in WHERE clause (hidden data) | Commenting out (`'--`), `OR 1=1` | `[x] Solved` |
| SQLi login bypass | Commenting out password check | `[x] Solved` |
| Determine number of columns | `ORDER BY` / `UNION SELECT NULL` | `[x] Solved` |
| Find column containing text | `UNION SELECT 'str', NULL` | `[x] Solved` |
| Retrieve data from other tables | `UNION SELECT username, password` | `[x] Solved` |
| Retrieve multiple values in 1 column | String concat (`\|\|`) | `[x] Solved` |
| Querying DB version (Oracle) | `FROM v$version` | `[x] Solved` |
| Querying DB version (MySQL/MSSQL) | `@@version` + `%23` / `--+` | `[x] Solved` |
| Listing DB contents (non-Oracle) | `information_schema.tables/columns` | `[x] Solved` |
| Listing DB contents (Oracle) | `all_tables` / `all_tab_columns` | `[x] Solved` |
| Filter bypass via XML encoding | XML Hex Entities (`&#x...;`) | `[x] Solved` |
| Blind SQLi with conditional responses | Boolean-based + `SUBSTRING` | `[x] Solved` |
| Blind SQLi with conditional errors | `CASE WHEN ... THEN TO_CHAR(1/0)` | `[x] Solved` |
| Visible error-based SQLi | `CAST(... AS int)` + `LIMIT 1` | `[x] Solved` |
| Blind SQLi with time delays | `pg_sleep(10)` | `[x] Solved` |
| Blind SQLi with time delays & info retrieval | Python + `pg_sleep()` + `SUBSTR` | `[x] Solved` |
| Blind SQLi with OAST interaction | DNS lookup via Burp Collaborator | `[ ] Pending (Burp Pro Trial)` |
| Blind SQLi with OAST data exfiltration | DNS exfiltration via Collaborator | `[ ] Pending (Burp Pro Trial)` |

---

## Related Notes
* [[01 - UNION Attacks & DB Enumeration]]
* [[02 - Blind SQLi Techniques]]
* [[99 - SQLi Cheat Sheet]]
