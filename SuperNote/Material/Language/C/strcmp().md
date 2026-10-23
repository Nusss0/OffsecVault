## Definition
> Standard C library function (`string.h`) that performs a byte-by-byte lexicographical comparison of two null-terminated strings `s1` and `s2`.

---
## Tags 

#Material #C #string-h #ReverseEngineering 

---
## Syntax
```c
#include <string.h>
int strcmp(const char *s1, const char *s2);
```

**Return Values:**
- `0`: Strings are equal.
- `< 0`: `s1` is lexicographically less than `s2`.
- `> 0`: `s1` is lexicographically greater than `s2`.

---
## Security & Reverse Engineering Behavior

### 1. Library Call Tracing (`ltrace`)
Because `strcmp()` is a dynamically linked C library function, dynamically linked binaries reveal the plaintext strings passed into `strcmp()` when run under `ltrace`:
```shell
$ ltrace ./binary my_guess
strcmp("my_guess", "SecretPassword123") = -1
```
Hardcoded credentials or target password checks using standard `strcmp()` can often be extracted immediately with `ltrace`.

### 2. Timing Attacks
Standard `strcmp()` returns immediately upon finding the first non-matching byte. In remote network applications, measuring slight timing variations allows an attacker to guess secrets character-by-character.
- *Mitigation:* Use constant-time comparison functions (e.g. `CRYPTO_memcmp`).

---
## Related Concepts : 
[[ltrace]], [[strace]], [[GDB]]
