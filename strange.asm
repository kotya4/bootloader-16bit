; bootloader

bits  16            ; still in 16 bit Real Mode
org   0x7c00        ; boot loaded by BIOS at 0x7C00  bnvhh
mov si, hellostring
call startprint

; readcommand :

READBUFFER_CAP equ 16
xor cl, cl ; READBUFFER_CAP - 1
mov si, readbufferstring
; xor bl, bl ; commandstring offset
mov di, commandsstring
readkey :
  cmp cl, READBUFFER_CAP ; -1 because last key must be 0
  jz exit
  inc cl

  ; read key press, al = ascii key
  mov ah, 00h
  int 16h


  ; exit on enter, can be flush of current readkey
  ; cmp al, 13
  ; jz endreadkey

   ; teletype output pressed key
  mov ah, 0eh
  int 10h

  ; save ascii key to buffer ( except 13 )
  mov [si], al
  inc si

  ; interpret command

  mov ah, [di]
  inc di

  cmp ah, 0 ; no more commands
  jz exit

  cmp ah, al ; compare command character
  jz same_commands ; characters are the same, read more
  jnz not_same_commands ; not the same, maybe command end aka ♥ ?

same_commands :
  jmp readkey

not_same_commands :
  mov di, commandsstring ; flush commandsstring offset
  cmp ah, 3 ; compare command character with ♥ ( command end can be removed if commands are sorted by length and alphabetically )
  jz end_of_command ; intepret ( also al can be checked for Enter or smth )
  jnz not_the_end_of_command


  not_the_end_of_command :
    ; must be commandsstring have another command? find it,
    ; you have to do same thing over, with readbuffer values
    ; wich already exist and if you find similar, start readkey.
    ; also you can remove al from readbuffer if there is and
    ; try find same command skipping from current di. overwise
    ; commandsstring must be sorted.
    ; if not, exit ?
    ; mov bh, readbufferstring
    ; mov bl, [bh]
    ; cmp bl,
    ; jz similar_not_found
    ; jnz similar_found
    ; similar_not_found :
    ; cmp bl,
    jmp exit


  COMMAND_EXIT equ 2
  COMMAND_HELLO equ 8

  end_of_command :
    ; commnads are the same, eval it
    ; evaluate_command
    cmp di, COMMAND_EXIT
    jz exit
    cmp di, COMMAND_HELLO
    jnz not_command_hello
    mov si, hellostring
    call startprint
    not_command_hello :



  ; jnz not_same_command
  ; ; ok, command is same
  ; jmp compare_commands
  ; not_same_command :





jmp readkey
; endreadkey :



; mov si, endlinestring
; call startprint


; mov si, readbufferstring
; mov al, [si]
; cmp al, '!'
; jz exit
; inc si
; inc di
; jmp readcommand



exit :
; echo buffer
; mov si, readbufferstring
; call startprint
mov si, endlinestring
call startprint
mov si, goodbyestring
call startprint

cli         ; Clear all Interrupts
hlt         ; halt the system

startprint :
  mov ah, 0eh ; teletype output
  mov bx, 0 ; page at 0
  ; mov si, hellostring ; string pointer to value
  print :
    mov al, [si]
    or al, al ; is character null
    jz endprint
    int 10h ; teletype output
    inc si
    jmp print
  endprint :
  ret

hellostring db 3, ' axinya boots helloing you ', 3, 10, 13, 0
goodbyestring db 3, ' axinya boots goodbying you ', 3, 10, 13, 0
endlinestring db 10, 13, 0
commandsstring db '!', 3, 'hello', 3, 0

readbufferstring times 16 db 0

times 510 - ( $ - $$ ) db 0 ; boot have to be 512 bytes
dw 0xAA55                   ; boot signiture
