
true :;./sct '\x55\x48\x89\xe5\xeb\x33\x48\x31\xff\x66\xbf\x01\x00\x5e\x48\x31\xd2\xb2\x0e\x41\xb0\x02\x49\xc1\xe0\x18\x49\x83\xc8\x04\x4c\x89\xc0\x0f\x05\x31\xff\x41\xb0\x02\x49\xc1\xe0\x18\x49\x83\xc8\x01\x4c\x89\xc0\x0f\x05\x48\x89\xec\x5d\xe8\xc8\xff\xff\xff\x48\x65\x6c\x6c\x6f\x2c\x20\x57\x6f\x72\x6c\x64\x21\x0a'; exit

; Assemble and link with:
; nasm -f macho64 -o HelloWorld.o HelloWorld.s
; ld -arch x86_64 -o HelloWorld HelloWorld.o

BITS 64

global start

section .text

start:

    push rbp
    mov rbp, rsp

    jmp short String

StringRet:
    xor rdi, rdi
    mov di, 0x01

    pop rsi

    xor rdx, rdx
    mov dl, 0xE

    mov r8b, 0x02
    shl r8, 24
    or r8, 0x04
    mov rax, r8

    syscall            ; System call for write(4)

    xor edi, edi

    mov r8b, 0x02
    shl r8, 24
    or r8, 0x01
    mov rax, r8

    syscall            ; System call for exit(1)

    mov rsp, rbp
    pop rbp

String:

    call StringRet
    db 'Hello, World!', 0x0a
