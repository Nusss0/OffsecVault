## Definition
> A **NOP Sled** (or **NOP Slide**) is a sequence of No-Operation machine instructions (`0x90` in x86/x64 assembly) prepended immediately before executable shellcode. Its purpose is to slide the CPU's instruction pointer safely into the payload even if the target jump address cannot be predicted with exact precision.

---
## Tags 

#Material #BinaryExploitation #NOP-Sled #Shellcode #Attack 

---
## How it Works

When the CPU encounters the byte `\x90`, it performs no action other than advancing the Instruction Pointer (`RIP` / `EIP`) to the next byte:

```
[ ... Padding ... ] [ Jump Target Address: 0x7fffffffe080 ]
                                 |
                                 V (Lands somewhere inside NOP Sled)
+---------------------------------------------------------------+
| \x90 \x90 \x90 \x90 \x90 \x90 \x90 \x90 \x90 \x90 \x90 ...    |  <-- NOP Sled
+---------------------------------------------------------------+
| Shellcode (\x31\xc0\x48\xbb\xd1\x9d\x96... )                  |  <-- Execution slides directly here!
+---------------------------------------------------------------+
```

---
## Key Use Cases

1. **Jitter & Stack Variations**:
   When environmental differences, varying argument lengths, or limited stack ASLR introduce slight shifts in stack addresses, a generous NOP sled (e.g. 100 to 2000 bytes) dramatically increases the probability that a guessed jump address will land successfully.
2. **Replacing Banned / Shifted Bytes**:
   When stripping out filtered bytes (e.g. instruction prefix `0x48`) from shellcode, replacing those bytes with `\x90` preserves offsets so internal relative jumps (`jmp short`) do not break.

---
## Related Concepts : 
[[Shellcode Database]], [[Buffer Overflow]], [[Assembly]], [[ASLR]], [[Python - Payload Insert]], [[perl]]
