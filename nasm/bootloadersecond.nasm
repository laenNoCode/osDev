[ORG 0X1000]
[bits 16]
%define STACK_32 0x7000000
jmp teste

Global_Descriptor_Table_32:
db 0, 0, 0, 0, 0, 0, 0, 0
db 0xff, 0xff, 0, 0, 0, 0b10011010, 0b11001111, 0; code segment, 0x08, ring 0
db 0xff, 0xff, 0, 0, 0, 0b10010010, 0b11001111, 0; data segment, 0x10, ring 0
db 0xff, 0xff, 0, 0, 0, 0b11111010, 0b11001111, 0; code segment, 0x18, ring 3 HAS TO BE UPDATED so user can't modify kernel at runtime
db 0xff, 0xff, 0, 0, 0, 0b11110010, 0b11001111, 0; data segment, 0x20, ring 3 or paging must be put in place


GDT_POINTER:
	magie_vaudou:
		dw GDT_POINTER - Global_Descriptor_Table_32 - 1
		dd Global_Descriptor_Table_32



teste:
	cli
	lgdt [GDT_POINTER]
	mov eax,cr0
	or eax,1
	;sgdt [gdt2]

	mov cr0,eax
	jmp 0x8:pmode
[bits 32]


pmode:
	mov eax, 0x10
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov esp,STACK_32
	mov ax,0xABCD
	mov bx,0
	mov cl,0x40
	mov dx,4
	mov al, 0x10
	out 0x70, al ;read floppy type from CMOS
	in al,0x71
	call print_register
	call 0X1800
	
	jmp hang


print_register:
	;save all the data
	;params : ax: to print
	;params: bx: location to print to, will be times 2 to calculate actual memory
	;cl: color
	push ax
	push bx
	push cx
	push dx
	push es

	push ax

	mov ax, bx
	mov bx,2
	mul bx
	mov bx,ax
	add ebx,0xB8000
	mov al,cl
	mov cx,6
	add ebx,1
	print_register_color_loop:
		mov byte [ebx],al
		add bx,2
	loop print_register_color_loop
	sub bx,3
	mov cx,4

	pop ax
	push ebx
	print_register_hex_print_loop:
		mov dx,0
		mov bx,0x10
		div bx
		add dx,'0'
		cmp dx,'9'
		jle print_register_hex_print_loop_numeric
			add dx,'A'-'9' - 1
		print_register_hex_print_loop_numeric:

		pop ebx
		mov byte [ebx],dl
		sub ebx,2
		push ebx

	loop print_register_hex_print_loop
	pop ebx
	mov byte [ebx],'x'
	sub ebx,2
	mov byte [ebx], '0'

	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret

hang: jmp hang
is_hdd: db 0
tmp_data: dw 0
;GDT



times 4*512 - ($ -$$)  - 1 db 0x0
db 0xFF
;next address will be located at 0x1800