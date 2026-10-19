## Challenge Info

**Platform:** OverTheWire - Leviathan
**Tags :** #Challenge #ReverseEngineering 
**Completion Date & Time :** 2026 - 01 - 15 / 17:02

---
## FLAG : `0dyxT7F4QD`

---
## Solution :

### Step 1 : Check for home directory

```shell
leviathan4@leviathan:~$ ls -la
total 24
drwxr-xr-x   3 root root       4096 Oct 14 09:27 .
drwxr-xr-x 150 root root       4096 Oct 14 09:29 ..
-rw-r--r--   1 root root        220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root root       3851 Oct 14 09:19 .bashrc
-rw-r--r--   1 root root        807 Mar 31  2024 .profile
dr-xr-x---   2 root leviathan4 4096 Oct 14 09:27 .trash
```
We found `.trash` folder, it seems suspicious. Try to look for it.

```shell
leviathan4@leviathan:~/.trash$ ls -la
total 24
dr-xr-x--- 2 root       leviathan4  4096 Oct 14 09:27 .
drwxr-xr-x 3 root       root        4096 Oct 14 09:27 ..
-r-sr-x--- 1 leviathan5 leviathan4 14940 Oct 14 09:27 bin
```
We got `bin` file which is setuid file. 
### Step 2 :  Try to run `bin` file

```shell
leviathan4@leviathan:~/.trash$ ./bin
00110000 01100100 01111001 01111000 01010100 00110111 01000110 00110100 01010001 01000100 00001010 
```

It seems like we get a set of binary, let's try to find where does it comes from :
```shell
leviathan4@leviathan:~/.trash$ ltrace ./bin
__libc_start_main(0x80490ad, 1, 0xffffd444, 0 <unfinished ...>
fopen("/etc/leviathan_pass/leviathan5", "r")                            = 0
+++ exited (status 255) +++
```

Alright, based on the output above, its clear that the binary is an output from `leviathan5` file which is password file. So, to retrieve the password, we need to translate the binary. There are so many ways to translate it, we could do it by manual or using shell.

### Step 3 : Translate the binary

Here we will use `Perl` to translate the binary.
```shell
leviathan4@leviathan:~/.trash$ echo 00110000 01100100 01111001 01111000 01010100 00110111 01000110 00110100 01010001 01000100 00001010 | tr -d ' ' | perl -lpe '$_=pack"B*",$_'
0dyxT7F4QD
```

We use `tr` to remove the spaces from the binary input because `perl` expect a continous binary input.

---
### Key Takeaways : 
- To easily convert binary to ASCII we could use `perl`
- But `B*` in `perl` doesn't accept spaces in input, so we need to delete it using `tr`

---
## Related Concepts : 
[[tr]], [[perl]], [[ltrace]], [[SetUID Files]]

---
## Next Challenge :
[[Leviathan (5 -> 6)]]