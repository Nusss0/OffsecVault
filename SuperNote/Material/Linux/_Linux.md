# Linux Internals, CLI & Mitigations

Reference hub for Linux command-line tools, filesystem/UID permissions, dynamic tracing, kernel/compiler exploit mitigations, and system calls.

---

## CLI Utilities (`CLI/`)
- [ ] [[_Linux CLI Commands]] - Dedicated mapper for Linux CLI commands (`cat`, `cd`, `grep`, `ln`, `ls`, `mount`, `perl`, `tr`, `whoami`).

## Core Concepts (`Concepts/`)
- [ ] [[Hidden Files in Linux]] - Dotfiles (`.bashrc`, `.ssh/`) and uncovering hidden configuration/credential artifacts.
- [ ] [[SetUID Files]] - Special SUID permission bit executing binaries with file owner privileges (`root`), a key PrivEsc vector.
- [ ] [[User ID in Linux]] - Real, effective, and saved UIDs (`getuid()`, `geteuid()`) used by the kernel for access control.

## Dynamic Tracing & Debugging (`Debugging/`)
- [ ] [[ltrace]] - Intercepts and logs dynamic shared library calls (`strcmp`, `printf`) made by a binary at runtime.
- [ ] [[strace]] - Traces Linux kernel system calls and signals made by a running process.

## Binary & OS Mitigations (`Mitigations/`)
- [ ] [[ASLR]] - Kernel randomization of stack, heap, and shared library base addresses at process startup.
- [ ] [[NX]] - Non-Executable (`W^X` / DEP) memory protection blocking direct shellcode execution on the stack or heap.
- [ ] [[PIE]] - Position Independent Executable compilation allowing randomization of the `.text`/`.data` base address.
- [ ] [[RELRO]] - Compile-time ELF hardening making the Global Offset Table (GOT) read-only to prevent GOT overwrite attacks.
- [ ] [[Stack Canary]] - Stack cookie validation placed before saved `RBP`/return address to detect and abort stack buffer overflows.

## System Calls (`SysCall/`)
- [ ] [[System Calls]] - Kernel-userspace boundary mechanism allowing unprivileged processes to request privileged OS operations.
- [ ] [[access()]] - Checks file access permissions using the real UID rather than effective UID (often involved in TOCTOU flaws).
- [ ] [[system()]] - Executes a shell command via `/bin/sh -c`, frequently abused in SUID PATH hijacking or command injection.
