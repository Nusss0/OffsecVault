---
tags:
  - HTB
  - CPTS
  - Material
  - Networking
---
> Host and port scanning is the process of identifying open ports, running services, service versions, service-provided information, and the operating system on a target that has already been confirmed alive.

---

## Port States

> [!info]- Six possible port states
> | State | Description |
> | --- | --- |
> | `open` | Connection to the port was established (TCP connection, UDP datagram, or SCTP association). |
> | `closed` | The received packet contains an RST flag. Can also be used to check if the target is alive. |
> | `filtered` | Nmap cannot tell if the port is open or closed — no response, or an error code is returned. |
> | `unfiltered` | Occurs only in TCP-ACK scans. The port is accessible, but open/closed cannot be determined. |
> | `open\|filtered` | No response received. A firewall or packet filter may be protecting the port. |
> | `closed\|filtered` | Occurs only in IP ID idle scans. Cannot determine if the port is closed or firewall-filtered. |

---

## Discovering Open TCP Ports

> By default, Nmap scans the top 1000 TCP ports. As root it uses the SYN scan (`-sS`); otherwise it falls back to the TCP connect scan (`-sT`).

> [!info] Why the default changes
> The SYN scan requires raw-socket permissions to craft raw TCP packets, which need root. Without root, Nmap cannot make raw packets and uses the connect scan (`-sT`) instead.

> [!info]- Port selection options
> | Option | Meaning |
> | --- | --- |
> | `-p 22,25,80,139,445` | Specific ports, listed individually. |
> | `-p 22-445` | A range of ports. |
> | `--top-ports=10` | Top N most frequent ports from Nmap's database. |
> | `-p-` | All 65535 ports. |
> | `-F` | Fast scan — top 100 ports. |

```shell
sudo nmap 10.129.2.28 --top-ports=10
```

---

## Tracing the Packets

> `--packet-trace` shows every packet Nmap sends and receives, giving a clear view of the scan's behavior.

> [!info] Cleaning the trace
> To see only port-scan packets, three discovery/lookup steps are disabled: `-Pn` (skip host discovery), `-n` (skip DNS resolution), `--disable-arp-ping` (skip ARP ping).

```shell
sudo nmap 10.129.2.28 -p 21 --packet-trace -Pn -n --disable-arp-ping
```

> [!note]
> On a closed port, the SENT line shows my SYN flag (`S`) going to the target. The RCVD line shows the target replying with RST+ACK (`RA`). ACK acknowledges receipt of my packet; RST ends the TCP session.

---

## Connect Scan

> The TCP Connect Scan (`-sT`) completes the full three-way handshake to determine port state. A port is open if it replies with SYN-ACK, closed if it replies with RST.

> [!info] Trade-offs
> The connect scan is highly accurate because it completes the handshake. It is one of the least stealthy scans — fully establishing a connection creates logs and is easily detected by IDS/IPS. It is considered "polite" because it behaves like a normal client and rarely disrupts services.

> [!note]
> SYN scan (`-sS`, half-open) is stealthier: it never completes the handshake, reducing connection logs. Advanced IDS/IPS can still detect it.

```shell
sudo nmap 10.129.2.28 -p 443 --packet-trace --disable-arp-ping -Pn -n --reason -sT
```

---

## Filtered Ports

> A `filtered` state usually means a firewall rule is handling the connection. The packets can either be **dropped** or **rejected**.

> [!info] Dropped vs rejected
> **Dropped:** no response comes back. Nmap retries (default `--max-retries` is 10), making the scan noticeably slower. **Rejected:** the target replies with an ICMP error (type 3, code 3 — port unreachable).

> [!note]
> A dropped-packet scan took ~2.06s versus ~0.05s for normal scans — the long duration comes from Nmap resending and waiting. If the host is known alive but a port is rejected via ICMP, assume a firewall is blocking that port and revisit it later.

```shell
sudo nmap 10.129.2.28 -p 139 --packet-trace -n --disable-arp-ping -Pn
```

```shell
sudo nmap 10.129.2.28 -p 445 --packet-trace -n --disable-arp-ping -Pn
```

---

## Discovering Open UDP Ports

> The UDP scan (`-sU`) probes UDP ports. Because UDP is stateless and has no three-way handshake, there is no acknowledgment, so timeouts are longer and the scan is much slower than a TCP scan.

> [!info] Interpreting UDP responses
> Nmap sends empty datagrams. An open UDP port only responds if the application is configured to do so. Response outcomes: a UDP reply → `open`; an ICMP error code 3 (port unreachable) → `closed`; any other ICMP response or no response → `open|filtered`.

```shell
sudo nmap 10.129.2.28 -F -sU
```

> [!info]- UDP state examples (`--reason`)
> | Port probed | Response | Resulting state | Reason shown |
> | --- | --- | --- | --- |
> | 137 | UDP response | `open` | `udp-response` |
> | 100 | ICMP port unreachable (type 3/code 3) | `closed` | `port-unreach` |
> | 138 | No response | `open\|filtered` | `no-response` |

---

## Version Scan

> The version scan (`-sV`) probes open ports to identify service names, versions, and other target details.

```shell
sudo nmap 10.129.2.28 -Pn -n --disable-arp-ping --packet-trace -p 445 --reason -sV
```

> [!note]
> On port 445 the version scan matched `Samba smbd 3.X - 4.X`, and the output revealed `Service Info: Host: Ubuntu` — useful OS and service intelligence gathered from a single open port.

---

## Related Source

[[Nmap]]