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

  ; Command: 'echo'
  mov di, cmd_echo
  call strcmp_prefix
  jc .do_echo

  ; Command: 'mmap'
  mov di, cmd_mmap
  call strcmp
  jc .do_mmap

  ; Command: 'cpu'
  mov di, cmd_cpu
  call strcmp
  jc .do_cpu

  ; Command: 'uptime'
  mov di, cmd_uptime
  call strcmp
  jc .do_uptime

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

.do_echo:
  ; Skip "echo " (5 chars)
  add si, 5
  call print_string
  mov si, newline
  call print_string
  ret

.do_mmap:
  mov si, msg_mmap_header
  call print_string

  xor ebx, ebx          ; continuation value, must be 0 for first call
  mov edx, 0x534D4150   ; 'SMAP'
  
.mmap_loop:
  mov di, mmap_entry    ; ES:DI points to destination buffer
  mov eax, 0xE820
  mov ecx, 24           ; request 24 bytes
  int 0x15

  jc .mmap_done         ; error if carry set
  cmp eax, 0x534D4150   ; check SMAP signature
  jne .mmap_done

  ; Display entry (Base Address: 64-bit, Length: 64-bit, Type: 32-bit)
  ; For simplicity in 16-bit real mode, we'll just show the low 32 bits of Base and Length
  
  ; Base Low
  mov eax, [mmap_entry]
  call print_hex_32
  mov si, space
  call print_string

  ; Length Low
  mov eax, [mmap_entry + 8]
  call print_hex_32
  mov si, space
  call print_string

  ; Type
  mov eax, [mmap_entry + 16]
  call print_hex_32
  mov si, newline
  call print_string

  test ebx, ebx         ; if ebx is 0, list is finished
  jz .mmap_done
  jmp .mmap_loop

.mmap_done:
  ret

.do_cpu:
  mov eax, 0
  cpuid
  
  ; Vendor ID is in EBX:EDX:ECX
  mov [vendor_id], ebx
  mov [vendor_id+4], edx
  mov [vendor_id+8], ecx
  mov byte [vendor_id+12], 0 ; Null terminate
  
  mov si, msg_cpu_vendor
  call print_string
  mov si, vendor_id
  call print_string
  mov si, newline
  call print_string
  ret

.do_uptime:
  ; Read BIOS timer tick (0040h:006Ch)
  ; 18.2 ticks per second.
  push es
  mov ax, 0x0040
  mov es, ax
  mov eax, [es:0x006C]
  pop es

  ; Divide ticks by 18 to get approximate seconds
  xor edx, edx
  mov ecx, 18
  div ecx ; EAX = seconds, EDX = remainder
  
  push eax ; save seconds
  mov si, msg_uptime
  call print_string
  pop eax
  call print_decimal_32
  mov si, msg_seconds
  call print_string
  ret

; --- helpers ---

; print_decimal_32: prints EAX in decimal
print_decimal_32:
  pusha
  mov ecx, 10
  xor bx, bx          ; digit counter

.push_digits:
  xor edx, edx
  div ecx
  push dx             ; remainder (digit)
  inc bx
  test eax, eax
  jnz .push_digits

.pop_digits:
  pop dx
  mov al, dl
  mov ah, 0x0E
  int 0x10
  dec bx
  jnz .pop_digits
  
  popa
  ret

; print_hex_32: prints EAX in hex
print_hex_32:
  pusha
  mov cx, 8             ; 8 hex digits
.loop:
  rol eax, 4            ; rotate top nibble to bottom
  push eax
  and al, 0x0F          ; mask nibble
  cmp al, 10
  jl .digit
  add al, 7             ; convert A-F
.digit:
  add al, '0'
  mov ah, 0x0E
  int 0x10
  pop eax
  loop .loop
  popa
  ret

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

; strcmp_prefix: DS:SI vs DS:DI. Sets Carry Flag if SI starts with DI.
strcmp_prefix:
  push si
  push di
.loop:
  mov bl, [di]
  test bl, bl     ; reached end of prefix?
  jz .match
  mov al, [si]
  cmp al, bl
  jne .no_match
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
msg_ver db "os-2week v0.1.0 (Day 11: RTC/Timer)", 13, 10, 0
msg_help db "Available: ver, cls, reboot, help, echo <text>, mmap, cpu, uptime", 13, 10, 0
msg_unknown db "Unknown command. Type 'help'.", 13, 10, 0
msg_mmap_header db "BaseLow  Length   Type", 13, 10, 0
msg_cpu_vendor db "CPU Vendor: ", 0
msg_uptime db "Uptime: ", 0
msg_seconds db " seconds", 13, 10, 0
prompt db "> ", 0
newline db 13, 10, 0
space db " ", 0

; Commands
cmd_ver db "ver", 0
cmd_cls db "cls", 0
cmd_reboot db "reboot", 0
cmd_help db "help", 0
cmd_echo db "echo ", 0
cmd_mmap db "mmap", 0
cmd_cpu db "cpu", 0
cmd_uptime db "uptime", 0

; Buffer
input_buffer times 64 db 0
mmap_entry times 24 db 0
vendor_id times 13 db 0
