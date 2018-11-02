all: boot.asm

boot.asm: main.o
	riscv32-unknown-elf-objdump  main.o  -d  > boot.asm
	
main.o: main.c
	riscv32-unknown-elf-gcc main.c -c -o main.o

clean:
	rm main.o boot.asm
