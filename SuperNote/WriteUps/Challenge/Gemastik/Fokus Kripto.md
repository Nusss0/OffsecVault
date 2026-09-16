## Challenge Info

**Platform:** GEMASTIK 2026 - Fokus Kripto

---

## FLAG : `PRAGEM{MCl4ReN_lU_w4rN4_4p4_b055_aec5c738d510636f}`

---

## Solution :

### Step 1 : Check `chall.py`.

First, let's check the challenge source code.

```bash
cat chall.py
```

Interesting part:

```python
p = getPrime(100)
q = getPrime(100)

g = Bitcoin.bullish(p, q)
secret = getrandbits(580)

print(g)
print(g**secret)

key = sha256(hex(secret).encode()).digest()[:16]
cipher = AES.new(key, AES.MODE_ECB)
ciphertext = cipher.encrypt(pad(flag.encode(), 16)).hex()
```

From the source code, we know that:

1. The challenge generates two 100-bit primes, `p` and `q`.
2. It generates matrix `g`.
3. It computes `g**secret`.
4. The AES key is generated from `secret`.
5. So our main goal is to recover `secret`.

If we can recover `secret`, we can rebuild the AES key and decrypt the ciphertext.

---

### Step 2 : Check `output.txt`.

The output file contains 3 things:

```bash
cat output.txt
```

The format is:

```text
g
g^secret
ciphertext
```

So in the solver, we parse it like this:
```python
out = Path("output.txt").read_text().strip().splitlines()

g = ast.literal_eval(out[0])
h = ast.literal_eval(out[1])
ct = bytes.fromhex(out[2])
```
Here:
```txt
g  = original matrix
h  = g^secret
ct = encrypted flag
```

---

### Step 3 : Recover `p` and `q`.

Look at the matrix generation inside `bullish()`:

```python
values = [
    [
        randrange(p * q),
        q * randrange(p * q),
        q**2 * randrange(p * q),
    ],
    [
        p * randrange(p * q),
        randrange(p**2 * q**2),
        q * randrange(p**2 * q**2),
    ],
    [
        p**2 * randrange(p * q),
        p * randrange(p**2 * q**2),
        randrange(p**3 * q**3),
    ],
]
```

From here, some matrix positions are always divisible by `p`, and some are always divisible by `q`.

So we can recover them using `gcd`.

```python
q = math.gcd(
    g[0][1], g[0][2], g[1][2],
    h[0][1], h[0][2], h[1][2]
)

p = math.gcd(
    g[1][0], g[2][0], g[2][1],
    h[1][0], h[2][0], h[2][1]
)
```

This works because the matrix structure leaks divisibility information.

---

### Step 4 : Understand the exponent problem.

We know:

```txt
h = g^secret
```

So this is basically a discrete logarithm problem, but inside a custom matrix group.

The easiest visible relation is from position `[0][0]`.

Modulo `p` and modulo `q`, the cross terms disappear, so:

```txt
h[0][0] = g[0][0]^secret
```

So we can recover part of `secret` using discrete log:

```python
xp1 = znlog(h[0][0] mod p, g[0][0] mod p)
xq1 = znlog(h[0][0] mod q, g[0][0] mod q)
```

But this is not enough to recover the full 580-bit `secret`.
We also need extra information from the higher-power structure, like `p^2` and `q^2`.

---

### Step 5 : Recover more residues using matrix logarithm.

Because the matrix is computed modulo powers of `p` and `q`, we can split the problem into:

```txt
p-adic part
q-adic part
```

The solver uses matrix logarithm to turn:

```txt
H = G^secret
```

into something linear:

```txt
log(H) = secret * log(G)
```

Then we solve linear congruences to recover:

```txt
secret mod p^2
secret mod q^2
```

After that, we combine all recovered residues using CRT.

---

### Step 6 : Full solver payload.

