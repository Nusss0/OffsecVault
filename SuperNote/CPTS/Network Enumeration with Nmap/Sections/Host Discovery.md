---
tags:
  - Material
  - HTB
  - CPTS
  - Networking
---

# Host Discovery

> Host discovery is the process of identifying which systems on a network are online and reachable before scanning them for ports and services. The most effective method uses ICMP echo requests.

> [!caution]
> Always store every scan. Results are used for comparison, documentation, and reporting. Different tools may produce different results, so it helps to distinguish which tool produced which output.

---

## Scan Network Range

> Scans an entire subnet to get an overview of which hosts are alive.

```shell
sudo nmap 10.129.2.0/24 -sn -oA tnet | grep for | cut -d" " -f5
```

| Option | Description |
| --- | --- |
| `10.129.2.0/24` | Target network range. |
| `-sn` | Disables port scanning. |
| `-oA tnet` | Stores results in all formats, filename starting with `tnet`. |

> [!info]
> This method only works if the target hosts' firewalls allow it. Otherwise, other scanning techniques (covered in "Firewall and IDS Evasion") are needed.

---

## Scan IP List

> Reads target hosts from a predefined list file instead of typing them manually. Common when a client provides an IP list for an internal penetration test.

```shell
cat hosts.lst
```

```shell
sudo nmap -sn -oA tnet -iL hosts.lst | grep for | cut -d" " -f5
```

| Option | Description |
| --- | --- |
| `-sn` | Disables port scanning. |
| `-oA tnet` | Stores results in all formats, filename starting with `tnet`. |
| `-iL` | Performs scans against targets in the provided `hosts.lst` list. |

> [!info]
> If fewer hosts respond than are in the list, the non-responding hosts may be ignoring ICMP echo requests due to firewall configuration. Nmap receives no response and marks them inactive.

---

## Scan Multiple IPs

> Specifies several individual IP addresses when only part of a network needs scanning.

```shell
sudo nmap -sn -oA tnet 10.129.2.18 10.129.2.19 10.129.2.20 | grep for | cut -d" " -f5
```

If the addresses are consecutive, a range can be defined in the relevant octet:

```shell
sudo nmap -sn -oA tnet 10.129.2.18-20 | grep for | cut -d" " -f5
```

---

## Scan Single IP

> Determines whether a single host is alive before scanning it for open ports and services.

```shell
sudo nmap 10.129.2.18 -sn -oA host
```

| Option | Description |
| --- | --- |
| `10.129.2.18` | Target host. |
| `-sn` | Disables port scanning. |
| `-oA host` | Stores results in all formats, filename starting with `host`. |

> [!info] Default ping behavior
> When port scanning is disabled (`-sn`), Nmap automatically performs a ping scan using ICMP Echo Requests (`-PE`). An ICMP reply is expected if the host is alive. However, before sending the ICMP echo request, Nmap first sends an ARP ping, which produces an ARP reply on a local network.

> [!info]
> `-PE` explicitly ensures ICMP echo requests are sent. `--packet-trace` shows all packets sent and received.

```shell
sudo nmap 10.129.2.18 -sn -oA host -PE --packet-trace
```

| Option | Description |
| --- | --- |
| `-PE` | Performs the ping scan using ICMP Echo requests against the target. |
| `--packet-trace` | Shows all packets sent and received. |

> [!info] `--reason`
> Displays why Nmap marked a host as alive. On a local network, the result shows the host was confirmed via `arp-response`, not the ICMP echo.

```shell
sudo nmap 10.129.2.18 -sn -oA host -PE --reason
```

| Option | Description |
| --- | --- |
| `--reason` | Displays the reason for a specific result. |

> [!note]
> On a local network, Nmap confirms a host is alive using the ARP request/reply alone, before the ICMP echo even runs. This is why the earlier scans never showed ICMP packets.

> [!info] Forcing ICMP echo requests
> `--disable-arp-ping` disables ARP pings, forcing Nmap to use the intended ICMP echo requests. The packet trace then shows the ICMP Echo request being sent and the Echo reply received.

```shell
sudo nmap 10.129.2.18 -sn -oA host -PE --packet-trace --disable-arp-ping
```

> [!tip]
> An ICMP echo request can help determine if a target is alive and help identify its system. More host discovery strategies: https://nmap.org/book/host-discovery-strategies.html

---
## Extras : 

>**TTL** (Time To Live) is a field in every IP packet. Each operating system sets a characteristic _default_ starting TTL, so you can guess the OS from the value you receive:

|Default TTL|Operating System|
|---|---|
|64|Linux / Unix|
|128|Windows|
|255|Cisco / network devices (and some Unix)|

---

## Related Source

[[Nmap]]