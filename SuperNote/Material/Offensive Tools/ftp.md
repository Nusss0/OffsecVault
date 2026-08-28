---
tags:
  - Tools
  - File-Transfer
  - Networking
  - Protocol
---
## Definition
>**File Transfer Protocol** is a built-in command-line client that connects your computer directly to a server, allowing you to browse, upload, or download files straight from the terminal.*
---
##  Syntax : 
```shell
ftp [options] <IP_Address/Domain>
```

### Options : 
| **Flag** | **Value** | **Description**                                                                                                     |
| -------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `-p`     | None      | Enables Passive mode for data transfers; useful for bypassing firewalls or NAT routing issues.                      |
| `-i`     | None      | Disables interactive prompting (yes/no) during multiple file transfers (e.g., when using `mget` or `mput`).         |
| `-v`     | None      | Enables verbose mode; displays all server responses, logs, and data transfer statistics.                            |
| `-n`     | None      | Disables auto-login upon initial connection, ignoring `.netrc` files. Useful for manual or scripted authentication. |
| `-d`     | None      | Enables debugging mode; displays raw internal commands sent from the client to the FTP server.                      |
| `-P`     | `<port>`  | Connects to a specific port number on the server instead of the default Port 21.                                    |
### Others :
- We could login without password, with Username : `anonymous` Password `anonymous`.

---
## Inside FTP
```shell
ftp> ...
```

### Useful syntax : 
| **Command**     | **Arguments**                | **Description**                                                                                                                               |
| --------------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `ls` or `dir`   | `[remote_path]`              | Lists files and directories in the current (or specified) remote directory.                                                                   |
| `pwd`           | None                         | Prints the current working directory on the remote server.                                                                                    |
| `cd`            | `<directory_name>`           | Changes the working directory on the remote FTP server.                                                                                       |
| `lcd`           | `[local_path]`               | Changes the local working directory on your own machine without leaving FTP.                                                                  |
| `get`           | `<remote_file> [local_file]` | Downloads a single file from the server to your local machine.                                                                                |
| `put`           | `<local_file> [remote_file]` | Uploads a single file from your local machine to the server.                                                                                  |
| `mget`          | `<file_pattern>`             | Downloads multiple files matching a wildcard pattern (e.g., `mget *.txt`).                                                                    |
| `mput`          | `<file_pattern>`             | Uploads multiple files matching a wildcard pattern.                                                                                           |
| `binary`        | None                         | Sets the transfer mode to binary. **Crucial** before transferring non-text files like images, executables, or archives to prevent corruption. |
| `ascii`         | None                         | Sets the transfer mode to ASCII (usually the default, only safe for plain text files).                                                        |
| `mkdir`         | `<directory_name>`           | Creates a new directory on the remote server.                                                                                                 |
| `delete`        | `<remote_file>`              | Deletes a single file on the remote server.                                                                                                   |
| `prompt`        | None                         | Toggles interactive prompting on or off (equivalent to the `-i` flag during connection).                                                      |
| `bye` or `quit` | None                         | Closes the connection and exits the FTP session.                                                                                              |

>[!important] Local Command
> We can use !\<cmd> to use local command, this command will run on our local terminal (Not inside FTP), but we run the command in `ftp` environment.
> 

---
## Related Source : 
[[CPTS/Footprinting/Sections/FTP|FTP]]