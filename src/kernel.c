#include "kernel.h"
#include <stdint.h>
#include <stddef.h>

// init the video memory pointer
uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;



// terminal make a char (16 bits)
uint16_t terminal_make_char(char c, char color) {
    return (color << 8 | c);
}

// put a char on screen
void terminal_putchar(int x, int y, char c, char color) {
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
}

// write a char to screen, and adjust current position
void terminal_writechar(char c, char color) {
    if(c == '\n') {
        terminal_col = 0;
        terminal_row += 1;
        return;
    }
    terminal_putchar(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if(terminal_col >= VGA_WIDTH) {
        terminal_col = 0;
        terminal_row += 1;
    }
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


// calculate the len of a string
size_t strlen(const char* str) {
    size_t len = 0;
    while(str[len]) {
        len++;
    }
    return len;
}

void print(const char* str) {
    int color = 1;
    size_t len = strlen(str);
    for(int j = 0; j < 10000; j++) {
        for(int i = 0; i < len; i++) {
            terminal_writechar(str[i], color);
            color+=1;
            if(color == 15) {
                color = 1;
            }
        }
    }

}


void kernel_main() {
    terminal_initialize();
    print("Hello Kernel       ");
}