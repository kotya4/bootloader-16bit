; bootloader
org   0x7c00        ; We are loaded by BIOS at 0x7C00

bits  16          ; We are still in 16 bit Real Mode

Start:


  mov cl, 255
  L:
    xor bx, bx
    mov ah, 0x0e
    mov al, cl
    int 0x10

    dec cl
    jnz L


  cli         ; Clear all Interrupts
  hlt         ; halt the system

times 510 - ($-$$) db 0       ; We have to be 512 bytes. Clear the rest of the bytes with 0

dw 0xAA55         ; Boot Signiture
