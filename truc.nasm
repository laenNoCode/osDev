
;=====================================
; nasmw boot.asm -f bin -o boot.bin
; partcopy boot.bin 0 200 -f0
 
[ORG 0x7c00]      ; add to offsets
xor ax,ax
mov ds,ax
mov AX,0xB800
mov es,ax
mov di, 0
mov byte [es:di+0],65
mov byte [es:di+1],65
mov byte [es:di+2],65
mov byte [es:di+3],66
hang:
   jmp hang
 
times 510-($-$$) db 0
db 0x55
db 0xAA