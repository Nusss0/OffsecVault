---
tags:
  - Tools
  - Networking
  - File-Transfer
---
## Function
>*is a command-line utility used to connect to SMB/CIFS network shares—typically Windows shared folders or Linux Samba servers.
It works very much like the `ftp` command, providing an interactive interface that allows you to browse, download, and upload files to a shared network drive directly from your terminal.*

---
##  Syntax  :

### Listing available shares : 
```shell
smbclient -L <IP> [options] #With password listing
smbclient -L -N <IP> [options] #Anonymous listing
```

### To connect to a specific share : 
```shell
smbclient //<IP>/<sharename> [options]
```

### Options : 
| **Flag** | **Argument**            | **Description**                                                                                                                                                                                                                       |
| -------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-L`     | `<IP_or_Hostname>`      | **List**. It queries the server and displays a list of all available shared folders (shares) and services on that target. You use this when you know the server's IP but do not know the exact `<share_name>` you want to connect to. |
| `-N`     | None                    | **No Pass**. It forces `smbclient` to suppress the password prompt and attempt a "null session" or anonymous login without a password.                                                                                                |
| `-U`     | `<username>[%password]` | Specifies the user to log in as. You can append the password directly using `%` (e.g., `-U admin%Password123`) to skip the prompt, which is useful for quick testing or scripting.                                                    |
| `-W`     | `<workgroup>`           | Specifies the Windows Workgroup or Active Directory domain name required for authentication.                                                                                                                                          |
| `-m`     | `<protocol_version>`    | Sets the maximum SMB protocol version allowed. Very useful when dealing with legacy systems (e.g., using `-m NT1` to force SMBv1 compatibility).                                                                                      |
| `-p`     | `<port>`                | Connects to a specific port on the server. By default, `smbclient` tries port 445 (SMB over TCP) and falls back to 139 (NetBIOS).                                                                                                     |
| `-c`     | `<command_string>`      | Executes a specific `smbclient` internal command (like `ls` or `get file.txt`) and then immediately exits. Excellent for bash scripting and automation.                                                                               |
| `-I`     | `<IP_address>`          | Explicitly sets the target IP address. This is helpful if you are connecting to a target using its NetBIOS hostname (`//SERVER/Share`) but DNS resolution is failing.                                                                 |
### Others :
- For further information please use manual page.
- SMB usually use port `445` over TCP or `139` (NETBIOS)

---
## Inside SMBClient
```shell
smb: \> ...
```
### Some useful command : 
| **Command**      | **Arguments**                | **Description**                                                                                                                                             |
| ---------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ls` or `dir`    | `[file_mask]`                | Lists the files and directories in the current remote working directory.                                                                                    |
| `cd`             | `<directory_name>`           | Changes the current working directory on the remote SMB share.                                                                                              |
| `pwd`            | None                         | Prints the current working directory on the remote server.                                                                                                  |
| `lcd`            | `[local_path]`               | Changes the working directory on your local machine. Useful so you don't have to exit `smbclient` to change where files are saved.                          |
| `get`            | `<remote_file> [local_file]` | Downloads a single file from the remote share to your local machine.                                                                                        |
| `put`            | `<local_file> [remote_file]` | Uploads a single file from your local machine to the remote SMB share.                                                                                      |
| `mget`           | `<file_mask>`                | Downloads multiple files that match the mask (e.g., `mget *.txt`).                                                                                          |
| `mput`           | `<file_mask>`                | Uploads multiple files that match the mask.                                                                                                                 |
| `prompt`         | None                         | Toggles interactive prompting on and off. If turned off, `mget` and `mput` will transfer files automatically without asking "yes/no" for every single file. |
| `recurse`        | None                         | Toggles directory recursion on and off. When turned on, commands like `mget` and `mput` will include all subdirectories and their contents.                 |
| `help` or `?`    | `[command]`                  | Displays a list of all available internal commands, or shows help for a specific command.                                                                   |
| `exit` or `quit` | None                         | Closes the connection and exits the `smbclient` session.                                                                                                    |

---
## Related Source : 
[[SMB]]