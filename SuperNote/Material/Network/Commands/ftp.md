---
tags:
  - Tools
  - File-Transfer
  - Networking
  - Protocol
  - Footprinting
---
	## Definition
> **File Transfer Protocol (ftp)** is a built-in command-line client used to interact with remote FTP servers (typically on TCP port 21) to enumerate directories, upload, and download files straight from the terminal.

---
## Connection Syntax
```shell
ftp [options] <target_IP_or_domain>
```

### Key Options:
| Flag | Description |
| :--- | :--- |
| `-p` | Enables **Passive mode** (PASV) — crucial if behind NAT or client firewall. |
| `-i` | Turns off interactive prompting during multiple file transfers (`mget`/`mput`). |
| `-v` | Verbose mode — displays all server responses and transfer statistics. |
| `-n` | Disables auto-login on initial connection. |
| `-d` | Debug mode — displays raw internal FTP commands/responses. |
| `-P <port>` | Connects to a custom port instead of default port 21. |

---
## Anonymous Authentication
> [!TIP] Anonymous Login
> Many misconfigured servers permit login without dedicated credentials:
> - **Username:** `anonymous` (or `ftp`)
> - **Password:** `anonymous` (or blank / any string)

```shell
ftp <target_ip>
Name: anonymous
Password: <tekan Enter atau ketik anonymous>
```

---
## Commands Inside FTP Session (`ftp>`)

| Command | Arguments | Description |
| :--- | :--- | :--- |
| `ls` / `dir` | `[path]` | List files in current or specified directory. |
| `ls -R` | None | Recursive directory listing (if supported by server). |
| `pwd` | None | Print current working directory on server. |
| `cd` | `<dir>` | Change remote directory. |
| `lcd` | `[local_path]` | Change working directory on **your local machine** without exiting. |
| `get` | `<remote> [local]` | Download a single file. |
| `mget` | `<pattern>` | Download multiple files matching wildcard (e.g., `mget *.txt`). |
| `put` | `<local> [remote]` | Upload a single file. |
| `mput` | `<pattern>` | Upload multiple files matching wildcard. |
| `binary` | None | Set transfer mode to **binary** (always run before downloading scripts, binaries, or keys). |
| `ascii` | None | Set transfer mode to plain ASCII text. |
| `status` | None | View current session status and connection modes. |
| `debug` | None | Toggle debug mode on/off to see raw command traffic. |
| `prompt` | None | Toggle confirmation prompts during `mget`/`mput`. |
| `!<command>` | None | Execute local bash command directly from inside FTP (e.g., `!ls`, `!cat flag.txt`). |
| `exit` / `quit` | None | Terminate session. |

---
## Footprinting & Enumeration Techniques

### 1. Nmap Script Scanning (Instant Anon & Banner Check)
```shell
# Cek anonymous access dan status banner
sudo nmap -p 21 --script ftp-anon,ftp-syst <target_ip>

# Cek semua script NSE terkait FTP
sudo nmap -p 21 --script "ftp-*" <target_ip>
```

### 2. Download Seluruh Isi Folder FTP Sekaligus (`wget`)
Jika login anonymous diperbolehkan dan foldernya banyak, download semua file secara rekursif:
```shell
wget -m --no-passive ftp://anonymous:anonymous@<target_ip>
```

---
## Related Source : 
[[CPTS/Footprinting/Sections/FTP|CPTS Footprinting - FTP]], [[WriteUps/HTB Machines/Fawn|HTB Fawn]], [[CPTS/Footprinting/Footprinting Lab - Easy|Footprinting Lab - Easy]]
