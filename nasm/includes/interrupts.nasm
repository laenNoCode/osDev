%macro interrupt 1
__nasm_interrupt_%1:
extern __c_interrupt_%1
	pusha
	call __c_interrupt_%1
	popa
	iret
%endmacro
interrupt 3
	