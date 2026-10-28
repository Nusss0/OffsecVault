---
tags:
  - Tools
  - Networking
---
## Function
>*to scan networks and identify which hosts are available on the network using raw packets, and services and applications, including the name and version, where possible. It can also identify the operating systems and versions of these hosts.*
---
###  Syntax : 
```shell
nmap <scan types> [options] <target>
```

### Scan Types :
| Scan Type               | Flag  |
| ----------------------- | ----- |
| SYN scan                | `-sS` |
| UDP scan                | `-sU` |
| TCP Connect scan        | `-sT` |
| Checking Firewall Exist | `-sA` |
>[!info] A **scan type** tells Nmap _how_ to probe the target — which kind of packets to send and how to read the responses to decide if a port is open, closed, or filtered.

### Options : 
| Command                    | Description                                                                                               |
| -------------------------- | --------------------------------------------------------------------------------------------------------- |
| `-p <ports(-,)>`           | Scan specific ports                                                                                       |
| `-p-`                      | Scan all 65535 ports                                                                                      |
| `-F`                       | Top Ports                                                                                                 |
| `-sV`                      | Detect service versions                                                                                   |
| `-sC`                      | Run default scripts                                                                                       |
| `-n`                       | Disable DNS Resolutions                                                                                   |
| `-O`                       | Detect OS                                                                                                 |
| `-A`                       | Aggressive (`-sV`, `-O`, scripts, traceroute)                                                             |
| `-Pn`                      | Skip ping, treat host as up                                                                               |
| `-v/-vv`                   | Verbose output (Show output directly)                                                                     |
| `-sn`                      | Disable port scanning                                                                                     |
| `-oN <file>`               | Save output (Normal) to a file                                                                            |
| `-oG <file>`               | Save output (Grepable) to a file                                                                          |
| `-oX <file>`               | Save output (XML) to a file                                                                               |
| `-oA <file>`               | Save output (ALL) to a file                                                                               |
| `-iL <file>`               | Performs defined scans against targets in provided `<file>` list.                                         |
| `--min-rate=<val>`         | stops Nmap from waiting patiently on each silent port. It keeps firing at ≥`<val>` packets/sec regardless |
| `--reason`                 | Displays the reason for specific result.                                                                  |
| `--packet-trace`           | Shows all packets sent and received                                                                       |
| `--disable-arp-ping`       | disable ARP pings                                                                                         |
| `--stats-every=<duration>` | Print stats every **x** seconds (`s`) or **x** minutes (`m`)                                              |
| `--script=trace`           | The ability to trace the progress of NSE scripts at the network level                                     |

---
## Extras :

### OS Detection by TTL

| Default TTL | Operating System                        |
| ----------- | --------------------------------------- |
| 64          | Linux / Unix                            |
| 128         | Windows                                 |
| 255         | Cisco / network devices (and some Unix) |

### Filtered Status on Nmap
>When a port is shown as filtered, it can have several reasons. In most cases, firewalls have certain rules set to handle specific connections. The packets can either be `dropped`, or `rejected` by firewalls.

>[!notes] The key difference is :
>- **Dropped** — firewall silently discards your packet.
>- **Rejected** — firewall actively refuses and tells you.

**Dropped :**
```shell
SENT ... TCP ... > ...:139 S ...
SENT ... TCP ... > ...:139 S ...      ← retry, still no reply
```

**Rejected : **
```shell
SENT ... TCP ... > ...:445 S ...
RCVD ... ICMP ... Port 445 unreachable (type=3/code=3) ...   ← the rejection
```

---
## Common NSE Scripts (By Protocol / Service)

Nmap Scripting Engine (NSE) scripts are located in `/usr/share/nmap/scripts/`.

### 1. FTP Scripts (Port 21)
| Script | Purpose |
| :--- | :--- |
| `ftp-anon` | Checks if anonymous FTP login is allowed and lists root files. |
| `ftp-syst` | Sends `STAT` command to get detailed FTP server status & banner. |
| `ftp-vsftpd-backdoor` | Checks for the notorious vsftpd 2.3.4 backdoor. |
| `ftp-proftpd-backdoor` | Checks for known ProFTPD backdoors (e.g. 1.3.3c). |

---

### 2. NFS Scripts (Port 111, 2049)
| Script | Purpose |
| :--- | :--- |
| `nfs-showmount` | Discovers exported NFS shares/directories (like `showmount -e`). |
| `nfs-ls` | Recursively lists files inside NFS shares without manually mounting. |
| `nfs-statfs` | Inspects disk space and share permissions on exported directories. |

---

### 3. SMB Scripts (Port 139, 445)
| Script | Purpose |
| :--- | :--- |
| `smb-os-discovery` | Discovers exact Windows OS version, domain, and computer name. |
| `smb-enum-shares` | Lists available SMB shares and checks anonymous/guest access. |
| `smb-enum-users` | Enumerates Windows local/domain users via SAM/LSA. |
| `smb-security-mode` | Checks if SMB Message Signing is enabled or enforced. |
| `smb-vuln-ms17-010` | Scans for the critical EternalBlue (MS17-010) vulnerability. |

---

### 4. DNS Scripts (Port 53)
| Script | Purpose |
| :--- | :--- |
| `dns-zone-transfer` | Attempts AXFR zone transfer to retrieve all DNS records. |
| `dns-nsid` | Queries Name Server ID (NSID) to fingerprint DNS implementation. |
| `dns-brute` | Brute-forces common subdomains. |

---

### 5. SMTP Scripts (Port 25)
| Script | Purpose |
| :--- | :--- |
| `smtp-enum-users` | Enumerates valid user mailboxes using `VRFY`, `EXPN`, or `RCPT TO`. |
| `smtp-commands` | Interrogates server features via `EHLO` (checks for `AUTH LOGIN`). |
| `smtp-open-relay` | Tests if the mail server allows unauthenticated external relaying. |

---

### 6. SSH Scripts (Port 22)
| Script | Purpose |
| :--- | :--- |
| `ssh-auth-methods` | Checks permitted auth methods (e.g. `publickey` vs `password`). |
| `ssh-hostkey` | Grabs SSH target public host key and fingerprint. |

---

### Others :
- Saved Format example : [[Saving the Results]]
- Script Categories: `default` (`-sC`), `vuln`, `safe`, `discovery`, `auth`, `brute`.
---
## Related Source : 
[[Service Scanning]], [[CrackMapExec]], [[ftp]], [[smbclient]]