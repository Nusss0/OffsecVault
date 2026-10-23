> Source : [HTB Academy - Footprinting (Windows Remote Management Protocols)](https://academy.hackthebox.com/app/module/112/section/1242)

---
## Overview
> Windows Server systems (enabled by default since Windows Server 2016) provide built-in remote hardware and system management services. The three primary components for remote administration in Windows environments are **RDP** (GUI-based), **WinRM** (CLI/PowerShell remoting), and **WMI** (management query and command execution).

---
## 1. RDP (Remote Desktop Protocol) — TCP/UDP 3389
> `Remote Desktop Protocol` (`RDP`) is Microsoft's proprietary protocol that transmits display graphics, mouse, and keyboard input over an encrypted network connection. It typically runs on **TCP port 3389** (and optionally UDP 3389).

### Security Layers & NLA
- **RDP Security (Legacy)**: Inadequate proprietary encryption without strong server identity verification.
- **TLS/SSL**: Standard TLS encryption, but often relies on self-signed certificates generating client warnings.
- **NLA (Network Level Authentication)**: Uses `CredSSP` (Credential Security Support Provider) to enforce user authentication *before* establishing the full RDP session and rendering the login screen. Modern servers require NLA by default.

### Footprinting RDP

#### 1. Nmap Scan with RDP Scripts
Reveals supported encryption layers, NLA status, NetBIOS/DNS hostname, OS Product Version, and exact system time:
```shell
nmap -sV -sC <target-IP> -p3389 --script rdp*
```

>[!warning] EDR & Threat Hunter Detection (`mstshash=nmap`)
>When running standard Nmap RDP scripts, Nmap sends RDP cookies containing `mstshash=nmap`. This signature is widely flagged by EDRs (Endpoint Detection and Response) and SOC analysts. Track packet details with:
>```shell
>nmap -sV -sC <target-IP> -p3389 --packet-trace --disable-arp-ping -n
>```

#### 2. Check Security Settings (`rdp-sec-check.pl`)
Utility by Cisco CX Security to evaluate supported encryption ciphers and protocol versions without authenticating:
```shell
git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git && cd rdp-sec-check
./rdp-sec-check.pl <target-IP>
```

#### 3. Initiating an RDP GUI Session from Linux
Connect using credentials via `xfreerdp`:
```shell
xfreerdp /u:<username> /p:'<password>' /v:<target-IP>

# If domain is required:
xfreerdp /u:<username> /d:<domain> /p:'<password>' /v:<target-IP>
```
*Alternative GUI tools: `Remmina`, `rdesktop`.*

---
## 2. WinRM (Windows Remote Management) — TCP 5985 / 5986
> `Windows Remote Management` (`WinRM`) is a command-line remote management protocol implementing the **WS-Management** standard over SOAP. It powers PowerShell Remoting (`Enter-PSSession`, `Invoke-Command`) and is enabled by default starting with Windows Server 2012.

### Ports
- **TCP 5985**: Default HTTP (unencrypted transport, though credentials may be encrypted via Kerberos/NTLM).
- **TCP 5986**: Default HTTPS (encrypted transport).

### Footprinting WinRM

#### 1. Nmap Service Scan
```shell
nmap -sV -sC <target-IP> -p5985,5986 --disable-arp-ping -n
```
*Often returns service name `Microsoft HTTPAPI httpd 2.0`.*

#### 2. Test Connection (from Windows / PowerShell)
```powershell
Test-WsMan -ComputerName <target-IP>
```

#### 3. Remote Shell Access via `evil-winrm` (from Linux)
When valid credentials (or NTLM hashes via `-H`) are acquired:
```shell
evil-winrm -i <target-IP> -u <username> -p '<password>'
```

---
## 3. WMI (Windows Management Instrumentation) — TCP 135
> `Windows Management Instrumentation` (`WMI`) is Microsoft's implementation of the Common Information Model (CIM) and Web-Based Enterprise Management (WBEM). It provides comprehensive read/write access to almost all Windows operating system settings, processes, accounts, and hardware states.

### Port & Communication Flow
- **TCP Port 135 (RPC / Endpoint Mapper)**: Initial connection and authentication handshake.
- Once authenticated, communication dynamically shifts to a **negotiated random high port** (or operates over SMB/RPC).
- Admin tools: PowerShell, VBScript, WMIC console (`wmic.exe`).

### Footprinting & Execution with `wmiexec.py` (Impacket)
Executes arbitrary commands on remote hosts via WMI without dropping a persistent binary service:
```shell
wmiexec.py <username>:'<password>'@<target-IP> "<command>"
```
Example:
```shell
python3 wmiexec.py Administrator:'P455w0rd!'@10.129.201.248 "hostname"
```

---
## Summary Cheatsheet

| Protocol | Default Ports | Primary Use | Quick Footprinting / Access Command |
| :--- | :---: | :--- | :--- |
| **RDP** | TCP/UDP 3389 | GUI Desktop Access | `nmap -sV -sC -p3389 --script rdp* <IP>`<br>`xfreerdp /u:<user> /p:<pass> /v:<IP>` |
| **WinRM** | TCP 5985 (HTTP)<br>TCP 5986 (HTTPS) | PowerShell / CLI Remoting | `nmap -p5985,5986 -sV <IP>`<br>`evil-winrm -i <IP> -u <user> -p <pass>` |
| **WMI** | TCP 135 (RPC) $\rightarrow$ High Ports | OS Administration & Queries | `wmiexec.py <user>:<pass>@<IP> "<command>"` |

