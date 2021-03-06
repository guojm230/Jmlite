#include "../include/stdio.h"
#include <g_constant.h>
#include "../include/io.h"

u16 text_cusor = 0;
const addr TEXT_ADDR = (addr)0xC00b8000;

const u16 CRT_INDEX_PORT = 0x03d4;
const u8 CUSOR_HIGH_OFFSET = 0x0e;
const u8 CUSOR_LOW_OFFSET = 0x0f;
const u16 CRT_DATA_PORT = 0x03d5;

const char BASE_C[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

/**
 * @brief 
 * 
 * @param c 
 * @param color
 * @param add_cusor whether push cusor
 */
void internalPutChar(char c,u8 color,bool add_cusor){
    u16 cusor = getCusor();
    addr current_addr = TEXT_ADDR + cusor*2;
    // new line
    if(c == '\n'){
        cusor = cusor/25*25+25;
        setCusor(cusor);
        return;
    }

    *current_addr = c;
    *(current_addr+1) = color;
    if(add_cusor){
        setCusor(cusor+1);
    }
}

void putCharWithStyle(char c,u8 color){
    internalPutChar(c,color,true);
}

void putChar(char c){
    internalPutChar(c,0x07,true);
}

void doPutNumber(u32 number,u32 base){
    if(base > 16){
        putString("不支持16以上的进制");
    }
    if(number != 0){
        doPutNumber(number/base,base);
        putChar(BASE_C[number%base]);
    }
}

void putNumberWithBase(u32 number,u32 base){
    switch(base){
        case 8:
            putString("0");
            break;
        case 2:
            putString("0b");
            break;
        default:
            putString("0x");
            break;
    }
    doPutNumber(number,base);
}

void putNumber(int number){
    if(number < 0){
        putChar('-');
    }
    putNumberWithBase(number,10);
}

void putString(char* str){
    while(*str != '\0'){
        putChar(*str);
        str++;
    }
}


u16 getCusor(){
    writePort(CRT_INDEX_PORT,CUSOR_LOW_OFFSET);
    u16 cusor = readPort(CRT_DATA_PORT);
    writePort(CRT_INDEX_PORT,CUSOR_HIGH_OFFSET);
    cusor = (readPort(CRT_DATA_PORT) << 8) | cusor;
    return cusor;
}

void setCusor(u16 poi){
    //low 8 bits
    u8 value = (u8)(poi & 0x00ff);
    writePort(CRT_INDEX_PORT,CUSOR_LOW_OFFSET);
    writePort(CRT_DATA_PORT,value);
    //high 8 bits
    value = (u8)(poi>>8);
    writePort(CRT_INDEX_PORT,CUSOR_HIGH_OFFSET);
    writePort(CRT_DATA_PORT,value);
}

void clearScreen(){
    int limit = 80*25*2;
    for(int i = 0;i < limit;i++){
        *(TEXT_ADDR+i) = 0;
    }
}