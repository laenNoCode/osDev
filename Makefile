floppy/floppy.flp:bin/bootloaderfirst.bin bin/bootloadersecond.bin bin/bootloadersecondp2.bin
	dd if=/dev/zero of=floppy/floppy.flp conv=notrunc bs=512 count=2880
	dd if=bin/bootloaderfirst.bin of=floppy/floppy.flp conv=notrunc bs=512 count=1	
	dd if=bin/bootloadersecond.bin of=floppy/floppy.flp seek=1 conv=notrunc bs=512 count=4
	dd if=bin/bootloadersecondp2.bin of=floppy/floppy.flp skip=12 seek=5 conv=notrunc bs=512 count=50
bin/bootloaderfirst.bin:nasm/bootloaderfirst.nasm
	nasm -f bin -o bin/bootloaderfirst.bin nasm/bootloaderfirst.nasm	
bin/bootloadersecond.bin: nasm/bootloadersecond.nasm
	nasm -f bin -o bin/bootloadersecond.bin nasm/bootloadersecond.nasm
bin/bootloadersecondp2.bin: o/bootloadersecondp2.o o/interrupts.o linker/linkerscript.ld
	ld -o bin/bootloadersecondp2.bin o/bootloadersecondp2.o o/interrupts.o -m elf_i386 -T linker/linkerscript.ld
o/interrupts.o: c/interrupts.c
	gcc -fno-pie -o o/interrupts.o -c c/interrupts.c -m32 -O1
o/bootloadersecondp2.o: nasm/bootloadersecondp2.nasm nasm/includes/interrupts.nasm
	nasm -f elf -o o/bootloadersecondp2.o nasm/bootloadersecondp2.nasm
