; src/stage2.asm
; Stage-2 payload loaded by the boot sector to 0x0000:0x1000.
; For now, just prints a message and halts.

BITS 16
ORG 0x1000

start:
  mov si, msg
  call print_string

shell:
  mov si, prompt
  call print_string

  call get_keystroke
  
  ; Echo back
  mov ah, 0x0E
  mov bh, 0x00
  mov bl, 0x07
  int 0x10

  ; If 'v', version
  cmp al, 'v'
  je .version

  jmp shell

.version:
  mov si, msg_ver
  call print_string
  jmp shell

.reboot:
  int 0x19

hang:
  mov si, msg_halt
  call print_string
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
msg_ver db 13, 10, "os-2week v0.1.0 (minimal)", 13, 10, 0
prompt db "> ", 0
msg_halt db 13, 10, "Halting system.", 13, 10, 0
