## Definition
> **TOCTOU (Time-of-Check to Time-of-Use)** is a class of software race conditions where a program checks a resource's state or permissions (Time of Check) and later uses that resource (Time of Use), but the state changes in the time window between the two actions.

---
## Tags 

#Material #LinuxBasic #RaceCondition #TOCTOU #Attack 

---
## Mechanics in SUID Exploitation

A classic TOCTOU scenario occurs in privileged SUID binaries that attempt to perform security checks on behalf of the real user before opening or processing files:

```c
// 1. Time of Check: checks permissions against Real UID
if (access(filename, R_OK) == 0) {
    // ---- [ RACE WINDOW ] ----
    // Attacker alters filename / symlink here!
    
    // 2. Time of Use: opens or executes file with SUID Effective UID
    system("/bin/cat filename");
}
```

### Exploit Vector: Symbolic Link Swapping
1. Attacker creates an innocuous file that passes the `access()` check (e.g., `/tmp/foobar`).
2. Program confirms access is permitted.
3. In the intervening window, attacker replaces `/tmp/foobar` with a **symbolic link** pointing to a protected file (e.g. `/etc/shadow` or password files).
4. Program uses its elevated SUID privilege to open or print the protected file.

### Exploit Vector: Space Separation in `system()`
If a program calls `system("/bin/cat " + input)`:
- If input is `"foo bar"`, `access("foo bar")` checks a single file named `"foo bar"`.
- However, when passed to `/bin/sh -c "/bin/cat foo bar"`, the shell splits arguments and executes `cat foo` and `cat bar`.
- Attacker can symlink `foo` to the secret file and pass `"foo bar"` to bypass the check!

---
## Prevention
- Avoid separate check-and-open calls; use atomic operations like `open()` with flags `O_CREAT | O_EXCL` or file descriptors (`faccessat`, `fstat`).
- Drop privileges (`setreuid(real_uid, real_uid)`) before performing sensitive operations instead of relying on `access()`.

---
## Related Concepts : 
[[access()]], [[system()]], [[SetUID Files]], [[ln]], [[ltrace]], [[System Calls]]
