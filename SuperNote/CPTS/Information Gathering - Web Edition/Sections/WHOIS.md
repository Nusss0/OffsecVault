---
tags:
  - CPTS
  - Material
  - HTB
  - Recon
  - WHOIS
---
> Source : [HTB Academy - Information Gathering - Web Edition (WHOIS)](https://academy.hackthebox.com/app/module/144/section/3073)

---
## About WHOIS
> **WHOIS** (typically operating over **TCP port 43**) is a widely used query and response protocol designed to access databases that store information about registered internet resources. While primarily associated with **domain names**, WHOIS also provides details about **IP address blocks** and **Autonomous Systems (ASNs)** — acting as a public "phonebook" for the internet.

### Basic Usage
```shell
whois <domain_or_IP>
```

Example query against `inlanefreight.com`:
```shell
nusss@htb[/htb]$ whois inlanefreight.com
[...]
Domain Name: inlanefreight.com
Registry Domain ID: 2420436757_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.registrar.amazon
Registrar URL: https://registrar.amazon.com
Updated Date: 2023-07-03T01:11:15Z
Creation Date: 2019-08-05T22:43:09Z
[...]
```

---
## Key Fields in a WHOIS Record

| Field | Description |
| :--- | :--- |
| **Domain Name** | The registered domain name itself (e.g., `example.com`). |
| **Registrar** | The company through which the domain was registered (e.g., GoDaddy, Namecheap, Amazon Registrar). |
| **Registrant Contact** | The individual or organization that legally owns/registered the domain. |
| **Administrative Contact** | The person responsible for administrative and policy management of the domain. |
| **Technical Contact** | The person/team handling technical operations and DNS issues for the domain. |
| **Creation & Expiration Dates** | Timestamps showing when the domain was initially registered, last updated, and when it is set to expire. |
| **Name Servers** | Authoritative DNS servers responsible for translating the domain name into IP addresses. |

---
## History & Evolution of WHOIS

> [!info]- History of WHOIS (1970s – Present)
> 1. **1970s — ARPANET & NIC**: Created by [Elizabeth Feinler](https://en.wikipedia.org/wiki/Elizabeth_J._Feinler) and her team at the Stanford Research Institute's Network Information Center (`NIC`) to track network users, hostnames, and domain names on the ARPANET.
> 2. **1982 — Formalisation (`RFC 812`)**: Standardized by Ken Harrenstien and Vic White at the NIC, defining the formal WHOIS query-response mechanism.
> 3. **1990s — Distributed WHOIS & RIRs**: As the internet grew exponentially, the centralized model was replaced by **Regional Internet Registries (RIRs)** (with key contributions from Randy Bush and John Postel), decentralizing resource management into regional zones.
> 4. **1998 — ICANN & UDRP**: The formation of the **Internet Corporation for Assigned Names and Numbers (ICANN)** (spearheaded by Vint Cerf) standardized global DNS and WHOIS policies and introduced the **Uniform Domain-Name Dispute-Resolution Policy (UDRP)** to arbitrate cybersquatting and trademark disputes.
> 5. **2018–Present — Privacy, GDPR & RDAP**: Growing privacy concerns and the implementation of the **General Data Protection Regulation (GDPR)** in 2018 led to widespread redaction/masking of personal PII in public WHOIS outputs. Modern initiatives like the **Registration Data Access Protocol (RDAP)** provide a more structured (JSON-based), granular, and privacy-conscious replacement for legacy WHOIS.

---
## Why WHOIS Matters for Web Recon
WHOIS records provide valuable intelligence during passive reconnaissance:

1. **Identifying Key Personnel**:
   - Unmasked WHOIS records can reveal names, corporate email addresses, physical addresses, and phone numbers of individuals managing the domain.
   - Useful for **social engineering**, **spear-phishing campaigns**, or identifying username/email naming conventions.
2. **Discovering Network Infrastructure**:
   - Technical fields such as **Name Servers**, **Registrar**, and **IP netblocks** reveal where DNS and infrastructure are hosted (e.g., AWS, Cloudflare, or self-hosted name servers), helping identify potential entry points or misconfigurations.
3. **Historical Data Analysis**:
   - Even if current WHOIS data is masked by privacy services or GDPR, historical WHOIS platforms (such as [WhoisFreaks](https://whoisfreaks.com/), SecurityTrails, or DomainTools) often retain older snapshots recorded *before* privacy guards were enabled, exposing original registrants, legacy mail servers, or historical IP ranges.

---
## Related Source
- [[Web Reconnaissance]]
- [[Domain Information]]
