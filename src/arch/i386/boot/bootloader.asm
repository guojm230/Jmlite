;bootloader will switch real mode to protected mode and enter 32 bits mode
;besides, we will write a elf-loader to load other modules that wrote by C or CPP

KERNEL_LOAD_ADDR equ 0xC0100000
MEMORY_TABLE_ADDR equ 0x00020000
PAGE_DIRERTORY_ADDR equ 0x0030000

MEMORY_TABLE_VADDR
PAGE_TABLE_VADDR equ 0xFFC00000
PAGE_DIRERTORY_VADDR equ 0x0030000

KERNEL_VADDR equ 0xC0000000
;3M kernel memory
KERNEL_ALLOCATE_MEMORY equ 0x00300000
;1M stack size
KERNEL_STACK_SIZE equ 0x00080000


section bootloader vstart=0x10000
;;;;;;;;;;;;;;;;;;;;;
; header
;;;;;;;;;;;;;;;;;;;;;
_size: dw end - $$
_entry: dw loader_entry - $$
        dw 0x1000

;;;;;;;;;;;;;;;;
;DATA AREA
;;;;;;;;;;;;;;;;
boot_device_index:
    db 0
text_cusor:
    dw 0


;flat-page memory model    
gdt_info:
    dw 23
    dw gdt_empty_seg   
    dw 0x0000 ;set at runtime
;G:1 D/B:1
gdt_empty_seg:
    dd 0x00000000
    dd 0x00000000
gdt_code_descriptor:
    dd 0x0000FFFF
    dd 0x00CF9800
gdt_data_descriptor:
    dd 0x0000FFFF
    dd 0x00CF9200

boot_info:
kernel_size: dd 0x00
kernel_entry: dd 0x00
kernel_start_addr: dd KERNEL_LOAD_ADDR

;the address of memory infos detected by e820h
memory_info_entry: dd MEMORY_TABLE_VADDR
;the virtual address of accessing page table
page_table_entry: dd PAGE_TABLE_VADDR
;the virtual address of page directory
page_directory_entry: dd PAGE_DIRERTORY_VADDR

allcaed_size dd KERNEL_ALLOCATE_MEMORY
stack_size dd KERNEL_STACK_SIZE


;;;;;;;;;;;;;;;;
;DATA END
;;;;;;;;;;;;;;;;
loader_entry:
    mov byte [boot_device_index],dl
    mov ax,0x2000
    mov es,ax
    mov di,0x00
    call detect_momory

    ;prepare for entering protected mode
    mov ax,cs
    shr ax,12
    mov [gdt_info + 4],ax
    lgdt [gdt_info]

    ;open a20 address line
    in al,0x92
    or al,0x02
    out 0x92,al

    cli ;disable interruption
    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp dword 0x0008:p_entry
;use e820 to detect memory capacity
;note: 
;   this method must run in real mode
;   this method only detect and store the struct list of memory info. 
;   Calculating task will be executed by kernel
detect_momory:
    push ebp
    mov ebp,esp
    push ebx
    push edi

    xor eax,eax
    mov eax,0xe820
    xor ebx,ebx
    mov edx,0x534D4150
    mov ecx,24
.detect:
    int 0x15
.if_d:
    cmp ebx,0
    jz .endif_d
    xor eax,eax
    mov eax,0xe820
    mov edx,0x534D4150
    mov ecx,24
    add edi,24
    loop .detect
.endif_d:
    pop edi
    pop ebx
    mov esp,ebp
    pop ebp
    ret

[bits 32]
p_entry:
    mov eax,0x00010
    mov ds,eax
    mov es,eax
    mov fs,eax
    mov gs,eax
    mov ss,eax  
    mov esp,0x7c00
    call open_paging
    call load_kernel
    mov eax,KERNEL_LOAD_ADDR
    mov dword ebx,[eax+0x18]
    mov [kernel_entry],ebx
    mov ebp,0xC03FFFFF
    mov esp,ebp
    push boot_info
    call ebx
    hlt
