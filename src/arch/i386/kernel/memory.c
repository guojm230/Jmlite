#include "../include/memory.h"
#include "../include/stdio.h"

//memory alignment
const u32 MEMORY_ALIGNMENT = 4;

SimpleMemoryManager simple_manager;

void initSimpleMemoryManager(BootInfo* boot_info){
    //the start address should align 4
    KernelInfo* ki = &boot_info->kernel_info;
    MemoryInfo* mi = &boot_info->memory_info;
    u32 heap_start = ki->start_addr + ki->size;
    if(heap_start % 4 != 0){
        heap_start = heap_start/4*4+4;
    }
    u32 heap_end = ki->start_addr + mi->allocated_size - mi->stack_size - 1;
    simple_manager.heap_start = heap_start;
    simple_manager.heap_end = heap_end;
    //init a memory block
    simple_manager.root_block.address = heap_start;
    simple_manager.root_block.size = heap_end - heap_start;
    simple_manager.root_block.free = true;
    simple_manager.root_block.next = null;
    simple_manager.block_size++;
    putString("memory manager inint,heap_start:");
    putNumberWithBase(simple_manager.heap_start,16);
    putString("heap_end:");
    putNumberWithBase(simple_manager.heap_end,16);
    putString("first_block_size:");
    putNumberWithBase(simple_manager.root_block.size,16);
}

//first adapt
//if fail,return null
void* simpleAllocate(u32 allocate_size){
    MemoryBlock* prev_block = null;
    MemoryBlock* current_block = &simple_manager.root_block;
    const u32 addtionalSize = sizeof(MemoryBlock);
    u32 actualSize = allocate_size+addtionalSize;
    while (current_block != null)
    {
        //when allocate memory we may need to create a new MemoryBlock node within heap.
        //We need a allocator to allocate memory for initializling allocator. This is a paradox!.
        //So we will place the new memory block and the length before the entry of allocated memory
        // while allocating memory for user
        if(current_block->free && current_block->size >= actualSize){
            // the size of free block > the size that need allocate
            if(current_block->size > actualSize + addtionalSize){
                MemoryBlock* memory_block = (MemoryBlock*) current_block->address;
                memory_block->address = current_block->address;
                memory_block->size = actualSize;
                memory_block->free = false;
                memory_block->next = current_block;
                if(prev_block == null){
                    simple_manager.root_block = *memory_block;
                } else {
                    prev_block->next = memory_block;
                }
                u32 new_address = current_block->address + actualSize;
                //align 4
                if(new_address % 4 != 0){
                    new_address = new_address/4*4+4;
                    memory_block->size = new_address - memory_block->address;
                }
                current_block->address = new_address;
                current_block->size = current_block->size - (new_address - memory_block->address);
                simple_manager.block_size++;
                putString("allocate new memory,address：");
                putNumberWithBase(current_block->address+sizeof(MemoryBlock),16);
                putString(" current size of blocks:");
                putNumber(simple_manager.block_size);
                return (void*)memory_block->address + sizeof(MemoryBlock);
            } else {
                current_block->free = false;
                return (void*)current_block->address + sizeof(MemoryBlock);
            }
        }
        prev_block = current_block;
        current_block = current_block->next;
    }
    return null;
}

void free(void* pointer){
    u32 infoSize = sizeof(MemoryBlock);
    MemoryBlock* memory_block = (MemoryBlock*)((addr)pointer - infoSize);
    memory_block->free = true;
    MemoryBlock* next_block = memory_block->next;
    //merge two adjacent free block
    if(next_block != null && next_block->free && 
        (next_block->address == memory_block->address + memory_block->size)){
            memory_block->size += next_block->size;
            memory_block->next = next_block->next;
    }
}

void detectMemory(addr memoryInfo){
    
}
