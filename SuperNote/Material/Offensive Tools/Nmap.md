---
tags:
  - Tools
  - Networking
---
## Function
>*to scan networks and identify which hosts are available on the network using raw packets, and services and applications, including the name and version, where possible. It can also identify the operating systems and versions of these hosts.*
---
###  Syntax : 
```shell
nmap <scan types> [options] <target>
```

### Scan Types :
| Scan Type        | Flag  |
| ---------------- | ----- |
| SYN scan         | `-sS` |
| UDP scan         | `-sU` |
| TCP Connect scan | `-sT` |
>[!info] A **scan type** tells Nmap _how_ to probe the target — which kind of packets to send and how to read the responses to decide if a port is open, closed, or filtered.

### Options : 
| Command        | Description                                   |
| -------------- | --------------------------------------------- |
| `-p 22,80,443` | Scan specific ports                           |
| `-p-`          | Scan all 65535 ports                          |
| `-sV`          | Detect service versions                       |
| `-sC`          | Run default scripts                           |
| `-O`           | Detect OS                                     |
| `-A`           | Aggressive (`-sV`, `-O`, scripts, traceroute) |
| `-Pn`          | Skip ping, treat host as up                   |
| `-oN file`     | Save output to a file                         |
| `-v`           | Verbose output                                |
### Others :
- For further information please use manual page.

---
## Related Source : 
[[Service Scanning]]