# 1.Write Master Boot Record
## Fundamental knowledges
When the computer starts up, it will enumerate all useable storage device to find a bootable device whose first partition end with 0x55aa.</br>
The device can be disk or floppy.

## Determine type and index of device we are using
In general,we install our boot iso on not only disk but also floppy.

## Outline
We first need to load bootloader into memory within 1MB. Consider the memory layout when run mbr: </br>
Our mbr code be loaed into 0x7c00 and stack expand downward from 0x7c00

## Problems about assembly

1. ### In 8086(16bit real mode),base registers and index registers are limited
- Base registers: BX BP<br/>
- Index registers: SI DI <br/>
- Register indirect mode – In this addressing mode the effective address is in SI, DI or BX.
- Based indexed mode – In this the effective address is sum of base register and index register. such as ``` MOV AL, [BP+SI]; MOV AX, [BX+DI] ```
- Based indexed displacement mode – In this type of addressing mode the effective address is the sum of index register, base register and displacement. such as ``` MOV AL,[SI+BP+2000]  ```

2. ### 8086 can address 2^20(1MB). But system can only use low 640kb memory. High memory use by bios, graphic  and so on.

