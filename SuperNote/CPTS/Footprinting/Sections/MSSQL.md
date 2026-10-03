>Source : [HTB Academy](https://academy.hackthebox.com/app/module/112/section/1246)

---
## About MSSQL
>[Microsoft SQL](https://www.microsoft.com/en-us/sql-server/sql-server-2019) (`MSSQL`) is Microsoft's SQL-based relational database management system. Unlike MySQL, which we discussed in the last section, MSSQL is closed source and was initially written to run on Windows operating systems. Strong native support on .NET.

### Clients 
>[SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) (`SSMS`) comes as a feature that can be installed with the MSSQL install package or can be downloaded & installed separately. Since SSMS is a client-side application, it can be installed and used on any system an admin or developer is planning to manage the database from. This means we could come across a vulnerable system with SSMS with saved credentials that allow us to connect to the database.

