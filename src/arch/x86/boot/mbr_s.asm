;mbr which is responsible for loading bootloader from disk or floppy
BOOT_LOADER_SEC equ  1 ;boot_loader sector index,count from 0
BOOT_LOADER_SEG equ 0x1000  ; segment of address that boot_loader will be loaded into
BOOT_LOADER_OFFSET equ 0x00 ; offset of address that boot_loader will be loaded into
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
    call read_bootloader
    mov ax,0x00
    mov es,ax
    mov ax,BOOT_LOADER_SEG
    mov ds,ax
    jmp far [es:boot_loader_entry]

read_bootloader:
    push bp
    mov bp,sp
    push bx
    call load_loader_info
    ;;;;;;;;;;;
    ;we have loaded a sector into memory after call load_loader_info; so
    ;if(size == 0 || size == 1)
    ;   return
    ;else load remainder sectors
    mov ax,boot_loader_size
    xor dx,dx
    mov cx,512
    div cx
    test ax,0
    je .ret
    sub ax,1
    test ax,0
    jz .ret
    mov cx,ax
    ;prepare parameters for reading remainder sectors
    ;do{...} while(cd>0)
.read:
    mov ax,[dap_offset]
    add ax,512
    mov [dap_offset],ax
    mov ax,dap_start_sector
    inc ax
    mov [dap_start_sector],ax
    mov ah,0x42
    mov dl,[boot_device_index]
    mov si,dap_size
    int 0x13
    loop .read
.ret:
    pop bx
    mov sp,bp
    pop bp
    ret

;get base information of bootloader
load_loader_info:
    push bp
    mov bp,sp
    
    mov byte dl,[boot_device_index]
    mov word [dap_offset],0x00
    mov word [dap_seg],BOOT_LOADER_SEG
    mov ax,BOOT_LOADER_SEC
    mov [dap_start_sector],ax
    mov ah,0x42
    mov si,dap_size
    int 0x13;
    mov ax,BOOT_LOADER_SEG
    mov es,ax
    mov word ax,[es:0]
    mov [boot_loader_size],ax
    mov word ax,[es:2]
    mov [boot_loader_entry],ax
    mov sp,bp
    pop bp
    ret

;check whether specific device support int13h extension
;parameters:
;device_index: int16
;return: int; support: 0 ; unspport:1
check_extension:
    push bp
    mov bp,sp
    push bx
    mov ah,0x41
    mov dl,[bp+4]
    mov bx,0x55AA
    int 13h
    lahf
    mov al,ah
    and ax,0x01
    pop bx
    mov sp,bp
    pop bp
    ret

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
boot_loader_size:
    dw 0

boot_loader_entry:
    dw 0
boot_loader_seg:
    dw BOOT_LOADER_SEG


;Disk Address Packet for int13h/42h
dap_size:
    db 0x10
dap_unused:
    db 0x00
dap_sector_count:
    dw 0x01
dap_offset:
    dw 0x0000
dap_seg:
    dw 0x1000
dap_start_sector:
    dd 0x00
    dd 0x00

text_cusor:
    dw 0




times 510-($-$$) db 0
dw 0xaa55

