.PHONY: all run clean

CC=clang
OS=$(shell uname -s)
CCARGS=-Wall -O0 -g -no-pie

all: sct_i386_$(OS) sct_x86-64_$(OS)

sct_i386.o: sct.c
	$(CC) -m32 -c $^ -o $@

sct_x86-64.o: sct.c
	$(CC) -c $^ -o $@

sct_i386_$(OS): i386.o sct_i386.o
	$(CC) $(CCARGS) -m32 $^ -o $@

sct_x86-64_$(OS): x86_64.o sct_x86-64.o
	$(CC) $(CCARGS) $^ -o $@

i386.o: i386.S
	$(CC) -c -m32 -mllvm --x86-asm-syntax=intel $^ -o $@

x86_64.o: x86_64.S
	$(CC) -c -mllvm --x86-asm-syntax=intel $^ -o $@

clean:
	rm -f *.o sct_i386_Linux sct_x86-64_Linux sct_i386_Darwin sct_x86-64_Darwin
