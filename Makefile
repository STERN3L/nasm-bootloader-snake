SRC_DIR   = src
BUILD_DIR = build

ASM      = nasm
ASMFLAGS = -f bin
QEMU     = qemu-system-i386

BOOT_SRC = $(SRC_DIR)/boot.asm
BOOT_IMG = $(BUILD_DIR)/boot.img

all: $(BOOT_IMG)

$(BOOT_IMG): $(BOOT_SRC)
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

run: $(BOOT_IMG)
	$(QEMU) -drive format=raw,file=$(BOOT_IMG)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
