floppy.flp:boot.bin
	dd if=boot.bin of=floppy.flp conv=notrunc bs=512 count=1	
boot.bin:test.nasm
	nasm -f bin -o boot.bin test.nasm	