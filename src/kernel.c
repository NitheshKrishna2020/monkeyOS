#include "kernel.h"
#include <stdint.h>

// init the video memory pointer
uint16_t* video_mem = 0;

uint16_t terminal_make_char(char c, char color) {
    return (color << 8 | c);
}


void terminal_initialize() {
    // pointer memory pointer to start of video memory
    video_mem = (uint16_t*)(0xB8000);

    // clear all orginal text
    for(int y = 0; y < VGA_HEIGHT; y++) {
        for(int x = 0; x < VGA_WIDTH; x++) {
            video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(' ', 0);
        }
    }   
}



void kernel_main() {
    terminal_initialize();

    video_mem[0] = 0x0241;
}