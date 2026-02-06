# os-2week Makefile

NASM ?= nasm
QEMU ?= qemu-system-i386

BUILD_DIR := build
SRC_DIR := src

BOOT_BIN   := $(BUILD_DIR)/boot.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
OS_IMG     := $(BUILD_DIR)/os.img

.PHONY: all clean run hexdump

all: $(OS_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<

$(STAGE2_BIN): $(SRC_DIR)/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<

# Build a tiny raw disk image:
# - sector 1: boot sector
# - sector 2: stage2 (padded/truncated to 512 bytes)
$(OS_IMG): $(BOOT_BIN) $(STAGE2_BIN) | $(BUILD_DIR)
	@cat $(BOOT_BIN) > $@
	@dd if=$(STAGE2_BIN) bs=512 count=1 conv=sync status=none >> $@

run: $(OS_IMG)
	$(QEMU) -drive format=raw,file=$(OS_IMG)

hexdump: $(BOOT_BIN)
	hexdump -C $(BOOT_BIN) | head -n 40

clean:
	rm -rf $(BUILD_DIR)
