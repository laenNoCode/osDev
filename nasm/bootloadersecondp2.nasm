[bits 32]
section .text
%include "nasm/includes/interrupts.nasm"

times 14*512 - ($ -$$)  - 1 db 0x0
db 0xFF