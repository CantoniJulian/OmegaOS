FLAGS = -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc
FILES = ./build/kernel.asm.o ./build/kernel.o

all:
	nasm -f bin ./src/btldr.asm -o ./bin/btldr.bin
	nasm -f elf -g  ./src/kernel.asm -o ./build/kernel.asm.o
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o
	
	i686-elf-gcc $(FLAGS) -T ./src/linker.ld -o ./bin/kernel.bin $(FILES)

	cat ./bin/btldr.bin ./bin/kernel.bin > ./bin/OS.bin
	dd if=/dev/zero of=./bin/OS.bin bs=512 count=8 conv=notrunc oflag=append

clean:
	rm -f ./bin/btldr.bin
	rm -f ./bin/OS.bin
	rm -f ./bin/kernel.bin
	rm -f ./build/kernel.asm.o
	rm -f ./build/kernel.o
	rm -f ./build/fullK.o
