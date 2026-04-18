/* src/kernel.c - Basic C Kernel for Day 13 transition */

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

void kernel_main() {
    const char* message = "Welcome to C Kernel (Ring 0)";
    print_string(message, 0x0A, 10, 10);
    
    while(1) {
        // Halt or busy loop for now
    }
}
