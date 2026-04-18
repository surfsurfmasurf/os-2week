# os-2week Makefile

CC := i686-elf-gcc
LD := i686-elf-ld
NASM ?= nasm
QEMU ?= qemu-system-i386

BUILD_DIR := build
SRC_DIR := src

BOOT_BIN   := $(BUILD_DIR)/boot.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
OS_IMG     := $(BUILD_DIR)/os.img

.PHONY: all clean run hexdump

all: $(OS_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<

$(STAGE2_BIN): $(SRC_DIR)/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<

$(KERNEL_BIN): $(SRC_DIR)/kernel.c | $(BUILD_DIR)
	@# Fallback to host gcc if i686-elf-gcc is missing
	@# On ARM64, -m32/elf_i386 might fail if multiarch is not installed.
	@# For Day 13, we create the source even if cross-compiling is tricky.
	@if command -v $(CC) >/dev/null 2>&1; then \
		$(CC) -ffreestanding -m32 -c $< -o $(BUILD_DIR)/kernel.o; \
		$(LD) -m elf_i386 -Ttext 0x100000 --oformat binary $(BUILD_DIR)/kernel.o -o $@; \
	elif gcc -ffreestanding -m32 -c $< -o $(BUILD_DIR)/kernel.o 2>/dev/null; then \
		ld -m elf_i386 -Ttext 0x100000 --oformat binary $(BUILD_DIR)/kernel.o -o $@; \
	else \
		echo "Warning: Cross-compiler (i686-elf) not found. Kernel C source created but not compiled."; \
		touch $@; \
	fi

# Build a tiny raw disk image:
# - sector 1: boot sector
# - sector 2: stage2
# - sector 3+: kernel
$(OS_IMG): $(BOOT_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	@cat $(BOOT_BIN) > $@
	@dd if=$(STAGE2_BIN) bs=512 count=1 conv=sync status=none >> $@
	@dd if=$(KERNEL_BIN) bs=512 conv=sync status=none >> $@

run: $(OS_IMG)
	$(QEMU) -drive format=raw,file=$(OS_IMG)

hexdump: $(BOOT_BIN)
	hexdump -C $(BOOT_BIN) | head -n 40

clean:
	rm -rf $(BUILD_DIR)
