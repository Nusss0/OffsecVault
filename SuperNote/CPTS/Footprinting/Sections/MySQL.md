>Source : [https://academy.hackthebox.com/app/module/112/section/1238](HTB Academy)

---
## About MySQL
>MySQL is an open-source SQL relational database management system developed and supported by Oracle. The database is controlled using the [SQL database language](https://www.w3schools.com/sql/sql_intro.asp). MySQL works according to the `client-server principle` and consists of a MySQL server and one or more MySQL clients.

The MySQL server is the actual database management system. It takes care of data storage and distribution. The data is stored in tables with different columns, rows, and data types. These databases are often exported or backed up as a single `.sql` file, for example `wordpress.sql`.

---
## MySQL Clients
>The MySQL clients can retrieve and edit the data using structured queries to the database engine. Inserting, deleting, modifying, and retrieving data, is done using the SQL database language. Therefore, MySQL is suitable for managing many different databases to which clients can send multiple queries simultaneously. Depending on the use of the database, access is possible via an internal network or the public Internet.

---
## Footprinting on MySQL

### Nmap Scanning
>Usually, the MySQL server runs on `TCP port 3306`, and we can scan this port with `Nmap` to get more detailed information. We use NSE script mysql on this case.

```shell
sudo nmap $ip -sV -sC -p3306 --script mysql*
```

### Interacting with MySQL server 
```shell
mysql -u <username/root> -p <password> -h <host/ip address>
```

### MySQL useful query command 
| **Command**                                          | **Description**                                                                                       |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `mysql -u <user> -p<password> -h <IP address>`       | Connect to the MySQL server. There should **not** be a space between the '-p' flag, and the password. |
| `show databases;`                                    | Show all databases.                                                                                   |
| `use <database>;`                                    | Select one of the existing databases.                                                                 |
| `show tables;`                                       | Show all available tables in the selected database.                                                   |
| `show columns from <table>;`                         | Show all columns in the selected table.                                                               |
| `select * from <table>;`                             | Show everything in the desired table.                                                                 |
| `select * from <table> where <column> = "<string>";` | Search for needed `string` in the desired table.                                                      |

---
## Questions
[[MySQL Questions]]