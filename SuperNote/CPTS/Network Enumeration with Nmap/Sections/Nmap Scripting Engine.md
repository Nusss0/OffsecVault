---
tags:
  - Material
  - HTB
  - CPTS
  - Networking
---
# Nmap Scripting Engine (NSE)

> The Nmap Scripting Engine (NSE) lets you run scripts written in Lua to interact with certain services. Its scripts are divided into 14 categories.

> [!info]- NSE script categories
> | Category | Description |
> | --- | --- |
> | auth | Determination of authentication credentials. |
> | broadcast | Scripts used for host discovery by broadcasting; discovered hosts can be automatically added to the remaining scans. |
> | brute | Executes scripts that try to log in to the respective service by brute-forcing with credentials. |
> | default | Default scripts executed by using the `-sC` option. |
> | discovery | Evaluation of accessible services. |
> | dos | Scripts used to check services for denial of service vulnerabilities; used less as it harms the services. |
> | exploit | Tries to exploit known vulnerabilities for the scanned port. |
> | external | Scripts that use external services for further processing. |
> | fuzzer | Identifies vulnerabilities and unexpected packet handling by sending different fields; can take much time. |
> | intrusive | Intrusive scripts that could negatively affect the target system. |
> | malware | Checks if some malware infects the target system. |
> | safe | Defensive scripts that do not perform intrusive and destructive access. |
> | version | Extension for service detection. |
> | vuln | Identification of specific vulnerabilities. |

---
## Defining Scripts

> There are several ways to specify which NSE scripts Nmap should run.

Default scripts (the `default` category):

```shell
sudo nmap <target> -sC
```

A specific script category:

```shell
sudo nmap <target> --script <category>
```

Individually named scripts:

```shell
sudo nmap <target> --script <script-name>,<script-name>,...
```

---
## SMTP Script Example

> Running the `banner` and `smtp-commands` scripts against an SMTP port to pull extra service information.

```shell
sudo nmap 10.129.2.28 -p 25 --script banner,smtp-commands
```

```shell
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-16 23:21 CEST
Nmap scan report for 10.129.2.28
Host is up (0.050s latency).

PORT   STATE SERVICE
25/tcp open  smtp
|_banner: 220 inlane ESMTP Postfix (Ubuntu)
|_smtp-commands: inlane, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8,
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)
```

| Scanning Option | Description |
| --- | --- |
| `10.129.2.28` | Scans the specified target. |
| `-p 25` | Scans only the specified port. |
| `--script banner,smtp-commands` | Uses the specified NSE scripts. |

The `banner` script reveals the Ubuntu distribution of Linux. The `smtp-commands` script shows which commands the target SMTP server accepts, which may help find existing users on the target.

---
## Aggressive Scan (-A)

> The aggressive option (`-A`) runs multiple scans at once: service detection (`-sV`), OS detection (`-O`), traceroute (`--traceroute`), and the default NSE scripts (`-sC`).

```shell
sudo nmap 10.129.2.28 -p 80 -A
```

```shell
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-17 01:38 CEST
Nmap scan report for 10.129.2.28
Host is up (0.012s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-generator: WordPress 5.3.4
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: blog.inlanefreight.com
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 2.6.32 (96%), Linux 3.2 - 4.9 (96%), Linux 2.6.32 - 3.10 (96%), Linux 3.4 - 3.10 (95%), Linux 3.1 (95%), Linux 3.2 (95%),
AXIS 210A or 211 Network Camera (Linux 2.6.17) (94%), Synology DiskStation Manager 5.2-5644 (94%), Netgear RAIDiator 4.2.28 (94%),
Linux 2.6.32 - 2.6.35 (94%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 1 hop

TRACEROUTE
HOP RTT      ADDRESS
1   11.91 ms 10.129.2.28

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.36 seconds
```

| Scanning Option | Description |
| --- | --- |
| `10.129.2.28` | Scans the specified target. |
| `-p 80` | Scans only the specified port. |
| `-A` | Performs service detection, OS detection, traceroute, and uses default scripts. |

From `-A`, the scan found the web server (Apache 2.4.29), the web application (WordPress 5.3.4), the page title (blog.inlanefreight.com), and that the OS is likely Linux (96%).

---
## Vulnerability Assessment

> The `vuln` category runs all vulnerability-related NSE scripts to find known issues on a service.

```shell
sudo nmap 10.129.2.28 -p 80 -sV --script vuln
```

```shell
Nmap scan report for 10.129.2.28
Host is up (0.036s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-enum:
|   /wp-login.php: Possible admin folder
|   /readme.html: Wordpress version: 2
|   /: WordPress version: 5.3.4
|   /wp-includes/images/rss.png: Wordpress version 2.2 found.
|   /wp-includes/js/jquery/suggest.js: Wordpress version 2.5 found.
|   /wp-includes/images/blank.gif: Wordpress version 2.6 found.
|   /wp-includes/js/comment-reply.js: Wordpress version 2.7 found.
|   /wp-login.php: Wordpress login page.
|   /wp-admin/upgrade.php: Wordpress login page.
|_  /readme.html: Interesting, a readme.
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-wordpress-users:
| Username found: admin
|_Search stopped at ID #25. Increase the upper limit if necessary with 'http-wordpress-users.limit'
| vulners:
|   cpe:/a:apache:http_server:2.4.29:
|       CVE-2019-0211   7.2 https://vulners.com/cve/CVE-2019-0211
|       CVE-2018-1312   6.8 https://vulners.com/cve/CVE-2018-1312
|       CVE-2017-15715  6.8 https://vulners.com/cve/CVE-2017-15715
<SNIP>
```

| Scanning Option | Description |
| --- | --- |
| `10.129.2.28` | Scans the specified target. |
| `-p 80` | Scans only the specified port. |
| `-sV` | Performs service version detection on specified ports. |
| `--script vuln` | Uses all related scripts from the specified category. |

These scripts interact with the web server and its web application to find version information and check various databases for known vulnerabilities.

> [!info]- Reference
> Full list of NSE scripts and categories: https://nmap.org/nsedoc/index.html

---
## Related Source

[[Nmap]], [[SMTP]], [[HTTP]]