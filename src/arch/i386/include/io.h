#ifndef I386_IO_H
#define I386_IO_H
#include <g_type.h>

u16 readPort(u16 port);

void writePort(u16 port,u8 value);

void writePort16(u16 port,u16 value);

#endif