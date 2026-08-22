---

---
Let's Try to check for the SMB server first
```shell
(venv) ┌──(nus㉿kali-htb)-[~/HTB/enum4linux-ng]
└─$ ./enum4linux-ng.py $IP -A
ENUM4LINUX - next generation (v1.3.10)

 ==========================
|    Target Information    |
 ==========================
[*] Target ........... 10.129.94.81
[*] Username ......... ''
[*] Random Username .. 'ilbwjjnl'
[*] Password ......... ''
[*] Timeout .......... 10 second(s)

 =====================================
|    Listener Scan on 10.129.94.81    |
 =====================================
[*] Checking LDAP
[-] Could not connect to LDAP on 389/tcp: connection refused
[*] Checking LDAPS
[-] Could not connect to LDAPS on 636/tcp: connection refused
[*] Checking SMB
[+] SMB is accessible on 445/tcp
[*] Checking SMB over NetBIOS
[+] SMB over NetBIOS is accessible on 139/tcp

 ===========================================================
|    NetBIOS Names and Workgroup/Domain for 10.129.94.81    |
 ===========================================================
[+] Got domain/workgroup name: DEVOPS
[+] Full NetBIOS names information:
- DEVSMB          <00> -         H <ACTIVE>  Workstation Service
- DEVSMB          <03> -         H <ACTIVE>  Messenger Service
- DEVSMB          <20> -         H <ACTIVE>  File Server Service
- ..__MSBROWSE__. <01> - <GROUP> H <ACTIVE>  Master Browser
- DEVOPS          <00> - <GROUP> H <ACTIVE>  Domain/Workgroup Name
- DEVOPS          <1d> -         H <ACTIVE>  Master Browser
- DEVOPS          <1e> - <GROUP> H <ACTIVE>  Browser Service Elections
- MAC Address = 00-00-00-00-00-00

 =========================================
|    SMB Dialect Check on 10.129.94.81    |
 =========================================
[*] Trying on 445/tcp
[+] Supported dialects and settings:
Supported dialects:
  SMB 1.0: false
  SMB 2.0.2: true
  SMB 2.1: true
  SMB 3.0: true
  SMB 3.1.1: true
Preferred dialect: SMB 3.1.1
SMB1 only: false
SMB signing required: true

 ===========================================================
|    Domain Information via SMB session for 10.129.94.81    |
 ===========================================================
[*] Enumerating via unauthenticated SMB session on 445/tcp
[+] Found domain information via SMB
NetBIOS computer name: DEVSMB
NetBIOS domain name: ''
DNS domain: ''
FQDN: nix01
Derived membership: workgroup member
Derived domain: unknown

 =========================================
|    RPC Session Check on 10.129.94.81    |
 =========================================
[*] Check for anonymous access (null session)
[+] Server allows authentication via username '' and password ''
[*] Check for guest access
[+] Server allows authentication via username 'ilbwjjnl' and password ''
[H] Rerunning enumeration with user 'ilbwjjnl' might give more results

 ===================================================
|    Domain Information via RPC for 10.129.94.81    |
 ===================================================
[+] Domain: DEVOPS
[+] Domain SID: NULL SID
[+] Membership: workgroup member

 ===============================================
|    OS Information via RPC for 10.129.94.81    |
 ===============================================
[*] Enumerating via unauthenticated SMB session on 445/tcp
[+] Found OS information via SMB
[*] Enumerating via 'srvinfo'
[+] Found OS information via 'srvinfo'
[+] After merging OS information we have the following result:
OS: Linux/Unix
OS version: '6.1'
OS release: ''
OS build: '0'
Native OS: not supported
Native LAN manager: not supported
Platform id: '500'
Server type: '0x809a03'
Server type string: Wk Sv PrQ Unx NT SNT InlaneFreight SMB server (Samba, Ubuntu)

 =====================================
|    Users via RPC on 10.129.94.81    |
 =====================================
[*] Enumerating users via 'querydispinfo'
[+] Found 0 user(s) via 'querydispinfo'
[*] Enumerating users via 'enumdomusers'
[+] Found 0 user(s) via 'enumdomusers'

 ======================================
|    Groups via RPC on 10.129.94.81    |
 ======================================
[*] Enumerating local groups
[+] Found 0 group(s) via 'enumalsgroups domain'
[*] Enumerating builtin groups
[+] Found 0 group(s) via 'enumalsgroups builtin'
[*] Enumerating domain groups
[+] Found 0 group(s) via 'enumdomgroups'

 ======================================
|    Shares via RPC on 10.129.94.81    |
 ======================================
[*] Enumerating shares
[+] Found 3 share(s):
IPC$:
  comment: IPC Service (InlaneFreight SMB server (Samba, Ubuntu))
  type: IPC
print$:
  comment: Printer Drivers
  type: Disk
sambashare:
  comment: InFreight SMB v3.1
  type: Disk
[*] Testing share IPC$
[-] Could not check share: STATUS_OBJECT_NAME_NOT_FOUND
[*] Testing share print$
[+] Mapping: DENIED, Listing: N/A
[*] Testing share sambashare
[+] Mapping: OK, Listing: OK

 =========================================
|    Policies via RPC for 10.129.94.81    |
 =========================================
[*] Trying port 445/tcp
[+] Found policy:
Domain password information:
  Password history length: None
  Minimum password length: 5
  Minimum password age: none
  Maximum password age: 49710 days (136 years) 6 hours 21 minutes
  Password properties:
  - DOMAIN_PASSWORD_COMPLEX: false
  - DOMAIN_PASSWORD_NO_ANON_CHANGE: false
  - DOMAIN_PASSWORD_NO_CLEAR_CHANGE: false
  - DOMAIN_PASSWORD_LOCKOUT_ADMINS: false
  - DOMAIN_PASSWORD_PASSWORD_STORE_CLEARTEXT: false
  - DOMAIN_PASSWORD_REFUSE_PASSWORD_CHANGE: false
Domain lockout information:
  Lockout observation window: 30 minutes
  Lockout duration: 30 minutes
  Lockout threshold: None
Domain logoff information:
  Force logoff time: 49710 days (136 years) 6 hours 21 minutes

 =========================================
|    Printers via RPC for 10.129.94.81    |
 =========================================
[+] No printers returned (this is not an error)

Completed after 42.49 seconds
```

