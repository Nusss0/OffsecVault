---
tags:
  - Tools
  - Python
  - BinaryExploitation
---
## Function
> **pwntools** is a CTF framework and exploit development library written in Python. Designed for rapid prototyping, it automates low-level socket handling, process interaction, cyclic pattern generation, integer/pointer pack and unpack operations, and ROP/shellcode crafting.

---
## Common Import & Context Setup
```python
from pwn import *

# Set target binary architecture and logging verbosity
context.binary = './vuln'
context.arch = 'amd64'           # 'i386' for 32-bit
context.log_level = 'debug'      # 'info', 'critical'
```

---
## Core Cheatsheet

### 1. Process & Networking
```python
p = process('./vuln')            # Local process
r = remote('10.10.10.10', 1337)  # Remote socket connection

p.send(b"data")                  # Send raw bytes
p.sendline(b"data")              # Send bytes with trailing newline
p.recv(1024)                     # Receive up to 1024 bytes
p.recvuntil(b"Enter input: ")    # Receive until delimiter
p.recvline()                     # Receive single line
p.interactive()                  # Switch to interactive terminal shell
```

### 2. Packing & Unpacking Numbers (Pointers/Addresses)
```python
# 64-bit Little Endian
p64(0x4011be)                    # -> b'\xbe\x11\x40\x00\x00\x00\x00\x00'
u64(b'\xbe\x11\x40\x00\x00\x00\x00\x00') # -> 0x4011be

# 32-bit Little Endian
p32(0x08048450)
u32(raw_bytes)
```

### 3. Cyclic Pattern (Finding RIP Offset)
```python
pattern = cyclic(200)            # Generate unique de Bruijn sequence
# Run process, crash, inspect crash address in GDB / core dump:
offset = cyclic_find(0x61616167) # Or cyclic_find(b"gaaa") -> returns exact integer offset
```

### 4. ELF & ROP Helpers
```python
elf = ELF('./vuln')
win_addr = elf.symbols['win']    # Direct lookup of symbol addresses
got_puts = elf.got['puts']       # GOT table entry
plt_puts = elf.plt['puts']       # PLT table entry

# ROP helper
rop = ROP(elf)
rop.win(0xdeadbeef)              # Auto-crafts gadget chain if symbols available
```

---
## Related Concepts : 
[[Buffer Overflow]], [[ROP]], [[GDB]], [[Python - Payload Insert]], [[Assembly Shellcode Database]]
