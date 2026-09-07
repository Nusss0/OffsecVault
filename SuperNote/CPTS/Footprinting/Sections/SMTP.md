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