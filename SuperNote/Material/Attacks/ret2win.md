## Definition
> **ret2win (Return-to-Win)** is a foundational binary exploitation technique where an attacker abuses a stack buffer overflow to overwrite the saved return address (RIP/EIP) with the address of an existing "win" or "flag-printing" function present within the binary itself (e.g., `win()`, `print_flag()`, `admin_shell()`).

---
## Tags 

#Material #BinaryExploitation #ret2win #Attack 

---
## Mechanics

When the binary already contains code that prints the flag or provides high privilege, you don't need shellcode or a full ROP chain. You simply overwrite the saved return address on the stack directly with the address of that target function:

```
Payload:
[ Padding up to Saved RIP ] + [ Address of win() ]
```

---
## Common Pitfalls & Edge Cases

### 1. The 16-Byte Stack Alignment Crash (Ubuntu / 64-bit glibc)
>[!warning] Segmentation fault on `movaps` inside `system()` / `printf()`
>In 64-bit Linux (x86-64 System V ABI), the stack pointer `RSP` **must be 16-byte aligned** (i.e., `RSP % 16 == 0`) before a `call` instruction is executed. Many libc functions (like `printf` or `system`) use SIMD instructions like `movaps` that crash if the stack is misaligned.
>
>**Fix**: Prepend a single dummy `ret` gadget before the `win()` address to align the stack:
>```python
>ret_gadget = 0x40101a # address of a single "ret"
>payload = padding + p64(ret_gadget) + p64(win_address)
>```

### 2. Skipping Authentication / Instruction Checks
If the `win` function begins with authentication checks (e.g. `cmp [rbp-0x4], 0x1337`), you can overwrite the return address to point **past** the check directly to the instruction block that prints the flag.

### 3. Partial Overwrite under PIE
When [[PIE]] is enabled, the base address of the binary is randomized, but the lower 12 bits (3 hex digits) remain constant due to page alignment.
- Overwriting only the lowest 2 bytes (16 bits) requires guessing or bruteforcing only **4 bits (1 nibble, 1 in 16 probability)**.

---
## Related Concepts : 
[[Buffer Overflow]], [[PIE]], [[ROP]], [[GDB]], [[Assembly - Control Flow]], [[Assembly - Stack Operations]], [[pwntools]]
