---
tags:
  - CPTS
  - Material
  - HTB
  - Recon
---
> Source : [HTB Academy - Information Gathering - Web Edition (Introduction)](https://academy.hackthebox.com/app/module/144/section/1247)

---
## Overview
> **Web Reconnaissance** is the foundation of a thorough security assessment. It involves systematically and meticulously collecting information about a target website or web application before delving into deeper analysis and potential exploitation. It forms a critical part of the [[Penetration Testing Phase - Information Gathering|Information Gathering]] phase of the Penetration Testing Process.

### Primary Goals of Web Reconnaissance
1. **Identifying Assets**: Uncovering all publicly accessible components of the target, such as web pages, subdomains, IP addresses, and technologies used, to build a comprehensive overview of the target's online presence.
2. **Discovering Hidden Information**: Locating sensitive data inadvertently exposed, including backup files, configuration files, hidden directories, or internal documentation that can reveal insights and entry points.
3. **Analysing the Attack Surface**: Examining the target's technologies, configurations, open ports, and services to identify potential vulnerabilities, weaknesses, and entry points for exploitation.
4. **Gathering Intelligence**: Collecting information (such as key personnel, email addresses, or patterns of behaviour) that can be leveraged for further technical exploitation or social engineering attacks.

> [!info] Offensive vs. Defensive Perspective
> - **Attackers** leverage reconnaissance to tailor their attacks, target specific weaknesses, and bypass security measures.
> - **Defenders** use reconnaissance to audit their own footprint, proactively identifying and patching exposures before malicious actors can exploit them.

---
## Types of Reconnaissance
Web reconnaissance is divided into two fundamental methodologies: **Active Reconnaissance** and **Passive Reconnaissance**.

| Methodology | Interaction with Target | Risk of Detection | Key Characteristics |
| :--- | :--- | :---: | :--- |
| **Active Reconnaissance** | Direct interaction (sending requests/probes to target systems) | **Medium to High** | Provides a direct and comprehensive view of infrastructure and security posture, but can trigger IDS/IPS, firewalls, WAFs, or security logs. |
| **Passive Reconnaissance** | No direct interaction (relies on publicly available/third-party data) | **Very Low** | Stealthier and unlikely to trigger alarms, though findings are limited to what is already publicly accessible or indexed. |

---
## 1. Active Reconnaissance
> In **active reconnaissance**, the tester directly interacts with the target system to gather information.

| Technique | Description | Example | Tools | Risk of Detection |
| :--- | :--- | :--- | :--- | :--- |
| **Port Scanning** | Identifying open ports and services running on the target. | Scanning a web server for open ports like `80` (HTTP) and `443` (HTTPS). | [[Nmap]], `Masscan`, `Unicornscan` | **High**: Direct interaction can trigger IDS and firewalls. |
| **Vulnerability Scanning** | Probing the target for known vulnerabilities, outdated software, or misconfigurations. | Scanning a web application for SQL injection (SQLi) or Cross-Site Scripting (XSS) flaws. | `Nessus`, `OpenVAS`, `Nikto` | **High**: Scanners send noisy exploit payloads easily detected by security solutions. |
| **Network Mapping** | Mapping the target's network topology, connected devices, and routing relationships. | Determining the packet path to reach the target server, revealing network hops and infrastructure. | `traceroute`, [[Nmap]] | **Medium to High**: Excessive or unusual traffic can raise suspicion. |
| **Banner Grabbing** | Retrieving metadata from banners displayed by running services. | Connecting to port `80` and inspecting the HTTP response header/banner for web server software and version. | `Netcat` (`nc`), `curl` | **Low**: Minimal interaction, though connections are still logged. |
| **OS Fingerprinting** | Identifying the underlying operating system of the target host. | Using TCP/IP stack fingerprinting (`nmap -O`) to determine if the host runs Windows or Linux. | [[Nmap]], `Xprobe2` | **Low**: Mostly low-noise, though advanced active probes can be detected. |
| **Service Enumeration** | Determining exact versions of services listening on open ports. | Using `nmap -sV` to identify `Apache 2.4.50` or `Nginx 1.18.0`. | [[Nmap]] | **Low**: Similar to banner grabbing; logged as standard traffic and less likely to trigger alerts. |
| **Web Spidering** | Crawling the target website to map web pages, directories, links, and files. | Running a crawler to map out website structure and discover hidden resources. | `Burp Suite Spider`, `OWASP ZAP Spider`, `Scrapy` | **Low to Medium**: Detectable if crawler speed/headers are not configured to mimic legitimate user traffic. |

---
## 2. Passive Reconnaissance
> In **passive reconnaissance**, the tester gathers information without directly interacting with the target, relying on publicly available resources and Open-Source Intelligence (`OSINT`).

| Technique | Description | Example | Tools | Risk of Detection |
| :--- | :--- | :--- | :--- | :--- |
| **Search Engine Queries** | Using search engines and advanced operators (Google Dorks) to uncover pages, files, profiles, and articles. | Searching Google for `"[Target Name] employees"` or indexed sensitive files. | `Google`, `DuckDuckGo`, `Bing`, `Shodan` | **Very Low**: Queries go to the search engine, not the target. |
| **WHOIS Lookups** | Querying WHOIS databases to retrieve domain registration and ownership details. | Looking up a target domain to find registrant name, contact info, registrar, and name servers. | `whois` CLI, online WHOIS lookup services | **Very Low**: Queries hit public WHOIS registries and do not alert the target. |
| **DNS Analysis** | Analysing DNS records to identify subdomains, mail servers, and hosting infrastructure. | Using `dig` against public resolvers or passive DNS sources to enumerate records and subdomains. | `dig`, `nslookup`, `host`, `dnsenum`, `fierce`, `dnsrecon` | **Very Low**: Standard DNS resolution is essential for normal internet browsing (unless brute-forcing the target's authoritative NS directly). |
| **Web Archive Analysis** | Examining historical snapshots of the target's website to spot changes, old endpoints, or leaked info. | Viewing past versions of a target website to see how it evolved over time. | `Wayback Machine` (`web.archive.org`) | **Very Low**: Traffic stays between the tester and the Internet Archive. |
| **Social Media Analysis** | Gathering intelligence from social platforms about personnel, tech stacks, and org structure. | Searching LinkedIn for target employees to learn roles, tech stacks used in job descriptions, and social engineering targets. | `LinkedIn`, `Twitter/X`, `Facebook`, OSINT tools | **Very Low**: Accessing public profiles is non-intrusive. |
| **Code Repositories** | Analysing public repositories for exposed credentials, API keys, internal URLs, or code vulnerabilities. | Searching GitHub for target-related repositories or commits containing secrets. | `GitHub`, `GitLab` | **Very Low**: Searching public repositories does not interact with target infrastructure. |

---
## Related Source
- [[Penetration Testing Phase - Information Gathering]]
- [[Enumeration Principles]]
- [[Domain Information]]
