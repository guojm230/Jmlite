#ifndef I386_BOOT_H
#define I386_BOOT_H
#include <g_constant.h>
#include <g_type.h>

/**
 * including some infos about kernel,
 * such as entri point,kernel size,drive address and so on.
 */
typedef struct{
    u32 size;
    u32 entry;  
    u32 start_addr;
} KernelInfo;


typedef struct{
    //entry address of memory info detected
    u32 memoryInfo;
    u32 page_table_entry;
    u32 page_directory_entry;
    //the memory already allocated for kernel
    u32 allocated_size;
    u32 stack_size;
} MemoryInfo;

/**
 * @brief  necessary startup infos passed by bootloader
 */
typedef struct{
    KernelInfo kernel_info;
    MemoryInfo memory_info;
} BootInfo;

void initBoot(BootInfo* boot_info);

#endif