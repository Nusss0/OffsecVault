## Definition
> **x86-64 Instruction Anatomy** explains the structural layout of machine code instructions in x86/x86-64 architectures. Unlike RISC architectures (such as ARM or MIPS) where all instructions have a fixed length (typically 4 bytes), x86-64 is a **CISC (Complex Instruction Set Computer)** architecture featuring **variable-length instructions** ranging from **1 byte up to 15 bytes**. Understanding instruction encoding enables precise byte calculation and aggressive payload minimization for shellcoding.

---
## Tags 
#Material #Assembly #x86-64 #Instruction-Encoding #MachineCode #Shellcode #Byte-Optimization #BinaryExploitation 

---
## 1. General Instruction Format

Every x86-64 machine instruction follows a strict sequential pipeline of optional components. An instruction's total byte size is simply the sum of all components it actually uses:

```
┌────────────┬──────────┬──────────┬──────────┬──────────────┬─────────────┐
│ Prefix(es) │  Opcode  │  ModR/M  │   SIB    │ Displacement │  Immediate  │
├────────────┼──────────┼──────────┼──────────┼──────────────┼─────────────┤
│  0–4 bytes │ 1–3 bytes│ 0–1 byte │ 0–1 byte │  0, 1, 2, 4  │  0, 1, 2, 4 │
└────────────┴──────────┴──────────┴──────────┴──────────────┴─────────────┘
```

---
## 2. Anatomy Component Breakdown

### 1. Prefixes (0 to 4 bytes)
Prefixes modify the default behavior, size, or addressing mode of an instruction.

* **REX Prefix (`0x40` – `0x4F`):**
  * Required when using 64-bit operand sizes or extended registers (`r8`–`r15`, `spl`, `bpl`, `sil`, `dil`).
  * Binary pattern: `0100WRXB`
    * **W = 1**: 64-bit operand size (most commonly **`0x48`** = `REX.W`).
  * *Why `xor rax, rax` is 3 bytes while `xor eax, eax` is 2 bytes:*
    * `xor rax, rax` $\rightarrow$ `48 31 c0` (Needs `0x48` REX prefix).
    * `xor eax, eax` $\rightarrow$ `31 c0` (Default 32-bit operand size in 64-bit mode, **no prefix needed**).
* **Operand-Size Override Prefix (`0x66`):**
  * Switches default operand size to 16-bit.
  * E.g., `xor ax, ax` $\rightarrow$ `66 31 c0` (Adds `0x66`, resulting in 3 bytes!).
* **Address-Size Override Prefix (`0x67`):**
  * Switches 64-bit addressing to 32-bit addressing (e.g. `[eax]` instead of `[rax]`).
* **Repeat / Branch / Lock Prefixes:**
  * `0xF3` (`REP` / `REPE`), `0xF2` (`REPNE`), `0xF0` (`LOCK`).

---

### 2. Opcode (1 to 3 bytes, typically 1)
The core operation identifier that specifies what the CPU must execute.
* **1-Byte Opcodes:**
  * `0x31`: `XOR` (register/memory)
  * `0x89`: `MOV` (register to register/memory)
  * `0x8D`: `LEA` (Load Effective Address)
  * `0x90`: `NOP`
  * `0x50` – `0x57`: `PUSH reg` (register index encoded directly into the opcode!)
  * `0x58` – `0x5F`: `POP reg` (register index encoded directly into the opcode!)
* **Multi-Byte Opcodes:**
  * `0x0F 0x05`: `syscall` (2-byte opcode)
  * `0x0F 0x34`: `sysenter` (2-byte opcode)
  * `0xCD 0x80`: `int 0x80` (Opcode `0xCD` + immediate `0x80`)

> [!tip] Direct Register Encoding in Opcodes
> Instructions like `push rax` (`50`), `push rdi` (`57`), `pop rax` (`58`), and `pop rdi` (`5F`) do **NOT** need a ModR/M byte because the destination register index is embedded directly into the lower 3 bits of the opcode byte itself. That is why simple push/pop instructions take only **1 byte**!

---

### 3. ModR/M (0 or 1 byte)
The **Addressing Mode** byte. It appears whenever an instruction references registers or memory operands.

The ModR/M byte is split into 3 bitfields: `[ Mod (2-bit) | Reg/Opcode (3-bit) | R/M (3-bit) ]`

