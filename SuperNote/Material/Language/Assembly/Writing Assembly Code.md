## Definition
> **Writing Assembly Code** covers the complete practical workflow of authoring standalone x86-64 assembly source files (`.s` or `.asm`), understanding assembly directives, managing the Linux System Call ABI, and assembling/linking machine code into executables or raw shellcode payloads.

---
## Tags 
#Material #Assembly #x86-64 #Shellcode #BinaryExploitation #Linux 

---
## 1. Boilerplate Template (GNU Assembler / GAS)

When writing standalone assembly in Linux using GCC or `as`, always start with this standard boilerplate:

```asm
.intel_syntax noprefix    # Use Intel syntax without requiring '%' on registers
.global _start            # Export entry point symbol to the linker

_start:
    # Instructions start here
```

> [!important] Directives Explained
> - **`.intel_syntax noprefix`**: Informs the GNU assembler to parse `mov dest, src` (Intel style) rather than default AT&T syntax, and permits register names like `rax`, `rdi` without `%` prefixes.
> - **`.global _start`**: Declares `_start` as the program's global entry point. Unlike C's `main()`, `_start` is the raw kernel entry point. Note the mandatory space between `.global` and `_start`.
> - **Comments**: In GNU Assembler on Linux x86-64, always use **`#`** for comments. Semicolons (`;`) act as **statement separators** (command delimiters) and will cause compilation syntax errors if used for inline comments.

---
## 2. Linux x86-64 Syscall Convention (ABI)

Linux communicates with user-space applications via System Calls. To invoke a syscall, load parameters into specific registers, then execute **`syscall`**:

| Parameter | Register | Description | Example |
| :--- | :--- | :--- | :--- |
| **Syscall ID** | `RAX` | Operating system function number | `0` = read, `1` = write, `2` = open, `60` = exit |
| **Arg 1** | `RDI` | First parameter | File descriptor, pointer to path |
| **Arg 2** | `RSI` | Second parameter | Pointer to memory buffer, flags |
| **Arg 3** | `RDX` | Third parameter | Count (number of bytes) |
| **Arg 4** | `R10` | Fourth parameter | *(Used in advanced calls like `mmap`)* |
| **Arg 5** | `R8` | Fifth parameter | *(Optional)* |
| **Arg 6** | `R9` | Sixth parameter | *(Optional)* |
| **Return** | `RAX` | Output/Result after `syscall` finishes | Return fd, bytes read, error status (`-1`) |

---
## 3. Standard Pattern: Open $\rightarrow$ Read $\rightarrow$ Write $\rightarrow$ Exit

A complete, working bare-metal assembly implementation of reading a file and printing it to the terminal:

```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. sys_open("/flag", O_RDONLY=0)
    lea rdi, [rip + flag_path]   # RDI = pointer to filename string
    xor rsi, rsi                 # RSI = 0 (O_RDONLY)
    mov rax, 2                   # RAX = 2 (sys_open)
    syscall                      # Return fd is stored into RAX

    # 2. sys_read(fd, buffer, count)
    mov rdi, rax                 # RDI = fd (moved from RAX immediately)
    mov rsi, rsp                 # RSI = stack pointer (buffer location)
    mov rdx, 0x100               # RDX = 256 bytes to read
    xor rax, rax                 # RAX = 0 (sys_read)
    syscall                      # Return bytes read is stored into RAX

    # 3. sys_write(fd, buffer, count)
    mov rdx, rax                 # RDX = bytes read from previous syscall
    mov rdi, 1                   # RDI = 1 (stdout / terminal screen)
    mov rsi, rsp                 # RSI = pointer to buffer in stack
    mov rax, 1                   # RAX = 1 (sys_write)
    syscall

    # 4. sys_exit(0)
    xor rdi, rdi                 # RDI = 0 (exit status SUCCESS)
    mov rax, 60                  # RAX = 60 (sys_exit)
    syscall

flag_path:
    .string "/flag"              # ASCII string terminated with null byte (\0)
```

---
## 4. Defining Data & Variables

Labels act as memory address markers. Data definitions are placed at the bottom or inside `.data`/`.rodata` sections:

- **`.string "text"`** (or `.asciz`): Inserts an ASCII string automatically terminated with a null byte (`\0`).
- **`.ascii "text"`**: Inserts an ASCII string *without* a terminating null byte.
- **`.byte 0x01, 0x02`**: Inserts raw machine bytes directly into memory.
- **`.quad 0x12345678`**: Inserts an 8-byte (64-bit) integer value.

---
## 5. Compiling & Assembling Workflows

Depending on the tools at hand, choose the best compilation method:

### Method A: Standalone Executable (GCC)
Best for testing code locally on Linux:
```bash
# Compile directly into an ELF executable (without standard C runtime)
gcc -nostdlib -static solve.s -o solve

# Run it
./solve
```
> *Tip: If testing Self-Modifying Code (SMC) locally, add `-Wl,-N` so the `.text` segment has Write permissions.*

### Method B: Extracting Raw Shellcode (`objcopy`)
Best for extracting pure binary machine bytes to pipe into a challenge binary:
```bash
# 1. Compile to object file or ELF
gcc -nostdlib -static solve.s -o solve.elf

# 2. Extract only executable instructions (.text)
objcopy -O binary --only-section=.text solve.elf payload.bin

# 3. Inject into target
./challenge < payload.bin
```

### Method C: One-Step Assembly with NASM
NASM defaults to Intel syntax and flat binary output:
```bash
nasm -f bin solve.asm -o payload.bin
```

### Method D: Python Automation with `pwntools`
No temporary files required; directly assembles in memory:
```python
from pwn import *
context.arch = 'amd64'

code = '''
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    mov rax, 2
    syscall
    ...
flag_path:
    .string "/flag"
'''

payload = asm(code)
p = process('./challenge')
p.send(payload)
p.interactive()
```

---
## 6. Common Pitfalls & Debugging Tips

1. **Semicolon Comment Trap**:
   `;` is NOT a comment in GNU Assembler on x86-64 Linux; it is a command separator! Always use `#` for comments.
2. **Missing Space in `.global _start`**:
   Writing `.global_start` will cause `unknown pseudo-op` errors.
3. **Overwriting `RAX` Too Early**:
   `sys_open` leaves `fd` in `RAX`. You must copy it to `RDI` (`mov rdi, rax`) *before* clearing or setting `RAX` for the next syscall (`xor rax, rax`).
4. **Hardcoded Memory Addresses**:
   Avoid absolute addresses in shellcode. Always use `[rip + label]` for **Position Independent Code (PIC)**.

---
## Related Concepts : 
[[Assembly]], [[Assembly - Registers]], [[Assembly - Data Movement]], [[RIP-Relative Addressing]], [[Self-Modifying Code]], [[System Calls]]
