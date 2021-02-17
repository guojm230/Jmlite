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
- ### build tool: make
- ### compile environment: ubuntu 20.04


## Introduction
Before start off writing code,we first need to understand the process of booting a operating system on x86 platform.
### 1. Load mbr(Master Boot Record) from disk or floppy into a special address(0x7c00) of memory. This task will be executed by hardware;
### 2. Mbr load bootloader
### 3. Bootloader load kernel
### 4. Kernel init fundamental function including process manager, memory manager, file system manager and so on. After that kernel can also load other modules,such as network manager.

## Contents

### 1. [Writing mbr code]