```
  7   6   5   4   3   2   1   0   (Bits)
┌───────┬───────────────┬───────┐
│  Mod  │  Reg / Opcode │  R/M  │
└───────┴───────────────┴───────┘
```
* **Mod (`Bits 7-6`):**
  * `11b`: Register-to-Register direct mode (no memory access).
  * `00b`: Memory mode without displacement (e.g., `[rax]`).
  * `01b`: Memory mode with 8-bit displacement (e.g., `[rax + disp8]`).
  * `10b`: Memory mode with 32-bit displacement (e.g., `[rax + disp32]`).
* **Reg (`Bits 5-3`):** Specifies the source/destination register (or an opcode extension).
* **R/M (`Bits 2-0`):** Specifies the register or memory addressing mode.

#### Concrete Examples:
1. **`xor eax, eax` $\rightarrow$ `31 c0` (2 bytes):**
   * Opcode: `0x31`
   * ModR/M: `0xC0` (`11 000 000b` $\rightarrow$ Mod=`11` (reg-reg), Reg=`000` (EAX), R/M=`000` (EAX)).
2. **`jmp rsi` $\rightarrow$ `ff e6` (2 bytes):**
   * Opcode: `0xFF` (Group 5 indirect jump)
   * ModR/M: `0xE6` (`11 100 110b` $\rightarrow$ Mod=`11`, Opcode extension=`/4`, R/M=`110` (RSI)).
3. **`syscall` $\rightarrow$ `0f 05` (2 bytes):**
   * Does not reference dynamic registers/memory $\rightarrow$ **No ModR/M byte needed**.

---

### 4. SIB (Scale-Index-Base) (0 or 1 byte)
Appears only when complex memory addressing is used, or when the base register is `rsp` / `r12`.

Structure: `[ Scale (2-bit) | Index (3-bit) | Base (3-bit) ]`
* Format: `[Base + Index * Scale + Displacement]`
* Scale can be $\times 1, \times 2, \times 4,$ or $\times 8$.
* Example: `mov eax, [rbx + rcx*4 + 0x10]` requires:
  `Opcode (8B)` + `ModRM (44)` + `SIB (8C)` + `Disp8 (10)`.

---

### 5. Displacement (0, 1, 2, or 4 bytes)
The offset added to a base register when accessing memory (e.g., `[base + disp]`).

* **No Displacement (0 bytes):**
  * `mov rsi, [rdx]` $\rightarrow$ ModR/M specifies Mod=`00` (0 bytes displacement).
* **8-bit Displacement (1 byte):**
  * Offset fits within $-128$ to $+127$ (`disp8`).
  * Example: `lea rsi, [rdx + 0x12]`
    * Prefix: `0x48` (REX.W for 64-bit RSI)
    * Opcode: `0x8D` (LEA)
    * ModR/M: `0x72` (Mod=`01` for disp8, Reg=RSI, R/M=RDX)
    * Disp8: `0x12` (1 byte offset)
    * **Total: `48 8d 72 12` = 4 bytes**.
* **32-bit Displacement (4 bytes):**
  * Offset requires full 32-bit sign-extended value (`disp32`).
  * Example: `lea rdi, [rip + 0x1000]` $\rightarrow$ 7 bytes (`48 8d 3d 00 10 00 00`).

---

### 6. Immediate (0, 1, 2, 4, or 8 bytes)
A constant value embedded directly inside the instruction stream.

* **Short-Form vs Standard-Form:**
  * For moving values to registers, x86 provides dedicated short-form opcodes (`0xB8 + reg` for 32-bit, `0xB0 + reg` for 8-bit).
* **32-bit Immediate Rule:**
  * `mov edx, 0x100` $\rightarrow$ Opcode `BA` (`mov r32, imm32` for EDX) + 4-byte imm (`00 01 00 00`). **Total = 5 bytes**.
  * `mov edx, 5` $\rightarrow$ Still **5 bytes**! (`BA 05 00 00 00`). In x86, there is no 1-byte immediate form for a 32-bit MOV destination.
* **8-bit Immediate Optimization:**
  * `mov dl, 5` $\rightarrow$ Opcode `B2` (`mov r8, imm8` for DL) + 1-byte imm (`05`). **Total = 2 bytes**!

---
## 3. Quick Size Reference (Cheat Sheet)

