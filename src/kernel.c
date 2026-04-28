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

void kernel_main() {
    clear_screen();
    const char* message = "OS-2WEEK KERNEL v0.0.2";
    print_string(message, 0x0B, 0, 0);
    print_string("Status: Keyboard driver active.", 0x07, 0, 1);
    print_string("> ", 0x0F, 0, 3);
    
    int cursor_x = 2;
    unsigned char last_scancode = 0;

    while(1) {
        unsigned char scancode = inb(0x60);
        if (scancode != last_scancode) {
            if (!(scancode & 0x80)) { // Key press
                // Simple placeholder for keystroke visualization
                print_char('*', 0x0A, cursor_x++, 3);
                if (cursor_x >= 79) cursor_x = 2;
            }
            last_scancode = scancode;
        }
    }
}
