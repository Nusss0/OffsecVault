## Definition
> Standard C library function (`string.h`) that copies the null-terminated byte string pointed to by `src` (including the terminating null byte `\0`) to the buffer pointed to by `dest`.

---
## Tags 

#Material #C #string-h #Vulnerability #BinaryExploitation 

---
## Syntax
```c
#include <string.h>
char *strcpy(char *dest, const char *src);
```

**Parameters:**
- `dest`: Pointer to the destination array where content will be copied.
- `src`: Pointer to the null-terminated string to be copied.

**Return Value:** Returns a pointer to the destination string `dest`.

---
## Security Risk & Vulnerability

>[!danger] Critical Security Flaw
>`strcpy()` performs **NO boundary checking whatsoever**. It continues reading and copying bytes from `src` into `dest` until it encounters a null byte (`\0`). If `src` contains more characters than `dest` is allocated to hold, it unconditionally overflows the destination buffer, corrupting adjacent stack or heap memory.

### Common Exploit Scenario:
```c
void vulnerable(char *input) {
    char buffer[64];
    strcpy(buffer, input); // <-- If input > 64 bytes: Stack Buffer Overflow!
}
```

### Safe Alternatives:
- `strncpy(dest, src, n)` — specifies maximum length (ensure manual null termination).
- `strlcpy(dest, src, size)` (BSD/libbsd) — guarantees null termination.
- `snprintf(dest, sizeof(dest), "%s", src)`.

---
## Related Concepts : 
[[Buffer Overflow]], [[gets()]], [[scanf()]], [[pwntools]]