| Instruction Pattern | Byte Size | Machine Code Example | Shellcoding Note |
| :--- | :---: | :--- | :--- |
| **`push reg` / `pop reg`** | **1** | `50` (`push rax`), `5f` (`pop rdi`) | Fastest & smallest way to preserve/load regs |
| **`push imm8`** | **2** | `6a 01` (`push 1`) | For immediate values between -128 and 127 |
| **`push imm32`** | **5** | `68 00 01 00 00` (`push 0x100`) | For immediate values $\ge 128$ |
| **`xor r32, r32`** | **2** | `31 c0` (`xor eax, eax`), `31 ff` (`xor edi, edi`) | Clears full 64-bit register without REX |
| **`mov r32, r32`** | **2** | `89 c7` (`mov edi, eax`) | Fast 32-bit register transfer |
| **`mov r8, imm8`** | **2** | `b0 01` (`mov al, 1`), `b2 05` (`mov dl, 5`) | Ultra-compact 1-byte constants |
| **`push rsp; pop reg`** | **2** | `54 5e` (`push rsp; pop rsi`) | 1 byte smaller than `mov rsi, rsp`! |
| **`syscall`** | **2** | `0f 05` | 2-byte kernel invocation |
| **`jmp / call reg`** | **2** | `ff e4` (`jmp rsp`), `ff e6` (`jmp rsi`) | Indirect jump via register |
| **`jmp rel8` (Short Jump)** | **2** | `eb 10` (`jmp short +16`) | Relative jump within $-128$ to $+127$ bytes |
| **`mov r64, r64`** | **3** | `48 89 e6` (`mov rsi, rsp`) | Requires `0x48` REX.W prefix |
| **`push 1; pop reg`** | **3** | `6a 01 58` (`push 1; pop rax`) | 4 bytes smaller than `mov rax, 1` |
| **`lea r64, [base + disp8]`**| **4** | `48 8d 72 12` (`lea rsi, [rdx + 0x12]`) | REX (1) + Opcode (1) + ModRM (1) + Disp (1) |
| **`mov r32, imm32`** | **5** | `ba 00 01 00 00` (`mov edx, 0x100`) | Opcode (1) + 4-byte immediate (4) |
| **`jmp / call rel32`** | **5** | `e9 xx xx xx xx` / `e8 xx xx xx xx` | Far jumps/calls within $\pm 2$ GB |
| **`mov r64, imm32`** | **7** | `48 c7 c0 01 00 00 00` (`mov rax, 1`) | REX (1) + Opcode (2) + 4-byte imm (4) |
| **`lea r64, [rip + disp32]`**| **7** | `48 8d 3d 58 00 00 00` | RIP-relative addressing with 4-byte offset |
| **`movabs r64, imm64`** | **10** | `48 b8 88 77 66 55 44 33 22 11` | Full 64-bit constant load |

---
## 4. Shellcode Byte Optimization Rules

1. **Leverage 32-bit Auto-Zeroing:**
   In x86-64, any write to a 32-bit sub-register (`eax`, `edi`, `edx`, etc.) automatically zeroes out bits 32–63 of the corresponding 64-bit register (`rax`, `rdi`, `rdx`).
   * *Avoid:* `mov rax, 0` (7 bytes) or `xor rax, rax` (3 bytes).
   * *Use:* `xor eax, eax` (**2 bytes**: `31 c0`).
2. **Push/Pop Trick for Small Numbers:**
   * *Avoid:* `mov rax, 1` (7 bytes: `48 c7 c0 01 00 00 00`).
   * *Use:* `push 1; pop rax` (**3 bytes**: `6a 01 58`). Saves 4 bytes!
3. **Push/Pop Trick for Pointer Copying:**
   * *Avoid:* `mov rsi, rsp` (3 bytes: `48 89 e6`).
   * *Use:* `push rsp; pop rsi` (**2 bytes**: `54 5e`). Saves 1 byte!
4. **Use Sub-Byte Registers When Setting Low Values:**
   If a register is already zeroed (e.g. `xor eax, eax`), setting `al` (`inc al` = 2 bytes or `mov al, 2` = 2 bytes) avoids 32-bit/64-bit immediate overhead.

---
## Related Source : 
- [[Writing Assembly Code]]
- [[Assembly - Registers]]
- [[Assembly - Data Movement]]
- [[Assembly - Logic & Bitwise]]
- [[RIP-Relative Addressing]]
- [[Assembly]]
