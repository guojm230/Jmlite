# 1.Write Master Boot Record
## Fundamental knowledges
When the computer starts up, it will enumerate all useable storage device to find a bootable device whose first partition end with 0x55aa.</br>
The device can be disk or floppy.

## Determine type and index of device we are using
In general,we install our boot iso on not only disk but also floppy.

## Problems about assembly

1. ### In 16bit mode,[bx|bp] and [si|di] can be used as index register when reference a memory address; 
    ``` assembly
        mov word ax,[ax+4]    ;error: invalid effective address
        mov word ax,[es:ax]   ;error: invalid effective address
        mov word ax,[bx+4]    ;right
        mov word ax,[es:bx]   ;right
        mov dword eax,[eax+4] ;right
    ```
