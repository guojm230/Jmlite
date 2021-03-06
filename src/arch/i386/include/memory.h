#ifndef I386_MEMORY_H
#define I386_MEMORY_H
#include <g_type.h>
#include "../include/boot.h"

typedef struct MemoryBlock
{
    u32 address;
    u32 size;
    bool free;
    struct MemoryBlock* prev;
    struct MemoryBlock* next;
} MemoryBlock;


//a simple memory mamager whose target is not efficient but only useable
//kernel will use the manager until another global memory manager is built
typedef struct{
    u32 heap_start;
    u32 heap_end;
    u32 block_size;
    MemoryBlock root_block;
    void* (*allocat)();
} SimpleMemoryManager;

void initSimpleMemoryManager(BootInfo* boot_info);

void* simpleAllocate(u32 allocate_size);



//void detectMemory(addr memoryInfo);
#endif