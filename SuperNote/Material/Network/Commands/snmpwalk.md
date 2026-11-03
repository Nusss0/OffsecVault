---
tags:
  - Commands
  - Network
  - SNMP
  - Reconnaissance
  - Footprinting
  - Material
---
## Function
> **`snmpwalk`** is a core CLI utility from the Net-SNMP suite used to query network devices running the Simple Network Management Protocol (SNMP). By executing recursive `GETNEXT` requests starting from a root or specific Object Identifier (OID), `snmpwalk` dumps an entire subtree of the Management Information Base (MIB). In penetration testing, it is used to extract running process command-line arguments, user accounts, network interfaces, and installed software without authentication beyond a valid community string.

---
## Syntax
```shell
snmpwalk [options] <Target_IP> [Starting_OID]
```

---
## Options :

| **Flag** | **Argument** | **Description** |
| :---: | :--- | :--- |
| **`-v`** | `1 \| 2c \| 3` | SNMP protocol version to use *(Most common in CTFs/labs: `2c`)*. |
| **`-c`** | `<string>` | Community string for authentication (v1/v2c) *(e.g. `public`, `backup`)*. |
| **`-t`** | `<seconds>` | Request timeout period in seconds *(Default: 1)*. |
| **`-r`** | `<retries>` | Number of retry attempts on timeout *(Default: 5)*. |
| **`-Cc`** | *(None)* | Do not check if returned OIDs are strictly increasing (prevents premature abort on misconfigured tables). |
| **`-O`** | `<format>` | Output formatting options (e.g. `-O n` for numeric OIDs, `-O s` for short names). |
| **`-u`** | `<username>` | Security username (SNMPv3 only). |
| **`-l`** | `<secLevel>` | Security level (SNMPv3: `noAuthNoPriv`, `authNoPriv`, `authPriv`). |

---
## Critical OIDs Cheat Sheet (High-Value Pentest Targets)

Rather than dumping the entire MIB tree (which can span tens of thousands of lines), query these specific OID subtrees for fast reconnaissance:

| Target Category | OID | MIB Object Name | Pentest Value |
| :--- | :--- | :--- | :--- |
| **System Info** | `1.3.6.1.2.1.1` | `system` | OS version, hostname, uptime, contact/admin email. |
| **Network Interfaces** | `1.3.6.1.2.1.2` | `interfaces` | Network cards, MAC addresses, internal IP routing. |
| **Running Process Names** | `1.3.6.1.2.1.25.4.2.1.2` | `hrSWRunName` | Running processes and daemons. |
| **Running Process Paths** | `1.3.6.1.2.1.25.4.2.1.4` | `hrSWRunPath` | Full file paths of active executables/scripts. |
| **Process CLI Parameters** | `1.3.6.1.2.1.25.4.2.1.5` | `hrSWRunParameters` | **Goldmine:** Leaked passwords, tokens, and script arguments. |
| **Installed Software** | `1.3.6.1.2.1.25.6.3.1.2` | `hrSWInstalledName` | Complete list of packages and patch levels (for CVE mapping). |
| **Storage / Mounts** | `1.3.6.1.2.1.25.2.3.1.3` | `hrStorageDescr` | Disks, partitions, and mounted network drives. |

---
## Common Use Cases & Real-World Examples

### 1. Full MIB Dump to File (Recommended Baseline)
Always dump the entire tree to a local text file so you can inspect and grep offline:
```bash
snmpwalk -v2c -c backup 10.129.202.20 > snmp_dump.txt
```

---

### 2. Searching for Leaked Credentials in Process Parameters
Processes often execute scripts with hardcoded credentials or CLI arguments:
```bash
# Query the process parameters OID directly:
snmpwalk -v2c -c backup 10.129.202.20 1.3.6.1.2.1.25.4.2.1.5

# Or grep through the dumped file for sensitive keywords:
grep -Ei "pass|pwd|user|key|secret|token|sh|py" snmp_dump.txt
```

#### Real-World Example Output (from CPTS Hard Lab):
```text
iso.3.6.1.2.1.25.1.7.1.2.1.2.6.66.65.67.75.85.80 = STRING: "/opt/tom-recovery.sh"
iso.3.6.1.2.1.25.1.7.1.2.1.3.6.66.65.67.75.85.80 = STRING: "tom NMds732Js2761"
```
* The process table captured an admin running `/opt/tom-recovery.sh` with plaintext credentials `tom NMds732Js2761`.

---

### 3. Enumerating Installed Packages for Vulnerability Research
Extract all installed software packages on the target host:
```bash
snmpwalk -v2c -c backup 10.129.202.20 1.3.6.1.2.1.25.6.3.1.2 > installed_packages.txt
```
*(Search for outdated versions of Apache, ProFTPD, sudo, or kernel packages).*

---

### 4. Resolving Human-Readable MIB Names
If `snmpwalk` displays raw numeric OIDs (`iso.3.6.1.2.1...`) instead of descriptive names (`hrSWRunName`), enable MIB downloading on Kali/Parrot:
```bash
sudo apt install snmp-mibs-downloader -y
sudo download-mibs
# Comment out 'mibs :' in /etc/snmp/snmp.conf
sudo sed -i 's/^mibs :/mibs +ALL/' /etc/snmp/snmp.conf
```

---
## Related Source : 
- [[_Network Commands]]
- [[onesixtyone]]
- [[CPTS/Footprinting/Footprinting Lab - Hard|Footprinting Lab - Hard]]
- [[CPTS/Footprinting/Sections/SNMP|CPTS Footprinting - SNMP]]
