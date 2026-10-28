---
tags:
  - Commands
  - Networking
  - SMB
  - File-Transfer
  - Material
---
## Function
> **`smbclient`** is a command-line client used to interact with SMB/CIFS network shares (Windows shared folders or Linux Samba servers) over TCP port 445 or 139. Operating with an FTP-like interface, it is the primary tool used to explore, upload, and download files directly from Windows network drives.

---
## Syntax

### 1. Listing Available Shares
```shell
# List shares anonymously / Null session:
smbclient -N -L //<Target_IP>

# List shares with credentials:
smbclient -U '<user>%<pass>' -L //<Target_IP>
```

### 2. Connecting to a Specific Share
```shell
smbclient -U '<user>%<pass>' //<Target_IP>/<share_name>
```

---
## Options :

| **Flag** | **Argument** | **Description** |
| :--- | :--- | :--- |
| `-L` | `<IP_or_Host>` | **List**. Queries the server and displays all available shares and workgroup/domain info. |
| `-N` | None | **No Pass**. Suppresses password prompt to attempt an anonymous or null session. |
| `-U` | `<user>[%pass]` | Specifies user and password. Append `%password` to bypass prompt. |
| `-W` | `<domain>` | Specifies the Windows Workgroup or Active Directory domain. |
| `-p` | `<port>` | Custom SMB port (default is 445, falls back to 139). |
| `-c` | `<command>` | **One-liner execution**. Runs internal SMB command (e.g. `get file.txt`) and exits immediately. |
| `-m` | `<version>` | Maximum SMB protocol version (e.g., `-m NT1` to force SMBv1 for legacy targets). |

---
## Commands Inside SMBClient (`smb: \>`)

| **Command** | **Description** |
| :--- | :--- |
| `ls` / `dir` | Lists files and folders in the current remote directory. |
| `cd <folder>` | Changes directory on the remote share. |
| `pwd` | Prints current remote working directory. |
| `lcd <path>` | Changes working directory on **your local machine** without exiting smbclient. |
| `get <remote> [local]` | Downloads a single file to your local machine. |
| `put <local> [remote]` | Uploads a single file to the remote share. |
| `mget <mask>` | Downloads multiple files matching wildcard (e.g., `mget *.txt`). |
| `prompt` | Toggles interactive yes/no prompting during `mget` / `mput`. |
| `recurse` | Toggles directory recursion on/off for batch downloading. |
| `exit` / `quit` | Closes session. |

---
## Common Use Cases & Real-World Examples

### 1. Anonymous Share Discovery & Exploration
```bash
# Check if server allows null session listing:
smbclient -N -L //10.129.202.41

# Connect to readable share without credentials:
smbclient -N //10.129.202.41/public
```

### 2. Authenticated Connection & File Theft (Lab Flow)
```bash
# Connect directly to devshare using credentials:
smbclient -U 'alex%lol123!mD' //10.129.202.41/devshare
```
Inside the prompt:
```text
smb: \> ls
smb: \> get important.txt
smb: \> exit
```

### 3. Non-Interactive One-Liner Download (`-c`)
Download a file directly to your local terminal without entering the interactive shell:
```bash
smbclient -U 'alex%lol123!mD' //10.129.202.41/devshare -c 'get important.txt'
```

### 4. Recursive Batch Download (All Files on Share)
```text
smb: \> recurse ON
smb: \> prompt OFF
smb: \> mget *
```

---
## Common Pitfalls & Troubleshooting

### 1. Difference: Listing (`-L`) vs Connecting (No `-L`)
> [!CAUTION] The `-L` Flag Trap
> * **To List Shares:** Use `-L //<IP>` **without** a folder name:
>   `smbclient -U 'alex%pass' -L //10.129.202.41`
> * **To Connect & Browse Files:** Remove `-L` and specify the share name:
>   `smbclient -U 'alex%pass' //10.129.202.41/devshare`

### 2. Warning: `Reconnecting with SMB1 for workgroup listing`
```text
Reconnecting with SMB1 for workgroup listing.
do_connect: Connection to 10.129.202.41 failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND)
Unable to connect with SMB1 -- no workgroup available
```
* **Why it happens:** After successfully retrieving shares via modern SMBv2/v3, `smbclient` attempts a secondary query for legacy NetBIOS workgroup names using deprecated SMBv1.
* **Impact:** **Harmless.** Modern Windows Servers disable SMBv1 for security, so this secondary query fails. If the shares table was printed above it, your scan was 100% successful.

### 3. Shell History Error: `zsh: event not found: ...`
* **Why it happens:** Passwords containing exclamation marks (`!`) inside double quotes (`"..."`) trigger bash/zsh history expansion.
* **Fix:** Always wrap credentials in **single quotes**: `-U 'alex%lol123!mD'`.

---
## Related Source : 
[[_Network Commands|Network Commands]], [[Material/Network/Commands/RPCclient|RPCclient]], [[CrackMapExec]], [[SMBMap]], [[Material/Network/Important Ports|Important Ports]]
