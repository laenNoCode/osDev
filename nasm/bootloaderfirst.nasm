


;=====================================
; nasmw boot.asm -f bin -o boot.bin
; partcopy boot.bin 0 200 -f0
;gonna load 2nd sector data to sum it 
     ; add to offsets
;setting up FAT16 filesystem
jmp start
nop
;in this experiment, we will try to load the os using unreal mode
BOOT_RECORD:
db "MSDOS5.0"; fat DOS version
dw 0x0200; 512, bytes per sector
db 8;number of blocs per cluster, represents 4kiB
dw 0x01;only first sector is not in the file system
db 01; one file allocation table
dw 0x10;16 root directory entries so that it occupies an entire sector (32x16)
dw 0xB40;number of blocks on the drive (2880 sectors on floppy)
db 0xF0;media descriptor, unused
dw 0x02;a fat only addresses 360 clusters on this drive
dw 0x12;18 sectors per track
dw 0x2;2 sides per floppy
dw 0,0;no hidden blocks
dw 0,0;no need for larger drive
dw 0x80;drive number
db 0x28;extended boot record signature
dw 0xDEAD, 0xBEEF;volume serial number
db "YOUEN BEA D"
db "FAT12   "




start:
;first, move the first stage to further away in memory
mov ax, 0x7C0
mov ds,ax
mov [DISK_LOADED_FROM], dl
mov ax, 0x050
mov es, ax
	
mov bx,0
copy_first_stage:
	mov word ax,[ds:bx]
	mov word [es:bx], ax
	inc bx
	inc bx
	cmp bx,512
	jl copy_first_stage

jmp 0x50:start_bootloader_other_address
start_bootloader_other_address:
mov ax,0x50
mov ds, ax
mov es, ax
mov ax, 0x7000
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



goto_second_stage:;resets t
       ;let's load that bad boy code
	;first let's reset the floppy disk we are going to load it from
	cli
	;let's get the drive CHS info
	setup_and_check_drive_type:
		mov ax,0x50
		mov es,ax
		mov ds,ax
		xor ax, ax
		mov al,[DISK_LOADED_FROM]
		cmp al,0x80
		je load_from_lba

	reset_floppy:
		mov ah,0 ;reset drive function
		mov dl,[DISK_LOADED_FROM];first floppy
		int 0x13
	jc reset_floppy
	load_floppy_code:
		mov ax,0x100 ;code will go into 1000h
		mov es,ax
		xor ax,ax

		xor bx,bx; starts on es:00
		mov ah, 0x2
		mov ch,0;first cylinder
		mov cl,5;forth sector, skip bootloader,fat and root directory
		mov dh,0;head number 0
		mov dl,[DISK_LOADED_FROM];first floppy
		mov al, 50;number of sectors to load, MAX, OS IS BEHIND
		int 0x13
		mov bx, (80*2 + 16) *2
		call print_register
		sti
	loaded:
		mov ax,[es:00]
		mov bx,160
		call print_register
	jump_second:
	jmp 0x000:0x1000
	load_from_lba:;checks if ext are here
		mov dword [bloffset], 0x0
		mov ax,0x100
		mov es,ax
		mov bx,0
		find_base_ptr:
		mov ax,0x50
		mov ds,ax
		mov si, DAP
		mov ax,0
		mov ah,0x42
		mov dl,[DISK_LOADED_FROM]
		int 0x13
		add bx, 12
		add dword [bloffset],1
		cmp byte [es:laenSign], 0x1A
		jne find_base_ptr
		add dword [bloffset], 3
		mov dword [blread], 50
		mov ah, 0x42
		mov dl,[DISK_LOADED_FROM]
		int 0x13
		jmp loaded

DAP:
	db 0x10;size of dap
	db 0; should be 0
blread:
	dw 1;number of sectors to read
	dw 0x00,0x100 ;reads data to 0x1000
bloffset:
	dd 00,0
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
times 508 - ($ -$$) db 0
DISK_LOADED_FROM:
db 0
laenSign:
db 0x1A;laen signature
db 0x55
db 0xAA
