---
tags:
  - Offensive-Tools
  - Network
  - SNMP
  - Brute-Force
  - Footprinting
  - Material
---
## Function
> **`onesixtyone`** is an ultra-fast, lightweight SNMP scanner and community string brute-forcing tool. By sending asynchronous UDP requests to port 161, it can scan thousands of community strings against single targets or entire class C subnets in seconds. In penetration testing, it is the primary reconnaissance tool to identify responsive SNMP agents and obtain valid *read* or *write* community strings.

---
## Syntax
```shell
onesixtyone [options] <Target_IP_or_Subnet> [community]
```

---
## Options :

| **Flag** | **Argument** | **Description** |
| :---: | :--- | :--- |
| **`-c`** | `<file>` | Path to wordlist of community strings to test *(e.g., SecLists `snmp.txt`)*. |
| **`-i`** | `<file>` | Path to target IP list file for multi-host scanning. |
| **`-o`** | `<file>` | Output scan results to a log file. |
| **`-p`** | `<port>` | Target UDP port number *(Default: 161)*. |
| **`-d`** | *(None)* | Debug mode: prints all sent and received packets. |
| **`-w`** | `<millisec>` | Wait time in milliseconds between sending packets *(Default: 10ms)*. |
| **`-q`** | *(None)* | Quiet mode: do not print progress or statistics. |

---
## Common Use Cases & Real-World Examples

### 1. Quick Scan with Built-In Community Strings
If no community file is provided, `onesixtyone` tests common built-in defaults (`public`, `private`):
```bash
onesixtyone 10.129.202.20
```

---

### 2. Brute-Force with SecLists Dictionary
Test thousands of standard community strings to find weak or non-standard passphrases (e.g. `backup`, `manager`, `internal`):
```bash
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt 10.129.202.20
```
*(Alternative dictionary path:* `/usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt`*)*

#### Typical Output & How to Read It:
```text
Scanning 1 hosts, 3219 communities
10.129.202.20 [backup] Linux NIXHARD 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64
```
* **`10.129.202.20`:** Target host IP.
* **`[backup]`:** **Valid Community String discovered.** Use this string as the passphrase for subsequent `snmpwalk` or `snmp-check` commands.
* **`Linux NIXHARD ...`:** System description (`sysDescr.0`) banner returned by the server, disclosing OS distribution, hostname, and kernel version.

---

### 3. Subnet / Mass Network Sweep
Scan a list of multiple hosts or an entire internal subnet:
```bash
# Scan from an IP list:
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt -i live_hosts.txt -o snmp_sweep.log

# Scan a full /24 network:
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt 192.168.1.0/24
```

---

### 4. Next Step After Finding a Community String
Once a valid community string is identified:
```bash
# 1. Walk the entire MIB tree:
snmpwalk -v2c -c <community_string> <Target_IP>

# 2. Or generate a structured overview with snmp-check:
snmp-check <Target_IP> -c <community_string>
```

---
## Related Source : 
- [[_Offensive Tools]]
- [[snmpwalk]]
- [[CPTS/Footprinting/Footprinting Lab - Hard|Footprinting Lab - Hard]]
- [[CPTS/Footprinting/Sections/SNMP|CPTS Footprinting - SNMP]]
