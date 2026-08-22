---
tags:
  - HTB
  - Material
  - CPTS
  - Networking
  - Protocol
---
>Server Message Block (SMB) is a client-server protocol that regulates access to files and entire directories and other network resources such as printers, routers, or interfaces released for the network

> [!info]- About SMB
>  [SMB](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688) first became available to a broader public, for example, as part of the OS/2 network operating system LAN Manager and LAN Server. Since then, the main application area of the protocol has been the Windows operating system series in particular, whose network services support SMB in a downward-compatible manner - which means that devices with newer editions can easily communicate with devices that have an older Microsoft operating system installed. With the free software project Samba, there is also a solution that enables the use of SMB in Linux and Unix distributions and thus cross-platform communication via SMB.

The SMB protocol enables the client to **communicate** with **other participants in the same network** to access files or services shared with it on the network. The SMB protocol enables the client to communicate with other participants in the same network to access files or services shared with it on the network. And before all that process, both parties must establish a **connection**.

SMB use TCP for this purpose, which provides for a three-way handshake between client and server before a connection is finally established.

> [!note]- Shares File & Acess Control
>An SMB server can provide arbitrary parts of its local file system as shares. Therefore the hierarchy visible to a client is partially independent of the structure on the server.
>Access rights are defined by `Access Control Lists` (`ACL`). They can be controlled in a fine-grained manner based on attributes such as `execute`, `read`, and `full access` for individual users or user groups. The ACLs are defined based on the shares and therefore do not correspond to the rights assigned locally on the server.

---
## Samba
> Samba is an alternative implementation of the SMB server, which is developed for Unix-based operating systems. It implements the Common Internet File System (CIFS).

> [!info]- CIFS
>  [CIFS](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs/934c2faa-54af-4526-ac74-6a24d126724e) is a dialect of SMB, meaning it is a specific implementation of the SMB protocol originally created by Microsoft. This allows Samba to communicate effectively with newer Windows systems. Therefore, it is often referred to as SMB/CIFS.

However, `CIFS` is considered a specific version of the SMB protocol, primarily aligning with `SMB version 1`. When SMB commands are transmitted over Samba to an older NetBIOS service, connections typically occur over TCP ports `137`, `138`, and `139`. In contrast, CIFS operates over TCP port `445` exclusively. There are several versions of SMB, including newer versions like `SMB 2` and `SMB 3`, which offer improvements and are preferred in modern infrastructures, while older versions like `SMB 1` (`CIFS`) are considered outdated but may still be used in specific environments.

> [!NOTE]- SMB Version
> |**SMB Version**|**Supported**|**Features**|
|---|---|---|
|CIFS|Windows NT 4.0|Communication via NetBIOS interface|
|SMB 1.0|Windows 2000|Direct connection via TCP|
|SMB 2.0|Windows Vista, Windows Server 2008|Performance upgrades, improved message signing, caching feature|
|SMB 2.1|Windows 7, Windows Server 2008 R2|Locking mechanisms|
|SMB 3.0|Windows 8, Windows Server 2012|Multichannel connections, end-to-end encryption, remote storage access|
|SMB 3.0.2|Windows 8.1, Windows Server 2012 R2||
|SMB 3.1.1|Windows 10, Windows Server 2016|Integrity checking, AES-128 encryption|

With version 3, the Samba server gained the ability to be a full member of an Active Directory domain. With version 4, Samba even provides an Active Directory domain controller. The SMB server daemon (`smbd`) belonging to Samba provides the first two functionalities, while the NetBIOS message block daemon (`nmbd`) implements the last two functionalities. The SMB service controls these two background programs.

