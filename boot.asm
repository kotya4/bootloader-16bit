bits  16            ; still in 16 bit Real Mode
org   0x7c00        ; boot loaded by BIOS at 0x7C00


;; ============ SECTOR 1 ============


SECTOR1 :


; setup stack and nullify ds, es
; source: https://stackoverflow.com/a/32705076/10562922

xor ax, ax      ; We want a segment of 0 for DS for this question
mov ds, ax      ;     Set AX to appropriate segment value for your situation
mov es, ax      ; In this case we'll default to ES=DS
mov bx, 8000h   ; Stack segment can be any usable memory
cli             ; Disable interrupts to circumvent bug on early 8088 CPUs
mov ss, bx      ; This places it with the top of the stack @ 0x80000.
mov sp, ax      ; Set SP=0 so the bottom of stack will be @ 0x8FFFF
sti             ; Re-enable interrupts
cld             ; Set the direction flag to be positive direction

; load second sector
; source: http://www.ctyme.com/intr/rb-0607.htm

WHERETOLOAD equ 7c00h + 200h

mov al, 01h          ; number of sectors to read
mov ch, 00h          ; tracks? cylinder number?
mov cl, [lastsector] ; sector number (from 1-63)
mov dh, 00h          ; head number?
; mov dl, 00h        ; drive number ( setted by bios at boot )
mov bx, 0000h
mov es, bx
mov bx, WHERETOLOAD  ; es:bx where to load
mov di, 0003h        ; retry 3 times on failure
call begreadsector
jc errreadsector

; successfully read

mov ah, 0eh ; teletype output
mov bx, 0 ; page at 0
mov cx, 200h
mov si, WHERETOLOAD
.printsector :
    mov al, [si]
    inc si
    int 10h ; teletype output
    loop .printsector






readkey :
    mov ah, 00h ; read key
    int 16h

    cmp al, 3 ; ctrl+c ?
    jz nonono

    cmp ah, 48h
    jz arrowup

    cmp ah, 50h
    jz arrowdown

    cmp ah, 4bh
    jz arrowleft

    cmp ah, 4dh
    jz arrowright

    ; TODO: check if text 512 bytes long

    mov ah, 0eh  ; teletype output
    int 10h

    mov [si], al
    inc si

    jmp readkey



arrowup :
    mov ah, 03h ; dh = row, dl = col
    int 10h
    dec dh
    cmp dh, 0
    jge .nooverflow
    xor dh, dh
    .nooverflow :
    mov ah, 02h
    int 10h
    jmp readkey

arrowleft :
    mov ah, 03h ; dh = row, dl = col
    int 10h
    dec dl
    cmp dl, 0
    jge .nooverflow
    xor dl, dl
    .nooverflow :
    mov ah, 02h
    int 10h
    jmp readkey

arrowdown :
    mov ah, 03h ; dh = row, dl = col
    int 10h
    inc dh
    cmp dh, 24
    jng .nooverflow
    mov dh, 24
    .nooverflow :
    mov ah, 02h
    int 10h
    jmp readkey

arrowright :
    mov ah, 03h ; dh = row, dl = col
    int 10h
    inc dl
    cmp dl, 79
    jng .nooverflow
    mov dl, 79
    .nooverflow :
    mov ah, 02h
    int 10h
    jmp readkey


nonono :
    mov al, '>'
    mov ah, 02h
    int 10h





; mov si, strnewline
; call begteletype
; mov si, strnewline
; call begteletype

jmp halt








mov si, strok
call begteletype

; mov si, strtest
; call begteletype

; mov si, strtest
; mov [si+2], byte '@'

; mov al, 01h ; AL = number of sectors to write (must be nonzero)
; mov ch, 00h ; CH = low eight bits of cylinder number
; mov cl, 02h ; CL = sector number 1-63 (bits 0-5), high two bits of cylinder (bits 6-7, hard disk only)
; mov dh, 00h ; DH = head number
; ; mov dl, 00h ; DL = drive number (bit 7 set for hard disk)
; ; ES:BX -> data buffer
; mov bx, 0000h
; mov es, bx
; mov bx, SECTOR2 ; es:bx what to load
; mov di, 0003h ; retry 3 times
; call begwritesector
; jc errwritesector

; mov si, strok
; call begteletype

; jmp halt

; failure on read

errreadsector :
    mov si, strcannotreadsector
    call begteletype
    jmp halt

; failure on write

errwritesector :
    mov si, strcannotwritesector
    call begteletype
    jmp halt

; halt the system

halt :
    mov ax, EMPTYSPACE
    call begaxtohex
    call begteletype
    cli
    hlt


;; FUNCTIONS


begreadsector :
    xor ah, ah ; reset disk system
    int 13h
    mov ah, 02h ; read sectors into memory
    int 13h
    jnc endreadsector ; success
    dec di
    jnz begreadsector ; retry
endreadsector :
ret


begwritesector :
    xor ah, ah ; reset disk system
    int 13h
    mov ah, 03h ; write sectors from memory
    int 13h
    jnc endwritesector ; success
    dec di
    jnz begwritesector ; retry
endwritesector :
ret


begteletype :
; inp ds:si = pointer to first character
; out none
; use ax, bx, int10h
    mov ah, 0eh ; teletype output
    mov bx, 0 ; page at 0
    .teletype :
        lodsb ; Load byte at address DS:(E)SI into AL, incs si
        or al, al ; is character null
        jz endteletype
        int 10h ; teletype output
        jmp .teletype
endteletype :
ret


begaxtohex :
; inp ax = uint
; out si = pointer to first character
; use bl
    mov si, straxtohex + 4
    .axtohex :
    dec si
    mov bl, al
    and bl, 0fh
    add bl, '0'
    mov [si], bl
    shr ax, 4
    jnz .axtohex
endaxtohex :
ret
straxtohex db 3, 3, 3, 3, 0


;; DATA


strcannotreadsector db 'Cannot read sector', 10, 13, 0
strcannotwritesector db 'Cannot write sector', 10, 13, 0
strok db 'ok', 10, 13, 0
lastsector db 2
strnewline db 10, 13, 0


EMPTYSPACE equ 200h - 2 - ( $ - SECTOR1 )
times EMPTYSPACE db 0 ; boot have to fit sector
dw 0xAA55                             ; boot signiture


;; ============ SECTOR 2 ============

db 'hello, world!'

