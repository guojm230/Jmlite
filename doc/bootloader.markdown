# Write Master Boot Record
## Fundamental knowledges
When the computer starts up, it will enumerate all useable storage devices to find a bootable device. This process is executed by hardware through checking whether the first sector of each storage device is MBR(Master Boot Record). MBR is the first sector of storage device containg bootstrap codes. It consist of 446 executable codes,partiontables and last 2 bytes containing a magic number 0xAA55(little-endian). Then hardware will load MBR above process found into a special memory address(0x7c00) to execute it</br>

Because Hardware only load MBR(512 bytes) into memory, we must leverage MBR to load more code for resolving the size limition.

So our overall tasks are very clear:
1. Write a MBR to load bootloader
2. Write a bootloader to load kernel

This method is usually called chain-loading.

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

