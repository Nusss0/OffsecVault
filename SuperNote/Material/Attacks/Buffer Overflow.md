## Definition
> **Stack Buffer Overflow** occurs when a program writes more data to a buffer located on the call stack than that buffer is allocated to hold. This extra data spills over into adjacent stack memory, corrupting local variables, the saved frame pointer (EBP/RBP), and most critically, the **saved return address (EIP/RIP)**.

---
## Tags 

#Material #BinaryExploitation #StackOverflow #Attack 

---
## Stack Memory Architecture

When a function is called, a stack frame is allocated in memory growing from **High Memory Address** down to **Low Memory Address**:

```
High Memory   +---------------------------------------+
              | Saved Return Address (RIP / EIP)      |  <-- Overwritten to redirect control flow
              +---------------------------------------+
              | Saved Base Pointer (RBP / EBP)        |  <-- Overwritten (useful for stack pivot)
              +---------------------------------------+
              | Local Variables (ints, pointers, etc) |  <-- Overwritten first
              +---------------------------------------+
Low Memory    | Buffer [e.g. char buf[64]]            |  <-- Input starts here & grows upwards
              +---------------------------------------+
```

>[!important] Memory Growth vs Buffer Growth
>While the stack grows **downwards** (towards lower memory addresses), buffers and arrays are written **upwards** (from low to high addresses). Therefore, overflowing a buffer naturally moves towards saved RBP and the return address!

---
## Vulnerability Root Causes

Unchecked input functions in C that do not limit write size:
- `gets()` — NEVER use, unbound read.
- `strcpy()`, `strcat()` — copies until `\0` (null byte).
- `scanf("%s")` or `sprintf()` — reads without length specifiers.
- `read()` / `recv()` — when the length argument exceeds buffer size.

---
## Exploitation Lifecycle

1. **Calculate Crash Offset**:
   Send a unique non-repeating pattern (e.g. via `cyclic 200` in `pwntools`) to identify the exact offset where RIP/EIP is overwritten (`cyclic -l <crash_value>`).
2. **Inspect Protections**:
   Run `checksec` to verify:
   - **Canary**: If enabled, stack cookie must be leaked or bypassed first.
   - **NX**: If disabled, shellcode can execute directly on the stack; if enabled, use [[ROP]] or [[ret2win]].
   - **PIE**: If enabled, base addresses are randomized; use [[ret2win]] with partial overwrite or leak base.
3. **Craft Payload Structure**:
   `[Padding / Junk * Offset] + [Target Address (RIP)] + [Optional Arguments / Shellcode]`

---
## Related Concepts : 
[[GDB]], [[Assembly - Stack Operations]], [[pwntools]], [[Python - Payload Insert]], [[ROP]], [[ret2win]], [[Stack Canary]], [[PIE]], [[NX]], [[ASLR]]
