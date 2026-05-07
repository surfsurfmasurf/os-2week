/* src/kernel.c - Basic C Kernel with simple keyboard echo */

#include <stdint.h>

void print_char(char c, int color, int x, int y) {
    char* video_memory = (char*)0xB8000;
    int offset = (y * 80 + x) * 2;
    video_memory[offset] = c;
    video_memory[offset + 1] = (char)color;
}

void print_string(const char* str, int color, int x, int y) {
    int i = 0;
    while (str[i] != '\0') {
        print_char(str[i], color, x + i, y);
        i++;
    }
}

void clear_screen() {
    for (int y = 0; y < 25; y++) {
        for (int x = 0; x < 80; x++) {
            print_char(' ', 0x07, x, y);
        }
    }
}

unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__ volatile("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

void outb(unsigned short port, unsigned char data) {
    __asm__ volatile("outb %0, %1" : : "a"(data), "Nd"(port));
}

unsigned char read_rtc(unsigned char reg) {
    outb(0x70, reg);
    return inb(0x71);
}

// Simple US QWERTY Scancode to ASCII table
char scancode_to_ascii[] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8',	/* 9 */
  '9', '0', '-', '=', '\b',	/* Backspace */
  '\t',			/* Tab */
  'q', 'w', 'e', 'r',	/* 19 */
  't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',	/* Enter key */
    0,			/* 29   - Control */
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',	/* 39 */
 '\'', '`',   0,		/* Left shift */
 '\\', 'z', 'x', 'c', 'v', 'b', 'n',			/* 49 */
  'm', ',', '.', '/',   0,				/* Right shift */
  '*',
    0,	/* Alt */
  ' ',	/* Space bar */
    0,	/* Caps lock */
    0,	/* 59 - F1 key ... > */
    0,   0,   0,   0,   0,   0,   0,   0,
    0,	/* < ... F10 */
    0,	/* 69 - Num lock*/
    0,	/* Scroll Lock */
    0,	/* Home key */
    0,	/* Up Arrow */
    0,	/* Page Up */
  '-',
    0,	/* Left Arrow */
    0,
    0,	/* Right Arrow */
  '+',
    0,	/* 79 - End key*/
    0,	/* Down Arrow */
    0,	/* Page Down */
    0,	/* Insert Key */
    0,	/* Delete Key */
    0,   0,   0,
    0,	/* F11 Key */
    0,	/* F12 Key */
    0,	/* All other keys are undefined */
};

char command_buffer[64];
int buffer_idx = 0;

void reset_prompt(const char* msg, int* x, int* y) {
    *y = 4;
    *x = 2;
    buffer_idx = 0;
    for(int i=0; i<64; i++) command_buffer[i] = 0;
    print_string("> ", 0x0F, 0, *y);
    // Clear the rest of the line
    for(int i=2; i<80; i++) print_char(' ', 0x07, i, *y);
}

void kernel_main() {
    clear_screen();
    const char* message = "OS-2WEEK KERNEL v0.0.9";
    print_string(message, 0x0B, 0, 0);
    print_string("Status: Command buffer active.", 0x07, 0, 1);
    print_string("Commands: (c) clear, (h) help, (v) version, (t) time, (p) peek, (x) exit, (r) reboot", 0x07, 0, 2);
    
    int cursor_x = 2;
    int cursor_y = 4;
    reset_prompt(message, &cursor_x, &cursor_y);
    
    unsigned char last_scancode = 0;

    while(1) {
        unsigned char scancode = inb(0x60);
        if (scancode != last_scancode) {
            if (!(scancode & 0x80)) { // Key press
                char c = scancode_to_ascii[scancode];
                if (c == '\n') {
                    // Simple command handler
                    cursor_y++;
                    if (command_buffer[0] == 'c' && command_buffer[1] == '\0') {
                        clear_screen();
                        print_string(message, 0x0B, 0, 0);
                        print_string("Status: Command buffer active.", 0x07, 0, 1);
                        print_string("Commands: (c) clear, (h) help, (v) version, (t) time, (p) peek, (x) exit, (r) reboot", 0x07, 0, 2);
                        cursor_y = 4;
                    } else if (command_buffer[0] == 'h' && command_buffer[1] == '\0') {
                        print_string("HELP: c=clear, h=help, v=version, t=time, p=peek, x=exit, r=reboot.", 0x0E, 0, cursor_y++);
                    } else if (command_buffer[0] == 'v' && command_buffer[1] == '\0') {
                        print_string(message, 0x0B, 0, cursor_y++);
                    } else if (command_buffer[0] == 'r' && command_buffer[1] == '\0') {
                        print_string("REBOOT: Sending 0xFE to port 0x64...", 0x0E, 0, cursor_y++);
                        outb(0x64, 0xFE);
                    } else if (command_buffer[0] == 't' && command_buffer[1] == '\0') {
                        unsigned char sec = read_rtc(0x00);
                        unsigned char min = read_rtc(0x02);
                        unsigned char hour = read_rtc(0x04);
                        
                        // BCD to binary conversion
                        sec = (sec & 0x0F) + ((sec / 16) * 10);
                        min = (min & 0x0F) + ((min / 16) * 10);
                        hour = (hour & 0x0F) + ((hour / 16) * 10);

                        char time_str[10];
                        time_str[0] = (hour / 10) + '0';
                        time_str[1] = (hour % 10) + '0';
                        time_str[2] = ':';
                        time_str[3] = (min / 10) + '0';
                        time_str[4] = (min % 10) + '0';
                        time_str[5] = ':';
                        time_str[6] = (sec / 10) + '0';
                        time_str[7] = (sec % 10) + '0';
                        time_str[8] = '\0';

                        print_string("TIME (UTC): ", 0x0D, 0, cursor_y);
                        print_string(time_str, 0x0D, 12, cursor_y++);
                    } else if (command_buffer[0] == 'x' && command_buffer[1] == '\0') {
                        print_string("EXIT: Halting CPU. Goodbye.", 0x0C, 0, cursor_y++);
                        __asm__ volatile("hlt");
                    } else if (command_buffer[0] == 'p' && command_buffer[1] == '\0') {
                        unsigned char* kernel_start = (unsigned char*)0x1000;
                        print_string("PEEK: First 4 bytes of 0x1000 (kernel load address):", 0x0D, 0, cursor_y++);
                        for(int i=0; i<4; i++) {
                            char hex[3];
                            unsigned char byte = kernel_start[i];
                            const char* hex_chars = "0123456789ABCDEF";
                            hex[0] = hex_chars[(byte >> 4) & 0x0F];
                            hex[1] = hex_chars[byte & 0x0F];
                            hex[2] = '\0';
                            print_string(hex, 0x0F, i*3, cursor_y);
                        }
                        cursor_y++;
                    } else if (buffer_idx > 0) {
                        print_string("Unknown command.", 0x0C, 0, cursor_y++);
                    }
                    
                    if (cursor_y >= 24) {
                        clear_screen();
                        cursor_y = 4;
                    }
                    reset_prompt(message, &cursor_x, &cursor_y);
                } else if (c == '\b') {
                    if (buffer_idx > 0) {
                        buffer_idx--;
                        command_buffer[buffer_idx] = 0;
                        cursor_x--;
                        print_char(' ', 0x07, cursor_x, cursor_y);
                    }
                } else if (c > 0 && buffer_idx < 63) {
                    command_buffer[buffer_idx++] = c;
                    command_buffer[buffer_idx] = '\0';
                    print_char(c, 0x0A, cursor_x++, cursor_y);
                }
            }
            last_scancode = scancode;
        }
    }
}


