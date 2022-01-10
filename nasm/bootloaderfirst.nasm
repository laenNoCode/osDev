


;=====================================
; nasmw boot.asm -f bin -o boot.bin
; partcopy boot.bin 0 200 -f0
;gonna load 2nd sector data to sum it 
[ORG 0x7c00]      ; add to offsets


xor ax,ax
mov ds,ax
mov ax, 0x9000
mov ss, ax
mov ax, 0xFFFF ; 65536 bytes of stack, stack will be changed later when all is ok
mov sp, ax
mov bp, ax

;BIG TODO : go to stage 2 !!! (all the rest of the stuff can be done at stage 2)
mov ax, 0xB800
mov es,ax
call check_a20
cmp al,1
je A20_end
call enable_A20
call check_a20

A20_end:

	jmp goto_second_stage
enable_A20:
	cli

	call    a20wait
	mov     al,0xAD
	out     0x64,al

	call    a20wait
	mov     al,0xD0
	out     0x64,al

	call    a20wait2
	in      al,0x60
	push    ax

	call    a20wait
	mov     al,0xD1
	out     0x64,al

	call    a20wait
	pop     ax
	or      al,2
	out     0x60,al

	call    a20wait
	mov     al,0xAE
	out     0x64,al

	call    a20wait
	sti
	ret
 
a20wait:
	in      al,0x64
	test    al,2
	jnz     a20wait
	ret
 
 
a20wait2:
	in      al,0x64
	test    al,1
	jz      a20wait2
	ret
check_a20:
	push ds
	push es
	push di
	push si
	cli

	xor ax, ax ; ax = 0
	mov es, ax

	not ax ; ax = 0xFFFF
	mov ds, ax

	mov di, 0x0500
	mov si, 0x0510

	mov al, byte [es:di]
	push ax

	mov al, byte [ds:si]
	push ax

	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF

	cmp byte [es:di], 0xFF

	pop ax
	mov byte [ds:si], al

	pop ax
	mov byte [es:di], al

	mov ax, 0
	je check_a20__exit

	mov ax, 1
 
check_a20__exit:

	pop si
	pop di
	pop es
	pop ds
	ret
;jumps to second stage bootloader
;
;
check_disk_status:
	xor ax,ax
	xor dx,dx
	xor cx,cx
	mov es,ax
	mov di,ax
	mov ah, 0x08
	mov dl,0x80
	int 0x13
	xor ax,ax
	mov bx,18
	mov al,dl
	jmp hang
goto_second_stage:;resets t
       ;let's load that bad boy code
	;first let's reset the floppy disk we are going to load it from
	reset_floppy:
		mov ah,0 ;reset drive function
		mov dl,0;first floppy
		int 0x13
	jc reset_floppy
	load_floppy_code:
		mov ax,0x1000 ;code will go into 1000h
		mov es,ax
		xor bx,bx
		mov ah, 0x2
		mov ch,0;first cylinder
		mov cl,2;second sector
		mov dl,0;first floppy
		mov al, 4;number of sectors to load
		int 0x13
	jmp 0x1000:0x0000
;checks the floppy data :

;        mov ah,0 ; reset drive
;        mov dl, 0;loads from floppy
;        int 0x13
;        jc goto_second_stage
;;loads code
;load_second_stage_code:
;
;        mov ax,0x1000;
;        mov es,ax
;        xor bx,bx 
;        ; all segment to load to
;
;        mov ah, 0x2; read instruction
;        mov al,0xFF; 
;        ;18 sectors per track, 80 tracks per side and two sides, for a total of 1,474,560 
;
;
;
;;load_data:
;;        mov ah, 0;reset drive
;;        mov dl, 0;load from floppy
;;        int 0x13
;;        jc load_data ;carry is set if bios int error
;;read__first_sector:
;        mov ax, 0x1000;data segment to append data to
;        mov es,ax
;        xor bx,bx ; reads to es:bx
;        mov ah, 0x02 ;read instruction
;        mov al, 1; reads 1 sector
;        mov ch,0; first cylinder
;        mov cl,1 ;sector ID (starts  from one)
;        mov dh, 0;head number
;        mov dl, 0; first floppy
;        int 0x13
;
;reset_hdd:
;        mov ah, 0;reset drive
;        mov dl, 0x80;load from HDD
;        int 0x13
;        jc load_data ;carry is set if bios int error
;write_first_sector:
;        mov ax, 0x1000;data segment to write from
;        mov es,ax
;        xor bx,bx ; writed to es:bx
;        mov ah, 0x03 ;write instruction
;        mov al, 1; reads 1 sector
;        mov ch,0; first cylinder
;        mov cl,1 ;sector ID (starts  from one)
;        mov dh, 0;head number
;        mov dl, 0x80; first hdd
;        int 0x13

;reset_drive:
;   mov ah, 0;reset drive function
;   mov dl, 0;floppy 0 (use 0x80 for HDD)
;   int 0x13 ; call bios read
;   jc reset_drive ;if carry set, reset had an error, so reset floppy

;read__first_sector:
;   mov ax,0x1000; sets the sector we want to read to
;   mov es,ax
;   xor bx, bx ;reads into es:bx => xor bx,bx => bx = 0
;   mov ah, 0x02 ;read instruction
;   mov al, 1 ; reads 1 sector (could be more)
;   mov ch, 0; still on first cylinder
;   mov cl, 1; sector number
;   mov dh, 0 ;head number
;   mov dl, 0; first floppy
;   int 0x13

;check_sum:
;   mov ax, 0x1000
;   mov ds,ax
;   xor bx,bx
;   xor ax,ax
;   mov cx,512
;   check_sum_loop:
;      mov byte dl,[bx]
;      add al,dl
;      inc bx
;      dec cx
;      cmp cx,0
;   jne check_sum_loop

;cli
;print_val:
;   mov bl, 0x10
;   div bl
;   mov bx, ax
;   xor ax, ax
;   mov ax, 0xB800
;   mov es,ax

;   xor ax,ax
;   mov al, bl
;   add ax,0xF100 + '0'
;   mov word [es:0],ax 
;   
;   xor ax,ax
;   mov al, bh
;   add ax,0xF100 + '0'
;   mov word [es:2],ax 
;;   mov dx,0
; ;  mov al, 0xF0
;;   mov byte [es:0], al
;;   mov al, bl
;;   add al, '0'
;;   mov byte [es:1],al
;

;ax : value to print
print_register:
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
        
        loop_print_register:
			mov dx,0
			mov bx, 0x10
			div  bx
			cmp dl,10
			jl low_print_register
				add dl, 'A' - '0' - 10
			low_print_register:
			add dl,'0'
			pop bx
			push ax
        	        mov byte [es:bx],dl
			dec bx
			dec bx
			pop ax
			push bx

;                mov bl,16
;                div bl
;                add al, '0'
;                pop bx
;                mov al,0x66
;                mov bx, 2
;                mov byte [es:bx],al
;                ;mov byte [es:bx + 1],al
;                mov al,ah
;                add bx,2
;                push bx
        loop loop_print_register
        pop bx
;
        pop bx
        pop ax
        sti
        ret

hang: jmp hang
is_hdd: db 0
times 510 - ($ -$$) db 0
db 0x55
db 0xAA
