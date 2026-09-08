```python
from pwn import *
context.log_level = 'critical' #to mute any failed attemp
file = ('')

# Payload Building
payload =  


#Write To File?
write('payload',payload)


# Process here
p = process(file)
p.send(payload)


output = p.recvall(timeout=2)
if b'flag' in output :
	print(output.decode('utf-8', errors='ignore'))
```
