## Definition
> **Assembly Language** is a low-level programming language that provides a direct representation of machine code instructions. Each assembly instruction typically corresponds to one machine instruction that the CPU executes. It's used for understanding program behavior at the hardware level, reverse engineering, exploit development, and performance-critical code.

---
## Tags 
#Material #BinaryExploitation #Assembly

---
## Architecture
This documentation covers **x86-64 (64-bit)** assembly with **Intel syntax**.

**Intel vs AT&T Syntax:**
- **Intel**: `mov dest, src` (destination first)
- **AT&T**: `mov src, dest` (source first, uses % and $ prefixes)

We use Intel syntax as it's more common in CTF challenges and reverse engineering.

---
## Assembly Topics

### Fundamentals
- [[Writing Assembly Code]] - Complete guide to writing, compiling, and running x86-64 assembly
- [[Assembly - Registers]] - Understanding x64 registers and their purposes
- [[RIP-Relative Addressing]] - Position Independent Code (PIC) and relative addressing mechanics

### Instructions by Category
- [[Assembly - Data Movement]] - MOV, LEA, XCHG instructions
- [[Assembly - Arithmetic Operations]] - ADD, SUB, INC, DEC, MUL, DIV
- [[Assembly - Logic & Bitwise]] - AND, OR, XOR, NOT, SHL, SHR

### Program Flow
- [[Assembly - Control Flow]] - JMP, CMP, conditional jumps (JE, JNE, JG, etc.)
- [[Assembly - Stack Operations]] - Understanding the stack, PUSH, POP

---
## Tools for Assembly

| Tool | Purpose |
|------|---------|
| **GDB** | Debug and step through assembly instructions |
| **objdump** | Disassemble compiled binaries |
| **nasm** | Assemble .asm files to machine code |
| **radare2** | Reverse engineering and disassembly |
| **pwntools** | Python library for exploit development |

---
## Assembly Syntax Quick Preview
```asm
; Intel Syntax (what we use)
mov rax, 5          ; Move 5 into RAX register
add rax, rbx        ; Add RBX to RAX
push rax            ; Push RAX onto stack
pop rbx             ; Pop from stack into RBX
call function       ; Call a function
ret                 ; Return from function

; AT&T Syntax (for reference)
movq $5, %rax       ; Same as: mov rax, 5
addq %rbx, %rax     ; Same as: add rax, rbx
```

---
## Important Concepts

### Program Counter
- **RIP (Instruction Pointer)**: Points to the next instruction to execute
- Cannot be directly modified (use JMP, CALL, RET instead)

### Stack Growth
- Stack grows **downward** (from high memory addresses to low)
- **RSP (Stack Pointer)**: Always points to top of stack
- PUSH decreases RSP, POP increases RSP

### Operand Sizes
| Size | Suffix | Bits | Example |
|------|--------|------|---------|
| Byte | `b` | 8 | `al`, `bl` |
| Word | `w` | 16 | `ax`, `bx` |
| Double Word | `d` | 32 | `eax`, `ebx` |
| Quad Word | `q` | 64 | `rax`, `rbx` |

---
## Others:
- For instruction reference: Intel® 64 and IA-32 Architectures Software Developer Manuals
- Online assembler/disassembler: https://defuse.ca/online-x86-assembler.htm
- Assembly tutorials: https://www.cs.virginia.edu/~evans/cs216/guides/x86.html

---
## Related Source:
- [[Writing Assembly Code]] - Practical guide to authoring & compiling assembly
- [[GDB]] - Essential for debugging assembly