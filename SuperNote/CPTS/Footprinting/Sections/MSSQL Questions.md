## Question 1
>Enumerate the target using the concepts taught in this section. List the hostname of MSSQL server.

By using metasploit, `mssql_ping` : 
```shell
msf auxiliary(scanner/mssql/mssql_ping) > set RHOST 10.129.254.196
RHOST => 10.129.254.196
msf auxiliary(scanner/mssql/mssql_ping) > run
[*] 10.129.254.196        - SQL Server information for 10.129.254.196:
[+] 10.129.254.196        -    ServerName      = ILF-SQL-01
[+] 10.129.254.196        -    InstanceName    = MSSQLSERVER
[+] 10.129.254.196        -    IsClustered     = No
[+] 10.129.254.196        -    Version         = 15.0.2000.5
[+] 10.129.254.196        -    tcp             = 1433
[+] 10.129.254.196        -    np              = \\ILF-SQL-01\pipe\sql\query
[*] 10.129.254.196        - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

### Answer : `ILF-SQL-01`

---
## Question 2 
>Connect to the MSSQL instance running on the target using the account (backdoor:Password1), then list the non-default database present on the server.

Using `impacket-mssqlclient` :
```shell
impacket-mssqlclient <uname>@$ip -windows-auth
```

Result : 
```shell
SQL (ILF-SQL-01\backdoor  dbo@master)> enum_db
name        is_trustworthy_on
---------   -----------------
master                      0
tempdb                      0
model                       0
msdb                        1
Employees                   0

```

### Answer : `Empoloyees`
