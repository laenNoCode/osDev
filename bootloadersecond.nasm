[org 0x1000]

test:
	call print
	jmp hang

print:
	mov ax,0xB800
	mov ES, ax
	mov BX,0x1
	mov Al, 'a'
	mov [es:bx], al
	mov bx, 1
	mov al,0x40
	mov [es:bx],al
	ret

hang: jmp hang
is_hdd: db 0

times 4*512 - ($ -$$)  - 1 db 0x0
db 32