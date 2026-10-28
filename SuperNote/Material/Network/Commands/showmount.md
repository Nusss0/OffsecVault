---
tags:
  - Commands
  - Network
  - NFS
  - Footprinting
  - Material
---
## Function
> **`showmount`** is a built-in Linux utility (part of the `nfs-common` package) used to query the remote NFS mount daemon (`mountd`) on a target server (via RPC port 111 and NFS port 2049). In penetration testing, it is the primary and fastest command to discover which shared folders/directories are exported to the network.

---
## Syntax
```shell
showmount [options] <Target_IP_or_Hostname>
```

---
## Options :

| **Flag** | **Long Flag** | **Description** |
| :---: | :--- | :--- |
| **`-e`** | `--exports` | **Show the NFS server's export list.** *(Most essential flag for pentesting)*. |
| **`-a`** | `--all` | List all client mount points and IP addresses currently connected to the server. |
| **`-d`** | `--directories` | List only the directories that are currently mounted by remote clients. |
| **`-v`** | `--version` | Display program version details. |

---
## Common Use Cases & Real-World Examples

### 1. Enumerate All Exported Shares (Footprinting First Step)
Query the remote NFS server to see what folders are publicly or internally shared:
```bash
showmount -e 10.129.202.41
```

#### Typical Output & How to Read It:
```text
Export list for 10.129.202.41:
/              *
/var/backups   10.129.0.0/16
/home/devs     10.10.14.0/24
```
* **`/` or `/var/backups`:** The remote folder path on the target server.
* **`*` (Wildcard):** Any IP address in the network is allowed to mount this share (World-mountable / Misconfigured).
* **`10.129.0.0/16`:** Access is restricted to clients belonging to that specific subnet.

---

### 2. Next Step After `showmount` (Mounting the Share)
Once you find an accessible export path from `showmount -e`:
```bash
# 1. Create a local mount directory:
sudo mkdir -p /mnt/nfs

# 2. Mount with '-o nolock' (Crucial to prevent hangs on Windows NFS / firewalls):
sudo mount -t nfs -o nolock 10.129.202.41:/ /mnt/nfs

# 3. Explore the files locally:
cd /mnt/nfs && ls -la
```

---

### 3. Troubleshooting & Alternatives

#### A. If `showmount -e` hangs or fails (`RPC: Unable to receive`):
Firewalls might block the standard RPC portmapper. Use Nmap NSE script as an alternative to query NFS directly:
```bash
sudo nmap -p 111,2049 --script nfs-showmount,nfs-ls 10.129.202.41
```

#### B. Check if NFS Daemons are Alive via `rpcinfo`:
```bash
rpcinfo -p 10.129.202.41
# Look for 'nfs' (program 100003) and 'mountd' (program 100005)
```

---
## Related Source : 
[[_Network Commands|Network Commands]], [[Important Ports]], [[Nmap]], [[CPTS/Footprinting/Sections/NFS|CPTS Footprinting - NFS]]
