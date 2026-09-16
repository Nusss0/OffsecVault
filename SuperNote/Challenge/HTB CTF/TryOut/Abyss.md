---
Platform: HTB - Try Out 2026
Tittle: Abyss
Date & Tme: 2026 - 09 - 11 10:44
tags:
  - Challenge
  - BinaryExploitation
  - ROP
---
---
## FLAG : `{}`

---
## Solution :

File security : 
```shell
┌──(nus㉿Anomaly12)-[~/pwn_abyss/challenge]
└─$ checksec --file=abyss
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   No canary found   NX enabled    No PIE          No RPATH   No RUNPATH   79 Symbols	  No	0		3		abyss

```

First, let's understand the Code flow : 
1. The program will check the `.creds` file as the username and password for login later
2. Next, it will ask for comamand, `0` for login.
3. The `cmd_read` will read any file name that we input, but it will check whether we've login or not.
4. It will take too much time if we try to bruteforce the credential. 

The vulnerability : 
1. Check the `cmd_login`, the code that used to copy `buffer` into `user/pass` has the same mechanism with `strcpy`, it will copy anything untill it find `\x00`. And the input source `buffer` is from `read()` function, which won't add `\x00` in the end of buffer (Even if there were memset `\x00`, it was useless because anything we use as buffer will overwrite it).
2. The layout of the stack is : 
	`Low : [buf][user][pass][0x10 padding][int i][rbp][ret_address] : High`
3. So, the idea is, we will overflow the pass, so it will reach ret address. But the problem is we know the read will only take 512bytes, and we know that pass could hold up to 512 bytes. 
4. The interesting part is, the `strcpy` method we discuss in point 1 before. If we fill the `buf` to 512 full, in C it will be `buf[512]`. While it hasn't found `\x00` , the value of `i` will increase, so  it will acess `buf[513]` untill it found `null terminator`. This mean, after `512 bytes` of buffer we input, it will continue overflowing the remaining stack `padding, i, rbp, return address`, based on the value of `user`. *Note : `buf[513] is the area of user*.

---
### Key Takeaways : 



---
## Related Concepts : 
[[]]

