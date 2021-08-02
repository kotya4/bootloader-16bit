BUILD_DIR=build
BOOTLOADER=boot

all:
	nasm -f bin $(BOOTLOADER).asm -o $(BUILD_DIR)/$(BOOTLOADER)
	dd if=/dev/zero of=$(BUILD_DIR)/disk.img bs=512 count=2880
	dd conv=notrunc if=$(BUILD_DIR)/$(BOOTLOADER) of=$(BUILD_DIR)/disk.img bs=512 count=1 seek=0

clean:
	rm $(BUILD_DIR)/*
