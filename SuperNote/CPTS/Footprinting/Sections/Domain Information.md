---
tags:
  - HTB
  - Material
  - Enumeration
  - Domain
  - CPTS
---
> Domain information is a core component of any penetration test, and it is not just about the subdomains but about the entire presence on the Internet.

> [!Important] Information Gathering
This type of information is gathered passively without direct and active scans. In other words, we remain hidden and navigate as "customers" or "visitors" to avoid direct connections to the company that could expose us.

 When `passively` gathering information, we can use third-party services to understand the company better. However, the first thing we should do is scrutinize the company's `main website`. Then, we should read through the texts, keeping in mind what technologies and structures are needed for these services.

---
## Online Presence
>Once we have a basic understanding of the company and its services, we can get a first impression of its presence on the Internet.

### SSL certificate
The first point of presence on the Internet may be the `SSL certificate` from the company's main website that we can examine. Such a certificate includes more than just a subdomain, and this means that the certificate is used for several domains, and these are most likely still active.
![[Pasted image 20260815125952.png]]

### Certificate Transparency
Another source to find more subdomains is [crt.sh](https://crt.sh/). This source is [Certificate Transparency](https://en.wikipedia.org/wiki/Certificate_Transparency) logs. 

> [!info]- Certificate Transparency
Certificate Transparency is a process that is intended to enable the verification of issued digital certificates for encrypted Internet connections. The standard ([RFC 6962](https://tools.ietf.org/html/rfc6962)) provides for the logging of all digital certificates issued by a certificate authority in audit-proof logs. This is intended to enable the detection of false or maliciously issued certificates for a domain. SSL certificate providers like [Let's Encrypt](https://letsencrypt.org/) share this with the web interface [crt.sh](https://crt.sh/), which stores the new entries in the database to be accessed later.

Here is the example of the usage : 
![[Pasted image 20260815130359.png]]

We can also output the format in JSON format. Further info : [HTB-Domain Information](https://academy.hackthebox.com/app/module/112/section/1061)

---
### Company Hosted Servers
> After collecting the subdomains from the method above, we can identify the hosts directly accessible from the Internet and not hosted by third-party providers. This is because we are not allowed to test the hosts without the permission of third-party providers.

```shell
nusss@htb[/htb]$ for i in $(cat subdomainlist);do host $i | grep "has address" | grep inlanefreight.com | cut -d" " -f1,4;done 
```
Output :
```
blog.inlanefreight.com 10.129.24.93 
inlanefreight.com 10.129.27.33 
matomo.inlanefreight.com 10.129.127.22 
www.inlanefreight.com 10.129.127.33 
s3-website-us-west-2.amazonaws.com 10.129.95.250
```
Once we see which hosts can be investigated further, we can generate a list of IP addresses with a minor adjustment to the `cut` command and run them through `Shodan`.

> [!Info]- Shodan
> [Shodan](https://www.shodan.io/) can be used to find devices and systems permanently connected to the Internet like `Internet of Things` (`IoT`). It searches the Internet for open TCP/IP ports and filters the systems according to specific terms and criteria. For example, open HTTP or HTTPS ports and other server ports for `FTP`, `SSH`, `SNMP`, `Telnet`, `RTSP`, or `SIP` are searched. As a result, we can find devices and systems, such as `surveillance cameras`, `servers`, `smart home systems`, `industrial controllers`, `traffic lights` and `traffic controllers`, and various network components.

---
### DNS Records

```shell
dig any <DNS>
```

`dig` is an **DNS lookup tools**, and `any` mean **ANY record type**. Example output : [HTB](https://academy.hackthebox.com/app/module/112/section/1061)

> [!info] Record Types :
> 
|Record|What it stores|Why a pentester cares|
|---|---|---|
|**A**|Hostname → IPv4 address|These are actual machines you may be able to attack|
|**MX**|Which mail servers handle email for the domain|Reveals if email is self-hosted (attackable) or outsourced (out of scope)|
|**NS**|Which name servers answer DNS queries for the domain|Name servers usually belong to the hosting/registrar company → identifies the provider|
|**TXT**|Free-form text; used for domain verification and email security (SPF, DKIM, DMARC)|Leaks which third-party services the company uses|
|**SOA**|Administrative info about the zone (primary NS, admin email, timers)|Minor; gives the admin contact address|


> [!warning] Real Use
>`dig any` mostly doesn't work anymore. RFC 8482 lets resolvers refuse ANY queries, so you'll usually get a near-empty reply. Query record types individually instead (`dig txt inlanefreight.com`, `dig mx ...`, `dig ns ...`).

---
## The Order : 
- [ ] **Collect subdomains** — SSL cert names + crt.sh output → save to `subdomainlist`.
- [ ] **Resolve each one to an IP** — the `for i in $(cat subdomainlist); do host $i ...` loop. A subdomain name alone tells you nothing about who owns the machine; you need the IP first.
- [ ] **Filter to company-owned hosts** — that's what the `grep inlanefreight.com` in the pipeline is doing. It keeps only the lines where the resolved name still belongs to the company, dropping subdomains that are CNAMEs pointing at a provider (S3, Cloudflare, etc.).
- [ ] **Feed the surviving IPs to Shodan** for passive port/service info.