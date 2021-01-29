BUILD_DIR=build

all:
	nasm -f bin bootloader.asm -o $(BUILD_DIR)/bootloader
	dd if=/dev/zero of=$(BUILD_DIR)/disk.img bs=512 count=2880
	dd conv=notrunc if=$(BUILD_DIR)/bootloader of=$(BUILD_DIR)/disk.img bs=512 count=1 seek=0

clean:
	rm $(BUILD_DIR)/*
