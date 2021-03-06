global readPort
global writePort
global writePort16

;parameters:
;port: int16
readPort:
    push ebp
    mov ebp,esp
    xor eax,eax
    mov edx,[ebp+8]
    in ax,dx
    mov esp,ebp
    pop ebp
    ret

;paramters:
;port: int16
;value: int8
writePort:
    push ebp
    mov ebp,esp
    mov edx,[ebp+8]
    mov eax,[ebp+12]
    out dx,al
    mov esp,ebp
    pop ebp
    ret

;paramters:
;port: int16
;value: int8
writePort16:
    push ebp
    mov ebp,esp
    mov edx,[ebp+8]
    mov eax,[ebp+12]
    out dx,ax
    mov esp,ebp
    pop ebp
    ret