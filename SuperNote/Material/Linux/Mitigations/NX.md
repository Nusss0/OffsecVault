## Definition
> **NX (No-Execute)**, also known as **DEP (Data Execution Prevention)** or **W^X (Write XOR Execute)**, is a CPU and operating system security mitigation that marks writable memory segments (such as the **Stack** and **Heap**) as non-executable. Any attempt to execute instructions stored in an NX-protected memory region triggers a Segmentation Fault (`SIGSEGV`).

---
## Tags 

#Material #BinaryExploitation #NX #Mitigation #OperatingSystem 

---
## How it Works

Modern CPU architectures (such as AMD64 and ARM) feature an **NX bit** (bit 63 of page table entries). 
- When the NX bit is set to `1` on a memory page, the CPU hardware refuses to fetch instructions from that address.
- In ELF binaries, this is controlled by the `GNU_STACK` program header:
  - `RW-`: Stack is readable and writable, but **NOT** executable (**NX Enabled**).
  - `RWE`: Stack is readable, writable, and **executable** (**NX Disabled**).

---
## Exploitation Impact

| NX Status | Attacker Options |
| :---: | :--- |
| **NX Disabled** | Can directly inject shellcode into the stack or heap buffer and jump straight to it. |
| **NX Enabled** | Direct shellcode execution on the stack will fail. Must use [[ROP]] (Return-Oriented Programming) or **ret2libc** using existing executable code segments. |

---
## Related Concepts : 
[[ROP]], [[Buffer Overflow]], [[Shellcode Database]], [[checksec]], [[Assembly]]
