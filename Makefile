floppy/floppy.flp:bin/bootloaderfirst.bin bin/boot.bin bin/fat.bin
	dd if=/dev/zero of=floppy/floppy.flp conv=notrunc bs=512 count=2880
	dd if=bin/bootloaderfirst.bin of=floppy/floppy.flp conv=notrunc bs=512 count=1
	dd if=bin/fat.bin of=floppy/floppy.flp seek=1 conv=notrunc bs=512 count=3
	dd if=bin/boot.bin of=floppy/floppy.flp seek=4 conv=notrunc bs=512 count=54
bin/bootloaderfirst.bin:nasm/bootloaderfirst.nasm
	nasm -f bin -o bin/bootloaderfirst.bin nasm/bootloaderfirst.nasm	
bin/tmp/bootloadersecond.bin: nasm/bootloadersecond.nasm
	nasm -f bin -o bin/tmp/bootloadersecond.bin nasm/bootloadersecond.nasm
bin/tmp/bootloadersecondp2.bin: o/bootloadersecondp2.o o/interrupts.o linker/linkerscript.ld
	ld -o bin/tmp/bootloadersecondp2.bin o/bootloadersecondp2.o o/interrupts.o -m elf_i386 -T linker/linkerscript.ld
o/interrupts.o: c/interrupts.c c/keyboard.c c/inout.c c/pci.c c/print.c
	gcc -fno-pie -o o/interrupts.o -c c/interrupts.c -m32 -O1
o/bootloadersecondp2.o: nasm/bootloadersecondp2.nasm nasm/includes/interrupts.nasm nasm/includes/keyboard.nasm
	nasm -f elf -o o/bootloadersecondp2.o nasm/bootloadersecondp2.nasm
bin/fat.bin: bin/boot.bin
	python3 utils/formatter.py
bin/boot.bin:bin/tmp/bootloadersecond.bin bin/tmp/bootloadersecondp2.bin
	dd if=/dev/zero of=bin/boot.bin bs=512 count=56
	dd if=bin/tmp/bootloadersecondp2.bin of=bin/boot.bin skip=8 conv=notrunc bs=512 count=50
	dd if=bin/tmp/bootloadersecond.bin of=bin/boot.bin conv=notrunc bs=512 count=4
	