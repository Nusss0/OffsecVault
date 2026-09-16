## Challenge Info

**Platform:** GEMASTIK 2026 - VS Code Extension

---

## FLAG : `PRAGEM{My_Goat_1s_Lioneeeel_Messiiii111111}`

---

## Solution :

### Step 1 : Check HTTP traffic.

Use `tshark` to inspect HTTP requests:

```bash
tshark -r network.pcapng -Y "http.request" -T fields -e frame.number -e ip.src -e ip.dst -e http.host -e http.request.uri
```

From the HTTP traffic, we find a suspicious downloaded file:

```shell
┌──(nus㉿Anomaly12)-[/mnt/shared/GEMASTIK/VSCode Extension]
└─$ tshark -r network.pcapng -Y "http.request" -T fields -e frame.number -e ip.src -e ip.dst -e http.host -e http.request.uri
1041	192.168.1.12	192.168.1.24	192.168.1.24:8080	/uc?export=download&id=19cWS2pXQEbyiArlzIR3aFv2JGuh01Dwk
```

Extract HTTP objects:

```shell
mkdir extracted
tshark -r network.pcapng --export-objects http,extracted
```

We got a file : 
```shell
┌──(nus㉿Anomaly12)-[/mnt/shared/GEMASTIK/VSCode Extension/extracted]
└─$ file uc%3fexport=download\&id=19cWS2pXQEbyiArlzIR3aFv2JGuh01Dwk 
uc%3fexport=download&id=19cWS2pXQEbyiArlzIR3aFv2JGuh01Dwk: ASCII text, with very long lines (439), with CRLF, LF line terminators
```

---

### Step 2 : Analyze the file payload.

The file payload is obfuscated, so we inspect it carefully.

Useful commands:

```shell
strings file
```

Continue to run this payload to decode the HTTP file results : 
```python
import re
from pathlib import Path

src = Path("extracted/file").read_text(errors="ignore")
chunks = re.findall(r'"([_.]{40,})"', src)

seed = (0x9b ^ 0x71) & 0xff
parts = {}

def dotstring_to_bytes(s):
    out = []
    for i in range(0, len(s) - 7, 8):
        v = 0
        for ch in s[i:i+8]:
            v <<= 1
            if ch == ".":
                v |= 1
        out.append(v & 0xff)
    return out

for s in chunks:
    b = dotstring_to_bytes(s)
    if len(b) < 5:
        continue

    idx = b[1] ^ ((seed * 3) & 0xff)

    if ((b[0] ^ seed ^ idx) & 0xff) != 0xa7:
        continue

    ln = b[2] ^ ((seed + 0x4d) & 0xff)
    checksum = b[3]

    if ln <= 0 or len(b) < 4 + ln:
        continue

    data = []
    for i in range(ln):
        x = idx * 43 + i
        y = (b[4+i] - (((x * 11) ^ seed) & 0xff)) & 0xff
        z = (seed + x * 73 + ((x % 19) * 17)) & 0xff
        data.append((y ^ z) & 0xff)

    if (((sum(data) & 0xff) ^ seed ^ ln) & 0xff) != checksum:
        continue

    parts[idx] = bytes(data)

payload = b"".join(parts[i] for i in sorted(parts))
Path("decoded.ps1").write_bytes(payload)

print(payload.decode(errors="replace"))
```
From the payload, we know that the real data is hidden inside DNS traffic.

---

### Step 3 : Extract DNS queries and Rebuild DNS exfiltrated JSON

Dump all DNS query names:

```bash
tshark -r network.pcapng -Y "dns.qry.name" -T fields -e dns.qry.name > chunks.txt
```

Then inspect:

```bash
cat chunks.txt
```

The DNS traffic contains chunks of the encrypted `secret.txt`
Now let's rebuild the exfiltrated JSON File :
```shell
tshark -r network.pcapng -Y 'dns.qry.name contains "sync.vscode-extension.lab"' -T fields -e dns.qry.name > dns.txt
```
Let's decrypt using this payload : 
```python
from pathlib import Path
import json

DOMAIN = "sync.vscode-extension.lab"

sessions = {}

for line in Path("dns.txt").read_text().splitlines():
    q = line.strip().rstrip(".")
    if not q.endswith(DOMAIN):
        continue

    parts = q.split(".")
    session = parts[0]
    seq = int(parts[1], 16)
    chunk = parts[2]

    sessions.setdefault(session, {})[seq] = chunk

# choose the session with the most chunks
session, chunks = max(sessions.items(), key=lambda x: len(x[1]))

hex_body = "".join(chunks[i] for i in sorted(chunks))
body = bytes.fromhex(hex_body).decode()

print(body)

data = json.loads(body)

with open("rebuilt.json", "w") as f:
    json.dump(data, f, indent=4)
```

Now from `rebuilt.json` we got : 
```text
CT : JezyFdQHftLBpo11zYNakolEcdBm6z6aqHpdLnA2bJAksT/TFV0mp8/NJqUh1q/7fzmFe3eyvCmdhiXIZlzhvw==
Key : 
MTIzNDU2Nzg5MGFiY2RlZjEyMzQ1Njc4OTBhYmNkZWY=
IV : 
bmlnaHQtbGl2ZS1pdiEhIQ==
```

---

### Step 4 : Rebuild and decrypt the exfiltrated data.

After sorting and combining the DNS chunks, we decrypt it using Python.
decrypt payload:

```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
import base64
import json

data = {
    "key": "MTIzNDU2Nzg5MGFiY2RlZjEyMzQ1Njc4OTBhYmNkZWY=",
    "iv": "bmlnaHQtbGl2ZS1pdiEhIQ==",
    "ciphertext": "JezyFdQHftLBpo11zYNakolEcdBm6z6aqHpdLnA2bJAksT/TFV0mp8/NJqUh1q/7fzmFe3eyvCmdhiXIZlzhvw=="
}

key = base64.b64decode(data["key"])
iv = base64.b64decode(data["iv"])
ct = base64.b64decode(data["ciphertext"])

cipher = AES.new(key, AES.MODE_CBC, iv)
pt = unpad(cipher.decrypt(ct), 16)

print(pt.decode())
```

The decrypted `secret.txt` contains:

```txt
https://github.com/AryoBama/My-Goat
stopmbgplease
```

So the decrypted file gives us a GitHub repository.

---

### Step 7 : Check the GitHub repository.

Clone the repository.

Using SSH:

```bash
git clone git@github.com:AryoBama/My-Goat.git
cd My-Goat
```

Check commit history:

```bash
git log --oneline
```

We find an interesting commit `ce47527`.
This commit deleted a file:

```txt
hmmmm/blabla.txt
```

Check the deleted file from the commit before deletion:

```bash
git show ce47527^:hmmmm/blabla.txt
```

The deleted file contains the flag:

```txt
PRAGEM{My_Goat_1s_Lioneeeel_Messiiii111111}
```
