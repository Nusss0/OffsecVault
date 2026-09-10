# Questions 1
>Figure out the exact organization name from the IMAP/POP3 service and submit it as the answer.

Since we got our credential, `robin`:`robin`, then let's directly try with curl.
```shell
┌──(nus㉿Anomaly12)-[~]
└─$ sudo nmap $ip -p110,143,993,995 -sC -sV
[sudo] password for nus:
Starting Nmap 7.98 ( https://nmap.org ) at 2026-09-10 14:13 +0700
Nmap scan report for 10.129.201.164
Host is up (0.26s latency).

PORT    STATE SERVICE  VERSION
110/tcp open  pop3     Dovecot pop3d
| ssl-cert: Subject: commonName=dev.inlanefreight.htb/organizationName=InlaneFreight Ltd/stateOrProvinceName=London/countryName=UK
| Not valid before: 2021-11-08T23:10:05
|_Not valid after:  2295-08-23T23:10:05
|_ssl-date: TLS randomness does not represent time
|_pop3-capabilities: SASL STLS UIDL CAPA AUTH-RESP-CODE TOP PIPELINING RESP-CODES
143/tcp open  imap     Dovecot imapd
|_imap-capabilities: ID ENABLE STARTTLS more Pre-login SASL-IR IDLE OK capabilities IMAP4rev1 LITERAL+ LOGIN-REFERRALS have listed post-login LOGINDISABLEDA0001
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=dev.inlanefreight.htb/organizationName=InlaneFreight Ltd/stateOrProvinceName=London/countryName=UK
| Not valid before: 2021-11-08T23:10:05
|_Not valid after:  2295-08-23T23:10:05
993/tcp open  ssl/imap Dovecot imapd
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=dev.inlanefreight.htb/organizationName=InlaneFreight Ltd/stateOrProvinceName=London/countryName=UK
| Not valid before: 2021-11-08T23:10:05
|_Not valid after:  2295-08-23T23:10:05
|_imap-capabilities: ID ENABLE more Pre-login IDLE post-login SASL-IR capabilities IMAP4rev1 LITERAL+ LOGIN-REFERRALS have listed AUTH=PLAINA0001 OK
995/tcp open  ssl/pop3 Dovecot pop3d
|_ssl-date: TLS randomness does not represent time
|_pop3-capabilities: SASL(PLAIN) USER UIDL CAPA AUTH-RESP-CODE TOP PIPELINING RESP-CODES
| ssl-cert: Subject: commonName=dev.inlanefreight.htb/organizationName=InlaneFreight Ltd/stateOrProvinceName=London/countryName=UK
| Not valid before: 2021-11-08T23:10:05
|_Not valid after:  2295-08-23T23:10:05

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 27.61 seconds

```

We got this : `organizationName=InlaneFreight Ltd`

## Answer : `InlaneFreight Ltd`

---
# Questions 2
>What is the FQDN that the IMAP and POP3 servers are assigned to?

From question 1 result : 
## Answer : `dev.inlanefreight.htb`

---
# Question 3
>Enumerate the IMAP service and submit the flag as the answer. (Format: HTB{...})

