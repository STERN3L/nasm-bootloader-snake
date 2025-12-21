PROJECT = boot

SRC_DIR = src
BUILD_DIR = build

ASM = nasm
ASMFLAGS = -f bin

BOOT_SRC = $(SRC_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/boot.bin
BOOT_IMG = $(BUILD_DIR)/boot.img

all: $(BOOT_IMG)

$(BOOT_BIN): $(BOOT_SRC)
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $(BOOT_BIN) $(BOOT_SRC)

$(BOOT_IMG): $(BOOT_BIN)
	mv $(BOOT_BIN) $(BOOT_IMG)

run: $(BOOT_IMG)
	qemu-system-i386 -drive format=raw,file=$(BOOT_IMG)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean run
