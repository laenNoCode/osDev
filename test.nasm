
;=====================================
; nasmw boot.asm -f bin -o boot.bin
; partcopy boot.bin 0 200 -f0
;gonna load 2nd sector data to sum it 
[ORG 0x7c00]      ; add to offsets
xor ax,ax
mov ds,ax


reset_drive:
   mov ah, 0;reset drive function
   mov dl, 0;floppy 0 (use 0x80 for HDD)
   int 0x13 ; call bios read
   jc reset_drive ;if carry set, reset had an error, so reset floppy

read__first_sector:
   mov ax,0x1000; sets the sector we want to read to
   mov es,ax
   xor bx, bx ;reads into es:bx => xor bx,bx => bx = 0
   mov ah, 0x02 ;read instruction
   mov al, 1 ; reads 1 sector (could be more)
   mov ch, 0; still on first cylinder
   mov cl, 1; sector number
   mov dh, 0 ;head number
   mov dl, 0; first floppy
   int 0x13

check_sum:
   mov ax, 0x1000
   mov ds,ax
   xor bx,bx
   xor ax,ax
   mov cx,512
   check_sum_loop:
      mov byte dl,[bx]
      add al,dl
      inc bx
      dec cx
      cmp cx,0
   jne check_sum_loop

cli
print_val:
   mov bl, 0x10
   div bl
   mov bx, ax
   xor ax, ax
   mov ax, 0xB800
   mov es,ax

   xor ax,ax
   mov al, bl
   add ax,0xF100 + '0'
   mov word [es:0],ax 
   
   xor ax,ax
   mov al, bh
   add ax,0xF100 + '0'
   mov word [es:2],ax 
;   mov dx,0
 ;  mov al, 0xF0
;   mov byte [es:0], al
;   mov al, bl
;   add al, '0'
;   mov byte [es:1],al

hang: jmp hang
db 0x12
times 510 - ($ -$$) db 0
db 0x55
db 0xAA