qemu-system-x86_64 -drive file=floppy/floppy.flp,format=raw,if=floppy -monitor stdio -d int -no-reboot -no-shutdown
objdump -D -Mintel -b binary -m i386 bin/bootloadersecond.bin