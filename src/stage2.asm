; src/stage2.asm
; Stage-2 payload loaded by the boot sector to 0x0000:0x1000.
; For now, just prints a message and halts.

BITS 16
ORG 0x1000

start:
  mov si, msg
  call print_string

  call get_keystroke
  mov si, msg_key
  call print_string

hang:
  cli
.hlt:
  hlt
  jmp .hlt

; --- helpers ---

; get_keystroke: wait for key, return AL=ascii, AH=scancode
get_keystroke:
  mov ah, 0x00
  int 0x16
  ret

; print_string: DS:SI -> 0-terminated string
print_string:
  pusha
.print:
  lodsb
  test al, al
  jz .done
  mov ah, 0x0E
  mov bh, 0x00
  mov bl, 0x07
  int 0x10
  jmp .print
.done:
  popa
  ret

msg db "os-2week: stage2 ok", 13, 10, 0
msg_key db "Key pressed. Halting.", 13, 10, 0
