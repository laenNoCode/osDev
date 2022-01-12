[bits 32]
section .text
extern print_w
works:
	call print_w
	ret

times 1*512 - ($ -$$)  - 1 db 0x0
db 0xFF