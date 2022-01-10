[org 0x1000:0x0000]

test:
	cli
	mov ax,0xABCD
	mov bx,0
	mov cl,0x40
	call print_register
	jmp hang

print:
	mov ax,0xB800
	mov ES, ax
	mov BX,0
	mov Al, 'a'
	mov [es:bx], al
	mov bx, 1
	mov al,0x40
	mov [es:bx],al
	ret

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

	mov ax,0xB800
	mov es,ax
	mov ax, bx
	mov bx,2
	mul bx
	mov bx,ax
	mov al,cl
	mov cx,6
	add bx,1
	print_register_color_loop:
		mov byte [es:bx],al
		add bx,2
	loop print_register_color_loop
	sub bx,3
	mov cx,4

	pop ax
	push bx
	print_register_hex_print_loop:
		mov dx,0
		mov bx,0x10
		div bx
		add dx,'0'
		cmp dx,'9'
		jle print_register_hex_print_loop_numeric
			add dx,'A'-'9' - 1
		print_register_hex_print_loop_numeric:

		pop bx
		mov byte [es:bx],dl
		sub bx,2
		push bx
		clf
	loop print_register_hex_print_loop
	pop bx
	mov byte [es:bx],'x'
	sub bx,2
	mov byte [es:bx], '0'

	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret

hang: jmp hang
is_hdd: db 0
tmp_data: dw 0
times 4*512 - ($ -$$)  - 1 db 0x0
db 32