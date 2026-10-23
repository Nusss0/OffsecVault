---
tags:
  - Tools
  - BinaryExploitation
  - ROP
---
## Function
> **ROPgadget** is an open-source tool that searches through ELF/PE/Mach-O binaries and shared libraries to identify and dump Return-Oriented Programming (ROP) gadgets, facilitating exploit chain development.

---
## Common Commands & Syntax

### Basic Gadget Search
```shell
# Dump all gadgets from binary
ROPgadget --binary ./vuln

# Search only gadgets ending with specific instructions (e.g. pop followed by ret)
ROPgadget --binary ./vuln --only "pop|ret"

# Search for a specific register gadget (e.g. pop rdi)
ROPgadget --binary ./vuln | grep "pop rdi"

# Search for strings (e.g. "/bin/sh")
ROPgadget --binary ./vuln --string "/bin/sh"
```

### Advanced Options:
- `--ropchain`: Attempts to automatically generate a full python-formatted execve ROP chain.
- `--badbytes "<hex>"`: Exclude gadgets whose virtual addresses contain forbidden bytes (e.g. `00` or `0a`).

---
## Related Concepts : 
[[ROP]], [[Buffer Overflow]], [[pwntools]], [[NX]], [[Assembly - Control Flow]]
