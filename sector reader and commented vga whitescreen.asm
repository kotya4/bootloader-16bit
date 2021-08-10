; bootloader

bits  16            ; still in 16 bit Real Mode
org   0x7c00        ; boot loaded by BIOS at 0x7C00

; mov ax,012h ;VGA mode
; int 10h ;640 x 480 16 colors.
; mov ax,0A000h
; mov es,ax ;ES points to the video memory.
; mov dx,03C4h ;dx = indexregister
; mov ax,0F02h ;INDEX = MASK MAP,
; out dx,ax ;write all the bitplanes.
; mov di,0 ;DI pointer in the video memory.
; mov cx,38400 ;(640 * 480)/8 = 38400
; mov ax,0FFh ;write to every pixel.
; rep stosb ;fill the screen



xor ah, ah ; reset disk system
int 13h

mov ah, 02h ; read sectors into memory
mov al, 01h ; number of sectors to read
mov ch, 00h ; tracks? cylinder number?
mov cl, 02h ; sector number (from 1-63)
mov dh, 00h ; head number?
; mov dl, 00h ; drive number ( setted by bios at boot )
mov bx, 00h
mov es, bx
mov bx, 7e00h ; es:bx where to load
int 13h
jc sectorloaderr
; jmp 7e00h ; 7c00h + 512 = 7c00h + 200h = 7e00h

mov si, stringok
call begprint

mov si, stringok2
call begprint

cli
hlt

sectorloaderr :
mov si, stringwtf
call begprint
cli
hlt

begprint :
  mov ah, 0eh ; teletype output
  mov bx, 0 ; page at 0
  print :
    mov al, [si]
    or al, al ; is character null
    jz endprint
    int 10h ; teletype output
    inc si
    jmp print
endprint :
ret

stringwtf db 'wtf', 10, 13, 0
stringok db 'ok', 10, 13, 0

times 510 - ( $ - $$ ) db 0 ; boot have to be 512 bytes
dw 0xAA55                   ; boot signiture

mov ah, 0eh ; teletype output
mov bx, 0 ; page at 0
mov al, '!'
int 10h ; teletype output
cli
hlt

stringok2 dw 'ok2', 0
