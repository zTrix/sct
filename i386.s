
.file   "i386.s"

.globl _print_regs
_print_regs:
    push esp
    push ebp
    pushf                   // must be saved here, or the following operation may affact eflags, push operation does not affact eflags
    mov ebp, esp
    and esp, 0xfffffff0     // for alignment, will cause segfault in printf SSE instructions if not correctly aligned

    sub esp, 8
    push ebp
    xor ebp, ebp
    push bp
    push SS     // 2 bytes
    push bp
    push CS     // 2 bytes
    push bp
    push DS     // 2 bytes
    push bp
    push ES     // 2 bytes
    push FS     // 4 bytes
    push GS     // 4 bytes
    // push eflags
    push bp
    mov ebp, [esp+26]
    mov bp, [ebp]
    push bp
    // push general registers
    push edi
    push esi
    push ebx
    push edx
    push ecx
    push eax
    mov ebp, [esp+52]
    // reserve space for eip, esp, ebp
    sub esp, 12
    // ebp
    mov eax, [ebp+2]
    mov [esp+8], eax
    // esp
    mov eax, [ebp+6]
    add eax, 4
    mov [esp+4], eax
    // eip
    mov eax, [ebp+10]
    mov [esp], eax
    // push fmt string
    jmp print_regs_fmt
get_back:
    call _printf
    add esp, 16
    pop eax
    pop ecx
    pop edx
    pop ebx
    pop esi
    pop edi
    popf

    add esp, 26
    pop esp

    popf
    pop ebp
    pop esp
    ret
print_regs_fmt:
    call get_back
    .asciz "$eip = 0x%x\n$esp = 0x%x\n$ebp = 0x%x\n$eax = 0x%x\n$ecx = 0x%x\n$edx = 0x%x\n$ebx = 0x%x\n$esi = 0x%x\n$edi = 0x%x\n$eflags = 0x%x\n$gs = 0x%x\n$fs = 0x%x\n$es = 0x%x\n$ds = 0x%x\n$cs = 0x%x\n$ss = 0x%x\n"

