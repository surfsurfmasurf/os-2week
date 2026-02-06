; src/boot.asm
; Stage-1 boot sector (512 bytes).
; Loads 1 sector (stage2) from disk into 0x0000:0x1000 and jumps to it.
;
; Build artifacts are assembled via the Makefile.
;
; Notes:
; - BIOS loads us at 0x0000:0x7C00 with DL = boot drive.
; - We use INT 13h (CHS) to read sector 2 (LBA 1) from the boot disk.

BITS 16
ORG 0x7C00

STAGE2_SEG     EQU 0x0000
STAGE2_OFF     EQU 0x1000
STAGE2_SECTORS EQU 1

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti

  mov [boot_drive], dl

  mov si, msg_boot
  call print_string

  ; Reset disk system
  xor ax, ax
  int 0x13

  ; Read stage2: CHS = 0/0/2 (sector numbers start at 1)
  mov ax, STAGE2_SEG
  mov es, ax
  mov bx, STAGE2_OFF

  mov ah, 0x02            ; read sectors
  mov al, STAGE2_SECTORS  ; count
  mov ch, 0x00            ; cylinder
  mov cl, 0x02            ; sector
  mov dh, 0x00            ; head
  mov dl, [boot_drive]
  int 0x13
  jc disk_error

  jmp STAGE2_SEG:STAGE2_OFF

disk_error:
  mov si, msg_disk_err
  call print_string
  jmp hang

; --- helpers ---
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

hang:
  cli
.hlt:
  hlt
  jmp .hlt

boot_drive db 0

msg_boot     db "os-2week: stage1 ok\r\n", 0
msg_disk_err db "disk read failed\r\n", 0

; Pad to 510 bytes, then add boot signature 0xAA55.
TIMES 510-($-$$) db 0
DW 0xAA55
