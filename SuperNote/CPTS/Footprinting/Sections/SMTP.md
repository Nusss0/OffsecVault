Source : 
>[HTB - SMTP SECTION](https://academy.hackthebox.com/app/module/112/section/1072)

---
## About SMTP
>The `Simple Mail Transfer Protocol` (`SMTP`) is a protocol for sending emails in an IP network. It can be used between an email client and an outgoing mail server or between two SMTP servers. In principle, it is a client-server-based protocol, although SMTP can be used between a client and a server and between two SMTP servers. In this case, a server effectively acts as a client.

Port request : 25 or 587

At the beginning of the connection, authentication occurs when the client confirms its identity with a user name and password. The emails can then be transmitted. For this purpose, the client sends the server sender and recipient addresses, the email's content, and other information and parameters. After the email has been transmitted, the connection is terminated again. The email server then starts sending the email to another SMTP server.

SMTP works unencrypted without further measures and transmits all commands, data, or authentication information in plain text. To prevent unauthorized reading of data, the SMTP is used in conjunction with SSL/TLS encryption. Under certain circumstances, a server uses a port other than the standard TCP port `25` for the encrypted connection, for example, TCP port `465`.

SMTP Flow
![[Pasted image 20260907093151.png]]

---
## Interact with SMTP Server
>To interact with the SMTP server, we can use the `telnet` tool to initialize a TCP connection with the SMTP server. The actual initialization of the session is done with the command mentioned above, `HELO` or `EHLO`.

> [!example]- Telnet, HELO, and EHLO
> ```shell
> nusss@htb[/htb]$ telnet 10.129.14.128 25
> 
> Trying 10.129.14.128...
> Connected to 10.129.14.128.
> Escape character is '^]'.
> 220 ESMTP Server 
> 
> #---------------------------------------------
> HELO mail1.inlanefreight.htb
> 
> 250 mail1.inlanefreight.htb
> 
> #----------------------------------------------
> EHLO mail1
> 
> 250-mail1.inlanefreight.htb
> 250-PIPELINING
> 250-SIZE 10240000
> 250-ETRN
> 250-ENHANCEDSTATUSCODES
> 250-8BITMIME
> 250-DSN
> 250-SMTPUTF8
> 250 CHUNKING
> ```

The command `VRFY` can be used to enumerate existing users on the system. However, this does not always work. Depending on how the SMTP server is configured, the SMTP server may issue `code 252` and confirm the existence of a user that does not exist on the system. A list of all SMTP response codes can be found [here](https://serversmtp.com/smtp-error/).

> [!example]- VRFY
> ```shell
> nusss@htb[/htb]$ telnet 10.129.14.128 25
> 
> Trying 10.129.14.128...
> Connected to 10.129.14.128.
> Escape character is '^]'.
> 220 ESMTP Server 
> 
> VRFY root
> 
> 252 2.0.0 root
> 
> 
> VRFY cry0l1t3
> 
> 252 2.0.0 cry0l1t3
> 
> 
> VRFY testuser
> 
> 252 2.0.0 testuser
> 
> 
> VRFY aaaaaaaaaaaaaaaaaaaaaaaaaaaa
> 
> 252 2.0.0 aaaaaaaaaaaaaaaaaaaaaaaaaaaa
> ```

---
## Send an Email

> [!example]- Email sending
> ```shell
> nusss@htb[/htb]$ telnet 10.129.14.128 25
> 
> Trying 10.129.14.128...
> Connected to 10.129.14.128.
> Escape character is '^]'.
> 220 ESMTP Server
> 
> 
> EHLO inlanefreight.htb
> 
> 250-mail1.inlanefreight.htb
> 250-PIPELINING
> 250-SIZE 10240000
> 250-ETRN
> 250-ENHANCEDSTATUSCODES
> 250-8BITMIME
> 250-DSN
> 250-SMTPUTF8
> 250 CHUNKING
> 
> 
> MAIL FROM: <cry0l1t3@inlanefreight.htb>
> 
> 250 2.1.0 Ok
> 
> 
> RCPT TO: <mrb3n@inlanefreight.htb> NOTIFY=success,failure
> 
> 250 2.1.5 Ok
> 
> 
> DATA
> 
> 354 End data with <CR><LF>.<CR><LF>
> 
> From: <cry0l1t3@inlanefreight.htb>
> To: <mrb3n@inlanefreight.htb>
> Subject: DB
> Date: Tue, 28 Sept 2021 16:32:51 +0200
> Hey man, I am trying to access our XY-DB but the creds don't work. 
> Did you make any changes there?
> .
> 
> 250 2.0.0 Ok: queued as 6E1CF1681AB
> 
> 
> QUIT
> 
> 221 2.0.0 Bye
> Connection closed by foreign host.
>```

---
## Footprinting the Services

The default Nmap scripts include `smtp-commands`, which uses the `EHLO` command to list all possible commands that can be executed on the target SMTP server.

> [!example]- Nmap 
> ```shell
> nusss@htb[/htb]$ sudo nmap 10.129.14.128 -sC -sV -p25
>
Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-27 17:56 CEST
Nmap scan report for 10.129.14.128
Host is up (0.00025s latency).
>
PORT   STATE SERVICE VERSION
25/tcp open  smtp    Postfix smtpd
|_smtp-commands: mail1.inlanefreight.htb, PIPELINING, SIZE 10240000, VRFY, ETRN, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING, 
MAC Address: 00:00:00:00:00:00 (VMware)
>
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 14.09 seconds
>
> ```

However, we can also use the [smtp-open-relay](https://nmap.org/nsedoc/scripts/smtp-open-relay.html) NSE script to identify the target SMTP server as an open relay using 16 different tests. If we also print out the output of the scan in detail, we will also be able to see which tests the script is running.

> [!example]- Nmap NSE script
> ```shell
> nusss@htb[/htb]$ sudo nmap 10.129.14.128 -p25 --script smtp-open-relay -v
> 
> Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-30 02:29 CEST
> NSE: Loaded 1 scripts for scanning.
> NSE: Script Pre-scanning.
> Initiating NSE at 02:29
> Completed NSE at 02:29, 0.00s elapsed
> Initiating ARP Ping Scan at 02:29
> Scanning 10.129.14.128 [1 port]
> Completed ARP Ping Scan at 02:29, 0.06s elapsed (1 total hosts)
> Initiating Parallel DNS resolution of 1 host. at 02:29
> Completed Parallel DNS resolution of 1 host. at 02:29, 0.03s elapsed
> Initiating SYN Stealth Scan at 02:29
> Scanning 10.129.14.128 [1 port]
> Discovered open port 25/tcp on 10.129.14.128
> Completed SYN Stealth Scan at 02:29, 0.06s elapsed (1 total ports)
> NSE: Script scanning 10.129.14.128.
> Initiating NSE at 02:29
> Completed NSE at 02:29, 0.07s elapsed
> Nmap scan report for 10.129.14.128
> Host is up (0.00020s latency).
> 
> PORT   STATE SERVICE
> 25/tcp open  smtp
> | smtp-open-relay: Server is an open relay (16/16 tests)
> |  MAIL FROM:<> -> RCPT TO:<relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@nmap.scanme.org> -> RCPT TO:<relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@ESMTP> -> RCPT TO:<relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest%nmap.scanme.org@[10.129.14.128]>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest%nmap.scanme.org@ESMTP>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest@nmap.scanme.org">
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest%nmap.scanme.org">
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org@[10.129.14.128]>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest@nmap.scanme.org"@[10.129.14.128]>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org@ESMTP>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<@[10.129.14.128]:relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<@ESMTP:relaytest@nmap.scanme.org>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest>
> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest@[10.129.14.128]>
> |_ MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest@ESMTP>
> MAC Address: 00:00:00:00:00:00 (VMware)
> 
> NSE: Script Post-scanning.
> Initiating NSE at 02:29
> Completed NSE at 02:29, 0.00s elapsed
> Read data files from: /usr/bin/../share/nmap
> Nmap done: 1 IP address (1 host up) scanned in 0.48 seconds
>            Raw packets sent: 2 (72B) | Rcvd: 2 (72B)
> ```

---
# Questions
[[SMTP Questions]]