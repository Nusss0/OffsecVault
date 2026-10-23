> Source : [HTB Academy - Footprinting (Linux Remote Management Protocols)](https://academy.hackthebox.com/app/module/112/section/1240)

---
## Overview
> Remote management services allow administrators to operate and troubleshoot Linux servers without physical access. Due to their privileged nature, improper configurations (such as weak credentials, insecure defaults, or legacy trust relationships) make them high-value targets during penetration testing.

---
## 1. SSH (Secure Shell) — TCP 22
> `Secure Shell` (`SSH`) is an encrypted protocol running on **TCP port 22** designed to replace unencrypted remote shells (Telnet, rlogin). It supports remote terminal access, command execution, SFTP file transfer, and port forwarding/tunneling.

### Protocols & Authentication
- **SSH-1 vs. SSH-2**: SSH-1 is legacy and vulnerable to Man-In-The-Middle (MITM) attacks. Modern networks use SSH-2.
- **OpenSSH Authentication Methods**:
  1. `Password authentication`
  2. `Public-key authentication` (Private key on client, public key in `~/.ssh/authorized_keys`)
  3. `Host-based authentication`
  4. `Keyboard authentication`
  5. `Challenge-response authentication`
  6. `GSSAPI authentication`

### Dangerous `sshd_config` Settings
Located at `/etc/ssh/sshd_config`:

| Setting | Risk / Description |
| :--- | :--- |
| `PasswordAuthentication yes` | Allows password authentication, enabling dictionary / brute-force attacks. |
| `PermitEmptyPasswords yes` | Allows login with no password for configured accounts. |
| `PermitRootLogin yes` | Allows direct remote login as `root`. |
| `Protocol 1` | Forces use of outdated, insecure SSH-1 protocol. |
| `X11Forwarding yes` | Enables GUI forwarding (historical CVEs like CVE-2016-1908 command injection). |
| `AllowTcpForwarding yes` | Permits port forwarding and pivoting through the host. |
| `PermitTunnel yes` | Allows arbitrary tunneling. |
| `DebianBanner yes` | Exposes detailed OS/patch versions in banner. |

### Footprinting SSH

#### 1. Audit Cryptography with `ssh-audit`
Scans for weak key exchanges (KEX), outdated ciphers, and known CVEs:
```shell
git clone https://github.com/jtesta/ssh-audit.git && cd ssh-audit
./ssh-audit.py <target-IP>
```

#### 2. Banner Grabbing & Supported Methods
```shell
# Verbose connection reveals server banner, OpenSSH version, and available auth methods
ssh -v <user>@<target-IP>
```

#### 3. Force Specific Authentication (e.g. Password Brute-Force)
```shell
ssh -v <user>@<target-IP> -o PreferredAuthentications=password
```

---
## 2. Rsync — TCP 873
> `Rsync` is a fast utility for copying files locally and across remote systems. It uses a **delta-transfer algorithm** to transmit only changed blocks of data. It defaults to **TCP port 873** or can be tunneled over SSH.

### Footprinting Rsync

#### 1. Nmap Service Scan
```shell
sudo nmap -sV -p 873 <target-IP>
```

#### 2. Probe Accessible Shares via Netcat
Connect and send protocol greeting + `#list` to reveal share names:
```shell
nc -nv <target-IP> 873
# Server sends: @RSYNCD: 31.0
# Reply with:   @RSYNCD: 31.0
# Request list: #list
```

#### 3. Enumerate & List Shared Directory Contents
```shell
# List directory contents on an open share (e.g. "dev")
rsync -av --list-only rsync://<target-IP>/dev
```

#### 4. Download / Sync Files Locally
```shell
# Download all files from unauthenticated share to local directory
rsync -av rsync://<target-IP>/dev ./loot_dev/
```

#### 5. Rsync over SSH
When Rsync requires or piggybacks on SSH:
```shell
rsync -av -e ssh ./local_file <user>@<target-IP>:/remote_path/
# Custom SSH port:
rsync -av -e "ssh -p 2222" <user>@<target-IP>:/share ./loot/
```

---
## 3. R-Services (Berkeley R-Commands) — TCP 512, 513, 514
> A legacy suite of unencrypted remote access tools developed for Unix before SSH. All traffic (passwords, commands, output) travels in **cleartext**, making it susceptible to MITM sniffing and session hijacking.

### Port & Command Mapping

| Command | Service Daemon | Port / Protocol | Description |
| :--- | :--- | :---: | :--- |
| `rexec` | `rexecd` | **TCP 512** | Remote command execution using username/password. |
| `rlogin` | `rlogind` | **TCP 513** | Remote interactive terminal session (similar to Telnet). |
| `rcp` | `rshd` | **TCP 514** | Remote file copy between hosts without overwrite prompt. |
| `rsh` | `rshd` | **TCP 514** | Direct remote shell execution relying on trusted host files. |
| `rwho` | `rwhod` | **UDP 513** | Broadcasts and lists logged-in network users. |
| `rusers` | `rusersd` | **RPC / UDP** | Displays detailed user accounts logged in across the subnet. |

### Access Control Flaw: Trust Relationships
R-services can bypass standard password authentication using:
- `/etc/hosts.equiv` — Global trust configuration across all users.
- `~/.rhosts` — Per-user configuration inside the user's home directory.

**Syntax**: `<hostname/IP> <username>`
>[!danger] Wildcard `+` Misconfiguration
>The `+` character acts as a wildcard.
>- `+ +` in `/etc/hosts.equiv` or `.rhosts` grants **any user from any host passwordless access**!

### Footprinting & Exploitation

#### 1. Scan Ports
```shell
sudo nmap -sV -p 512,513,514 <target-IP>
```

#### 2. Log in without Password via `rlogin`
If trust is misconfigured in `.rhosts`:
```shell
rlogin <target-IP> -l <username>
```

#### 3. Enumerate Active Users on Network
```shell
# List active network users via rwho daemon
rwho

# Detailed logged-in user information (host, tty, idle time, date)
rusers -al <target-IP>
```


