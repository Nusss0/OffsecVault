---

---
---
## Question 1

> Which version of the FTP server is running on the target system? Submit the entire banner as the answer.

Do the full enumeration with nmap : 
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ sudo nmap -sV -p21 -sC -A 10.129.202.5
[sudo] password for nus:
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-17 22:10 +0700

PORT   STATE SERVICE VERSION
21/tcp open  ftp
| fingerprint-strings:
|   GenericLines:
|     220 InFreight FTP v1.1
|     Invalid command: try being more creative
|     Invalid command: try being more creative
|   NULL:
|_    220 InFreight FTP v1.1
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--   1 ftpuser  ftpuser        39 Nov  8  2021 flag.txt
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port21-TCP:V=7.99%I=7%D=8/17%Time=6A83247A%P=x86_64-pc-linux-gnu%r(NULL
SF:,18,"220\x20InFreight\x20FTP\x20v1\.1\r\n")%r(GenericLines,74,"220\x20I
SF:nFreight\x20FTP\x20v1\.1\r\n500\x20Invalid\x20command:\x20try\x20being\
SF:x20more\x20creative\r\n500\x20Invalid\x20command:\x20try\x20being\x20mo
SF:re\x20creative\r\n");
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose|router
Running: Linux 4.X|5.X, MikroTik RouterOS 7.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5 cpe:/o:mikrotik:routeros:7 cpe:/o:linux:linux_kernel:5.6.3
OS details: Linux 4.15 - 5.19, Linux 5.0 - 5.14, MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3)
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT       ADDRESS
1   185.93 ms 10.10.14.1
2   186.09 ms 10.129.202.5

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 81.91 seconds
```

From here we got some informations : 
- FTP server banner
- FTP has the anonymous feature, and we could see `flag.txt` there.
### Answers : `InFreight FTP v1.1`

---
## Question 2

>Enumerate the FTP server and find the flag.txt file. Submit the contents of it as the answer.

Since the service allows anonymous, then we could log in with :
```
Name : anonymous
Pass : anonymous
```

Here is the full process
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ ftp $IP
Connected to 10.129.202.5.
220 InFreight FTP v1.1
Name (10.129.202.5:nus): anonymous
331 Anonymous login ok, send your complete email address as your password
Password:
230 Anonymous access granted, restrictions apply
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> get flag.txt
local: flag.txt remote: flag.txt
229 Entering Extended Passive Mode (|||5786|)
150 Opening BINARY mode data connection for flag.txt (39 bytes)
    39        1.77 MiB/s
226 Transfer complete
39 bytes received in 00:00 (0.05 KiB/s)
ftp> exit
c221 Goodbye.
┌──(nus㉿kali-htb)-[~/HTB]
└─$ cat flag.txt
HTB{b7skjr4c76zhsds7fzhd4k3ujg7nhdjre}
```

Use `get` to download the file and obtain `flag.txt`.

---
## Notes 
- Downloaded file will be saved on the folder we open `FTP`
- Each run on `nmap` could cause a diff **RESULT**. This happens because of *Probe Timing* on `nmap`
---
## Source :
[[CPTS/Footprinting/Sections/FTP]]

