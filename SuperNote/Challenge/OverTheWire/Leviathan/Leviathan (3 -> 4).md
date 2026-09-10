## Challenge Info

**Platform:** OverTheWire
**Tags :** #Challenge #ReverseEngineering 
**Completion Date & Time :** 2026 - 01 - 15 / 12:15

---
## FLAG : `WG1egElCvO`

---
## Solution :

### Step 1 : Check for home directory.

```shell
leviathan3@leviathan:~$ ls -la
total 40
drwxr-xr-x   2 root       root        4096 Oct 14 09:27 .
drwxr-xr-x 150 root       root        4096 Oct 14 09:29 ..
-rw-r--r--   1 root       root         220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root       root        3851 Oct 14 09:19 .bashrc
-r-sr-x---   1 leviathan4 leviathan3 18100 Oct 14 09:27 level3
-rw-r--r--   1 root       root         807 Mar 31  2024 .profile
```

### Step 2 : Check for `level3` file.

```shell
leviathan3@leviathan:~$ ./level3
Enter the password> hi
bzzzzzzzzap. WRONG
```
This seems like we need a correct password to continue. Try to use `ltrace`
```shell
leviathan3@leviathan:~$ ltrace ./level3
__libc_start_main(0x80490ed, 1, 0xffffd464, 0 <unfinished ...>
strcmp("h0no33", "kakaka")                                          = -1
printf("Enter the password> ")                                      = 20
fgets(Enter the password> password
"password\n", 256, 0xf7fae5c0)                                      = 0xffffd23c
strcmp("password\n", "snlprintf\n")                                 = -1
puts("bzzzzzzzzap. WRONG"bzzzzzzzzap. WRONG)                        = 19
+++ exited (status 0) +++
```

We could see the correct input is `snlprintf`. 

```
leviathan3@leviathan:~$ ./level3
Enter the password> snlprintf
[You've got shell]!
$ 
```

### Step 3 : Execute `cat` command.

```shell
$ cat /etc/leviathan_pass/leviathan4
WG1egElCvO
```

We have got the password `WG1egElCvO`. 

---
### Key Takeaways : 
- This level is same as  [[Leviathan (1 -> 2)]], there are no anything to learn.
- This program calls a function to compare and validate our input.

---
## Related Concepts : 
[[ltrace]], [[SetUID Files]]

---
## Next Challenge :
[[Leviathan (4 -> 5)]]