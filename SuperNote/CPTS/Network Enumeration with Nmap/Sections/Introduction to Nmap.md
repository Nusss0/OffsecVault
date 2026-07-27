---
tags:
---
# Introduction to Nmap

> Network Mapper (`Nmap`) is an open-source network analysis and security auditing tool written in C, C++, Python, and Lua. It scans networks to identify available hosts and their services and applications, including name and version where possible, and can identify host operating systems and versions. It can also determine whether packet filters, firewalls, or intrusion detection systems (IDS) are configured as needed.

---

## Use Cases

> Nmap is one of the most used tools by network administrators and IT security specialists.

> [!info]- Uses
> - Audit the security aspects of networks
> - Simulate penetration tests
> - Check firewall and IDS settings and configurations
> - Types of possible connections
> - Network mapping
> - Response analysis
> - Identify open ports
> - Vulnerability assessment

---

## Nmap Architecture

> Nmap offers many different types of scans to obtain various results about targets. It can be divided into the following scanning techniques:

> [!info]- Scanning techniques
> - Host discovery
> - Port scanning
> - Service enumeration and detection
> - OS detection
> - Scriptable interaction with the target service (Nmap Scripting Engine)

---

## Syntax

> The syntax for Nmap is fairly simple:

```shell
nmap <scan types> <options> <target>
```

---

## Scan Techniques

> Nmap offers many different scanning techniques, making different types of connections and using differently structured packets to send.

```shell
nmap --help

<SNIP>
SCAN TECHNIQUES:
  -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
  -sU: UDP Scan
  -sN/sF/sX: TCP Null, FIN, and Xmas scans
  --scanflags <flags>: Customize TCP scan flags
  -sI <zombie host[:probeport]>: Idle scan
  -sY/sZ: SCTP INIT/COOKIE-ECHO scans
  -sO: IP protocol scan
  -b <FTP relay host>: FTP bounce scan
<SNIP>
```

> [!info] TCP-SYN Scan (`-sS`)
> One of the default settings unless defined otherwise, and one of the most popular scan methods. It can scan several thousand ports per second. It sends one packet with the `SYN` flag and never completes the three-way handshake, so it does not establish a full TCP connection to the scanned port.

> [!info]- SYN scan response interpretation
> - If the target sends a `SYN-ACK` flagged packet back, Nmap detects the port as `open`.
> - If the target responds with an `RST` flagged packet, it indicates the port is `closed`.
> - If Nmap does not receive a packet back, it displays the port as `filtered`. Depending on the firewall configuration, certain packets may be dropped or ignored by the firewall.

Example of such a scan:

```shell
sudo nmap -sS localhost

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-11 22:50 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000010s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
5432/tcp open  postgresql
5901/tcp open  vnc-1

Nmap done: 1 IP address (1 host up) scanned in 0.18 seconds
```

> [!info] Output columns
> - First column: the port number.
> - Second column: the service's status.
> - Third column: what kind of service it is.

---
## Related Source
[[Nmap]]