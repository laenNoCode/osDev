[ORG 0X1000]
[bits 16]
%define STACK_32 0x7000000
jmp teste

print_register_16:
        cli
        push ax
        push bx 

        push ax
        ;sets the es to be graphical memory
        mov ax, 0xB800
        mov es, ax
        pop ax
;       mov bx,4
		add bx,6
        push bx
        mov cx,4
        
        loop_print_register_16:
			mov dx,0
			mov bx, 0x10
			div  bx
			cmp dl,10
			jl low_print_register_16
				add dl, 'A' - '0' - 10
			low_print_register_16:
			add dl,'0'
			pop bx
			push ax
        	        mov byte [es:bx],dl
			dec bx
			dec bx
			pop ax
			push bx
        loop loop_print_register_16
        pop bx
;
        pop bx
        pop ax
        sti
        ret






print_ram_entry:
	mov ax,di
	mov dx,0
	mov bx, 24
	div bx
	add ax,1
	mov bx,160
	mov dx,0
	mul bx
	mov bx,ax
	mov al, '0'
	call print_char
	add bx,2
	mov al, 'x'
	call print_char
	add bx, 32
	%assign a 0
	%rep 2
		mov eax, [es:di + a]
		%rep 8
			mov cx,16
			mov edx,0
			div ecx
			call print_hex
			sub ebx,2
		%endrep
		%assign a a+4
	%endrep
	add bx, 36
	mov al, '0'
	call print_char
	add bx,2
	mov al, 'x'
	call print_char
	add bx, 32
	%rep 2
		mov eax, [es:di + a]
		%rep 8
			mov cx,16
			mov edx,0
			div ecx
			call print_hex
			sub ebx,2
		%endrep
		%assign a a+4
	%endrep
	add bx,36
	mov byte dl, [es:di + a]
	call print_hex
	ret
print_char:
	pusha
	push es
	mov dx, ax
	mov ax,0xB800
	mov es,ax
	mov [es:bx], dl
	pop es
	popa
	ret
print_hex:
	pusha
	push es
	mov ax,0xB800
	mov es,ax
	mov ax,dx
	cmp al,10
	jl print_hex_dec
	add al, 'A' - '0' - 10
	print_hex_dec:
		add al, '0'
	mov [es:bx], al
	pop es
	popa
	ret

get_installed_ram:
	mov ebx, 0x000
	mov ax, 0x10
	mov es,ax
	mov di, 0x00
	mov edx, 0x534D4150
	mov eax, 0xE820 
	mov ecx, 0x24
	int 0x15
	pusha
	push es
		call print_ram_entry
	pop es
	popa
	loop_get_installed_ram:
		add di,24
		mov edx, 0x534D4150
		mov ecx,24
		mov eax, 0xE820 
		int 0x15
		pusha
		push es
			call print_ram_entry
		pop es
		popa
		cmp ebx, 0
		jne loop_get_installed_ram
	ret
hang_16:jmp hang_16


teste:
	mov cx,80*25
	mov bx, 0
	mov ax,0xB800
	mov es,ax
	clear_screen_loop:
		mov byte [es:bx], ' '
		add bx,2
	loop clear_screen_loop
	call get_installed_ram
	cli
	xor ax,ax
	mov ds,ax
	mov es,ax
	lgdt [GDT_POINTER]
	mov eax,cr0
	or eax,1
	;sgdt [gdt2]
	mov cr0,eax
	jmp 0x8:pmode
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
[bits 32]

pmode:
	mov eax, 0x10
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov esp,STACK_32
	mov ax,0
	mov  byte al,[0x100 + 509]; drive we boot from !
	mov byte [current_drive], al; will be located at 0x17FF
	mov bx,0
	mov cl,0x40
	mov dx,4
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
tmp_data: dw 0
;GDT



times 4*512 - ($ -$$)  - 1 db 0x0
current_drive: db 0
;next address will be located at 0x1800