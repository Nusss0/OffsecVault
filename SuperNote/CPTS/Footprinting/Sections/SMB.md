---
tags:
  - HTB
  - Material
  - CPTS
  - Networking
  - Protocol
---
>Server Message Block (SMB) is a client-server protocol that regulates access to files and entire directories and other network resources such as printers, routers, or interfaces released for the network

> [!info]- About SMB
>  [SMB](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688) first became available to a broader public, for example, as part of the OS/2 network operating system LAN Manager and LAN Server. Since then, the main application area of the protocol has been the Windows operating system series in particular, whose network services support SMB in a downward-compatible manner - which means that devices with newer editions can easily communicate with devices that have an older Microsoft operating system installed. With the free software project Samba, there is also a solution that enables the use of SMB in Linux and Unix distributions and thus cross-platform communication via SMB.

The SMB protocol enables the client to **communicate** with **other participants in the same network** to access files or services shared with it on the network. The SMB protocol enables the client to communicate with other participants in the same network to access files or services shared with it on the network. And before all that process, both parties must establish a **connection**.

SMB use TCP for this purpose, which provides for a three-way handshake between client and server before a connection is finally established.

> [!note]- Shares File & Acess Control
>An SMB server can provide arbitrary parts of its local file system as shares. Therefore the hierarchy visible to a client is partially independent of the structure on the server.
>Access rights are defined by `Access Control Lists` (`ACL`). They can be controlled in a fine-grained manner based on attributes such as `execute`, `read`, and `full access` for individual users or user groups. The ACLs are defined based on the shares and therefore do not correspond to the rights assigned locally on the server.

---
## Samba
> Samba is an alternative implementation of the SMB server, which is developed for Unix-based operating systems.