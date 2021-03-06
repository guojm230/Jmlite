#include <g_type.h>
#include "../include/boot.h"
#include "../include/memory.h"
#include "../include/stdio.h"

char *s = null;

void test(){
    putChar(*s);
}

int _start(BootInfo* boot_info){
    clearScreen();
    setCusor(0);
    initBoot(boot_info);
    s =(char*) simpleAllocate(1);
    *s = 'e';
    test();
    return 0;
}