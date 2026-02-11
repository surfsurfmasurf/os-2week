; src/stage2.asm
; Stage-2 payload loaded by the boot sector to 0x0000:0x1000.
; Updated for Day 7: Input Buffering & Command Parsing foundations.

BITS 16
ORG 0x1000

start:
  mov si, msg
  call print_string

shell_loop:
  mov si, prompt
  call print_string

  mov di, input_buffer ; Set DI to start of buffer
  mov cx, 0            ; Buffer index / length counter

input_loop:
  call get_keystroke   ; Returns AL=ascii, AH=scancode

  ; Handle Backspace
  cmp al, 0x08
  je .backspace

  ; Handle Enter
  cmp al, 0x0D
  je .enter

  ; Check buffer limit (avoid overflow)
  cmp cx, 63
  jge input_loop

  ; Echo character
  mov ah, 0x0E
  int 0x10

  ; Store in buffer
  stosb
  inc cx
  jmp input_loop

.backspace:
  test cx, cx
  jz input_loop        ; If buffer empty, do nothing
  dec cx
  dec di
  
  ; Visual backspace (move cursor back, print space, move back again)
  mov ah, 0x0E
  mov al, 0x08
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x08
  int 0x10
  jmp input_loop

.enter:
  ; Null-terminate the string
  mov byte [di], 0
  
  ; New line
  mov si, newline
  call print_string

  ; If buffer is empty, just loop
  test cx, cx
  jz shell_loop

  ; Process Command
  call process_command
  jmp shell_loop

; --- Command Processing ---

process_command:
  mov si, input_buffer

  ; Command: 'ver'
  mov di, cmd_ver
  call strcmp
  jc .do_ver

  ; Command: 'cls'
  mov di, cmd_cls
  call strcmp
  jc .do_cls

  ; Command: 'reboot'
  mov di, cmd_reboot
  call strcmp
  jc .do_reboot

  ; Command: 'help'
  mov di, cmd_help
  call strcmp
  jc .do_help

  ; Unknown command
  mov si, msg_unknown
  call print_string
  ret

.do_ver:
  mov si, msg_ver
  call print_string
  ret

.do_cls:
  mov ax, 0x0003 ; Reset video mode (clears screen)
  int 0x10
  ret

.do_reboot:
  int 0x19
  ret

.do_help:
  mov si, msg_help
  call print_string
  ret

; --- helpers ---

; strcmp: DS:SI vs DS:DI. Sets Carry Flag if match.
strcmp:
  push si
  push di
.loop:
  mov al, [si]
  mov bl, [di]
  cmp al, bl
  jne .no_match
  test al, al     ; reached end of both?
  jz .match
  inc si
  inc di
  jmp .loop
.no_match:
  pop di
  pop si
  clc
  ret
.match:
  pop di
  pop si
  stc
  ret

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

; --- data ---

msg db "os-2week: stage2 ok", 13, 10, 0
msg_ver db "os-2week v0.1.0 (Day 7: String Input & Command Parsing)", 13, 10, 0
msg_help db "Available: ver, cls, reboot, help", 13, 10, 0
msg_unknown db "Unknown command. Type 'help'.", 13, 10, 0
prompt db "> ", 0
newline db 13, 10, 0

; Commands
cmd_ver db "ver", 0
cmd_cls db "cls", 0
cmd_reboot db "reboot", 0
cmd_help db "help", 0

; Buffer
input_buffer times 64 db 0
