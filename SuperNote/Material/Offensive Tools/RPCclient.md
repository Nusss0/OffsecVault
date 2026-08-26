---
tags:
  - Tools
  - Networking
  - Enumeration
---
## Definition
>**`rpcclient`** is a command-line utility used to execute Microsoft Remote Procedure Call (MS-RPC) functions on a remote Windows or Samba server. It acts as an interactive client that allows you to query the server for detailed system information, such as domain users, groups, security identifiers (SIDs), and password policies.
---
##  Syntax : 
```shell
rpcclient [options] <IP/DNS>
```

### Options : 
| **Flag** | **Argument**            | **Description**                                                                                              |
| -------- | ----------------------- | ------------------------------------------------------------------------------------------------------------ |
| `-U`     | `<username>[%password]` | Specifies the username (and optionally password) to authenticate with. Use `-U ""` for a null/blank session. |
| `-N`     | None                    | Forces `rpcclient` to not ask for a password (useful for attempting anonymous or null sessions).             |
| `-c`     | `<command_string>`      | Executes a specific internal command and exits immediately. Great for single-line enumeration scripts.       |
| `-W`     | `<workgroup_or_domain>` | Specifies the Active Directory domain or workgroup name.                                                     |
| `-p`     | `<port>`                | Connects to a specific port. By default, it targets port 139 or 445.                                         |
|          |                         |                                                                                                              |
### Others :
- For further information please use manual page.

---
## Inside RPCclient
```shell
rpcclient $>
```

### Useful Command
| **Command**       | **Arguments** | **Description**                                                                                        |
| ----------------- | ------------- | ------------------------------------------------------------------------------------------------------ |
| `srvinfo`         | None          | Server information. (Displays basic information about the remote server like OS version and hostname). |
| `enumdomains`     | None          | Enumerates all domains that are deployed in the network.                                               |
| `querydominfo`    | None          | Provides domain, server, and user information of deployed domains.                                     |
| `netshareenumall` | None          | Enumerates all available shares on the target.                                                         |
| `netsharegetinfo` | `<share>`     | Provides information about a specific share.                                                           |
| `enumdomusers`    | None          | Enumerates all domain users. (Outputs their usernames and RIDs).                                       |
| `enumdomgroups`   | None          | Enumerates all groups in the domain or local system along with their RIDs.                             |
| `queryuser`       | `<RID>`       | Provides detailed information about a specific user using their RID.                                   |
| `querygroup`      | `<RID>`       | Displays detailed information about a specific group using its RID.                                    |
| `lookupnames`     | `<username>`  | Resolves a username to its corresponding SID (Security Identifier).                                    |
| `lookupsids`      | `<SID>`       | Resolves a SID back to its corresponding username.                                                     |
| `getdompwinfo`    | None          | Retrieves the domain's password policy (e.g., minimum length, complexity requirements).                |
| `enumprivs`       | None          | Enumerates the privileges of the currently authenticated user on the remote system.                    |
| `quit` or `exit`  | None          | Closes the connection and exits the `rpcclient` session.                                               |

---
## Related Source : 
[[SMB]]