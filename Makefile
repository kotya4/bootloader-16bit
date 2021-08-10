BUILD_DIR=build
BOOTLOADER=boot
SIZE=1024

all:
	nasm -f bin $(BOOTLOADER).asm -o $(BUILD_DIR)/$(BOOTLOADER)
# 	SIZE=$(wc $(BUILD_DIR)/$(BOOTLOADER) -c | cut -d " " -f)
	dd if=/dev/zero of=$(BUILD_DIR)/disk.img bs=512 count=2880
	dd conv=notrunc if=$(BUILD_DIR)/$(BOOTLOADER) of=$(BUILD_DIR)/disk.img bs=$(SIZE) count=1 seek=0

clean:
	rm $(BUILD_DIR)/*
