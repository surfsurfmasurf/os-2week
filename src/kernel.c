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

unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__ volatile("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}

void kernel_main() {
    const char* message = "Welcome to C Kernel (Ring 0)";
    print_string(message, 0x0F, 0, 0);
    print_string("Keyboard Echo (Scancodes): ", 0x07, 0, 1);
    
    int cursor_x = 27;
    unsigned char last_scancode = 0;

    while(1) {
        unsigned char scancode = inb(0x60);
        if (scancode != last_scancode) {
            if (!(scancode & 0x80)) { // Key press
                // Print hex-ish scancode (just 0-9 for simple test)
                print_char((scancode % 10) + '0', 0x0A, cursor_x++, 1);
                if (cursor_x >= 80) cursor_x = 0;
            }
            last_scancode = scancode;
        }
    }
}
