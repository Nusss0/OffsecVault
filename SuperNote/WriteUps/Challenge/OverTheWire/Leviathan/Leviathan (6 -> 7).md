## Challenge Info

**Platform:** OverTheWire - Leviathan
**Tags :** #Challenge #ReverseEngineering 
**Completion Date & Time :** 2026 - 01 - 15 / 18:28

---
## FLAG : `qEs5Io5yM8`

---
## Solution :

### Step 1 : Check for home directory

```shell
leviathan6@leviathan:~$ ls -la
total 36
drwxr-xr-x   2 root       root        4096 Oct 14 09:27 .
drwxr-xr-x 150 root       root        4096 Oct 14 09:29 ..
-rw-r--r--   1 root       root         220 Mar 31  2024 .bash_logout
-rw-r--r--   1 root       root        3851 Oct 14 09:19 .bashrc
-r-sr-x---   1 leviathan7 leviathan6 15036 Oct 14 09:27 leviathan6
-rw-r--r--   1 root       root         807 Mar 31  2024 .profile
```

We could see a `SUID` file (`leviathan6`) in home directory. Let's try to run it : 
```shell
leviathan6@leviathan:~$ ./leviathan6
usage: ./leviathan6 <4 digit code>
```

It seems like we supposed to guess the 4 digit code. Try to look with `ltrace` with random 4 digit input to trace the function call : 
```shell
leviathan6@leviathan:~$ ltrace ./leviathan6 0000
__libc_start_main(0x80490dd, 2, 0xffffd454, 0 <unfinished ...>
atoi(0xffffd5c4, 0, 0, 0)                                                  = 0
puts("Wrong"Wrong)                                                         = 6
+++ exited (status 0) +++
```

The input is turned to 4 digit integer and no any Comparative Function was called, so it is useless to use `ltrace`. This mean, we should use `GDB` instead. For binary exploitation, we will use `GEF (GDB enhanced feature)`.

Here is the main code in assembly (We use "0000" as random input) :
```asm
   0x080491c6 <+0> :	lea    ecx,[esp+0x4]
   0x080491ca <+4> :	and    esp,0xfffffff0
   0x080491cd <+7> :	push   DWORD PTR [ecx-0x4]
   0x080491d0 <+10>:	push   ebp
   0x080491d1 <+11>:	mov    ebp,esp
   0x080491d3 <+13>:	push   ebx
   0x080491d4 <+14>:	push   ecx
   0x080491d5 <+15>:	sub    esp,0x10
   0x080491d8 <+18>:	mov    eax,ecx
   0x080491da <+20>:	mov    DWORD PTR [ebp-0xc],0x1bd3
   0x080491e1 <+27>:	cmp    DWORD PTR [eax],0x2
   0x080491e4 <+30>:	je     0x8049206 <main+64>
   0x080491e6 <+32>:	mov    eax,DWORD PTR [eax+0x4]
   0x080491e9 <+35>:	mov    eax,DWORD PTR [eax]
   0x080491eb <+37>:	sub    esp,0x8
   0x080491ee <+40>:	push   eax
   0x080491ef <+41>:	push   0x804a008
   0x080491f4 <+46>:	call   0x8049040 <printf@plt>
   0x080491f9 <+51>:	add    esp,0x10
   0x080491fc <+54>:	sub    esp,0xc
   0x080491ff <+57>:	push   0xffffffff
   0x08049201 <+59>:	call   0x8049080 <exit@plt>
   0x08049206 <+64>:	mov    eax,DWORD PTR [eax+0x4]
   0x08049209 <+67>:	add    eax,0x4
   0x0804920c <+70>:	mov    eax,DWORD PTR [eax]
   0x0804920e <+72>:	sub    esp,0xc
   0x08049211 <+75>:	push   eax
   0x08049212 <+76>:	call   0x80490a0 <atoi@plt>
   0x08049217 <+81>:	add    esp,0x10
   0x0804921a <+84>:	cmp    DWORD PTR [ebp-0xc],eax
   0x0804921d <+87>:	jne    0x804924a <main+132>
   0x0804921f <+89>:	call   0x8049050 <geteuid@plt>
   0x08049224 <+94>:	mov    ebx,eax
   0x08049226 <+96>:	call   0x8049050 <geteuid@plt>
   0x0804922b <+101>:	sub    esp,0x8
   0x0804922e <+104>:	push   ebx
   0x0804922f <+105>:	push   eax
   0x08049230 <+106>:	call   0x8049090 <setreuid@plt>
   0x08049235 <+111>:	add    esp,0x10
   0x08049238 <+114>:	sub    esp,0xc
   0x0804923b <+117>:	push   0x804a022
   0x08049240 <+122>:	call   0x8049070 <system@plt>
   0x08049245 <+127>:	add    esp,0x10
   0x08049248 <+130>:	jmp    0x804925a <main+148>
   0x0804924a <+132>:	sub    esp,0xc
   0x0804924d <+135>:	push   0x804a02a
   0x08049252 <+140>:	call   0x8049060 <puts@plt>
   0x08049257 <+145>:	add    esp,0x10
   0x0804925a <+148>:	mov    eax,0x0
   0x0804925f <+153>:	lea    esp,[ebp-0x8]
   0x08049262 <+156>:	pop    ecx
   0x08049263 <+157>:	pop    ebx
   0x08049264 <+158>:	pop    ebp
   0x08049265 <+159>:	lea    esp,[ecx-0x4]
   0x08049268 <+162>:	ret
```

From the code above, here is the main points : 
1. **The programs need an arguments to run**
```asm
   0x080491e1 <+27>: cmp    DWORD PTR [eax],0x2
```
This code compares our Arugments Count with `2`, One for filename and One for `Arguments`.
If it doesnt equal, it will continue and exit with an error messages.

2. **Compare PIN**
```asm
   0x0804921a <+84>:	cmp    DWORD PTR [ebp-0xc],eax
```

This code should be comparing our input with `$eax` register. We could check `$eax` registers :
```shell
gef➤  p/x $eax
$1 = 0x3
```

So, this code directly compare our input with `[$ebp-0xc]`, we could just check for the value saved in `$ebp-0xc`.
```shell
gef➤  x/d $ebp-0xc
0xffffd33c:	7123
```

Now, we have retrieved the pin `7123`.

### Step 2 : Execute `./leviathan6` with correct PIN

```shell
leviathan6@leviathan:~$ ./leviathan6 7123
$ cat /etc/leviathan_pass/leviathan7
qEs5Io5yM8
```

---
### Key Takeaways : 
- Always understand the flow for assembly.

---
## Related Concepts : 
- [[GDB]]
- For other writeup check this web https://mayadevbe.me/posts/overthewire/leviathan/level7/

---
## Next Challenge :
[[Narnia ( 0 )]]