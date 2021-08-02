; bootloader

bits  16            ; still in 16 bit Real Mode
org   0x7c00        ; boot loaded by BIOS at 0x7C00  bnvhh
mov si, hellostring
call startprint

; readcommand :

BUFFER_CAP equ 16 ; related to cl for now
xor cl, cl
mov si, bufferstring
readkey :
  ; endreadkey on buffer oveerload
  cmp cl, BUFFER_CAP
  jz endreadkey
  inc cl

  ; read key press, al = ascii key
  mov ah, 00h
  int 16h

  ; exit on enter, can be flush of current readkey
  cmp al, 13
  jz endreadkey

  ; teletype output pressed key ( except 13 )
  mov ah, 0eh
  int 10h

  ; save ascii key to buffer ( except 13 )
  mov [si], al
  inc si
jmp readkey
endreadkey :

; echo bufferstring
; mov si, endlinestring
; call startprint
; mov si, bufferstring
; call startprint

xor cx, cx
xor dx, dx
mov si, commandsstring
mov di, bufferstring
call startfind
test cx, cx
jz print_zero
  mov si, isnotzerostring
  call startprint
  jmp okay
print_zero :
  mov si, iszerostring
  call startprint
  jmp okay

okay :

; mov si, bufferstring
; mov al, [si]
; cmp al, '!'
; jz exit
; inc si
; inc di
; jmp readcommand



exit :
mov si, endlinestring
call startprint
mov si, goodbyestring
call startprint

cli         ; Clear all Interrupts
hlt         ; halt the system

startprint :
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

startfind :
  ; cx must be zero, the processed length
  ; dx must be zero, the sameness value
  ; si is pointer to sequence ( where to search string )
  ; di is pointer to string ( what to search )
  mov bx, di
  mov al, [si] ; sequence char
  mov ah, [di] ; string char
  inc si
  inc di
  ; out of sequence \0
  cmp al, 0
  jz end_of_comparition
  ; out of string \0
  cmp ah, 0
  jz end_of_comparition
  ; end of sequence 20h
  cmp al, 20h
  jz end_of_comparition
  ; inc the processed length
  inc cx
  ; sameness of values
  cmp al, ah
  jnz find_next
  inc dx ; inc the sameness value
  jmp startfind

  find_next :
    mov di, bx ; reset string pointer
    mov dx, 0 ; the sameness value now initial
    mov cx, 0 ; the processed length now initial
    jmp startfind

  end_of_comparition :
    cmp dx, cx
    jnz not_same
    test dx, dx
    jz not_same
    ; values are same (where?)
    mov cx, 1
    jmp endfind

    not_same :
      ; values are not the same
      mov cx, 0
      test ah, ah
      jz endfind ; end of string, exit
      test al, al
      jz endfind ; end of sequence, exit
      jmp find_next ; pointers not reach the end, find next
endfind :
ret





hellostring db 3, ' axinya boots helloing you ', 3, 10, 13, 0
goodbyestring db 3, ' axinya boots goodbying you ', 3, 10, 13, 0
endlinestring db 10, 13, 0
commandsstring db '! hello', 0
iszerostring db ' is zero', 0
isnotzerostring db ' is not zero', 0

bufferstring times BUFFER_CAP db 0

times 510 - ( $ - $$ ) db 0 ; boot have to be 512 bytes
dw 0xAA55                   ; boot signiture