;open page mode
open_paging:
    push ebp
    mov ebp,esp
    push edi

    mov eax,PAGE_DIRERTORY_ADDR
    ;the address of first page table
    add eax,0x1000
    or eax,0x003
    mov [PAGE_DIRERTORY_ADDR],eax
    ;self-map
    mov eax,PAGE_DIRERTORY_ADDR
    or eax,0x003
    mov [PAGE_DIRERTORY_ADDR+0xFFC],eax
    ;map the linear address 0x00000000-0x00400000 to virtual address 0x00000000-0x00400000
    mov edi,PAGE_DIRERTORY_ADDR
    add edi,0x1000
    mov ecx,1024
    mov eax,0x00
    mov edx,0x00
.map:
    mov edx,eax
    or edx,0x003
    mov [edi],edx
    add eax,0x1000
    add edi,4
    loop .map
    ;map the linear address 0x00000000-0x00400000 to virtual address 0xC0000000-0xC0400000
    mov eax,PAGE_DIRERTORY_ADDR
    add eax,0x1000
    or eax,0x003
    mov [PAGE_DIRERTORY_ADDR+0x300*4],eax
    mov eax,PAGE_DIRERTORY_ADDR
    mov cr3,eax
    mov eax,cr0
    or eax,0x80000000
    ;set control register
    mov cr0,eax

    pop edi
    mov esp,ebp
    pop ebp
    ret

;load kernel    
load_kernel:
    push ebp
    mov ebp,esp    
    push ebx
    push esi

    xor eax,eax
    ;caculate the number of sectors that bootloader take up
    mov ax,[_size]
    xor edx,edx
    mov ecx,512
    div ecx
    ;mbr take up a sector
    inc eax
    ;store sector address
    mov ebx,eax
    push KERNEL_LOAD_ADDR
    push eax
    call read_sector
    push KERNEL_LOAD_ADDR
    call calculate_elf_size
    mov [kernel_size],eax
    mov ecx,512
    div ecx
    cmp eax,0
    jz .ret
    cmp edx,0
    jz .endif_remainder
.if_remainder:
    inc eax
.endif_remainder:
    dec eax
    jz .ret
    mov ecx,eax
    mov esi,KERNEL_LOAD_ADDR
.read_rest:
    add esi,512
    inc ebx
    ;store ecx
    push ecx
    push esi
    push ebx
    call read_sector
    add esp,8   ;clear parameter stack
    pop ecx
    loop .read_rest

.ret:
    pop esi
    pop ebx
    mov esp,ebp
    pop ebp
    ret   
    

;;;;;;;;;;;;;;;;
;HELPER FUNCTIONS
;;;;;;;;;;;;;;;;

;parameters:
;caculation method: e_shoff + ( e_shentsize * e_shnum )
;headerAddr: addr32 ; the address where elf header located in
calculate_elf_size:
    push ebp
    mov ebp,esp
    push ebx

    mov ebx,[ebp+8]
    xor eax,eax
    ;e_shentsize
    mov ax,[ebx+0x2E]
    ;e_shnum
    xor ecx,ecx
    mov cx,[ebx+0x30]
    xor edx,edx
    mul ecx
    mov dword ecx,[ebx+0x20]
    add eax,ecx

    pop ebx
    mov esp,ebp
    pop ebp
    ret

;read a sector from specific hard(current is master) drive
;parameters:
;sectorAddress: int32  LBA
;address: addr32 address where data be loaded intoto
read_sector:
    push ebp
    mov ebp,esp    
    push ebx

    ;number of sectors to read
    mov edx,0x01f2
    mov eax,0x0001
    out dx,al

    ;sector address
    mov eax,[ebp + 8]
    inc edx ;0x01f3
    ;set sector address
    out dx,al

    inc edx ;0x01f4
    shr eax,8
    out dx,al

    inc edx ;0x01f5
    shr eax,8
    out dx,al

    inc edx ;0x01f6
    shr eax,8
    ;set address mode as lba and bits 24 to 27 of the block number
    or eax,1110_0000B
    out dx,al

    inc edx ;0x01f7
    mov eax,0x20
    out dx,al
;wait for ready status of hard drive
.wait:
    in al,dx
    and al,0x88
    cmp al,0x08
    jnz .wait

    mov ecx,256
    ;prepare for reading
    mov ebx,[ebp+12]
    mov edx,0x01f0
.read:
    in ax,dx
    mov word [ebx],ax
    add ebx,2
    loop .read

    pop ebx
    mov esp,ebp
    pop ebp
    ret
;fill up integral sectors
tail:
    times 512 - ($-$$-512*(($-$$)/512)) db 0
end:
