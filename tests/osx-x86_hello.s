
BITS 32

section .text
global _start

_start:
    push len
    jmp push_str
get_back:
    push 0x1
    mov eax, 0x4
    sub esp, 0x4 ; Stack align
    int 0x80 ; write

    mov eax, 0x1
    sub esp, 0x4
    int 0x80 ; exit

push_str:
    call get_back
    msg db 'Hello world!', 0xa
    len equ $ - msg


