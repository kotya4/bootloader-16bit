; bootloader

bits  16            ; still in 16 bit Real Mode
org   0x7c00        ; boot loaded by BIOS at 0x7C00  bnvhh
mov si, hellostring
call startprint

interpreter_loop :

; read

BUFFER_CAP equ 16 ; related to cl for now
xor bx, bx
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
  mov [si], byte 0
  jz endreadkey

  ; teletype output pressed key ( except 13 )
  mov ah, 0eh
  int 10h

  ; save ascii key to buffer ( except 13 )
  mov [si], al
  inc si
jmp readkey
endreadkey :

; echo

; mov si, endlinestring
; call startprint
; mov si, bufferstring
; call startprint

; find

xor bx, bx
xor cx, cx
mov si, commandsstring
mov di, bufferstring
call startfind

; interpret

cmp bx, -1
jz call_NOT_FOUND

cmp bx, 2
jz call_COMMAND_EXIT

cmp bx, 8
jz call_COMMAND_HELLO

; error
mov si, errorstring
call startprint
jmp exit

call_NOT_FOUND :
  mov si, notfoundstring
  call startprint
  mov si, endlinestring
  call startprint
  jmp interpreter_loop

call_COMMAND_HELLO :
  mov si, endlinestring
  call startprint
  mov si, hellostring
  call startprint
  jmp interpreter_loop

call_COMMAND_EXIT :
  jmp exit

exit :
mov si, endlinestring
call startprint
mov si, goodbyestring
call startprint

cli         ; Clear all Interrupts
hlt         ; halt the system


;; FUNCTIONS


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
  ; input :
  ; ax
  ; bx must be zero, processed sequence length
  ; cx must be zero, the processed string length
  ; dx
  ; si is pointer to sequence ( where to search string ), words separated by 20h
  ; di is pointer to string ( what to search )
  ; output :
  ; bx is -1 if string not occures in sequence
  ;    is -2 if i made mistake in my code
  ;    is index of the end of found word
  mov dx, di ; contains original string pointer
  mov al, [si] ; sequence char
  mov ah, [di] ; string char
  inc si
  inc di
  inc bx
  ;
  test al, al ; seq == 0
  jnz seq_not_zero
  ; seq = 0
  test ah, ah ; str == 0
  jnz quit_notfound ; str ! 0
  ; seq = 0, str = 0
  quit_compare :
  ; cmp cx, dx
  ; jnz quit_notfound ; cx = dx
  ; seq = 0, str = 0, cx = dx
  test cx, cx ; cx == 0
  jz quit_notfound ; cx = 0
  ; cx ! 0
  ; ( FOUND )
  ; mov bx, 0
  ret
  ;
  quit_notfound :
  ; seq = 0, str ! 0
  ; ( NOT FOUND )
  mov bx, -1
  ret
  ;
  seq_not_zero :
  ; seq ! 0
  cmp al, ' ' ; seq == ' '
  jnz seq_is_char ; seq ! ' '
  ; seq = ' '
  test ah, ah ; str == 0
  jz quit_compare ; str = 0
  ; seq = ' ', str is char
  reset :
  ; ( RESET )
  mov di, dx ; reset string pointer
  ; mov dx, 0 ; the sameness value now initial
  mov cx, 0 ; the processed string length now initial
  jmp startfind
  ;
  seq_is_char : ; seq ! ' ' ! 0
  test ah, ah ; str == 0
  jz quit_notfound ; str = 0
  ; str is char
  inc cx ; str.length += 1
  cmp al, ah ; seq == str
  jnz reset ; seq ! str
  ; seq = str
  ; ( NEXT )
  ; inc dx ; sameness += 1
  jmp startfind
  ; never happens
  mov bx, -2
  ret


;; DATA


COMMAND_EXIT equ 2
COMMAND_HELLO equ 8

hellostring db 3, ' axinyaos helloing you ', 3, 10, 13, 0
goodbyestring db 3, ' axinyaos goodbying you ', 3, 10, 13, 0
endlinestring db 10, 13, 0
commandsstring db '! hello', 0
foundstring db ' found', 0
notfoundstring db ' not found', 0
errorstring db ' error', 0
luckystring db ' lucky', 0
bufferstring times BUFFER_CAP db 0


times 510 - ( $ - $$ ) db 0 ; boot have to be 512 bytes
dw 0xAA55                   ; boot signiture