```shell
┌──(nus㉿Anomaly12)-[~]
└─$ curl -k "imaps://$ip" --user robin:robin -v
*   Trying 10.129.201.164:993...
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* SSL Trust: peer verification disabled
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / x25519 / RSASSA-PSS
* Server certificate:
*   subject: C=UK; ST=London; L=London; O=InlaneFreight Ltd; OU=DevOps DepÃartment; CN=dev.inlanefreight.htb; emailAddress=cto.dev@dev.inlanefreight.htb
*   start date: Nov  8 23:10:05 2021 GMT
*   expire date: Aug 23 23:10:05 2295 GMT
*   issuer: C=UK; ST=London; L=London; O=InlaneFreight Ltd; OU=DevOps DepÃartment; CN=dev.inlanefreight.htb; emailAddress=cto.dev@dev.inlanefreight.htb
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
*  SSL certificate verification failed, continuing anyway!
* Established connection to 10.129.201.164 (10.129.201.164 port 993) from 10.10.14.219 port 36744
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
< * OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN] HTB{roncfbw7iszerd7shni7jr2343zhrj}
> A001 CAPABILITY
< * CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN
< A001 OK Pre-login capabilities listed, post-login capabilities have more.
> A002 AUTHENTICATE PLAIN AHJvYmluAHJvYmlu
< * CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SNIPPET=FUZZY PREVIEW=FUZZY LITERAL+ NOTIFY SPECIAL-USE
< A002 OK Logged in
> A003 LIST "" *
< * LIST (\Noselect \HasChildren) "." DEV
* LIST (\Noselect \HasChildren) "." DEV
< * LIST (\Noselect \HasChildren) "." DEV.DEPARTMENT
* LIST (\Noselect \HasChildren) "." DEV.DEPARTMENT
< * LIST (\HasNoChildren) "." DEV.DEPARTMENT.INT
* LIST (\HasNoChildren) "." DEV.DEPARTMENT.INT
< * LIST (\HasNoChildren) "." INBOX
* LIST (\HasNoChildren) "." INBOX
< A003 OK List completed (0.001 + 0.000 secs).
* Connection #0 to host 10.129.201.164:993 left intact
```
From here we got the banner.

## Answer : `HTB{roncfbw7iszerd7shni7jr2343zhrj}`
---
# Question 4 
>What is the customized version of the POP3 server?

