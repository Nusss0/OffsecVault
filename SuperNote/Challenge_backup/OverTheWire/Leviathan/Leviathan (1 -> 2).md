## Challenge Info

**Platform:** OverTheWire - Leviathan
**Tags :** #Challenge #ReverseEngineering 
**Completion Date & Time :** 2026 - 01 - 14 / 23:10

---
## FLAG : `NsN1HwFoyN`

---
## Solution :

### Step 1 : Check for home directory.
```shell
leviathan1@leviathan:~$ ls -la
total 36
drwxr-xr-x 2 root root 4096 Oct 14 09:27 .
drwxr-xr-x 150 root root 4096 Oct 14 09:29 ..
-rw-r--r-- 1 root root 220 Mar 31 2024 .bash_logout
-rw-r--r-- 1 root root 3851 Oct 14 09:19 .bashrc
-r-sr-x--- 1 leviathan2 leviathan1 15084 Oct 14 09:27 check
-rw-r--r-- 1 root root 807 Mar 31 2024 .profile
```

As we can see here, there are something promising `check` files. It is a setuid file and also executeable.
### Step 2 : Try to execute `./check`

Before this step, i have tried to read the whole file using `strings` command, but it throws up all strings in the binary. So, we run it directly to check it.

```shell
leviathan1@leviathan:~$ ./check
password: 3QJ3TgzHDq
Wrong password, Good Bye ...
```

It looks like we need the **Correct** password continue. As we see in **Step 1**, we could know that the owner of this file is `leviathan2`, which mean we could probably access the password file.

### Step 3 : Try using `ltrace`

```shell
leviathan1@leviathan:~$ ltrace ./check
__libc_start_main(0x80490ed, 1, 0xffffd464, 0 <unfinished ...>
printf("password: ")                                                  = 10
getchar(0, 0, 0x786573, 0x646f67password: 3QJ3TgzHDq)                 = 51
getchar(0, 51, 0x786573, 0x646f67)                                    = 81
getchar(0, 0x5133, 0x786573, 0x646f67)                                = 74
strcmp("3QJ", "sex")                                                  = -1
puts("Wrong password, Good Bye ..."Wrong password, Good Bye ...)      = 29
+++ exited (status 0) +++
```

Got it, we could see this process called `strcmp("3QJ", "sex")`, it means it compare our 3 first input with a string `"sex"`.

### Step 4 : Try the correct password.

```shell
leviathan1@leviathan:~$ ./check
password: sex
$ whoami
leviathan2
```

This seem work very well. We could acess a shell with leviathan2 privilleges.

### Step 5 : Find the Password file.

```shell
$ cat /etc/leviathan_pass/leviathan2
NsN1HwFoyN
```

As we know, all of the leviathan passwords are stored in `/etc/leviathan_pass` folders. 
Finally we got the password  `"NsN1HwFoyN"`

---
### Key Takeaways :
- Since we knew `./check` is a process file. We could use `ltrace` to trace what functions a process called.

---
## Related Concepts : 
[[ltrace]], [[cat]], [[whoami]], [[ls]], [[SetUID Files]]

---
## Next Challenge :
[[Leviathan (2 -> 3)]]