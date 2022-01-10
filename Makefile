floppy.flp:bootloaderfirst.bin bootloadersecond.bin
	dd if=bootloaderfirst.bin of=floppy.flp conv=notrunc bs=512 count=1	
	dd if=bootloadersecond.bin of=floppy.flp seek=1 conv=notrunc bs=512 count=4
bootloaderfirst.bin:bootloaderfirst.nasm
	nasm -f bin -o bootloaderfirst.bin bootloaderfirst.nasm	
bootloadersecond.bin: bootloadersecond.nasm
	nasm -f bin -o bootloadersecond.bin bootloadersecond.nasm
