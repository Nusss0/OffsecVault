## Question 1
>Enumerate the MySQL server and determine the version in use. (Format: MySQL X.X.XX)

```shell
sudo nmap $ip -sV -sC -p3306 --script "mysql*"
```
Result : 
![[Pasted image 20261007102747.png]]

### Answer : MySQL 8.0.27

---
## Question 2
> During our penetration test, we found weak credentials "robin:robin". We should try these against the MySQL server. What is the email address of the customer "Otto Lang"?

```shell
mysql -u robin -probin -h $ip --ssl=0 #on mariadb
```
For the SQL Command : 
```sql
USE customers;
SELECT * FROM myTable WHERE name="Otto Lang";
```

Result : 
![[Pasted image 20261007103809.png]]

### Answer : `ultrices@google.htb` 