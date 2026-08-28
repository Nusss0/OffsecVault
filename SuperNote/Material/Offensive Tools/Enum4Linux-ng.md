---
tags:
  - Networking
  - Tools
  - Enumeration
  - Python
---
## Definition
>*a modern, actively maintained Python 3 rewrite of the classic penetration testing tool `enum4linux` (which was written in Perl). It acts as a wrapper around standard Samba tools (such as `smbclient`, `rpcclient`, `net`, and `nmblookup`) to extract a wealth of information from Windows and Samba systems over SMB and LDAP.*
---
##  Syntax : 
```shell
./enum4linux-ng.py <IP> <OPTIONS>
```

### Options : 
| **Flag**        | **Description**                                                                                                                       |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `-A`            | Do **all** simple enumeration (Users, Groups, Shares, Policies, OS). This runs automatically if you don't provide any specific flags. |
| `-U`            | Get the user list via RPC.                                                                                                            |
| `-S`            | Get the list of shares via RPC.                                                                                                       |
| `-G`            | Get the list of groups via RPC.                                                                                                       |
| `-P`            | Get the domain or local password policy.                                                                                              |
| `-u [Username]` | Specify the username to authenticate with. Omitting it defaults to a null (anonymous) session `""`.                                   |
| `-p [Password]` | Specify the password to authenticate with.                                                                                            |
| `-H [NTHash]`   | Pass-the-Hash: Authenticate using an NTLM hash instead of a cleartext password.                                                       |
| `-R`            | Perform RID cycling to extract users and groups. Highly useful when the target restricts anonymous RPC enumeration.                   |
| `-oJ <File>`    | Writes the output to a JSON file.                                                                                                     |
| `-oY <File>`    | Writes the output to a YAML file.                                                                                                     |

### Others :
- Install before using this tools

---
## Install Enum4Linux-ng

```shell
git clone https://github.com/cddmp/enum4linux-ng.git <PATH>
cd <PATH>/enum4linux-ng
pip3 install -r requirements.txt
#Or using venv if in linux environment
```

---
## Related Source : 
[[SMB]]