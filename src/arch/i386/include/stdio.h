#ifndef I386_STDIO_H
#define I386_STDIO_H
#include <g_type.h>

//put a char to screen
void putChar(char c);

void putNumberWithBase(u32 number,u32 base);

void putNumber(int number);

u16 getCusor();

void setCusor(u16 poi);

void putString(char* str);

void clearScreen();

// //put char sequence to screen
// void putText(char* c);

// //get the current position of cusor
// int getCusor();

#endif