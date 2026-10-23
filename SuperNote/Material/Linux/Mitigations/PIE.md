## Definition
> **PIE (Position Independent Executable)** is a binary protection mechanism where the executable binary is compiled as shared-library-like code, allowing the operating system kernel to load all executable code and data sections at a randomized base address in virtual memory upon every execution.

---
## Tags 

#Material #BinaryExploitation #PIE #Mitigation #Linux 

---
## How PIE Works

- **Without PIE (No PIE)**:
  The binary is loaded at a fixed virtual address (typically `0x400000` for 64-bit ELF or `0x08048000` for 32-bit ELF). Function addresses like `win()` or `main()` are known in advance and do not change between executions.
- **With PIE (PIE Enabled)**:
  The base address of the binary changes on every execution (e.g. `0x55xxxxxx0000`). All jumps and memory references inside the binary use **relative addressing** (RIP-relative: `[rip + offset]`).

---
## Memory Alignment & Offset Permanence

>[!important] The Last 3 Nibbles (12 Bits) Never Change!
>Because virtual memory is loaded in **4 KB (4096 bytes) pages** (`0x1000`), the base address always ends with `0x000`. This means the last **3 hex digits (12 bits)** of any function or instruction address are identical across runs.
>
>For example:
>- Target function offset in ELF: `0x000012d4`
>- Loaded run 1: `0x55a3c9b812d4`
>- Loaded run 2: `0x5601fa8712d4`
>Notice that `...2d4` never changes!

---
## Bypass Techniques

1. **Information Leak**:
   Format string attacks or buffer over-reads that leak any pointer from the binary (such as saved return address from `__libc_start_main` or local function pointers). By subtracting the known function offset from the leaked address, the attacker calculates the exact base address:
   $$\text{Binary Base} = \text{Leaked Address} - \text{Known Offset}$$
2. **Partial Overwrite (Bruteforce)**:
   In a stack buffer overflow, instead of overwriting the full 8-byte pointer, overwrite only the **lowest 2 bytes (16 bits)**:
   - Lowest 12 bits are known and fixed.
   - Only 4 bits (1 hex nibble) must be guessed.
   - The probability of success is $\frac{1}{16}$ (takes only ~16–30 attempts on average).

---
## Related Concepts : 
[[ret2win]], [[Buffer Overflow]], [[ASLR]], [[checksec]], [[pwntools]], [[GDB]]
