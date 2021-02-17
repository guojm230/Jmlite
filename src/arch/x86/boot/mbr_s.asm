;mbr which is responsible for loading bootloader from disk or floppy
BOOT_LOADER_SEC equ 1   ;boot_loader sector index,count from zero
BOOT_LOADER_MEMORY_ADDR equ 0xc0000;the address boot_loader will be loaded
TEXT_SEG equ 0xb800

section mbr vstart=0x7c00
    ;store boot_device_index into memory
    mov byte [boot_device_index],dl
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    xor di,di
    xor si,si
    mov ds,ax
    mov es,ax
    ;init_stack, from 0x7c00 down
    mov ax,0x00
    mov ss,ax
    mov ax,0x7c00
    mov bp,ax
    mov sp,ax
    ;;;;;;;;;;
    ; push message
    ;call put_text
    mov ax,5
    push ax
    mov ax,message
    push ax
    call put_text
    hlt

read_bootloader:
    ;detect device type
    mov ax,bx
    ret

;read data from floppy
read_floppy:


;put text to screen
;parameters:
;text: addr16; address of text; the address must less than 2^16 - 1
;length: int16; the length of text
put_text:
    push bp
    mov bp,sp
    push bx
    mov cx,[bp+6]
    mov bx,[bp+4]
.put:
    ;store cx,dx before invoke funcion
    push cx
    push dx
    mov byte al,[bx]
    mov ah,0x07
    push ax
    call put_char
    pop dx  ;this instruction does nothing but to clear parameter-stack 
    pop dx
    pop cx
    inc bx
    loop .put
    pop bx
    mov sp,bp
    pop bp
    ret


;put a char to screen
;can be used in printing some debug infos
;parameters:
; data: byte16 ; high:color low:ascii
put_char:
    push bp
    mov bp,sp
    push bx
    mov word ax,[text_cusor]
    mov cl,2
    mul cl
    mov bx,ax
    mov ax,TEXT_SEG
    mov es,ax
    mov ax,[bp+4]
    mov word [es:bx],ax
    mov word ax,[text_cusor]
    inc ax
    mov word [text_cusor],ax
    pop bx
    mov sp,bp
    pop bp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boot_device_index:
    db 0
text_cusor:
    dw 0
message:
    db 'hello'



times 510-($-$$) db 0
dw 0xaa55

