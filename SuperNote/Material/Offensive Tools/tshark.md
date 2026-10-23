---
tags:
  - Tools
  - Networking
  - Forensics
---
## Function
> **tshark** is the terminal-oriented, command-line version of Wireshark. It is designed to capture packet data from a live network or read packets from a saved capture file (`.pcap` / `.pcapng`), filter on specific protocols, print packet details, and export transferred files.

---
## Cheatsheet & Common Commands

### 1. Reading PCAP Files
```shell
# Read and display packets
tshark -r capture.pcapng

# Filter by display filter (-Y)
tshark -r capture.pcapng -Y "http.request"
tshark -r capture.pcapng -Y "dns"
```

### 2. Extract Specific Fields
```shell
# Extract DNS queried domain names
tshark -r capture.pcapng -Y "dns.qry.name" -T fields -e dns.qry.name

# Extract HTTP request host and URI
tshark -r capture.pcapng -Y "http.request" -T fields -e ip.src -e ip.dst -e http.host -e http.request.uri
```

### 3. Export Transferred HTTP Objects / Files
```shell
mkdir extracted
tshark -r capture.pcapng --export-objects http,extracted
```

---
## Related Concepts : 
[[grep]], [[cat]], [[DNS Exfiltration]]