Let's enumerate inside the POP3 server using SSL/TLS : 
```bash
┌──(nus㉿Anomaly12)-[~]
└─$ openssl s_client -connect $ip:pop3s
Connecting to 10.129.201.164
CONNECTED(00000003)
Can't use SSL_get_servername
depth=0 C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
verify error:num=18:self-signed certificate
verify return:1
depth=0 C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
verify return:1
---
Certificate chain
 0 s:C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
   i:C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
   a:PKEY: RSA, 2048 (bit); sigalg: sha256WithRSAEncryption
   v:NotBefore: Nov  8 23:10:05 2021 GMT; NotAfter: Aug 23 23:10:05 2295 GMT
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIEUzCCAzugAwIBAgIUDf35PqFuv6Uv0EECM8dFmNSZoY8wDQYJKoZIhvcNAQEL
BQAwgbcxCzAJBgNVBAYTAlVLMQ8wDQYDVQQIDAZMb25kb24xDzANBgNVBAcMBkxv
bmRvbjEaMBgGA1UECgwRSW5sYW5lRnJlaWdodCBMdGQxHDAaBgNVBAsME0Rldk9w
cyBEZXDDg2FydG1lbnQxHjAcBgNVBAMMFWRldi5pbmxhbmVmcmVpZ2h0Lmh0YjEs
MCoGCSqGSIb3DQEJARYdY3RvLmRldkBkZXYuaW5sYW5lZnJlaWdodC5odGIwIBcN
MjExMTA4MjMxMDA1WhgPMjI5NTA4MjMyMzEwMDVaMIG3MQswCQYDVQQGEwJVSzEP
MA0GA1UECAwGTG9uZG9uMQ8wDQYDVQQHDAZMb25kb24xGjAYBgNVBAoMEUlubGFu
ZUZyZWlnaHQgTHRkMRwwGgYDVQQLDBNEZXZPcHMgRGVww4NhcnRtZW50MR4wHAYD
VQQDDBVkZXYuaW5sYW5lZnJlaWdodC5odGIxLDAqBgkqhkiG9w0BCQEWHWN0by5k
ZXZAZGV2LmlubGFuZWZyZWlnaHQuaHRiMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAxvMwFE6m+iBUSujb5d6DUy1xDYR5awzQRwddyvq6iBrMxbnptSrn
+j0UOKWHCOpD5LREwP26ghUg0lVJzfo+v5pQJGnxEXKg0OFlzWEd8xgx/JWW/z1/
rDsWlNa2yYZkCy68YWJlC7UZxvcDFrI0V0pDJIkrjForw26laoYDkrh1A5F8uUXD
1TwRLLYo+NGmtNHT3BADJpv6aFUZ4CGrqBQNi7XpsTZ948WLhUwQvWmebiK06Dai
TvMNKBctjWAiNI4xvq34W9hIUaPxT1JJzuujRslep6nHGHW00QEWTWgyOMYThc3b
HtKIHMfDLTUMz7s8RhVVwlWE6+ly1DMRgQIDAQABo1MwUTAdBgNVHQ4EFgQUGDTC
9B5KCKPWT7vXbnMunL/mEE4wHwYDVR0jBBgwFoAUGDTC9B5KCKPWT7vXbnMunL/m
EE4wDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEADh0v5XWCf3KO
atrWcoiIOC67Z0ZIO7yEF+fQo8z+Wx1dWzmCFVu7u4+l7slcdJICCGBbOX8eItWS
chwzgnWJToyX8PWY8lSaB8ifMDQcr457Y7O6NmvgU35sRcLnYYqXzu2oh0lxsFLR
vL1wpyDLPhhoI++j1fELhiJ3GWiUQrb0vfJPcbSkHTgzf0hm7mLJTaqt3WfS/Gr2
8Oh7vSfzvqvHLE7HHAO0G5Q81zo+wWsrQF0s40HEF/raEMfOy2Htm79YjyjAlLWf
ueS+u8rX2smOYdRIpL3UPx7+yZPGu47vYoetde1Z5cfTCgmeS05BQ2qMOp6Tw6+G
xUuqg8nK1Q==
-----END CERTIFICATE-----
subject=C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
issuer=C=UK, ST=London, L=London, O=InlaneFreight Ltd, OU=DevOps DepÃartment, CN=dev.inlanefreight.htb, emailAddress=cto.dev@dev.inlanefreight.htb
---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: rsa_pss_rsae_sha256
Peer Temp Key: X25519, 253 bits
---
SSL handshake has read 1667 bytes and written 1740 bytes
Verification error: self-signed certificate
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Protocol: TLSv1.3
Server public key is 2048 bit
This TLS version forbids renegotiation.
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 18 (self-signed certificate)
---
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 2B6BF0C532F5853D9E01C6EA4FCD2972ED6531CA9EF223D529055F0FAFEB376D
    Session-ID-ctx:
    Resumption PSK: 4532EC31E1C205AE704E1864CBC6F6BD7DEA777056EE5053A2D97FDEA7494516CA25F850011A93A1E54B455FD366960C
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - 47 9a 92 22 e6 25 50 34-3c 9b d5 e6 15 52 db 5e   G..".%P4<....R.^
    0010 - ac 39 5a 2e fd 69 1b 68-fd 4a 67 d2 7b 46 75 1b   .9Z..i.h.Jg.{Fu.
    0020 - 8e 4f 90 e7 f2 37 19 a1-d6 57 32 5f 92 7c 00 a1   .O...7...W2_.|..
    0030 - f7 1a a2 d7 35 cf d7 0e-6a a6 69 48 ff 98 7d 22   ....5...j.iH..}"
    0040 - be e4 02 27 db 66 48 be-c7 fe 6e f6 12 7e f8 80   ...'.fH...n..~..
    0050 - 53 ab f0 8b c0 87 b5 ed-a5 e8 9e ec 08 cc eb a9   S...............
    0060 - 16 a6 63 32 44 f9 61 d7-6b 5c 46 f9 13 7c cf f2   ..c2D.a.k\F..|..
    0070 - 82 af 65 88 21 d7 d6 50-a4 f6 d9 87 af b8 2f 9d   ..e.!..P....../.
    0080 - 30 2b 46 af 9b c3 3e 90-75 2e 09 84 56 e1 0f 55   0+F...>.u...V..U
    0090 - 63 06 fd 74 9e e9 33 16-1d b3 08 56 6f 57 b0 28   c..t..3....VoW.(
    00a0 - fe 62 7a f3 fd 3a 5c 23-0c 4a 84 48 8d 0a 6c 7a   .bz..:\#.J.H..lz
    00b0 - f2 ad c7 e1 43 07 ec a0-6b 14 d7 c9 fd 54 c7 98   ....C...k....T..

    Start Time: 1789025531
    Timeout   : 7200 (sec)
    Verify return code: 18 (self-signed certificate)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 63EF9F5ACE6D95FD60A6B9A90D6EF795408D74F47C879EDB6684C87B4E84337D
    Session-ID-ctx:
    Resumption PSK: 79A8A9317E619EF395832963D801155327EF7629E9D0BAA4AF22B273C7B035A9080E71160B11F721FC17F90422588876
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - 47 9a 92 22 e6 25 50 34-3c 9b d5 e6 15 52 db 5e   G..".%P4<....R.^
    0010 - e3 36 7d 0b 55 7e ac f6-cb f7 aa 78 b8 1d 7f 1f   .6}.U~.....x....
    0020 - 29 7e 15 8a 31 ec 1c 1c-38 fe 73 76 48 08 8b fe   )~..1...8.svH...
    0030 - 0b d3 3c d9 24 62 46 92-16 2a fa a2 48 78 20 7d   ..<.$bF..*..Hx }
    0040 - 40 1a a2 3d b2 ed 28 5f-9f a9 72 b2 a9 d3 a5 e9   @..=..(_..r.....
    0050 - a0 f9 d9 4e 71 d8 6b 36-22 27 0f 75 25 2d 4f 3d   ...Nq.k6"'.u%-O=
    0060 - b5 15 5c a2 ec e0 55 70-3e 3e ad ea 3f 9f 4d 31   ..\...Up>>..?.M1
    0070 - a5 a6 55 32 dc 07 41 c3-ba 70 d7 f5 a1 7e 27 ac   ..U2..A..p...~'.
    0080 - 60 a7 1b 22 a5 fa 75 f6-21 e4 e2 c9 77 06 66 ac   `.."..u.!...w.f.
    0090 - 8b 2c 1e 6b 62 bb 56 99-db 2d df 42 15 f1 3c ad   .,.kb.V..-.B..<.
    00a0 - 4e 6f 08 78 fe 12 20 f9-09 01 6a a1 85 06 d6 bb   No.x.. ...j.....
    00b0 - 0d 4f 6f f2 6f 8d 2f de-6b 59 09 5e 23 fb 9e 59   .Oo.o./.kY.^#..Y

    Start Time: 1789025531
    Timeout   : 7200 (sec)
    Verify return code: 18 (self-signed certificate)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
