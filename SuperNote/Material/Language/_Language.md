# Language & Debugging Reference

Low-level x86-64 assembly programming, security-relevant C `libc` functions, binary debugging, and exploit scripting helpers.

---

## x86-64 Assembly (`Assembly/`)
- [ ] [[Assembly]] - Core x86-64 architecture overview and Intel vs. AT&T syntax conventions.
- [ ] [[Assembly - Registers]] - 64-bit, 32-bit, 16-bit, and 8-bit CPU register hierarchy and special-purpose registers (`RIP`, `RSP`, `RBP`).
- [ ] [[Assembly - Data Movement]] - Instructions for copying and exchanging data between registers, memory, and immediates (`MOV`, `LEA`, `XCHG`).
- [ ] [[Assembly - Arithmetic Operations]] - Integer arithmetic instructions and CPU status flag side effects (`ADD`, `SUB`, `INC`, `DEC`, `MUL`, `DIV`).
- [ ] [[Assembly - Logic & Bitwise]] - Bit-level masking, clearing registers, and bit-shifting (`XOR`, `AND`, `OR`, `TEST`, `SHL`, `SHR`).
- [ ] [[Assembly - Control Flow]] - Unconditional/conditional jumps, comparisons (`CMP`), loops, and execution redirection.
- [ ] [[Assembly - Stack Operations]] - LIFO stack mechanics, calling conventions, and stack frame manipulation (`PUSH`, `POP`, `CALL`, `RET`).
- [ ] [[Assembly - Instruction Anatomy & Byte Calculation]] - Variable-length x86-64 opcode encoding and byte minimization for tight shellcode budgets.
- [ ] [[RIP-Relative Addressing]] - Position-independent memory referencing relative to `RIP` for ASLR/PIE-safe shellcode.
- [ ] [[Writing Assembly Code]] - End-to-end GAS/NASM boilerplate, Linux syscall ABI, and compiling raw shellcode binaries.
- [ ] [[Assembly Shellcode Database]] - Curated x86-64 shellcode payloads (file reading, `execve`, null-free, opcode-filtered). *(Located in `Material/Database/`)*

## C Standard Library (`C/`)
- [ ] [[execve()]] - Syscall wrapper replacing the current process image with a new executable while preserving PID and UIDs.
- [ ] [[getenv()]] - Reads process environment variables (`stdlib.h`), relevant to stack/environment offset calculations.
- [ ] [[gets()]] - Unbounded `stdin` read (`stdio.h`); classic cause of trivial stack-based buffer overflows.
- [ ] [[printf()]] - Variadic formatted output (`stdio.h`); vulnerable to Format String memory leaks and arbitrary writes when given untrusted format strings.
- [ ] [[snprintf()]] - Bounded buffer variant of `printf()`; prevents buffer overflow but remains vulnerable to Format String bugs.
- [ ] [[scanf()]] - Formatted `stdin` input (`stdio.h`); prone to buffer overflow with unbounded `%s` specifiers.
- [ ] [[strcmp()]] - Lexicographical comparison of null-terminated strings (`string.h`), commonly targeted during reverse engineering.
- [ ] [[strcpy()]] - Unbounded string copy (`string.h`); major source of stack/heap buffer overflows.
- [ ] [[setuid()]] - Sets the effective UID of a calling process (e.g., dropping or restoring root privileges in SUID binaries).
- [ ] [[setreuid()]] - Sets both real and effective UIDs simultaneously, commonly invoked in privilege escalation shellcode.

## Debuggers (`Debugger/`)
- [ ] [[GDB]] - GNU Debugger workflow for setting breakpoints, inspecting registers/stack memory, and stepping through binaries.

## Python Exploit Helpers (`Python/`)
- [ ] [[Python - Payload Insert]] - Patterns for delivering binary exploit payloads into target programs via CLI arguments and `stdin`.
