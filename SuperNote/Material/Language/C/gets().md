## Definition
> Standard C library function (`stdio.h`) historically used to read a line from `stdin` into a buffer until a newline character or EOF is found. 

---
## Tags 

#Material #C #stdio-h #Vulnerability #BinaryExploitation 

---
## Syntax
```c
#include <stdio.h>
char *gets(char *s);
```

---
## Security Risk & Vulnerability

>[!danger] The Most Infamous Banned Function in C
>`gets()` has **no parameter specifying the maximum length of the destination buffer**. It is inherently impossible to use `gets()` safely on untrusted input because there is no mechanism to stop input from overflowing any buffer size.
>
>- Formally deprecated in C99 and completely removed from the ISO C11 standard.
>- Modern compilers issue explicit build warnings whenever `gets()` is invoked.

### Common Exploit Scenario:
```c
char buf[128];
gets(buf); // Direct control over stack return address (RIP)!
```

### Safe Alternatives:
- `fgets(buf, sizeof(buf), stdin)`
- `getline(&lineptr, &n, stdin)`

---
## Related Concepts : 
[[Buffer Overflow]], [[strcpy()]], [[scanf()]], [[ROP]]
