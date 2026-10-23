---
tags:
  - Tools
  - BinaryExploitation
---
## Function
> **checksec** is a command-line utility used to inspect which binary security mitigations and compiler hardening properties (RELRO, Stack Canary, NX, PIE, RPATH, FORTIFY) are enabled on an executable file.

---
## Syntax
```shell
checksec --file=<executable>
```

### Example Output:
```shell
[*] '/path/to/binary'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

---
## How to Interpret the Output

| Field | Meaning | If Disabled / Missing |
| :--- | :--- | :--- |
| **RELRO** | [[RELRO]] (Relocation Read-Only). Full, Partial, or No RELRO. | If Partial or None: GOT entries can be overwritten via format string or write-what-where. |
| **Stack** | [[Stack Canary]] protection. | If **No canary found**: Return address can be overwritten without worrying about stack cookies. |
| **NX** | [[NX]] (No-Execute) memory protection. | If **NX unknown / NX disabled**: Shellcode injected into the stack can be executed directly! |
| **PIE** | [[PIE]] (Position Independent Executable). | If **No PIE**: Executable code addresses are fixed (typically `0x400000`), making hardcoded targets reliable. |
| **Stripped** | Binary symbol table status. | If **No**: Function names and variable names are visible in GDB (`info functions`). |

---
## Related Concepts : 
[[PIE]], [[NX]], [[Stack Canary]], [[RELRO]], [[ASLR]], [[GDB]], [[Buffer Overflow]]
