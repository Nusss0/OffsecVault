## Definition
> **DNS Exfiltration** (or **DNS Tunneling**) is a covert channel technique where an attacker extracts sensitive data or commands across firewalled network boundaries by encoding the data into standard DNS queries (such as subdomain names in `A` or `TXT` requests) sent to an attacker-controlled authoritative name server.

---
## Tags 

#Material #NetworkSecurity #Forensics #DataExfiltration 

---
## Mechanics

Internal firewalls often block direct outbound HTTP/TCP connections, but almost always permit outbound UDP port 53 (DNS) queries to internal resolvers so that machines can resolve domains.

```
Compromised Host                Internal DNS Resolver           Attacker DNS Server
     |                                    |                               |
     |--- Query: a1b2c3.attacker.com ---->|                               |
     |                                    |--- Query: a1b2c3.attacker.com>| (Attacker logs query!)
     |                                    |<-- NXDOMAIN / Response -------|
     |<-- NXDOMAIN / Response ------------|                               |
```

### Data Encoding:
The payload is broken into chunks, encoded (Hex, Base32, Base64), and appended as subdomains:
```
<chunk_seq>.<encoded_data>.attacker-domain.com
```

---
## Analysis & Detection (with `tshark`)
Extract all unique DNS query names from a capture file to reconstruct the exfiltrated stream:
```shell
tshark -r capture.pcapng -Y "dns.qry.name" -T fields -e dns.qry.name > queries.txt
```

---
## Related Concepts : 
[[tshark]], [[AES]], [[grep]], [[cat]]