---
## Question 1
>What version of the SMB server is running on the target system? Submit the entire banner as the answer.

From the script above, we knew that port `139,445` is active, so let's try to do Nmap :
```bash
sudo nmap $IP -sC -sV -p139,445
```
Result :
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ sudo nmap $IP -sV -sC -p139,445
[sudo] password for nus:
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-22 13:01 +0700
Nmap scan report for 10.129.94.81
Host is up (0.19s latency).

PORT    STATE SERVICE     VERSION
139/tcp open  netbios-ssn Samba smbd 4
445/tcp open  netbios-ssn Samba smbd 4

Host script results:
|_nbstat: NetBIOS name: DEVSMB, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb2-time:
|   date: 2026-08-22T06:01:24
|_  start_date: N/A
| smb2-security-mode:
|   3.1.1:
|_    Message signing enabled but not required

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 14.28 seconds
```
### Answer : `Samba smbd 4`

---
## Question 2
>What is the name of the accessible share on the target?

From the script above only `sambashare` get the result `[+] Mapping: OK, Listing: OK`. So the answer should be `sambashare`.

### Answer : `sambashare`

---
## Question 3 
>Connect to the discovered share and find the flag.txt file. Submit the contents as the answer.

First connect to the share :
```bash
smbclient -N //$IP/sambashare
```

Check for the directories :
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ smbclient -N  //$IP/sambashare
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Mon Nov  8 20:43:14 2021
  ..                                  D        0  Mon Nov  8 22:53:19 2021
  .profile                            H      807  Tue Feb 25 19:03:22 2020
  contents                            D        0  Mon Nov  8 20:43:45 2021
  .bash_logout                        H      220  Tue Feb 25 19:03:22 2020
  .bashrc                             H     3771  Tue Feb 25 19:03:22 2020

		4062912 blocks of size 1024. 414160 blocks available
smb: \> cd contents
smb: \contents\> ls
  .                                   D        0  Mon Nov  8 20:43:45 2021
  ..                                  D        0  Mon Nov  8 20:43:14 2021
  flag.txt                            N       38  Mon Nov  8 20:43:45 2021

		4062912 blocks of size 1024. 414156 blocks available
```

We could see `flag.txt`  there, let's download it : 
```shell
smb: \contents\> get flag.txt
getting file \contents\flag.txt of size 38 as flag.txt (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
```

Use local command to read the file contetns
```shell
smb: \contents\> !cat flag.txt
HTB{o873nz4xdo873n4zo873zn4fksuhldsf}
```

### Answer : `HTB{o873nz4xdo873n4zo873zn4fksuhldsf}`

---
## Question 4
>Find out which domain the server belongs to

We already obtain this information via `enum4linux-ng` :
```shell
 ===================================================
|    Domain Information via RPC for 10.129.94.81    |
 ===================================================
[+] Domain: DEVOPS
[+] Domain SID: NULL SID
[+] Membership: workgroup member
```

### Answer : `DEVOPS`

---
## Question 5 
>Find additional information about the specific share we found previously and submit the customized version of that specific share as the answer.

It actually just ask about the `comments` or `remark`, we've obtain this information before :
```shell
sambashare:
  comment: InFreight SMB v3.1
  type: Disk
```

### Answer : `InFreight SMB v3.1`

---
## Question 6
>What is the full system path of that specific share? (format: "/directory/names")

To obtain this information, we need to login as `anonymous user` on the `rpcclient` and obtain the info via `netshareenumall`

```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ rpcclient -U "" $IP
Password for [WORKGROUP\]:
rpcclient $> netshareenumall
netname: print$
	remark:	Printer Drivers
	path:	C:\var\lib\samba\printers
	password:	
netname: sambashare
	remark:	InFreight SMB v3.1
	path:	C:\home\sambauser\
	password:	
netname: IPC$
	remark:	IPC Service (InlaneFreight SMB server (Samba, Ubuntu))
	path:	C:\tmp
	password:	
rpcclient $>
```

### Answer : `C:\home\sambauser\`