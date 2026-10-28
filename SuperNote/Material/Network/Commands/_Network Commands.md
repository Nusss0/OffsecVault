# Network Commands

A collection of standard command-line tools and protocol clients used to communicate with, interrogate, and transfer files across network services.

---

## File Transfer & Protocol Clients
- [ ] [[showmount]] - Utility to query the remote NFS mount daemon (ports 111/2049) to discover exported network shares.
- [ ] [[Material/Linux/CLI/mount|mount]] - System command to mount remote NFS shares (`-t nfs -o nolock`) or SMB shares (`-t cifs`) directly to local filesystem.
- [ ] [[ftp]] - Built-in command-line client for File Transfer Protocol (TCP port 21) to navigate directories, download, and upload files.
- [ ] [[curl]] - Versatile CLI tool used to transfer data to or from a server supporting HTTP, HTTPS, FTP, SFTP, and more.
- [ ] [[smbclient]] - Command-line client to interact with SMB/CIFS network shares (Windows & Samba), featuring an FTP-like interface.
- [ ] [[RPCclient]] - Tool to execute client-side MS-RPC functions to query users, groups, and domains over MSRPC/SMB (port 135/445).

## Network Interrogation & Packet Analysis
- [ ] [[Netcat]] - The TCP/IP Swiss Army knife for port scanning, banner grabbing, transferring files, and spawning reverse/bind shells.
- [ ] [[tshark]] - Terminal-based network protocol analyzer and CLI version of Wireshark for capturing and parsing `.pcap` packet streams.
