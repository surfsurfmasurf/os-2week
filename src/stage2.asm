; src/stage2.asm
; Stage-2 payload loaded by the boot sector to 0x0000:0x1000.
; For now, just prints a message and halts.

BITS 16
ORG 0x1000

start:
  mov si, msg
  call print_string

hang:
  cli
.hlt:
  hlt
  jmp .hlt

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

msg db "os-2week: stage2 ok", 0
