
true :; ./sct_x86-64_Linux '\x6a\x3b\x58\x99\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x52\x53\x54\x5f\x52\x5e\x0f\x05'; exit

bits 64

    push   0x3b
    pop    rax
    cdq
    movabs rbx,0x68732f2f6e69622f

    push   rdx
    push   rbx
    push   rsp
    pop    rdi
    push   rdx
    pop    rsi
    syscall

