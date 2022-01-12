floppy/floppy.flp:bin/bootloaderfirst.bin bin/bootloadersecond.bin bin/bootloadersecondp2.bin
	dd if=/dev/zero of=floppy/floppy.flp conv=notrunc bs=512 count=2880
	dd if=bin/bootloaderfirst.bin of=floppy/floppy.flp conv=notrunc bs=512 count=1	
	dd if=bin/bootloadersecond.bin of=floppy/floppy.flp seek=1 conv=notrunc bs=512 count=4
	dd if=bin/bootloadersecondp2.bin of=floppy/floppy.flp skip=4 seek=5 conv=notrunc bs=512 count=16
bin/bootloaderfirst.bin:nasm/bootloaderfirst.nasm
	nasm -f bin -o bin/bootloaderfirst.bin nasm/bootloaderfirst.nasm	
bin/bootloadersecond.bin: nasm/bootloadersecond.nasm
	nasm -f bin -o bin/bootloadersecond.bin nasm/bootloadersecond.nasm
bin/bootloadersecondp2.bin: o/bootloadersecondp2.o o/print_w.o linker/linkerscript.ld
	ld -o bin/bootloadersecondp2.bin o/bootloadersecondp2.o o/print_w.o -m elf_i386 -T linker/linkerscript.ld
o/print_w.o: c/print_w.c
	gcc -fno-pie -o o/print_w.o -c c/print_w.c -m32
o/bootloadersecondp2.o: nasm/bootloadersecondp2.nasm
	nasm -f elf -o o/bootloadersecondp2.o nasm/bootloadersecondp2.nasm
