#include "../include/boot.h"
#include "../include/memory.h"

void initBoot(BootInfo* boot_info){
    initSimpleMemoryManager(boot_info);
}