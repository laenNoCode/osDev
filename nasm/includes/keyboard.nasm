%define PIC1		0x20		
%define PIC2		0xA0		; IO base address for slave PIC 
%define PIC1_COMMAND	PIC1
%define PIC1_DATA	(PIC1+1)
%define PIC2_COMMAND	PIC2
%define PIC2_DATA	(PIC2+1)
%define PIC_EOI		0x20	
IO_WAIT:
	push eax
	in eax,0x80;unused port
	pop eax
	ret
keyboard_init:
	mov al,0x11 ; RESET COMMAND
	out PIC1_COMMAND,al
	call IO_WAIT
	out PIC2_COMMAND, al	
	call IO_WAIT
	mov al, 0x20; new interrupt offset to avoid material interrupt conflict (pic remaping)
	out PIC1_DATA,al
	call IO_WAIT
	mov al,0x28
	out PIC2_DATA, al
	call IO_WAIT

	mov al,4
	out PIC1_DATA, al
	call IO_WAIT
	mov al,2
	out PIC2_DATA, al
	call IO_WAIT
	mov al, 0xFE
	out  0x21, al;enables only the keyboard interrupt
	mov al, 0xff
	out  0xA1, al
	mov eax,3
	mov ebx,keyboard_msg
	mov edx,100
	int 0x81
	ret
keyboard_msg:
db "keyboard init done ", 10,0