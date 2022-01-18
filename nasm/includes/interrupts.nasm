make_idt:
	pusha
	call put_interrupt_record
	lidt [idt_descriptor]
	sti
	mov eax, 0x00
	int 0x81

	
	mov eax, 0x1
	mov bl,0x0C
	int 0x81
	mov eax, 0x3
	mov ebx, texte
	mov edx, 300
	int 0x81
	
	
	popa
	ret
texte:
	db "wellcome to laen os.", 10, "system is currently in developpement", 10, 0

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
%rep 128
interrupt i
%assign i i+1
%endrep
;interrupt 128 is particular as it concerns system calls
__nasm_interrupt_128:
extern __c_interrupt_128
	pusha
	push ebx
	push eax
	call __c_interrupt_128
	pop eax
	pop ebx
	popa
	iret
__nasm_interrupt_129:
extern __c_interrupt_129
	pusha
	push edx
	push ebx
	push eax
	call __c_interrupt_129
	pop eax
	pop ebx
	pop edx
	popa
	iret
%assign i 0x82
%rep 126
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