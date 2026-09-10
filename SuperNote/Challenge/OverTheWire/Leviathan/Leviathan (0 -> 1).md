## Challenge Info

**Platform:** OverTheWire - Leviathan
**Category:** #LinuxBasic #Challenge 
**Completion Date & Time :** 2026 - 01 - 13 / 12:17

---
## FLAG : `3QJ3TgzHDq`

---
## Solution :

### Step 1 : Find related file
If we use `ls` only, we could only see a blank result. So we need to check for hidden files.
```bash
ls -la
```

Output :
```shell
total 24
drwxr-xr-x   3 root       root       4096 Oct 14 09:27 .
drwxr-xr-x 150 root       root       4096 Oct 14 09:29 ..
drwxr-x---   2 leviathan1 leviathan0 4096 Oct 14 09:27 .backup
-rw-r--r--   1 root       root        220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root       root       3851 Oct 14 09:19 .bashrc
-rw-r--r--   1 root       root        807 Mar 31  2024 .profile
```

### Step 2 : Check `.backup` folder

```bash
cd .bakcup
ls -la
```

Output : 
```shell
total 140
drwxr-x--- 2 leviathan1 leviathan0   4096 Oct 14 09:27 .
drwxr-xr-x 3 root       root         4096 Oct 14 09:27 ..
-rw-r----- 1 leviathan1 leviathan0 133259 Oct 14 09:27 bookmarks.html
```

### Step 3 : Check bookmarks.html
If we use `cat` directly, it would probably messed up by showing too much informations and messages. So, we should use `grep` instead to retrieve the information/keyword we want.
```bash
grep "pass" bookmarks.html
```

Output : 
```shell
<DT><A HREF="http://leviathan.labs.overthewire.org/passwordus.html | This will be fixed later, the password for leviathan1 is 3QJ3TgzHDq" ADD_DATE="1155384634" LAST_CHARSET="ISO-8859-1" ID="rdf:#$2wIU71">pasword to leviathan1</A>
```

---
### Key Takeaways : 
- Hidden files require `ls -la` to be visible. 
- Instead of showing all text, we could use `grep` to show keyword we want.

---
## Related Concepts : 
[[cd]], [[ls]], [[grep]], [[Hidden Files in Linux]]

---
## Next Challenge :
[[Leviathan (1 -> 2)]]