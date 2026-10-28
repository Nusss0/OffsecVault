---
tags:
  - Database
  - MSSQL
  - SQL
  - Footprinting
  - Material
  - Cheatsheet
---
## Function
> **Microsoft SQL Server (MSSQL)** menggunakan dialek **Transact-SQL (T-SQL)**. Saat melakukan penetration testing, audit, atau CTF, fokus utama querying adalah melakukan *reconnaissance* cepat: mencari database non-default, mendeteksi tabel sensitif (kredensial, akun, konfigurasi), memeriksa kolom, serta mengekstrak data tanpa merusak integritas server.

---

## 1. Quick Recon & Server Context

Query pembuka untuk mengetahui hak akses dan posisi user saat pertama kali connect:

| Tujuan | Query T-SQL | Keterangan |
| :--- | :--- | :--- |
| **Versi MSSQL** | `SELECT @@version;` | Cek OS, patch level, dan edisi SQL Server |
| **Current User** | `SELECT SYSTEM_USER;` atau `SELECT USER_NAME();` | Cek user login vs context user |
| **Current Database** | `SELECT DB_NAME();` | Mengetahui database yang sedang aktif |
| **Check Admin Privilege** | `SELECT IS_SRVROLEMEMBER('sysadmin');` | Return `1` jika **sysadmin / SA** (full control), `0` jika user biasa |
| **List Server Logins** | `SELECT name FROM sys.server_principals WHERE type IN ('S','U');` | User login tingkat server (SQL & Windows) |

---

## 2. Menemukan Database

### A. List Semua Database di Server
```sql
SELECT name FROM sys.databases;
```
*(Database default sistem: `master`, `tempdb`, `model`, `msdb`. Cari nama di luar 4 ini).*

### B. List Database Non-Sistem (User Created) Saja
```sql
SELECT name FROM sys.databases WHERE database_id > 4;
```

### C. Pindah / Switch Database
```sql
USE <database_name>;
```
*Contoh:* `USE accounts;`

---

## 3. Menemukan Tabel (Table Recon)

### A. List Tabel di Database yang Sedang Aktif
Gunakan standar ANSI `INFORMATION_SCHEMA` atau tabel metadata `sys.tables`:
```sql
-- Menggunakan INFORMATION_SCHEMA (hanya tabel biasa, abaikan view):
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Atau menggunakan sys.tables:
SELECT name FROM sys.tables;
```

### B. Mencari Tabel Berdasarkan Kata Kunci (Keyword Search)
Mencari tabel yang mengandung kata seperti `user`, `pass`, `admin`, `acc`, `token`, atau `flag`:
```sql
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%user%' 
   OR TABLE_NAME LIKE '%pass%' 
   OR TABLE_NAME LIKE '%acc%' 
   OR TABLE_NAME LIKE '%login%';
```

### C. List Tabel di Database Lain (Tanpa Pindah `USE`)
Gunakan prefix 3-bagian: `<Database>.INFORMATION_SCHEMA.TABLES`:
```sql
SELECT TABLE_NAME FROM accounts.INFORMATION_SCHEMA.TABLES;
```

---

## 4. Menemukan Kolom (Column Recon)

### A. List Semua Kolom & Tipe Data dari Suatu Tabel
```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = '<table_name>';
```
*Contoh:*
```sql
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'devsacc';
```

### B. Shortcut via Stored Procedure
```sql
EXEC sp_columns <table_name>;
```

### C. Mencari Kolom Sensitif di SELURUH Database yang Aktif
Mencari semua tabel yang memiliki kolom berbau kredensial:
```sql
SELECT TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%pass%' 
   OR COLUMN_NAME LIKE '%pwd%' 
   OR COLUMN_NAME LIKE '%secret%' 
   OR COLUMN_NAME LIKE '%key%';
```

---

## 5. Ekstraksi Data (`SELECT`)

### A. Dump Data (Batasi Jumlah Baris)
Hindari server freeze jika tabel memiliki jutaan baris dengan menggunakan `TOP`:
```sql
-- Ambil 10 baris pertama:
SELECT TOP 10 * FROM <table_name>;

-- Ambil semua baris:
SELECT * FROM <table_name>;
```

### B. Filter Data Menggunakan `WHERE`
> [!IMPORTANT] Aturan String Literal SQL
> Nilai teks/string di SQL **wajib diapit single quote** (`'...'`). Jika tanpa kutip, MSSQL menganggapnya nama kolom.

```sql
-- Exact match:
SELECT * FROM devsacc WHERE username = 'HTB';

-- Pattern matching (LIKE):
SELECT * FROM devsacc WHERE username LIKE 'admin%';
SELECT * FROM devsacc WHERE email LIKE '%@inlanefreight.htb';
```

### C. Direct Cross-Database Query
Query data tabel di database lain tanpa perlu `USE <db>`:
```sql
-- Format: <Database>.<Schema>.<Table> (default schema adalah dbo)
SELECT * FROM accounts.dbo.devsacc;
```

---

## 6. Post-Exploitation & Command Execution (Bonus Privileged)

Jika login memiliki role `sysadmin` (atau status `IS_SRVROLEMEMBER('sysadmin') = 1`):

### A. Enable `xp_cmdshell`
```sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
```

### B. Eksekusi OS Command
```sql
EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'powershell -c "ipconfig"';
```

---

## 7. Format Eksekusi dari Berbagai Tools CLI

### 1. Via `impacket-mssqlclient` (Koneksi Remote Interaktif)
```bash
# Connect:
impacket-mssqlclient <user>:'<pass>'@<target_ip> -windows-auth

# Di dalam prompt SQL>:
SQL> SELECT name FROM sys.databases;
SQL> USE accounts;
SQL> SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;
SQL> SELECT * FROM devsacc;
```

### 2. Via `sqlcmd` di Windows (Lokal / Remote)
* Parameter `-E` : Windows Trusted Authentication (menggunakan akun Windows saat ini).
* Parameter `-d <db>` : Langsung pilih database.
* Parameter `-Q "<query>"` : Jalankan query dan langsung exit.

```cmd
sqlcmd -S localhost -E -Q "SELECT name FROM sys.databases"
sqlcmd -S localhost -E -d accounts -Q "SELECT * FROM devsacc WHERE username = 'HTB'"
```

### 3. Via `crackmapexec` (Remote Execution)

* **Melalui modul MSSQL langsung (Port 1433):**
  ```bash
  crackmapexec mssql <target_ip> -u '<user>' -p '<pass>' -q "SELECT name FROM sys.databases"
  crackmapexec mssql <target_ip> -u '<user>' -p '<pass>' -d accounts -q "SELECT * FROM devsacc"
  ```

* **Melalui SMB execution (Jika port 1433 internal/firewalled, memanfaatkan admin access):**
  > [!TIP] Perhatikan Quoting di Bash
  > Gunakan double single quotes (`''`) untuk string SQL di dalam flag `-Q "..."` agar tidak bentrok dengan parser bash.

  ```bash
  crackmapexec smb <target_ip> -u '<user>' -p '<pass>' -x 'sqlcmd -E -d accounts -Q "SELECT * FROM devsacc WHERE username = ''HTB''"'
  ```

---

## Related Source :
- [[_Database]]
- [[SQL Syntax & Footprinting]]
- [[CrackMapExec]]
- [[CPTS/Footprinting/Footprinting Lab - Medium|Footprinting Lab - Medium]]
- [[CPTS/Footprinting/Sections/MSSQL|MSSQL Footprinting Notes]]
