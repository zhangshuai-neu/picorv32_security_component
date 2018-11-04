all: boot.data
	@ echo "ok"
	
boot.data: boot.asm
	$(shell ./get_data.sh)

boot.asm: main.o
	riscv32-unknown-elf-objdump  main.o  -d  > boot.asm
	
main.o: main.c
	riscv32-unknown-elf-gcc main.c -c -o main.o

clean:
	rm main.o boot.asm
