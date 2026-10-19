>Source : [HTB Academy](https://academy.hackthebox.com/app/module/112/section/1246)

---
## About MSSQL
>[Microsoft SQL](https://www.microsoft.com/en-us/sql-server/sql-server-2019) (`MSSQL`) is Microsoft's SQL-based relational database management system. Unlike MySQL, which we discussed in the last section, MSSQL is closed source and was initially written to run on Windows operating systems. Strong native support on .NET.

### Clients 
>[SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) (`SSMS`) comes as a feature that can be installed with the MSSQL install package or can be downloaded & installed separately. Since SSMS is a client-side application, it can be installed and used on any system an admin or developer is planning to manage the database from. This means we could come across a vulnerable system with SSMS with saved credentials that allow us to connect to the database.

---
## Footprinting 
>There are many ways we can approach footprinting the MSSQL service, the more specific we can get with our scans, the more useful information we will be able to gather. NMAP has default mssql scripts that can be used to target the default tcp port `1433` that MSSQL listens on.

Port : 1433

### Using NMAP
>The scripted NMAP scan below provides us with helpful information. We can see the `hostname`, `database instance name`, `software version of MSSQL` and `named pipes are enabled`. We will benefit from adding these discoveries to our notes.
```shell
sudo nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-xp-cmdshell,ms-sql-config,ms-sql-ntlm-info,ms-sql-tables,ms-sql-hasdbaccess,ms-sql-dac,ms-sql-dump-hashes --script-args mssql.instance-port=1433,mssql.username=sa,mssql.password=,mssql.instance-name=MSSQLSERVER -sV -p 1433 $ip
```
*We could use `ms-sql*` alternatively, but it will run all NMAP NSE Script including the `ms-sql-brute` which will take a long time*

### Using Metasploit 
>We can also use Metasploit to run an auxiliary scanner called `mssql_ping` that will scan the MSSQL service and provide helpful information in our footprinting process.
```shell
msf6 auxiliary(scanner/mssql/mssql_ping) > set rhosts 10.129.201.248

rhosts => 10.129.201.248

msf6 auxiliary(scanner/mssql/mssql_ping) > run

[*] 10.129.201.248:       - SQL Server information for 10.129.201.248:
[+] 10.129.201.248:       -    ServerName      = SQL-01
[+] 10.129.201.248:       -    InstanceName    = MSSQLSERVER
[+] 10.129.201.248:       -    IsClustered     = No
[+] 10.129.201.248:       -    Version         = 15.0.2000.5
[+] 10.129.201.248:       -    tcp             = 1433
[+] 10.129.201.248:       -    np              = \\SQL-01\pipe\sql\query
[*] 10.129.201.248:       - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

---
## Connect to Mssqclient.py
>If we can guess or gain access to credentials, this allows us to remotely connect to the MSSQL server and start interacting with databases using T-SQL (`Transact-SQL`).

Install `mssqlclient` : 
```shell
sudo apt update && sudo apt install impacket-scripts python3-impacket -y
```

Usage : 
```shell
impacket-mssqlclient <uname>@$ip -windows-auth
```

---
## Questions
[[MSSQL Questions]]