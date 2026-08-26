---
tags:
  - Tools
  - Enumeration
  - Networking
---
## Function
>**SMBMap** is a specialized, Python-based penetration testing tool used to enumerate Samba (SMB) shares across a network or domain. It acts as a wrapper around Impacket and makes it incredibly easy to see which network drives exist, determine what permissions a user has (READ, WRITE, or NO ACCESS), search for sensitive files, and upload/download data.
---
##  Syntax : 

### Basic Enumeration (Null session)
```shell
smbmap -H <IP> -u "" -p ""
```

### Basic Enumeration (With valid credential)
```shell
smbmap -H <IP> -u <UserName> -p <Password> -d <DOMAIN>
```

### Recursively Searching For Files 
```shell
smbmap -H <IP> -u <UserName> -p <Password> -R <ShareName>
```

### Download / Uploading Files 
```shell
# Downloading a file
smbmap -H <IP> -u <UserName> -p <Password> --download <Path>

# Uploading a reverse shell payload
smbmap -H <IP> -u <UserName> -p <Password> --upload <Path>
```

### Options : 
| **Flag**               | **Description**                                                                    |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `-H <IP>`              | Specifies the target IP address or hostname.                                       |
| `--host-file <file>`   | Targets a list of IPs contained in a text file.                                    |
| `-u <user>`            | Specifies the username. Omit for a null session.                                   |
| `-p <pass>`            | Specifies the password. Can also take an NTLM hash for Pass-the-Hash.              |
| `-d <domain>`          | Specifies the Active Directory domain.                                             |
| `-r <share>`           | Lists the root contents of a specific share.                                       |
| `-R <share>`           | **Recursively** lists all files and directories within a share.                    |
| `-A <regex>`           | Searches for specific file names matching a pattern (e.g., `config`, `passwords`). |
| `--download <path>`    | Downloads a specific file from the target to your local machine.                   |
| `--upload <src> <dst>` | Uploads a local file to the target share (requires write access).                  |
| `-x <command>`         | Executes a command on the target system (requires local admin rights).             |
### Others :


---
## Related Source : 
[[SMB]]