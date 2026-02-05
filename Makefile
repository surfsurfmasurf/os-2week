# os-2week Makefile

NASM ?= nasm
QEMU ?= qemu-system-i386

BUILD_DIR := build
SRC_DIR := src

BOOT_BIN := $(BUILD_DIR)/boot.bin

.PHONY: all clean run hexdump

all: $(BOOT_BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<

run: $(BOOT_BIN)
	$(QEMU) -drive format=raw,file=$(BOOT_BIN)

hexdump: $(BOOT_BIN)
	hexdump -C $(BOOT_BIN) | head -n 40

clean:
	rm -rf $(BUILD_DIR)
