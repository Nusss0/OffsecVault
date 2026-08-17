---
tags:
  - Material
  - HTB
  - CPTS
  - Networking
  - Firewall
  - IDS/IPS
---
> Nmap gives us many different ways to bypass firewall rules and IDS/IPS. These methods include the fragmentation of packets, the use of decoys, and others.

---
## Firewalls

> A firewall is a security measure against unauthorized connection attempts from extertal networks. It is based on software and/or hardware components that monitor network traffic passing through the firewall and decide how to handle the connection based on the rules that have been set. It checks whether individual network packets are passed, dropped, or blocked, to prevent unwanted connections tbuthat could be potentially dangerous.

---
## IDS/IPS

> Like the firewall, the intrusion detection system (IDS) and intrusion prevention system (IPS) are also software-based components.

>[!info] IDS
> Scans the network for potential attacks, analyzes them, and reports any detected attacks.

>[!info] IPS
> Complements IDS by taking specific defensive measures if a potential attack should have been detected.

The analysis of such attacks is based on pattern matching and signatures. If specific patterns are detected, such as a service detection scan, IPS may prevent the pending connection attempts.

---

## Determine Firewalls and Their Rules

> When a port is shown as `filtered`, it can have several reasons. In most cases, firewalls have certain rules set to handle specific connections. The packets can either be **dropped** or **rejected**.

>[!info] Dropped
> The packets are ignored, and no response is returned from the host.

>[!info] Rejected
> Elicits an explicit response. TCP packets are returned with an `RST` flag, while ICMP can contain different types of error codes.

>[!info]- ICMP error codes for rejected packets
>
> - Net Unreachable
> - Net Prohibited
> - Host Unreachable
> - Host Prohibited
> - Port Unreachable
> - Proto Unreachable

Nmap's TCP ACK scan (`-sA`) is much harder to filter for firewalls and IDS/IPS systems than regular SYN (`-sS`) or Connect (`-sT`) scans, because it only sends a TCP packet with the `ACK` flag. When a port is closed or open, the host must respond with an `RST` flag.

>[!important] Why the ACK flag passes the firewall
>
> All connection attempts (with the `SYN` flag) from external networks are usually blocked by firewalls. However, packets with the `ACK` flag are often passed, because the firewall cannot determine whether the connection was first established from the external network or the internal network.

#### SYN-Scan

```shell
sudo nmap 10.129.2.28 -p 21,22,25 -sS -Pn -n --disable-arp-ping --packet-trace
```

```shell
PORT   STATE    SERVICE
21/tcp filtered ftp
22/tcp open     ssh
25/tcp filtered smtp
```

#### ACK-Scan

```shell
sudo nmap 10.129.2.28 -p 21,22,25 -sA -Pn -n --disable-arp-ping --packet-trace
```

```shell
PORT   STATE      SERVICE
21/tcp filtered   ftp
22/tcp unfiltered ssh
25/tcp filtered   smtp
```

|Scanning Options|Description|
|---|---|
|`-sS`|Performs SYN scan on specified ports.|
|`-sA`|Performs ACK scan on specified ports.|
|`-Pn`|Disables ICMP Echo requests.|
|`-n`|Disables DNS resolution.|
|`--disable-arp-ping`|Disables ARP ping.|
|`--packet-trace`|Shows all packets sent and received.|

>[!note] Reading the RCVD flags
>
> With the SYN scan (`-sS`), the target tries to establish the TCP connection by sending back a `SYN-ACK` (`SA`). With the ACK scan (`-sA`), an open port replies with the `RST` (`R`) flag. If no packet comes back at all (port 25 here), the packets are being dropped.

---

## Detect IDS/IPS

> Detection of IDS/IPS systems is much more difficult than firewalls, because these are passive traffic monitoring systems. IDS systems examine all connections between hosts and notify the administrator if packets contain defined contents or specifications. IPS systems take configured measures independently to prevent potential attacks automatically.

Several virtual private servers (VPS) with different IP addresses are recommended to determine whether such systems are on the target network during a penetration test.

>[!warning] Getting blocked
>
> If the administrator detects a potential attack, the first step is to block the IP address the attack comes from. We then lose access to the network from that IP, and our ISP may be contacted and blocked from all Internet access.

