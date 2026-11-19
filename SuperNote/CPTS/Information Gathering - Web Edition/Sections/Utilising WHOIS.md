---
tags:
  - CPTS
  - Material
  - HTB
  - Recon
  - WHOIS
---
> Source : [HTB Academy - Information Gathering - Web Edition (Utilising WHOIS)](https://academy.hackthebox.com/app/module/144/section/1248)

---
## Practical Scenarios for WHOIS Data
> WHOIS records provide critical context across both defensive investigations and offensive reconnaissance.

| Scenario | Context | Key WHOIS Indicators Found | Actionable Outcome |
| :--- | :--- | :--- | :--- |
| **1. Phishing Investigation** | Security gateway flags an email claiming to be from a bank urging employees to click a link. | - **Registration Date**: Registered just a few days ago.<br>- **Registrant**: Hidden behind a privacy service.<br>- **Name Servers**: Associated with a known bulletproof hosting provider. | Strong indicators of a freshly spun-up phishing domain. IT blocks the domain, alerts employees, and pivots on the hosting provider/IPs to uncover related phishing infrastructure. |
| **2. Malware Analysis** | Researcher analyses malware communicating with a remote Command-and-Control (`C2`) domain. | - **Registrant**: Individual using an anonymous free email service.<br>- **Location**: Address in a jurisdiction with high cybercrime prevalence.<br>- **Registrar**: Known for lax abuse policies. | Confirms the C2 is hosted on compromised or bulletproof infrastructure; researcher identifies the upstream hosting provider to report abuse. |
| **3. Threat Intelligence Report** | Analysts track domains used across historical campaigns by an APT / financial threat group. | - **Registration Dates**: Registered in clusters right before major attacks.<br>- **Registrants**: Reused aliases and fake identities.<br>- **Name Servers**: Shared across multiple domains.<br>- **Takedown History**: Prior law enforcement/security seizures. | Builds a profile of the threat actor's **TTPs** (Tactics, Techniques, and Procedures) and generates **Indicators of Compromise (IOCs)** to proactively block future campaigns. |

---
## Using the `whois` CLI Tool

### 1. Installation
```shell
sudo apt update
sudo apt install whois -y
```

### 2. Querying a Target Domain (`facebook.com`)
```shell
nusss@htb[/htb]$ whois facebook.com
Domain Name: FACEBOOK.COM
Registry Domain ID: 2320948_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.registrarsafe.com
Registrar URL: http://www.registrarsafe.com
Updated Date: 2024-04-24T19:06:12Z
Creation Date: 1997-03-29T05:00:00Z
Registry Expiry Date: 2033-03-30T04:00:00Z
Registrar: RegistrarSafe, LLC
Registrar IANA ID: 3237
Registrar Abuse Contact Email: abusecomplaints@registrarsafe.com
Registrar Abuse Contact Phone: +1-650-308-7004
Domain Status: clientDeleteProhibited https://icann.org/epp#clientDeleteProhibited
Domain Status: clientTransferProhibited https://icann.org/epp#clientTransferProhibited
Domain Status: clientUpdateProhibited https://icann.org/epp#clientUpdateProhibited
Domain Status: serverDeleteProhibited https://icann.org/epp#serverDeleteProhibited
Domain Status: serverTransferProhibited https://icann.org/epp#serverTransferProhibited
Domain Status: serverUpdateProhibited https://icann.org/epp#serverUpdateProhibited
Name Server: A.NS.FACEBOOK.COM
Name Server: B.NS.FACEBOOK.COM
Name Server: C.NS.FACEBOOK.COM
Name Server: D.NS.FACEBOOK.COM
DNSSEC: unsigned
URL of the ICANN Whois Inaccuracy Complaint Form: https://www.icann.org/wicf/
>>> Last update of whois database: 2024-06-01T11:24:10Z <<<
[...]
Registry Registrant ID: 
Registrant Name: Domain Admin
Registrant Organization: Meta Platforms, Inc.
[...]
```

---
## Analysing the WHOIS Output

1. **Domain Registration**:
   - **Registrar**: `RegistrarSafe, LLC` (IANA ID: `3237`)
   - **Creation Date**: `1997-03-29`
   - **Expiry Date**: `2033-03-30`
   - *Insight*: Long-standing registration and a distant expiration date confirm an established, legitimate corporate asset.
2. **Domain Owner**:
   - **Registrant / Admin / Tech Organization**: `Meta Platforms, Inc.`
   - **Registrant / Admin / Tech Contact**: `Domain Admin`
   - *Insight*: Confirms corporate ownership (`Meta Platforms, Inc.`) using a generic role account (`Domain Admin`) rather than exposing individual employee names.
3. **Domain Status (EPP Status Codes)**:
   - `clientDeleteProhibited`, `clientTransferProhibited`, `clientUpdateProhibited`
   - `serverDeleteProhibited`, `serverTransferProhibited`, `serverUpdateProhibited`
   - *Insight*: Both registrar-level (`client*`) and registry-level (`server*`) locks are enforced to prevent unauthorized domain hijacking, modification, or deletion.
4. **Name Servers**:
   - `A.NS.FACEBOOK.COM` – `D.NS.FACEBOOK.COM`
   - *Insight*: Custom, self-hosted authoritative name servers within the `facebook.com` zone show that Meta manages its own DNS infrastructure directly.

> [!tip] Combining Recon Techniques
> While corporate WHOIS records often use generic role accounts (like `Domain Admin`) and may not directly expose individual employees or specific vulnerabilities, combining WHOIS findings (such as custom name servers, admin contact domains, and IP netblocks) with DNS enumeration and OSINT provides a complete picture of the target's attack surface.

---
## Questions
[[WHOIS Questions]]

---
## Related Source
- [[WHOIS]]
- [[Web Reconnaissance]]
