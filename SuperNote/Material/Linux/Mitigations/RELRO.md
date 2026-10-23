## Definition
> **RELRO (Relocation Read-Only)** is a compile-time hardening defense in ELF binaries that makes specific binary sections (most notably the **Global Offset Table (GOT)**) read-only after dynamic symbols have been linked, preventing attackers from overwriting function pointers.

---
## Tags 

#Material #BinaryExploitation #RELRO #Mitigation #Linux 

---
## RELRO Modes

| Level | Compiler Flag | Description & GOT Status |
| :---: | :--- | :--- |
| **No RELRO** | `-Wl,-z,norelro` | The GOT table is placed before internal data sections and remains writable throughout execution. Exploitable via GOT overwrite. |
| **Partial RELRO** | `-Wl,-z,relro` | Default on most GCC builds. Non-PLT GOT sections (`.got`) are read-only, but the PLT GOT (`.got.plt`) remains writable so dynamic linking can resolve functions lazily. **GOT overwrite attacks are still possible!** |
| **Full RELRO** | `-Wl,-z,relro,-z,now` | All symbols are resolved immediately at startup (`BIND_NOW`). The entire GOT (`.got` and `.got.plt`) is marked **read-only** before program execution begins. **GOT overwrites are completely mitigated!** |

---
## Related Concepts : 
[[checksec]], [[Buffer Overflow]], [[Format String Attack]], [[ROP]]