>[!info] Detecting an IPS with a single host
>
> Scan from a single host (VPS). If at any time this host is blocked and loses access to the target network, we know the administrator has taken some security measure. We can then continue the penetration test with another VPS, and know we need to be quieter with our scans.

---

## Decoys

> The Decoy scanning method (`-D`) makes Nmap generate various random IP addresses inserted into the IP header to disguise the origin of the packet sent. We can generate a specific number of random (`RND`) IP addresses separated by a colon (`:`). Our real IP address is then randomly placed among the generated ones.

>[!caution] Decoys must be alive
>
> Otherwise the service on the target may be unreachable due to SYN-flooding security mechanisms.

#### Scan by Using Decoys

```shell
sudo nmap 10.129.2.28 -p 80 -sS -Pn -n --disable-arp-ping --packet-trace -D RND:5
```

|Scanning Options|Description|
|---|---|
|`-D RND:5`|Generates five random IP addresses that indicate the source IP the connection comes from.|

The spoofed packets are often filtered out by ISPs and routers even when they come from the same network range. We can instead specify our own VPS IP addresses and combine them with "IP ID" manipulation in the IP headers.

Another scenario: only individual subnets lack access to a service. We can manually specify the source IP address (`-S`) to test for better results. Decoys can be used for SYN, ACK, ICMP, and OS detection scans.

#### Testing Firewall Rule

```shell
sudo nmap 10.129.2.28 -n -Pn -p445 -O
```

```shell
PORT    STATE    SERVICE
445/tcp filtered microsoft-ds
Too many fingerprints match this host to give specific OS details
```

#### Scan by Using Different Source IP

```shell
sudo nmap 10.129.2.28 -n -Pn -p 445 -O -S 10.129.2.200 -e tun0
```

```shell
PORT    STATE SERVICE
445/tcp open  microsoft-ds
```

|Scanning Options|Description|
|---|---|
|`-O`|Performs operating system detection scan.|
|`-S`|Scans the target by using a different source IP address.|
|`10.129.2.200`|Specifies the source IP address.|
|`-e tun0`|Sends all requests through the specified interface.|

[!note] Result of switching source IP

> The first scan showed port 445 as `filtered` with no OS match. Reusing a trusted source IP (`-S`) made the same port show `open`, letting OS detection produce Linux guesses. The firewall rule was tied to the source IP.

---

## DNS Proxying

> By default, Nmap performs reverse DNS resolution to find more information about the target. DNS queries are made over UDP port 53. TCP port 53 was previously used only for "Zone transfers" between DNS servers or data transfers larger than 512 bytes, but IPv6 and DNSSEC expansions now cause many DNS requests to be made via TCP port 53.

[!info] Specifying DNS servers (`--dns-server`)

> `--dns-server <ns>,<ns>` lets us set the DNS servers ourselves. This is fundamental in a demilitarized zone (DMZ): the company's DNS servers are usually more trusted than Internet ones, so we can use them to interact with internal hosts.

[!info] Source port 53 (`--source-port`)

> Using TCP port 53 as a source port. If the administrator uses the firewall to control this port and does not filter IDS/IPS properly, our TCP packets will be trusted and passed through.

#### SYN-Scan of a Filtered Port

```shell
sudo nmap 10.129.2.28 -p50000 -sS -Pn -n --disable-arp-ping --packet-trace
```

```shell
PORT      STATE    SERVICE
50000/tcp filtered ibm-db2
```

#### SYN-Scan From DNS Port

```shell
sudo nmap 10.129.2.28 -p50000 -sS -Pn -n --disable-arp-ping --packet-trace --source-port 53
```

```shell
PORT      STATE SERVICE
50000/tcp open  ibm-db2
```

|Scanning Options|Description|
|---|---|
|`--source-port 53`|Performs the scans from the specified source port.|

>[!tip] Confirming with Netcat
>
> Now that the firewall accepts TCP port 53, IDS/IPS filters might also be configured weaker. Test by connecting to the port with Netcat from source port 53:

```shell
ncat -nv --source-port 53 10.129.2.28 50000
```

```shell
Ncat: Connected to 10.129.2.28:50000.
220 ProFTPd
```

---

## Related Source

- [[Nmap]]
- [[Netcat]]