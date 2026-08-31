## Question 1
>Enumerate the NFS service and submit the contents of the flag.txt in the "nfs" share as the answer.

```shell
┌──(nus㉿Anomaly12)-[~]
└─$ showmount -e $ip
Export list for 10.129.152.244:
/var/nfs      10.0.0.0/8
/mnt/nfsshare 10.0.0.0/8
```

From the list of shares above, we could see there are 2 shares within the services.
Let's us mount to the NFS Service :

```shell
┌──(nus㉿Anomaly12)-[~]
└─$ mkdir target
┌──(nus㉿Anomaly12)-[~]
└─$ sudo mount -t nfs $ip:/ target
[sudo] password for nus:
┌──(nus㉿Anomaly12)-[~]
└─$ cd target
┌──(nus㉿Anomaly12)-[~/target]
└─$ tree
.
├── mnt
│   └── nfsshare
│       └── flag.txt
└── var
    └── nfs
        └── flag.txt

5 directories, 2 files
```

Now we find there are two flags here, let's try to obtain the flag from nfs share first.
```shell
┌──(nus㉿Anomaly12)-[~/target]
└─$ cat var/nfs/flag.txt
HTB{hjglmvtkjhlkfuhgi734zthrie7rjmdze}
```

### Answer : `HTB{hjglmvtkjhlkfuhgi734zthrie7rjmdze}`

---
## Question 2
>Enumerate the NFS service and submit the contents of the flag.txt in the "nfsshare" share as the answer.

We have find the share on Question 1, so let's just retrieve the flag : 
```shell
┌──(nus㉿Anomaly12)-[~/target]
└─$ cat mnt/nfsshare/flag.txt
HTB{8o7435zhtuih7fztdrzuhdhkfjcn7ghi4357ndcthzuc7rtfghu34}
```

### Answer : `HTB{8o7435zhtuih7fztdrzuhdhkfjcn7ghi4357ndcthzuc7rtfghu34}`

---
## Unmount Target 
```shell
┌──(nus㉿Anomaly12)-[~]
└─$ sudo umount target
```
