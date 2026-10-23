## Definition
> **AES (Advanced Encryption Standard)** is a symmetric block cipher standardized by NIST (FIPS PUB 197). It processes fixed data blocks of **128 bits (16 bytes)** using symmetric keys of **128, 192, or 256 bits**.

---
## Tags 

#Material #Cryptography #SymmetricCipher #AES 

---
## Common Modes of Operation

### 1. ECB (Electronic Codebook)
- Each 16-byte block is encrypted independently with the same key.
- **Flaw**: Identical plaintext blocks produce identical ciphertext blocks, leaking patterns (e.g. the famous ECB Linux Penguin).
- Does **not** require an Initialization Vector (IV).

### 2. CBC (Cipher Block Chaining)
- Each plaintext block is XORed with the preceding ciphertext block before encryption.
- Requires an **Initialization Vector (IV)** for the first block.
- Prevents identical plaintext blocks from producing repeating ciphertext patterns.

---
## Padding (PKCS#7)
Because AES operates on strict 16-byte boundaries, plaintexts whose length is not a multiple of 16 bytes must be padded. PKCS#7 appends $N$ bytes, each with value $N$ (e.g. if 3 bytes missing: `\x03\x03\x03`).

---
## Python Decryption Example (`cryptography` / `pycryptodome`)
```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
import base64

key = b"16_byte_secret!!"
iv  = b"16_byte_iv_here!"
ciphertext = base64.b64decode(raw_b64)

# CBC Decryption
cipher = AES.new(key, AES.MODE_CBC, iv)
plaintext = unpad(cipher.decrypt(ciphertext), 16)
print(plaintext.decode())
```

---
## Related Concepts : 
[[Python - Payload Insert]], [[DNS Exfiltration]]
