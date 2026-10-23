## Definition
> Standard C library function (`stdio.h`) that reads formatted input from the standard input stream (`stdin`) and stores values into variables specified by arguments.

---
## Tags 

#Material #C #stdio-h #Vulnerability #BinaryExploitation 

---
## Syntax
```c
#include <stdio.h>
int scanf(const char *format, ...);
```

---
## Security Risk & Vulnerability

>[!danger] Unbounded `%s` Format Specifier
>When `%s` is used without an explicit field width limit, `scanf` reads input continuously until whitespace or EOF is encountered, without checking if the target buffer is large enough:
>```c
>char buf[20];
>scanf("%s", buf); // Vulnerable to Stack Buffer Overflow!
>```

### Width Mismatch Vulnerability
Even if a width is specified (e.g. `scanf("%24s", buf)` into `buf[20]`), if the width exceeds the buffer allocation, it overflows into adjacent variables on the stack (such as local control variables or flags).

### Safe Usage:
Always enforce strict width matching the buffer size minus one byte for the null terminator:
```c
char buf[20];
scanf("%19s", buf); // Safe: leaves 1 byte for '\0'
```

---
## Related Concepts : 
[[Buffer Overflow]], [[strcpy()]], [[gets()]], [[printf()]]