+OK InFreight POP3 v9.188

```

Now we got the version in the last row.

## Answer : `InFreight POP3 v9.188`
---
# Question 5
>What is the admin email address?

Let's try to searching inside the client inbox
```shell
openssl s_client -connect $ip:imaps -quiet

```

After connecting, use this sequence of commands : 

```shell
#Login
a1 LOGIN robin robin
a1 OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SNIPPET=FUZZY PREVIEW=FUZZY LITERAL+ NOTIFY SPECIAL-USE] Logged in

#List all folders
a2 LIST "" *
* LIST (\Noselect \HasChildren) "." DEV
* LIST (\Noselect \HasChildren) "." DEV.DEPARTMENT
* LIST (\HasNoChildren) "." DEV.DEPARTMENT.INT
* LIST (\HasNoChildren) "." INBOX
a2 OK List completed (0.001 + 0.000 secs).

#try to view the most suspicious folder
a3 SELECT DEV.DEPARTMENT.INT
* FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
* OK [PERMANENTFLAGS (\Answered \Flagged \Deleted \Seen \Draft \*)] Flags permitted.
* 1 EXISTS
* 0 RECENT
* OK [UIDVALIDITY 1636414279] UIDs valid
* OK [UIDNEXT 2] Predicted next UID
a3 OK [READ-WRITE] Select completed (0.001 + 0.000 secs).

#try to see the email content
a4 FETCH 1 BODY[]
* 1 FETCH (BODY[] {167}
Subject: Flag
To: Robin <robin@inlanefreight.htb>
From: CTO <devadmin@inlanefreight.htb>
Date: Wed, 03 Nov 2021 16:13:27 +0200

HTB{983uzn8jmfgpd8jmof8c34n7zio}
)
a4 OK Fetch completed (0.001 + 0.000 secs).
```

From the result above we got the admin email address and it's content.

## Answer : `devadmin@inlanefreight.htb`

---
# Question 6
>Try to access the emails on the IMAP server and submit the flag as the answer. (Format: HTB{...})

From question 5, we can see the email content contains a flag.

## Answer : `HTB{983uzn8jmfgpd8jmof8c34n7zio}`
