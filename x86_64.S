
#include "asm_common.h"

.file   "x86_64.s"

.globl cdecl(print_regs)
cdecl(print_regs):
    push rsp
    push rbp
    pushf           // save rflags
    mov rbp, rsp
    and rsp, 0xfffffffffffffff0

    sub rsp, 16
    push rbp
    xor rbp, rbp

    mov rbp, CS
    push rbp
    // push CS         // 2 bytes ?
    mov rbp, FS
    push rbp
    // push FS         // 4 bytes ?
    mov rbp, GS
    push rbp
    // push GS         // 4 bytes ? 
    
    // push rflags
    xor rbp, rbp
    push bp
    push bp
    push bp
    mov rbp, [rsp+30]
    mov bp, [rbp]
    push bp

    // push general registers
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push rdi
    push rsi
    push rbx
    push rdx
    push rcx
    push rax
    mov rbp, [rsp+144]
    sub rsp, 24
    // rbp
    mov rax, [rbp+2]
    mov [rsp+16], rax
    // rsp
    mov rax, [rbp+10]
    add rax, 8
    mov [rsp+8], rax
    // rip
    mov rax, [rbp+18]
    mov [rsp], rax

    // push fmt string
    jmp print_regs_fmt
get_back:
    pop rdi
    mov rsi, 32     // print space
    mov rdx, 32
    mov rcx, 32
    mov r8, 32
    mov r9, 32
    call cdecl(printf)
    add rsp, 24
    pop rax
    pop rcx
    pop rdx
    pop rbx
    pop rsi
    pop rdi
    pop r8
    pop r9
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15

    add rsp, 62

    popf
    pop rbp
    pop rsp
    ret
print_regs_fmt:
    call get_back
    .asciz"Register:%c%c%c%c%c\n$rip = 0x%llx\n$rsp = 0x%llx\n$rbp = 0x%llx\n$rax = 0x%llx\n$rcx = 0x%llx\n$rdx = 0x%llx\n$rbx = 0x%llx\n$rsi = 0x%llx\n$rdi = 0x%llx\n$r8 = 0x%llx\n$r9 = 0x%llx\n$r10 = 0x%llx\n$r11 = 0x%llx\n$r12 = 0x%llx\n$r13 = 0x%llx\n$r14 = 0x%llx\n$r15 = 0x%llx\n$rflags = 0x%llx\n$gs = 0x%llx\n$fs = 0x%llx\n$cs = 0x%llx\n"

