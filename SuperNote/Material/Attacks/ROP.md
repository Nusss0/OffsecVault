## Definition
> **Return-Oriented Programming (ROP)** is an advanced exploitation technique used to bypass security protections like **NX/DEP (No-Execute)**. Instead of injecting and executing new shellcode, the attacker stitches together short sequences of machine instructions already present in executable memory segments (the binary or libc) that terminate in a `ret` instruction. These instruction sequences are called **gadgets**.

---
## Tags 

#Material #BinaryExploitation #ROP #Attack 

---
## Core Concepts

### 1. Gadgets
A gadget is a short snippet of code ending with `ret` (`0xc3`).
Example gadgets:
```asm
pop rdi ; ret
pop rsi ; pop rdx ; ret
mov [rax], rdx ; ret
```

When `ret` is executed, the CPU pops the top value off the stack into the instruction pointer (`RIP`), transferring control to whatever address is on the stack.

### 2. The ROP Chain
By placing a sequence of gadget addresses and their corresponding data arguments on the stack, the attacker chains multiple gadgets together like a virtual program.

```
Stack Layout during ROP:
+-----------------------------------+
| Address of "pop rdi; ret" gadget  |  <-- Saved RIP points here
+-----------------------------------+
| Address of "/bin/sh" string       |  <-- Popped into RDI register (1st argument in x64)
+-----------------------------------+
| Address of system() function      |  <-- ret jumps to system("/bin/sh")
+-----------------------------------+
```

---
## Calling Conventions Reference

>[!info] x86 (32-bit) vs x86-64 (64-bit)
>- **x86 (32-bit)**: Arguments are passed directly on the **stack**:
>  `[Address of Function] + [Fake Return Address] + [Arg 1] + [Arg 2] ...`
>- **x86-64 (64-bit)**: First 6 integer/pointer arguments are passed via **registers**:
>  1. `RDI`
>  2. `RSI`
>  3. `RDX`
>  4. `RCX`
>  5. `R8`
>  6. `R9`
>  Additional arguments are pushed to the stack. Gadgets like `pop rdi; ret` are essential to populate these registers before calling functions.

---
## Finding Gadgets
Using tools such as [[ROPgadget]]:
```shell
ROPgadget --binary ./vuln --only "pop|ret"
```

---
## Related Concepts : 
[[Buffer Overflow]], [[ROPgadget]], [[Assembly - Control Flow]], [[Assembly - Stack Operations]], [[NX]], [[ASLR]], [[pwntools]]
