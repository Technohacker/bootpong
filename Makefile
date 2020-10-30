binary:
	nasm bootpong.s

run: binary
	qemu-system-x86_64 -drive format=raw,file=bootpong 

all: binary

.PHONY: all, run, binary