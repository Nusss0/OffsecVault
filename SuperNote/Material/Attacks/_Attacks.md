# Attacks

Comprehensive methodology, exploitation guides, and reference material for common offensive attack vectors and binary exploitation techniques.

---

## Memory & Binary Exploitation
- [ ] [[Buffer Overflow]] - Classic stack-based buffer overflow exploitation to overwrite return addresses and hijack execution flow.
- [ ] [[ROP]] - Return-Oriented Programming technique chaining gadgets ending in `ret` to bypass Non-Executable (NX/DEP) memory protections.
- [ ] [[ret2win]] - Beginner binary exploitation pattern redirecting control flow to an existing intended or secret function.
- [ ] [[NOP Sled]] - Sliding execution flow safely into a payload using a runway of `0x90` (`NOP`) instructions.
- [ ] [[Format String Attack]] - Exploiting vulnerabilities where user input is passed directly to format functions (`printf`, `snprintf`) to leak or overwrite memory.
- [ ] [[Shellcode Database]] - Curated collection of tested shellcode payloads (file reading, execve, socket reuse) without null bytes.

## Race Conditions & Logic Flaws
- [ ] [[TOCTOU]] - Time-of-Check to Time-of-Use race condition vulnerabilities exploiting the window between permission check and file access.

## Shells & Post-Access
- [ ] [[Reverse Shell Cheatsheet]] - Multi-language one-liners (Bash, Python, Netcat, PowerShell, PHP) to establish reverse shells back to an attacker listener.
