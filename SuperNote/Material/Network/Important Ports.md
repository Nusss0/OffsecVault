---
tags:
  - Network
  - Ports
  - Footprinting
  - Reconnaissance
  - Material
---
## Function
> A curated reference guide to essential network ports encountered during penetration testing and footprinting. Knowing the standard port numbers, associated transport protocols, authentication mechanisms, and primary attack/enumeration angles allows a pentester to quickly prioritize open attack surfaces.

---
## Quick Reference Table

|    Port    | Protocol / Service                | Transport | Default Auth / Mechanism    | Primary Footprinting & Attack Angle                                                                           |
| :--------: | :-------------------------------- | :-------: | :-------------------------- | :------------------------------------------------------------------------------------------------------------ |
|  **`21`**  | **FTP** *(File Transfer)*         |    TCP    | Plaintext credentials       | Anonymous login (`anonymous:anonymous`), cleartext credential sniffing, file upload/download.                 |
|  **`22`**  | **SSH** *(Secure Shell)*          |    TCP    | Public key / Password       | Encrypted remote shell, public key auth (`id_rsa`), password brute-force, password reuse.                     |
|  **`25`**  | **SMTP** *(Simple Mail Transfer)* |    TCP    | Cleartext / `AUTH LOGIN`    | Mail routing, user mailbox enumeration (`VRFY`/`EXPN`/`RCPT TO`), Open Relay testing.                         |
|  **`53`**  | **DNS** *(Domain Name System)*    | UDP / TCP | None (Standard queries)     | Name resolution (UDP), Zone Transfer AXFR (`dig axfr`, TCP), subdomain brute-forcing, DNS exfiltration.       |
|  **`80`**  | **HTTP** *(Web)*                  |    TCP    | Anonymous / Basic Auth      | Web applications, web configuration leakage, directory/vhost fuzzing, CMS vulnerabilities.                    |
| **`110`**  | **POP3** *(Mail Retrieval)*       |    TCP    | Plaintext credentials       | Downloading mailbox emails to client, credential brute-forcing.                                               |
| **`111`**  | **RPCBind** *(Portmapper)*        | TCP / UDP | None                        | Maps UNIX RPC programs to port numbers; enumerates active RPC services and NFS mounts.                        |
| **`135`**  | **MSRPC** *(Microsoft RPC)*       |    TCP    | Windows NTLM / Kerberos     | Windows endpoint mapper; user/group/domain enumeration, DCOM interface interaction.                           |
| **`139`**  | **NetBIOS-SSN**                   |    TCP    | Windows Auth                | Legacy SMB over NetBIOS; Windows workgroup, computer name, and share discovery.                               |
| **`143`**  | **IMAP** *(Mail Sync)*            |    TCP    | Plaintext / TLS             | Email synchronization directly on server, credential authentication.                                          |
| **`443`**  | **HTTPS** *(HTTP Secure)*         |    TCP    | TLS / SSL Certificate       | Encrypted web applications; SSL certificate inspection (discloses internal domain names & admin emails).      |
| **`445`**  | **SMB** *(Direct Host / CIFS)*    |    TCP    | Windows NTLM / Kerberos     | Core Windows file sharing; Null sessions, readable/writable shares, SAM/LSA hash dumping, Pass-the-Hash.      |
| **`1433`** | **MSSQL** *(SQL Server)*          |    TCP    | Windows Auth / SQL Login    | Database engine; default sysadmin account `sa`, OS command execution via `xp_cmdshell`.                       |
| **`2049`** | **NFS** *(Network File System)*   | TCP / UDP | UNIX UID Matching (No Pass) | Remote network drive mounting; root squashing (`nobody:nogroup`), client-side UID spoofing.                   |
| **`3306`** | **MySQL**                         |    TCP    | MySQL Native Password       | Relational database queries; unauthenticated default `root` access, data exfiltration.                        |
| **`3389`** | **RDP** *(Remote Desktop)*        | TCP / UDP | Windows Credentials         | Full graphical desktop GUI access (`ms-wbt-server`); interactive administrative sessions.                     |
| **`5985`** | **WinRM HTTP**                    |    TCP    | Windows NTLM / Kerberos     | Remote PowerShell execution on Windows; requires membership in `Administrators` or `Remote Management Users`. |
| **`5986`** | **WinRM HTTPS**                   |    TCP    | TLS + Windows Auth          | Encrypted WinRM channel over SSL/TLS.                                                                         |

---
## Protocol Characteristics & Footprinting Notes

### File Transfer & Storage
* **FTP (`21`)**: Uses dual channels — Control channel on port 21 and Data channel on port 20 (Active mode) or a negotiated dynamic unprivileged port (Passive mode). Highly prone to anonymous read/write misconfigurations.
* **NFS (`2049` & `111`)**: Does not use passwords. Relies strictly on UNIX numeric UIDs. If exported with `no_root_squash`, client root retains superuser privileges; otherwise root is squashed to `nobody`.
* **SMB (`445` & `139`)**: Core vector in Windows and Active Directory environments. Permits null sessions (empty user and password) if misconfigured, revealing network shares, domain users, and password policies.

### Remote Administration
* **SSH (`22`)**: Standard on Linux. Password login is frequently disabled in favor of RSA/Ed25519 key authentication (`id_rsa` mapped to `authorized_keys`).
* **WinRM (`5985` / `5986`)**: Windows equivalent of SSH for remote PowerShell management. Standard users are denied access by default unless explicitly granted remote management rights.
* **RDP (`3389`)**: Provides remote graphical desktop access. Critical target for password reuse attacks to gain interactive GUI access to management consoles (e.g., SSMS, internal tools).

### Mail & Name Services
* **DNS (`53`)**: Standard queries use UDP. TCP port 53 is used for Zone Transfers (AXFR) or queries larger than 512 bytes. Unrestricted zone transfers reveal the entire internal network map.
* **SMTP (`25`)**: Protocol for sending mail. Supports user enumeration via legacy commands (`VRFY`, `EXPN`) and authentication via ESMTP `AUTH LOGIN` (Base64 encoded).

### Databases
* **MSSQL (`1433` / UDP `1434`)**: Microsoft SQL Server. The default superuser is `sa`. Often configured to listen only on `localhost` or protected by firewall from external access, requiring local execution (via SMB `sqlcmd`) or RDP access.
* **MySQL (`3306`)**: Popular open-source database. Often misconfigured with default empty passwords for the `root` user or exposed externally on development servers.

---
## Related Source : 
[[Nmap]], [[CrackMapExec]], [[Material/Network/Commands/ftp|ftp]], [[Material/Network/Commands/smbclient|smbclient]], [[SQL Syntax & Footprinting]]