Payload:
```python
from pathlib import Path
import ast
import math
from itertools import product
from hashlib import sha256
from cypari2 import Pari
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

out = Path("output.txt").read_text().strip().splitlines()

g = ast.literal_eval(out[0])
h = ast.literal_eval(out[1])
ct = bytes.fromhex(out[2])

# Recover p and q from the divisibility pattern
q = math.gcd(
    g[0][1], g[0][2], g[1][2],
    h[0][1], h[0][2], h[1][2]
)

p = math.gcd(
    g[1][0], g[2][0], g[2][1],
    h[1][0], h[2][0], h[2][1]
)

print("[+] p =", p)
print("[+] q =", q)

class Full:
    def __init__(self, a):
        self.a = [row[:] for row in a]

    def __mul__(self, other):
        r = [[0] * 3 for _ in range(3)]

        for i, j, k in product(range(3), repeat=3):
            r[i][k] += self.a[i][j] * other.a[j][k]

        for i, j in product(range(3), repeat=2):
            r[i][j] %= p ** (i + 1) * q ** (j + 1)

        return Full(r)

    def __pow__(self, e):
        ans = Full([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
        cur = Full(self.a)

        while e:
            if e & 1:
                ans = ans * cur

            cur = cur * cur
            e >>= 1

        return ans

    def __eq__(self, other):
        return self.a == other.a

G = Full(g)
H = Full(h)

class PPart:
    def __init__(self, a, pr):
        self.pr = pr
        self.a = [[a[i][j] % (pr ** (i + 1)) for j in range(3)] for i in range(3)]

    def __mul__(self, other):
        pr = self.pr
        r = [[0] * 3 for _ in range(3)]

        for i, j, k in product(range(3), repeat=3):
            r[i][k] += self.a[i][j] * other.a[j][k]

        for i, j in product(range(3), repeat=2):
            r[i][j] %= pr ** (i + 1)

        return PPart(r, pr)

    def __sub__(self, other):
        return PPart(
            [[self.a[i][j] - other.a[i][j] for j in range(3)] for i in range(3)],
            self.pr
        )

    def scale(self, c):
        return PPart(
            [[c * self.a[i][j] for j in range(3)] for i in range(3)],
            self.pr
        )

def eyeP(pr):
    return PPart([[1, 0, 0], [0, 1, 0], [0, 0, 1]], pr)

def logP(A, pr):
    N = A - eyeP(pr)
    return N - (N * N).scale(pow(2, -1, pr ** 3))

class QPart:
    def __init__(self, a, pr):
        self.pr = pr
        self.a = [[a[i][j] % (pr ** (j + 1)) for j in range(3)] for i in range(3)]

    def __mul__(self, other):
        pr = self.pr
        r = [[0] * 3 for _ in range(3)]

        for i, j, k in product(range(3), repeat=3):
            r[i][k] += self.a[i][j] * other.a[j][k]

        for i, j in product(range(3), repeat=2):
            r[i][j] %= pr ** (j + 1)

        return QPart(r, pr)

    def __sub__(self, other):
        return QPart(
            [[self.a[i][j] - other.a[i][j] for j in range(3)] for i in range(3)],
            self.pr
        )

    def scale(self, c):
        return QPart(
            [[c * self.a[i][j] for j in range(3)] for i in range(3)],
            self.pr
        )

def eyeQ(pr):
    return QPart([[1, 0, 0], [0, 1, 0], [0, 0, 1]], pr)

def logQ(A, pr):
    N = A - eyeQ(pr)
    return N - (N * N).scale(pow(2, -1, pr ** 3))

def solve_linear_logs(LA, LB, pr, is_q=False):
    x = 0
    M = 1
    sols = []

    for i, j in product(range(3), repeat=2):
        exp = (j + 1) if is_q else (i + 1)
        mod = pr ** exp

        a = LA.a[i][j] % mod
        b = LB.a[i][j] % mod

        if a == 0:
            continue

        v = 0
        aa = a

        while aa and aa % pr == 0:
            aa //= pr
            v += 1

        if v < exp:
            m = pr ** (exp - v)
            sol = ((b // (pr ** v)) % m) * pow((a // (pr ** v)) % m, -1, m) % m
            sols.append((m, sol))

    for m, sol in sorted(sols, reverse=True):
        d = math.gcd(M, m)
        assert (sol - x) % d == 0

        l = M // d * m
        t = ((sol - x) // d * pow(M // d, -1, m // d)) % (m // d)

        x = (x + M * t) % l
        M = l

    return x, M

def crt(x, M, y, N):
    d = math.gcd(M, N)
    assert (y - x) % d == 0

    l = M // d * N
    t = ((y - x) // d * pow(M // d, -1, N // d)) % (N // d)

    return (x + M * t) % l, l

# Recover p-adic and q-adic residues
lsem = math.lcm(p - 1, q - 1)

xp, Mp = solve_linear_logs(
    logP(PPart((G ** (lsem * q * q)).a, p), p),
    logP(PPart((H ** (lsem * q * q)).a, p), p),
    p,
    False
)

xq, Mq = solve_linear_logs(
    logQ(QPart((G ** (lsem * p * p)).a, q), q),
    logQ(QPart((H ** (lsem * p * p)).a, q), q),
    q,
    True
)

# Recover semisimple residues from h[0][0] = g[0][0]^secret
pari = Pari()
pari.allocatemem(2 ** 29)

xp1 = int(pari(
    f"znlog(Mod({h[0][0] % p},{p}), Mod({g[0][0] % p},{p}), {p - 1})"
))

qord = (q - 1) // 3

xq1 = int(pari(
    f"znlog(Mod({h[0][0] % q},{q}), Mod({g[0][0] % q},{q}), {qord})"
))

# Combine all residues using CRT
secret = 0
mod = 1

for y, N in [
    (xp, Mp),
    (xq, Mq),
    (xp1, p - 1),
    (xq1, qord),
]:
    secret, mod = crt(secret, mod, y, N)

assert secret < 2 ** 580
assert mod > 2 ** 580
assert G ** secret == H

print("[+] secret =", secret)

# Decrypt flag
key = sha256(hex(secret).encode()).digest()[:16]

decryptor = Cipher(
    algorithms.AES(key),
    modes.ECB()
).decryptor()

dec = decryptor.update(ct)

flag = dec[:-dec[-1]].decode()

print("[+] flag =", flag)
```

Result:

```txt
PRAGEM{MCl4ReN_lU_w4rN4_4p4_b055_aec5c738d510636f}
```
---