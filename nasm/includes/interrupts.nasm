make_idt:
	pusha
	call put_interrupt_record
	lidt [idt_descriptor]
	sti
	int 0x80
	popa
	ret

%macro interrupt 1
__nasm_interrupt_%1:
extern __c_interrupt_%1
	pusha
	call __c_interrupt_%1
	popa
	iret
%endmacro
;will block further interrupts



%assign i 0
%rep 256
interrupt i
%assign i i+1
%endrep


%macro idt_record_load 1
	
	mov eax, __nasm_interrupt_%1
	mov word [ebx], ax 
	add ebx,8
%endmacro
put_interrupt_record:
	pusha
	mov ebx,idt_records
	%assign i 0
	%rep 256
	idt_record_load i
	%assign i i+1
	%endrep
	popa
	ret

idt_records:
	times (256) dw 0x00, 0x0008, 0xEE00, 0x00;interrupt gate, for hardware
	;times (224) dw 0x00, 0x0008, 0xEE00, 0x00;interrupt trap, for soft


idt_descriptor:
	dw 0x7ff;c'etait en bytes, pas en nombre d'entrées
	dw idt_records