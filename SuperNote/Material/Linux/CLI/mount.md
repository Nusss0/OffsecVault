---
tags:
  - Commands
  - Linux
  - Storage
  - NFS
  - SMB
  - Footprinting
  - Material
---
## Function
> **`mount`** is a fundamental Linux system utility used to attach storage devices, disk partitions, disk images (ISO/IMG), or remote network shares (NFS/CIFS) to a specific directory (called a *mount point*) in the local Linux filesystem tree. Once mounted, remote or external files can be viewed, searched, and edited just like local files.

---
## Syntax
```shell
sudo mount -t <filesystem_type> -o <options> <device_or_remote_source> <local_mount_point>
```

---
## Options :

| **Flag** | **Argument** | **Description** |
| :---: | :--- | :--- |
| **`-t`** | `<type>` | **Filesystem type** (`nfs`, `cifs`, `ext4`, `vfat`, `iso9660`, `auto`). |
| **`-o`** | `<options>` | **Mount options** (comma-separated): `nolock`, `vers=3`, `ro`, `rw`, `username=`, `password=`. |
| **`-v`** | None | Verbose mode; displays detailed diagnostic output during mount negotiation. |
| **`-l`** | None | Lists all currently mounted filesystems on the system along with labels. |
| **`-r`** | None | Mounts the filesystem as read-only (equivalent to `-o ro`). |
| **`-w`** | None | Mounts the filesystem as read-write (equivalent to `-o rw`, default). |

### Essential `-o` Options for Pentesting:
* **`nolock`:** Disables file locking (prevents NFS client hangs on Windows servers or firewalled RPC daemons).
* **`vers=3` / `vers=2`:** Forces specific NFS protocol versions (essential for legacy targets).
* **`username=<user>,password=<pass>`:** Credentials used when mounting Windows SMB shares via `cifs`.

---
## Common Use Cases & Real-World Pentesting Examples

### 1. Mounting a Remote NFS Share (Lab Standard)
After discovering an exported path via `showmount -e <target_ip>`:
```bash
# 1. Create a local folder to serve as the mount point:
sudo mkdir -p /mnt/nfs

# 2. Mount the remote NFS export locally:
sudo mount -t nfs -o nolock,vers=3 10.129.202.41:/ /mnt/nfs

# 3. Navigate and search through files:
cd /mnt/nfs && ls -la
```

---

### 2. Mounting a Remote Windows SMB Share
Instead of using interactive `smbclient`, mount the entire share as a local drive:
```bash
# 1. Create mount directory:
sudo mkdir -p /mnt/smb

# 2. Mount CIFS/SMB share with credentials:
sudo mount -t cifs //10.129.202.41/devshare /mnt/smb -o username=alex,password='lol123!mD'

# 3. Inspect contents:
ls -la /mnt/smb
```

---

### 3. Inspecting Active Mounts
```bash
# Check if your share is currently mounted:
mount | grep -E 'nfs|cifs'

# Check disk space & mount points:
df -hT
```

---

### 4. Clean Unmounting When Finished (`umount`)
Always unmount network shares after completing an assessment:
```bash
# Standard unmount:
sudo umount /mnt/nfs

# Force / Lazy unmount (if terminal hangs or directory is reported "busy"):
sudo umount -l /mnt/nfs
```

> [!CAUTION] "Target is busy" Error
> If `umount` throws `target is busy`, ensure your terminal is **not** currently inside the `/mnt/nfs` directory (`cd ~` before unmounting).

---
## Related Source : 
[[_Linux CLI Commands|Linux CLI Commands]], [[Material/Network/Commands/showmount|showmount]], [[Material/Network/Important Ports|Important Ports]], [[CPTS/Footprinting/Sections/NFS|CPTS Footprinting - NFS]]