In a network, each host participates in the same `workgroup`. A workgroup is a group name that identifies an arbitrary collection of computers and their resources on an SMB network. There can be multiple workgroups on the network at any given time. IBM developed an `application programming interface` (`API`) for networking computers called the `Network Basic Input/Output System` (`NetBIOS`). The NetBIOS API provided a blueprint for an application to connect and share data with other computers. In a NetBIOS environment, when a machine goes online, it needs a name, which is done through the so-called `name registration` procedure. Either each host reserves its hostname on the network, or the [NetBIOS Name Server](https://networkencyclopedia.com/netbios-name-server-nbns/) (`NBNS`) is used for this purpose. It also has been enhanced to [Windows Internet Name Service](https://networkencyclopedia.com/windows-internet-name-service-wins/) (`WINS`).

---
## Default Configuration
> Samba offers a wide range of [settings](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) that we can configure. Again, we define the settings via a text file where we can get an overview of some of the settings.

> [!example]- Filtered Out Settings Configurations
> ```shell
> nusss@htb[/htb]$ cat /etc/samba/smb.conf | grep -v "#\|\;" 
>
[global]
   workgroup = DEV.INFREIGHT.HTB
   server string = DEVSMB
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   panic action = /usr/share/samba/panic-action %d
>
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
>
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
>
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes
>
[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
>
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
> ```

The global settings are the configuration of the available SMB server that is used for all shares (e.g. printers). In the individual shares (e.g. printers), the global settings can be overwritten, which is highly misconfigured. 

> [!info]- Understanding of Samba Configuration
> |**Setting**|**Description**|
|---|---|
|`[sharename]`|The name of the network share.|
|`workgroup = WORKGROUP/DOMAIN`|Workgroup that will appear when clients query.|
|`path = /path/here/`|The directory to which user is to be given access.|
|`server string = STRING`|The string that will show up when a connection is initiated.|
|`unix password sync = yes`|Synchronize the UNIX password with the SMB password?|
|`usershare allow guests = yes`|Allow non-authenticated users to access defined share?|
|`map to guest = bad user`|What to do when a user login request doesn't match a valid UNIX user?|
|`browseable = yes`|Should this share be shown in the list of available shares?|
|`guest ok = yes`|Allow connecting to the service without using a password?|
|`read only = yes`|Allow users to read files only?|
|`create mask = 0700`|What permissions need to be set for newly created files?|

Some of the above settings already bring some sensitive options. However, suppose we question the settings listed below and ask ourselves what the employees could gain from them, as well as attackers. In that case, we will see what advantages and disadvantages the settings bring with them.

> [!info]- Some Dangerous Settings
> |**Setting**|**Description**|
|---|---|
|`browseable = yes`|Allow listing available shares in the current share?|
|`read only = no`|Forbid the creation and modification of files?|
|`writable = yes`|Allow users to create and modify files?|
|`guest ok = yes`|Allow connecting to the service without using a password?|
|`enable privileges = yes`|Honor privileges assigned to specific SID?|
|`create mask = 0777`|What permissions must be assigned to the newly created files?|
|`directory mask = 0777`|What permissions must be assigned to the newly created directories?|
|`logon script = script.sh`|What script needs to be executed on the user's login?|
|`magic script = script.sh`|Which script should be executed when the script gets closed?|
|`magic output = script.out`|Where the output of the magic script needs to be stored?|

It is highly recommended to look at the man pages for Samba and configure it ourselves and experiment with the settings. We will then discover potential aspects that will be interesting for us as a penetration tester. In addition, the more familiar we become with the Samba server and SMB, the easier it will be to find our way around the environment and use it for our purposes.

---
## Restarting Samba
>Once we have adjusted `/etc/samba/smb.conf` to our needs, we have to restart the service on the server.

> [!todo] Samba Restart Syntax
> ```shell
> sudo systemctl restart smbd
> ```

---
## SMBclient - Connecting to the shares.
> We can display a list (`-L`) of the server's shares with the `smbclient` command from our host. We use the so-called `null session` (`-N`), which is `anonymous` access without the input of existing users or valid passwords.


> [!example]- Connect to the Share
> ![[Pasted image 20260820205228.png]]

We can see that we now have five different shares on the Samba server from the result. Thereby `print$` and an `IPC$` are already included by default in the basic setting, as we have already seen. If we are not familiar with the client program, we can use the `help` command on successful login, listing all the possible commands we can execute.

---
## Download Files from SMB
>Once we have discovered interesting files or folders, we can download them using the `get` command. Smbclient also allows us to execute local system commands using an exclamation mark at the beginning (`!<cmd>`) without interrupting the connection.

> [!example]- Example of Download Files & System Command Usage on SMB
> ```shell
> smb: \> get prep-prod.txt 
>
getting file \prep-prod.txt of size 71 as prep-prod.txt (8,7 KiloBytes/sec) 
(average 8,7 KiloBytes/sec)
>
smb: \> !ls
>
prep-prod.txt
>
smb: \> !cat prep-prod.txt
>
[] check your code with the templates
[] run code-assessment.py
[] …    
> ```

From the administrative point of view, we can check these connections using `smbstatus`. Apart from the Samba version, we can also see who, from which host, and which share the client is connected. This is especially important once we have entered a subnet (perhaps even an isolated one) that the others can still access.

---
## Nmap on SMB
> Nmap also has many options and NSE scripts that can help us examine the target's SMB service more closely and get more information. The downside, however, is that these scans can take a long time. Therefore, it is also recommended to look at the service manually, mainly because we can find much more details than Nmap could show us.

> [!example]- Nmap Scanning Result
> ```shell
> nusss@htb[/htb]$ sudo nmap 10.129.14.128 -sV -sC -p139,445
>
Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 15:15 CEST
Nmap scan report for sharing.inlanefreight.htb (10.129.14.128)
Host is up (0.00024s latency).
>
PORT    STATE SERVICE     VERSION
139/tcp open  netbios-ssn Samba smbd 4.6.2
445/tcp open  netbios-ssn Samba smbd 4.6.2
MAC Address: 00:00:00:00:00:00 (VMware)
>
Host script results:
|_nbstat: NetBIOS name: HTB, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-09-19T13:16:04
|_  start_date: N/A
>
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.35 seconds
> ```

We can see from the results that it is not very much that Nmap provided us with here.

---
## RPC on SMB
>`rpcclient` is a tool to perform MS-RPC function. It is one of the handy tools for interact manually with SMB and send specific request for the information.

> [!info]- Remote Procedure Call (RPC)
> The [Remote Procedure Call](https://www.geeksforgeeks.org/remote-procedure-call-rpc-in-operating-system/) (`RPC`) is a concept and, therefore, also a central tool to realize operational and work-sharing structures in networks and client-server architectures. The communication process via RPC includes passing parameters and the return of a function value.

Syntax to connect with client 
```shell
nusss@htb[/htb]$ rpcclient -U "" 10.129.14.128

Enter WORKGROUP\'s password:
rpcclient $> 
```

The `rpcclient` offers us many different requests with which we can execute specific functions on the SMB server to get information. A complete list of all these functions can be found on the [man page](https://www.samba.org/samba/docs/current/man-html/rpcclient.1.html) of the rpcclient.

> [!NOTE]- Some common functions on **rpcclient**
> |**Query**|**Description**|
|---|---|
|`srvinfo`|Server information.|
|`enumdomains`|Enumerate all domains that are deployed in the network.|
|`querydominfo`|Provides domain, server, and user information of deployed domains.|
|`netshareenumall`|Enumerates all available shares.|
|`netsharegetinfo <share>`|Provides information about a specific share.|
|`enumdomusers`|Enumerates all domain users.|
|`queryuser <RID>`|Provides information about a specific user.|

> [!example]- RPCclient Enumeration
> ![[Pasted image 20260822120402.png]]
> ![[Pasted image 20260822120416.png]]
> ![[Pasted image 20260822120422.png]]

These examples show us what information can be leaked to anonymous users. Once an `anonymous` user has access to a network service, it only takes one mistake to give them too many permissions or too much visibility to put the entire network at significant risk.

Most importantly, anonymous access to such services can also lead to the discovery of other users, who can be attacked with brute-forcing in the most aggressive case.

Let us see how we can enumerate users using the `rpcclient`.

> [!example]- User Enumeration with RPCclient
> ```shell
> rpcclient $> enumdomusers
>
> user:[mrb3n] rid:[0x3e8]
> user:[cry0l1t3] rid:[0x3e9]
>
>
> rpcclient $> queryuser 0x3e9
>
>        User Name   :   cry0l1t3
>        Full Name   :   cry0l1t3
>        Home Drive  :   \\devsmb\cry0l1t3
>        Dir Drive   :
>        Profile Path:   \\devsmb\cry0l1t3\profile
>        Logon Script:
>        Description :
>        Workstations:
>        Comment     :
>        Remote Dial :
>        Logon Time               :      Do, 01 Jan 1970 01:00:00 CET
>        Logoff Time              :      Mi, 06 Feb 2036 16:06:39 CET
>        Kickoff Time             :      Mi, 06 Feb 2036 16:06:39 CET
>        Password last set Time   :      Mi, 22 Sep 2021 17:50:56 CEST
>        Password can change Time :      Mi, 22 Sep 2021 17:50:56 CEST
>        Password must change Time:      Do, 14 Sep 30828 04:48:05 CEST
>        unknown_2[0..31]...
>        user_rid :      0x3e9
>        group_rid:      0x201
>        acb_info :      0x00000014
>        fields_present: 0x00ffffff
>        logon_divs:     168
>        bad_password_count:     0x00000000
>        logon_count:    0x00000000
>        padding1[0..7]...
>        logon_hrs[0..21]...
>
>
> rpcclient $> queryuser 0x3e8
>
>        User Name   :   mrb3n
>        Full Name   :
>        Home Drive  :   \\devsmb\mrb3n
>        Dir Drive   :
>        Profile Path:   \\devsmb\mrb3n\profile
>        Logon Script:
>        Description :
>        Workstations:
>        Comment     :
>        Remote Dial :
>        Logon Time               :      Do, 01 Jan 1970 01:00:00 CET
>        Logoff Time              :      Mi, 06 Feb 2036 16:06:39 CET
>        Kickoff Time             :      Mi, 06 Feb 2036 16:06:39 CET
>        Password last set Time   :      Mi, 22 Sep 2021 17:47:59 CEST
>        Password can change Time :      Mi, 22 Sep 2021 17:47:59 CEST
>        Password must change Time:      Do, 14 Sep 30828 04:48:05 CEST
>        unknown_2[0..31]...
>        user_rid :      0x3e8
>        group_rid:      0x201
>        acb_info :      0x00000010
>        fields_present: 0x00ffffff
>        logon_divs:     168
>        bad_password_count:     0x00000000
>        logon_count:    0x00000000
>        padding1[0..7]...
>        logon_hrs[0..21]...
>    ```

We can then use the results to identify the group's RID, which we can then use to retrieve information from the entire group.

> [!example]- RPCclient Group Enumeration
>```shell
rpcclient $> querygroup 0x201
>
>        Group Name:     None
>        Description:    Ordinary Users
>        Group Attribute:7
>        Num Members:2
>```

---
## Brute Forcing User RIDs
> The query `queryuser <RID>` is mostly allowed based on the RID. So we can use the rpcclient to brute force the RIDs to get information. We can create a `For-loop` using `Bash` where we send a command to the service using rpcclient and filter out the results.

> [!Example]- Brute Forcing Scripts
> ```shell
> nusss@htb[/htb]$ for i in $(seq 500 1100);do rpcclient -N -U "" 10.129.14.128 -c "queryuser 0x$(printf '%x\n' $i)" | grep "User Name\|user_rid\|group_rid" && echo "";done
>
>        User Name   :   sambauser
>        user_rid :      0x1f5
>        group_rid:      0x201
 >       
 >       User Name   :   mrb3n
 >       user_rid :      0x3e8
 >       group_rid:      0x201
 >       
 >       User Name   :   cry0l1t3
 >       user_rid :      0x3e9
 >       group_rid:      0x201
> ```

Alternatively, we could use a Python script from  [Impacket](https://github.com/SecureAuthCorp/impacket) called [samrdump.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/samrdump.py).

> [!example]- Impacket - Samrdump.py
> ```shell
> nusss@htb[/htb]$ samrdump.py 10.129.14.128
>
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation
>
[*] Retrieving endpoint list from 10.129.14.128
Found domain(s):
 . DEVSMB
 . Builtin
[*] Looking up users in domain DEVSMB
Found user: mrb3n, uid = 1000
Found user: cry0l1t3, uid = 1001
mrb3n (1000)/FullName: 
mrb3n (1000)/UserComment: 
mrb3n (1000)/PrimaryGroupId: 513
mrb3n (1000)/BadPasswordCount: 0
mrb3n (1000)/LogonCount: 0
mrb3n (1000)/PasswordLastSet: 2021-09-22 17:47:59
mrb3n (1000)/PasswordDoesNotExpire: False
mrb3n (1000)/AccountIsDisabled: False
mrb3n (1000)/ScriptPath: 
cry0l1t3 (1001)/FullName: cry0l1t3
cry0l1t3 (1001)/UserComment: 
cry0l1t3 (1001)/PrimaryGroupId: 513
cry0l1t3 (1001)/BadPasswordCount: 0
cry0l1t3 (1001)/LogonCount: 0
cry0l1t3 (1001)/PasswordLastSet: 2021-09-22 17:50:56
cry0l1t3 (1001)/PasswordDoesNotExpire: False
cry0l1t3 (1001)/AccountIsDisabled: False
cry0l1t3 (1001)/ScriptPath: 
[*] Received 2 entries.
> ```

---
## SMBMap & CrackMapExec
>The information we have already obtained with `rpcclient` can also be obtained using other tools. For example, the [SMBMap](https://github.com/ShawnDEvans/smbmap) and [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec) tools are also widely used and helpful for the enumeration of SMB services.

> [!example]- SMBMap
> ```shell
> > nusss@htb[/htb]$ smbmap -H 10.129.14.128
> 
> [+] Finding open SMB ports....
> [+] User SMB session established on 10.129.14.128...
> [+] IP: 10.129.14.128:445       Name: 10.129.14.128                                     
>         Disk                                                    Permissions     Comment
>         ----                                                    -----------     -------
>         print$                                                  NO ACCESS       Printer Drivers
>         home                                                    NO ACCESS       INFREIGHT Samba
>         dev                                                     NO ACCESS       DEVenv
>         notes                                                   NO ACCESS       CheckIT
>         IPC$                                                    NO ACCESS       IPC Service (DEVSM)
> ```

> [!example]- CrackMapExec
> ```shell
> nusss@htb[/htb]$ crackmapexec smb 10.129.14.128 --shares -u '' -p ''
>
SMB         10.129.14.128   445    DEVSMB           [*] Windows 6.1 Build 0 (name:DEVSMB) (domain:) (signing:False) (SMBv1:False)
SMB         10.129.14.128   445    DEVSMB           [+] \: 
SMB         10.129.14.128   445    DEVSMB           [+] Enumerated shares
SMB         10.129.14.128   445    DEVSMB           Share           Permissions     Remark
SMB         10.129.14.128   445    DEVSMB           -----           -----------     ------
SMB         10.129.14.128   445    DEVSMB           print$                          Printer Drivers
SMB         10.129.14.128   445    DEVSMB           home                            INFREIGHT Samba
SMB         10.129.14.128   445    DEVSMB           dev                             DEVenv
SMB         10.129.14.128   445    DEVSMB           notes           READ,WRITE      CheckIT
SMB         10.129.14.128   445    DEVSMB           IPC$                            IPC Service (DEVSM)
> ```

---
## Enum4Linux-ng
>Another tool worth mentioning is the so-called [enum4linux-ng](https://github.com/cddmp/enum4linux-ng), which is based on an older tool, enum4linux. This tool automates many of the queries, but not all, and can return a large amount of information.

> [!NOTE]- Installation
> ```shell
> nusss@htb[/htb]$ git clone https://github.com/cddmp/enum4linux-ng.git
nusss@htb[/htb]$ cd enum4linux-ng
nusss@htb[/htb]$ pip3 install -r requirements.txt
> ```

> [!example]- Enum4Linux-ng Enumeration
> ```shell
> > nusss@htb[/htb]$ ./enum4linux-ng.py 10.129.14.128 -A
> 
> ENUM4LINUX - next generation
> 
>  ==========================
> |    Target Information    |
>  ==========================
> [*] Target ........... 10.129.14.128
> [*] Username ......... ''
> [*] Random Username .. 'juzgtcsu'
> [*] Password ......... ''
> [*] Timeout .......... 5 second(s)
> 
>  =====================================
> |    Service Scan on 10.129.14.128    |
>  =====================================
> [*] Checking LDAP
> [-] Could not connect to LDAP on 389/tcp: connection refused
> [*] Checking LDAPS
> [-] Could not connect to LDAPS on 636/tcp: connection refused
> [*] Checking SMB
> [+] SMB is accessible on 445/tcp
> [*] Checking SMB over NetBIOS
> [+] SMB over NetBIOS is accessible on 139/tcp
> 
>  =====================================================
> |    NetBIOS Names and Workgroup for 10.129.14.128    |
>  =====================================================
> [+] Got domain/workgroup name: DEVOPS
> [+] Full NetBIOS names information:
> - DEVSMB          <00> -         H <ACTIVE>  Workstation Service
> - DEVSMB          <03> -         H <ACTIVE>  Messenger Service
> - DEVSMB          <20> -         H <ACTIVE>  File Server Service
> - ..__MSBROWSE__. <01> - <GROUP> H <ACTIVE>  Master Browser
> - DEVOPS          <00> - <GROUP> H <ACTIVE>  Domain/Workgroup Name
> - DEVOPS          <1d> -         H <ACTIVE>  Master Browser
> - DEVOPS          <1e> - <GROUP> H <ACTIVE>  Browser Service Elections
> - MAC Address = 00-00-00-00-00-00
> 
>  ==========================================
> |    SMB Dialect Check on 10.129.14.128    |
>  ==========================================
> [*] Trying on 445/tcp
> [+] Supported dialects and settings:
> SMB 1.0: false
> SMB 2.02: true
> SMB 2.1: true
> SMB 3.0: true
> SMB1 only: false
> Preferred dialect: SMB 3.0
> SMB signing required: false
> 
>  ==========================================
> |    RPC Session Check on 10.129.14.128    |
>  ==========================================
> [*] Check for null session
> [+] Server allows session using username '', password ''
> [*] Check for random user session
> [+] Server allows session using username 'juzgtcsu', password ''
> [H] Rerunning enumeration with user 'juzgtcsu' might give more results
> 
>  ====================================================
> |    Domain Information via RPC for 10.129.14.128    |
>  ====================================================
> [+] Domain: DEVOPS
> [+] SID: NULL SID
> [+] Host is part of a workgroup (not a domain)
> 
>  ============================================================
> |    Domain Information via SMB session for 10.129.14.128    |
>  ============================================================
> [*] Enumerating via unauthenticated SMB session on 445/tcp
> [+] Found domain information via SMB
> NetBIOS computer name: DEVSMB
> NetBIOS domain name: ''
> DNS domain: ''
> FQDN: htb
> 
>  ================================================
> |    OS Information via RPC for 10.129.14.128    |
>  ================================================
> [*] Enumerating via unauthenticated SMB session on 445/tcp
> [+] Found OS information via SMB
> [*] Enumerating via 'srvinfo'
> [+] Found OS information via 'srvinfo'
> [+] After merging OS information we have the following result:
> OS: Windows 7, Windows Server 2008 R2
> OS version: '6.1'
> OS release: ''
> OS build: '0'
> Native OS: not supported
> Native LAN manager: not supported
> Platform id: '500'
> Server type: '0x809a03'
> Server type string: Wk Sv PrQ Unx NT SNT DEVSM
> 
>  ======================================
> |    Users via RPC on 10.129.14.128    |
>  ======================================
> [*] Enumerating users via 'querydispinfo'
> [+] Found 2 users via 'querydispinfo'
> [*] Enumerating users via 'enumdomusers'
> [+] Found 2 users via 'enumdomusers'
> [+] After merging user results we have 2 users total:
> '1000':
>   username: mrb3n
>   name: ''
>   acb: '0x00000010'
>   description: ''
> '1001':
>   username: cry0l1t3
>   name: cry0l1t3
>   acb: '0x00000014'
>   description: ''
> 
>  =======================================
> |    Groups via RPC on 10.129.14.128    |
>  =======================================
> [*] Enumerating local groups
> [+] Found 0 group(s) via 'enumalsgroups domain'
> [*] Enumerating builtin groups
> [+] Found 0 group(s) via 'enumalsgroups builtin'
> [*] Enumerating domain groups
> [+] Found 0 group(s) via 'enumdomgroups'
> 
>  =======================================
> |    Shares via RPC on 10.129.14.128    |
>  =======================================
> [*] Enumerating shares
> [+] Found 5 share(s):
> IPC$:
>   comment: IPC Service (DEVSM)
>   type: IPC
> dev:
>   comment: DEVenv
>   type: Disk
> home:
>   comment: INFREIGHT Samba
>   type: Disk
> notes:
>   comment: CheckIT
>   type: Disk
> print$:
>   comment: Printer Drivers
>   type: Disk
> [*] Testing share IPC$
> [-] Could not check share: STATUS_OBJECT_NAME_NOT_FOUND
> [*] Testing share dev
> [-] Share doesn't exist
> [*] Testing share home
> [+] Mapping: OK, Listing: OK
> [*] Testing share notes
> [+] Mapping: OK, Listing: OK
> [*] Testing share print$
> [+] Mapping: DENIED, Listing: N/A
> 
>  ==========================================
> |    Policies via RPC for 10.129.14.128    |
>  ==========================================
> [*] Trying port 445/tcp
> [+] Found policy:
> domain_password_information:
>   pw_history_length: None
>   min_pw_length: 5
>   min_pw_age: none
>   max_pw_age: 49710 days 6 hours 21 minutes
>   pw_properties:
>   - DOMAIN_PASSWORD_COMPLEX: false
>   - DOMAIN_PASSWORD_NO_ANON_CHANGE: false
>   - DOMAIN_PASSWORD_NO_CLEAR_CHANGE: false
>   - DOMAIN_PASSWORD_LOCKOUT_ADMINS: false
>   - DOMAIN_PASSWORD_PASSWORD_STORE_CLEARTEXT: false
>   - DOMAIN_PASSWORD_REFUSE_PASSWORD_CHANGE: false
> domain_lockout_information:
>   lockout_observation_window: 30 minutes
>   lockout_duration: 30 minutes
>   lockout_threshold: None
> domain_logoff_information:
>   force_logoff_time: 49710 days 6 hours 21 minutes
> 
>  ==========================================
> |    Printers via RPC for 10.129.14.128    |
>  ==========================================
> [+] No printers returned (this is not an error)
> 
> Completed after 0.61 seconds
> ```

---
## Questions :
[[SMB Questions]]