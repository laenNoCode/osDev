floppy/floppy.flp:bin/bootloaderfirst.bin bin/bootloadersecond.bin
	dd if=/dev/zero of=floppy/floppy.flp conv=notrunc bs=512 count=2880
	dd if=bin/bootloaderfirst.bin of=floppy/floppy.flp conv=notrunc bs=512 count=1	
	dd if=bin/bootloadersecond.bin of=floppy/floppy.flp seek=1 conv=notrunc bs=512 count=4
bin/bootloaderfirst.bin:nasm/bootloaderfirst.nasm
	nasm -f bin -o bin/bootloaderfirst.bin nasm/bootloaderfirst.nasm	
bin/bootloadersecond.bin: nasm/bootloadersecond.nasm
	nasm -f bin -o bin/bootloadersecond.bin nasm/bootloadersecond.nasm
