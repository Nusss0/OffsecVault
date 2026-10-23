## Definition
> A **Stack Canary** (also called a stack cookie or guard) is a security defense mechanism that places a secret randomized integer on the stack right before the saved base pointer (EBP/RBP) and return address. Before a function returns, the compiler inserts code to verify whether the canary value remains unaltered; if a mismatch occurs, execution immediately terminates to thwart buffer overflows.

---
## Tags 

#Material #BinaryExploitation #StackCanary #Mitigation #Linux 

---
## Mechanics

When compiled with `gcc -fstack-protector`:

1. **Prologue**:
   At function entry, a random canary value is fetched from a thread control block (`fs:0x28` in 64-bit x86) and placed onto the stack:
   ```asm
   mov    rax, QWORD PTR fs:0x28
   mov    QWORD PTR [rbp-0x8], rax
   xor    eax, eax
   ```
2. **Epilogue**:
   Before returning, the stored value on the stack is checked against `fs:0x28`:
   ```asm
   mov    rax, QWORD PTR [rbp-0x8]
   sub    rax, QWORD PTR fs:0x28
   je     .clean_exit
   call   __stack_chk_fail
   ```

>[!info] Why Canaries End in `\x00` (Null Byte)
>On 64-bit Linux, canaries are 8 bytes long and their least significant byte (LSB) is always `\x00` (e.g. `0x7a31b409c21d00`). This is intentional: string functions like `strcpy()`, `gets()`, and `printf()` treat `\x00` as a terminator, preventing naive string reads or writes from leaking or bypassing the canary without terminating.

---
## Bypass Techniques

1. **Information Leak**:
   Leak the canary via format string `%p` or by overwriting memory just up to the canary's null byte so `puts()` or `printf()` prints it out. Then include the exact canary in the overflow payload.
2. **Bruteforcing (Forking Servers)**:
   If the target process uses `fork()`, the child processes retain identical memory layouts and canary values. The canary can be bruteforced byte-by-byte (256 attempts per byte).
3. **Overwriting Other Local Variables**:
   Stack variables stored *before* the canary can be corrupted without touching the canary itself.

---
## Related Concepts : 
[[Buffer Overflow]], [[checksec]], [[GDB]], [[Assembly - Stack Operations]]
