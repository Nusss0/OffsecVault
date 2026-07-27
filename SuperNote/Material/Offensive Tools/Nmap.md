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
| Scan Type        | Flag  |
| ---------------- | ----- |
| SYN scan         | `-sS` |
| UDP scan         | `-sU` |
| TCP Connect scan | `-sT` |
>[!info] A **scan type** tells Nmap _how_ to probe the target — which kind of packets to send and how to read the responses to decide if a port is open, closed, or filtered.

### Options : 
| Command              | Description                                                                                               |
| -------------------- | --------------------------------------------------------------------------------------------------------- |
| `-p <ports(-,)>`     | Scan specific ports                                                                                       |
| `-p-`                | Scan all 65535 ports                                                                                      |
| `-F`                 | Top Ports                                                                                                 |
| `-sV`                | Detect service versions                                                                                   |
| `-sC`                | Run default scripts                                                                                       |
| `-n`                 | Disable DNS Resolutions                                                                                   |
| `-O`                 | Detect OS                                                                                                 |
| `-A`                 | Aggressive (`-sV`, `-O`, scripts, traceroute)                                                             |
| `-Pn`                | Skip ping, treat host as up                                                                               |
| `-v`                 | Verbose output                                                                                            |
| `-sn`                | Disable port scanning                                                                                     |
| `-oN <file>`         | Save output (Normal) to a file                                                                            |
| `-oG <file>`         | Save output (Grepable) to a file                                                                          |
| `-oX <file>`         | Save output (XML) to a file                                                                               |
| `-oA <file>`         | Save output (ALL) to a file                                                                               |
| `-iL <file>`         | Performs defined scans against targets in provided `<file>` list.                                         |
| `--min-rate=<val>`   | stops Nmap from waiting patiently on each silent port. It keeps firing at ≥`<val>` packets/sec regardless |
| `--reason`           | Displays the reason for specific result.                                                                  |
| `--packet-trace`     | Shows all packets sent and received                                                                       |
| `--disable-arp-ping` | disable ARP pings                                                                                         |

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
### Others :
- Saved Format example : [[Saving the Results]]

---
## Related Source : 
[[Service Scanning]]