/* src/kernel.c - Basic C Kernel with simple keyboard echo */

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

void kernel_main() {
    clear_screen();
    const char* message = "OS-2WEEK KERNEL v0.0.3";
    print_string(message, 0x0B, 0, 0);
    print_string("Status: Keyboard ASCII mapping active.", 0x07, 0, 1);
    print_string("> ", 0x0F, 0, 3);
    
    int cursor_x = 2;
    unsigned char last_scancode = 0;

    while(1) {
        unsigned char scancode = inb(0x60);
        if (scancode != last_scancode) {
            if (!(scancode & 0x80)) { // Key press
                char c = scancode_to_ascii[scancode];
                if (c > 0) {
                    print_char(c, 0x0A, cursor_x++, 3);
                    if (cursor_x >= 79) cursor_x = 2;
                }
            }
            last_scancode = scancode;
        }
    }
}
