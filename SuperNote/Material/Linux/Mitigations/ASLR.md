## Definition
> **ASLR (Address Space Layout Randomization)** is an operating system kernel-level defense that randomizes the memory locations of program memory segments—specifically the **Stack**, **Heap**, and **Libraries (libc, ld.so)**—every time a program runs.

---
## Tags 

#Material #LinuxBasic #ASLR #Mitigation #OperatingSystem 

---
## ASLR vs PIE

>[!note] Distinction
>- **ASLR**: Controlled by the **Kernel**. Randomizes the stack, heap, and loaded shared libraries (`libc`).
>- **PIE**: Controlled by the **Compiler** (`gcc -fPIE -pie`). Randomizes the main executable code segment (`.text`, `.plt`, `.got`, `.data`).
>- If a binary has **No PIE** but the OS has **ASLR enabled**: The binary's `.text` section is fixed (e.g. `0x400000`), but the stack and libc addresses will still be randomized!

---
## Linux ASLR Configuration

In Linux, ASLR state is controlled via `/proc/sys/kernel/randomize_va_space`:

| Value | Mode | Description |
| :---: | :--- | :--- |
| **0** | Disabled | No randomization. Everything (stack, heap, libs) is fixed. |
| **1** | Partial | Randomizes stack, mmap libraries, and VDSO. |
| **2** | Full | Randomizes stack, heap (brk), mmap libraries, and VDSO *(default on modern Linux)*. |

Inspect or toggle:
```bash
cat /proc/sys/kernel/randomize_va_space
# Disable ASLR (requires root)
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

---
## Bypass Techniques

1. **Information Leak**:
   Leak a pointer pointing to libc or the stack (via format string, uninitialized read, etc.) to calculate the base address.
2. **NOP Sledding**:
   For randomized stacks where execution is permitted (NX disabled), a large [[NOP Sled]] broadens the valid landing zone.
3. **ROP in Non-PIE Binaries**:
   If the binary itself lacks PIE, gadgets in the binary's code segment (`0x400000`) can be called reliably regardless of ASLR.

---
## Related Concepts : 
[[PIE]], [[NOP Sled]], [[Buffer Overflow]], [[ROP]], [[NX]], [[Stack Canary]]
