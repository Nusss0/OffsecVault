## Question 1 
> Enumerate the SMTP service and submit the banner, including its version as the answer.

```shell
┌──(nus㉿Anomaly12)-[~/htb-vpn]
└─$ sudo nmap $ip -p25,587 -sC -sV
Starting Nmap 7.98 ( https://nmap.org ) at 2026-09-08 12:27 +0700
Stats: 0:00:35 elapsed; 0 hosts completed (1 up), 1 undergoing Service Scan
Service scan Timing: About 100.00% done; ETC: 12:28 (0:00:00 remaining)
Nmap scan report for 10.129.23.111
Host is up (0.27s latency).

PORT    STATE  SERVICE    VERSION
25/tcp  open   smtp
|_smtp-commands: mail1, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING
| fingerprint-strings:
|   Hello:
|     220 InFreight ESMTP v2.11
|_    Syntax: EHLO hostname
587/tcp closed submission
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port25-TCP:V=7.98%I=7%D=9/8%Time=6A9F9CE2%P=x86_64-pc-linux-gnu%r(Hello
SF:,36,"220\x20InFreight\x20ESMTP\x20v2\.11\r\n501\x20Syntax:\x20EHLO\x20h
SF:ostname\r\n");

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 68.42 seconds

```

### Answer : 220 InFreight ESMTP v2.11

---
## Question 2
>Enumerate the SMTP service even further and find the username that exists on the system. Submit it as the answer.

```shell
┌──(nus㉿Anomaly12)-[~/htb-vpn]
└─$ sudo nmap $ip -p25,587 --script smtp-open-relay -v
[sudo] password for nus:
Starting Nmap 7.98 ( https://nmap.org ) at 2026-09-08 12:26 +0700
NSE: Loaded 1 scripts for scanning.
NSE: Script Pre-scanning.
Initiating NSE at 12:26
Completed NSE at 12:26, 0.00s elapsed
Initiating Ping Scan at 12:26
Scanning 10.129.23.111 [4 ports]
Completed Ping Scan at 12:26, 0.31s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 12:26
Completed Parallel DNS resolution of 1 host. at 12:26, 0.51s elapsed
Initiating SYN Stealth Scan at 12:26
Scanning 10.129.23.111 [2 ports]
Discovered open port 25/tcp on 10.129.23.111
Completed SYN Stealth Scan at 12:26, 0.33s elapsed (2 total ports)
NSE: Script scanning 10.129.23.111.
Initiating NSE at 12:26
Completed NSE at 12:27, 24.19s elapsed
Nmap scan report for 10.129.23.111
Host is up (0.26s latency).

PORT    STATE  SERVICE
25/tcp  open   smtp
| smtp-open-relay: Server is an open relay (16/16 tests)
|  MAIL FROM:<> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@nmap.scanme.org> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@InFreight> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<relaytest%nmap.scanme.org@[10.129.23.111]>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<relaytest%nmap.scanme.org@InFreight>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<"relaytest@nmap.scanme.org">
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<"relaytest%nmap.scanme.org">
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<relaytest@nmap.scanme.org@[10.129.23.111]>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<"relaytest@nmap.scanme.org"@[10.129.23.111]>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<relaytest@nmap.scanme.org@InFreight>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<@[10.129.23.111]:relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<@InFreight:relaytest@nmap.scanme.org>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<nmap.scanme.org!relaytest>
|  MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<nmap.scanme.org!relaytest@[10.129.23.111]>
|_ MAIL FROM:<antispam@[10.129.23.111]> -> RCPT TO:<nmap.scanme.org!relaytest@InFreight>
587/tcp closed submission

NSE: Script Post-scanning.
Initiating NSE at 12:27
Completed NSE at 12:27, 0.00s elapsed
Read data files from: /usr/share/nmap
Nmap done: 1 IP address (1 host up) scanned in 25.95 seconds
           Raw packets sent: 6 (240B) | Rcvd: 3 (124B)
```

