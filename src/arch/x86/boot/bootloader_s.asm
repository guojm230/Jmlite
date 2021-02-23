;bootloader will switch real mode to protected mode and enter 32 bits mode
;besides, we will write a elf-loader to load other modules that wrote by C or CPP
section bootloader
;;;;;;;;;;;;;;;;;;;;;
; header
;;;;;;;;;;;;;;;;;;;;;
_size: dw end
_entry: dw loader_entry

;;;;;;;;;;;;;;;;
;DATA AREA
;;;;;;;;;;;;;;;;
text_cusor:
    dw 0

;;;;;;;;;;;;;;;;
;DATA END
;;;;;;;;;;;;;;;;
loader_entry:
    mov ax,0xb800
    mov es,ax
    mov al,0x34
    mov ah,0x07
    mov word [es:0],ax
    hlt
;;;;;;;;;;;;;;;;
;FUNCTIONS
;;;;;;;;;;;;;;;;
;填充至整数个扇区
tail:
    times 512 - ($-$$-512*(($-$$)/512)) db 0
end:
