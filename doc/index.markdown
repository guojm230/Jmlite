# A lite operating system build by C++

The goal of writing a operating system by myself is to deepen understanding of operating system,computer net,computer organization and data structure.

## Structures
A simple operating system consist of the following components:

1. ### Bootloader: <br/> In order to straight start writing kernel,we will use grub bootloader in the begining. We can also make own bootloader later. But to do this require we must write a adapter to receive different boot params from grub or my bootloader.
2. ### Kernel: <br/>The core of a operating system,including process manager,memory manager,I/O manager and so on.
3. ### Other Components: <br/> Such as net protocol and compiler.

## Tools and languages

- ### Assembly compiler: nasm
- ### Assambly dialect: nasm
- ### Kernel launage: cpp
- ### Cpp compile tool: clang
- ### build tool: makefile
- ### compile environment: ubuntu 20.04


## Build kernel throuth grub
### 1. grub fundamentals
- #### grub layout header
    The layout header of grub is a sepecial data block which contains  some necessary informations about kernel.It must be placed within the first 32768 bytes of the OS image and must be 64-bit aligned. </br>

    So we first need to write a asm files which contain grub layout header and link it into the final OS image.
- #### grub tools
    Grub has many useful tools.


