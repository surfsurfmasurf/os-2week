; src/boot.asm
; Minimal 512-byte boot sector.
; Prints a message via BIOS teletype (INT 10h/AH=0Eh) then halts.
;
; Build: nasm -f bin -o build/boot.bin src/boot.asm
; Run:   qemu-system-i386 -drive format=raw,file=build/boot.bin

BITS 16
ORG 0x7C00

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  mov si, msg
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
  ; hang
  cli
.hlt:
  hlt
  jmp .hlt

msg db "os-2week: boot ok", 0

; Pad to 510 bytes, then add boot signature 0xAA55.
TIMES 510-($-$$) db 0
DW 0xAA55
