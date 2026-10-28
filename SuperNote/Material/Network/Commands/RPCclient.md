---
tags:
  - Commands
  - Networking
  - MSRPC
  - Enumeration
  - Active-Directory
  - Material
---
## Function
> **`rpcclient`** is a command-line utility used to execute Microsoft Remote Procedure Call (MS-RPC) functions against Windows and Samba servers over TCP port 135 or port 445 (via Named Pipes). Unlike `smbclient` which interacts with files, `rpcclient` is specifically designed for **identity and domain intelligence gathering** (enumerating domain users, groups, security identifiers/SIDs, and password policies).

---
## Syntax
```shell
rpcclient [options] <Target_IP_or_Hostname>
```

---
## Options :

| **Flag** | **Argument** | **Description** |
| :---: | :--- | :--- |
| **`-U`** | `<user>[%pass]` | Username and optional password. Use `-U ""` for a null/blank session. |
| **`-N`** | None | Suppress password prompt (ideal for null session attempts). |
| **`-c`** | `<command>` | **One-liner execution**. Executes a specific RPC command and exits immediately. |
| **`-W`** | `<domain>` | Specify domain or workgroup name. |
| **`-p`** | `<port>` | Target port (default targets 445 or 139). |

---
## Commands Inside RPCclient (`rpcclient $>`)

| **Command** | **Description** |
| :--- | :--- |
| `srvinfo` | Displays server OS version, build, and hostname. |
| `enumdomusers` | **Enumerates all domain/local users** along with their relative IDs (RIDs). |
| `enumdomgroups` | Enumerates all domain/local security groups. |
| `queryuser <RID>` | Displays detailed user profile (bad password count, logon scripts, group memberships). |
| `querygroup <RID>` | Displays group details and member count. |
| `querygroupmem <RID>` | Lists all member RIDs belonging to a specific group (e.g. Domain Admins). |
| `getdompwinfo` | **Retrieves password policy** (minimum password length, complexity, lockout threshold). |
| `lookupnames <username>` | Resolves a username to its corresponding SID. |
| `lookupsids <SID>` | Resolves a SID back to its plaintext username (useful for RID cycling). |
| `netshareenumall` | Lists all shared folders on the host. |
| `quit` / `exit` | Closes RPC session. |

---
## Common Use Cases & Real-World Examples

### 1. Anonymous User Harvesting (Null Session)
Extract a full list of valid usernames without having any credentials:
```bash
# Connect with null session:
rpcclient -U "" -N 10.129.202.41
```
Inside the session:
```text
rpcclient $> enumdomusers
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[alex] rid:[0x3e9]
user:[HTB] rid:[0x3ea]
```

### 2. Automated One-Liner User List Generation (`-c`)
Dump users directly to a text file for password spraying wordlists:
```bash
rpcclient -U "" -N 10.129.202.41 -c "enumdomusers" | awk -F'[' '{print $2}' | awk -F']' '{print $1}' > users.txt
```

### 3. Checking Password Policy Before Spraying
Avoid account lockouts by checking the lockout threshold before launching brute-force attacks:
```bash
rpcclient -U 'alex%lol123!mD' 10.129.202.41 -c "getdompwinfo"
```
*Output tells you minimum password length and if accounts lock after failed attempts.*

### 4. Inspecting Privileges of a Specific User (via RID)
```bash
# User alex has RID 1001 (0x3e9):
rpcclient -U 'alex%lol123!mD' 10.129.202.41 -c "queryuser 0x3e9"
```

---
## Related Source : 
[[_Network Commands|Network Commands]], [[Material/Network/Commands/smbclient|smbclient]], [[CrackMapExec]], [[Enum4Linux-ng]], [[Material/Network/Important Ports|Important Ports]]
