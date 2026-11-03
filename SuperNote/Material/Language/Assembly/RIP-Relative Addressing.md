## Definition
> **RIP-Relative Addressing** (also known as PC-relative addressing) is an addressing mode introduced in the x86-64 architecture where target memory locations are referenced as a signed 32-bit displacement relative to the current Instruction Pointer (**`RIP`**), rather than as an absolute memory address.

---
## Tags 

#Material #Assembly #x86-64 #PIC #Shellcode #BinaryExploitation 

---
## Why It Matters (Absolute vs Relative)

In modern 64-bit binaries and shellcode development, memory layout is rarely static due to **ASLR (Address Space Layout Randomization)**, **PIE (Position Independent Executable)**, or arbitrary memory buffers (such as `mmap()` pages).

- **Absolute Addressing (`mov rdi, 0x401020`)**:
  Hardcodes a fixed memory address. If the binary or shellcode runs at any other base address (e.g. `0x1b895000`), accessing `0x401020` crashes with a **Segmentation Fault**.
- **RIP-Relative Addressing (`lea rdi, [rip + label]`)**:
  Calculates the address as `Current_RIP + Distance`. Because the distance between instructions and data embedded in the shellcode stays constant regardless of where the payload is loaded in RAM, the calculated address is **always valid**. This produces **Position Independent Code (PIC)**.

---
## Mechanics

When the CPU executes an instruction, the `RIP` register already points to the **start of the next instruction**.

```
Address       Machine Code              Assembly Instruction
---------------------------------------------------------------------------------
0x1000        48 8d 3d 19 00 00 00      lea rdi, [rip + 0x19]  # RIP = 0x1007
0x1007        ...                       ...
...           ...                       ...
0x1020        2f 66 6c 61 67 00         .string "/flag"        # Target string
```

### Offset Calculation by Assembler:
$$\text{Offset} = \text{Target Address} - \text{Next Instruction Address (RIP)}$$
$$0x1020 - 0x1007 = \mathbf{+0x19}$$

At runtime, the CPU evaluates:
$$\text{Effective Address} = \text{RIP} + 0x19 = 0x1007 + 0x19 = \mathbf{0x1020} \quad (\&"/flag")$$

---
## Common Use Cases

### 1. Referencing Data in Shellcode
Loading strings or buffers defined alongside shellcode instructions without needing `jmp-call-pop` gadgets:
```asm
lea rdi, [rip + flag_path]      # Loads pointer to "/flag"
...
flag_path:
    .string "/flag"
```

### 2. Modifying Adjacent Bytes (Self-Modifying Code)
Pointing directly to the instruction immediately following the current one:
```asm
inc byte ptr [rip]              # [rip] points to next byte (0x0e)
.byte 0x0e, 0x05                # Mutates into 0x0f 0x05 (syscall)
```

---
## Related Concepts : 
[[Self-Modifying Code]], [[Assembly]], [[Assembly - Registers]], [[Assembly - Data Movement]], [[PIE]], [[ASLR]]
