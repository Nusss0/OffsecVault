## Definition
> **Self-Modifying Code (SMC)** is code that alters its own instructions in memory while it is executing. In binary exploitation and shellcoding, SMC is commonly used to bypass static signature filters, antivirus detection, and opcode blacklists by assembling or mutating instructions dynamically at runtime.

---
## Tags 

#Material #BinaryExploitation #Shellcode #Self-Modifying-Code #Evasion #Attack 

---
## Prerequisites

For SMC to function, the target memory segment must have both **Write** and **Execute** permissions (**RWX** or `PROT_WRITE | PROT_EXEC`):
- Modern operating systems enforce **W^X** (Write XOR Execute / DEP / NX) on normal binaries, causing SMC to trigger a segmentation fault if attempted on standard `.text` segments.
- However, challenge environments, JIT compilers, packers, and custom shellcode testbeds explicitly map memory pages as **RWX** (e.g. via `mmap`), making SMC possible.

---
## How it Works

Static security filters examine byte patterns *before* execution. By intentionally placing mutated or incomplete bytes into the payload, the static filter is bypassed. Once running, the code repairs or reconstructs the original instructions in-place before jumping into them.

```
[ Phase 1: Static Inspection ]
Memory Content: ... [ \xfe\x05\x00\x00\x00\x00 ] [ \x0e ] [ \x05 ] ...
Filter Check  : Looking for \x0f\x05 (syscall)? -> NOT FOUND -> PASSED!

[ Phase 2: Runtime Execution ]
1. CPU executes 'inc byte ptr [rip]' (fe 05 00 00 00 00)
   - RIP points to next byte (\x0e)
   - Operation: byte[\x0e] + 1 = \x0f
2. Memory is mutated in-place:
   ... [ \xfe\x05\x00\x00\x00\x00 ] [ \x0f ] [ \x05 ] ...
3. Next instruction cycle:
   - CPU executes \x0f\x05 -> 'syscall' executed successfully!
```

---
## Implementation Patterns

### 1. In-place Mutation via RIP-Relative Pointer
Useful when bypassing single-instruction blacklists (e.g., `syscall` `0x0f 0x05`, `int 0x80` `0xcd 0x80`):
```asm
inc byte ptr [rip]      # Increment next byte by 1 in memory
.byte 0x0e, 0x05        # 0x0e becomes 0x0f right before CPU reaches it
```

### 2. XOR / Arithmetic Decoder Stub
Useful when evading heavy character restrictions (e.g. alphanumeric shellcode, null-free filters):
- An unobfuscated decoder stub loops over an encoded payload buffer.
- Performs runtime decoding (`xor`, `add`, or `sub`) directly into memory.
- Jumps to the freshly decoded shellcode payload.

---
## Key Use Cases

1. **Bypassing Syscall / Opcode Filters**:
   When challenge filters forbid opcodes like `syscall` (`0x0f05`), `sysenter` (`0x0f34`), or `int 0x80` (`0xcd80`), SMC constructs the forbidden bytes dynamically right before execution.
2. **Polymorphic & Metamorphic Engines**:
   Altering byte signatures every run to avoid heuristic or static hash-based detection.
3. **Anti-Disassembly & Packing**:
   Confusing static disassemblers (like IDA or Ghidra) by hiding real code flow until execution.

---
## Related Concepts : 
[[RIP-Relative Addressing]], [[Basic Shellcode]], [[Shellcode Database]], [[System Calls]], [[Assembly - Data Movement]]
