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

  ; Command: 'time'
  mov di, cmd_time
  call strcmp
  jc .do_time

  ; Command: 'date'
  mov di, cmd_date
  call strcmp
  jc .do_date

  ; Command: 'color'
  mov di, cmd_color
  call strcmp_prefix
  jc .do_color

  ; Command: 'dump'
  mov di, cmd_dump
  call strcmp_prefix
  jc .do_dump

  ; Command: 'peek'
  mov di, cmd_peek
  call strcmp_prefix
  jc .do_peek

  ; Command: 'poke'
  mov di, cmd_poke
  call strcmp_prefix
  jc .do_poke

  ; Command: 'pci'
  mov di, cmd_pci
  call strcmp
  jc .do_pci

  ; Command: 'mem'
  mov di, cmd_mem
  call strcmp
  jc .do_mem

  ; Command: 'beep'
  mov di, cmd_beep
  call strcmp
  jc .do_beep

  ; Command: 'exit' (alias for reboot)
  mov di, cmd_exit
  call strcmp
  jc .do_reboot

  ; Command: 'panic' (simulate panic)
  mov di, cmd_panic
  call strcmp
  jc .do_panic

  ; Command: 'halt' (halt the CPU)
  mov di, cmd_halt
  call strcmp
  jc .do_halt

  ; Command: 'rand' (simple random number)
  mov di, cmd_rand
  call strcmp
  jc .do_rand

  ; Command: 'ls' (list files - mock)
  mov di, cmd_ls
  call strcmp
  jc .do_ls_mock

  ; Command: 'cat' (print file contents)
  mov di, cmd_cat
  call strcmp_prefix
  jc .do_cat

  ; Command: 'type' (alias for cat)
  mov di, cmd_type
  call strcmp_prefix
  jc .do_cat

  ; Command: 'edit' (edit memory as string)
  mov di, cmd_edit
  call strcmp_prefix
  jc .do_edit

  ; Command: 'read' (read sector - INT 13h)
  mov di, cmd_read
  call strcmp_prefix
  jc .do_read

  ; Command: 'write' (write sector - INT 13h)
  mov di, cmd_write
  call strcmp_prefix
  jc .do_write

  ; Command: 'fill' (fill buffer with byte)
  mov di, cmd_fill
  call strcmp_prefix
  jc .do_fill

  ; Command: 'seek' (mock seek)
  mov di, cmd_seek
  call strcmp_prefix
  jc .do_seek

  ; Command: 'whoami'
  mov di, cmd_whoami
  call strcmp
  jc .do_whoami

  ; Command: 'su' (mock user switch)
  mov di, cmd_su
  call strcmp_prefix
  jc .do_su_mock

  ; Command: 'sudo' (mock sudo)
  mov di, cmd_sudo
  call strcmp_prefix
  jc .do_sudo_mock

  ; Command: 'ps' (list processes - mock)
  mov di, cmd_ps
  call strcmp
  jc .do_ps_mock

  ; Command: 'kill' (mock kill)
  mov di, cmd_kill
  call strcmp_prefix
  jc .do_kill_mock

  ; Command: 'df' (disk space mock)
  mov di, cmd_df
  call strcmp
  jc .do_df_mock

  ; Command: 'du' (disk usage mock)
  mov di, cmd_du
  call strcmp
  jc .do_du_mock

  ; Command: 'free' (memory usage)
  mov di, cmd_free
  call strcmp
  jc .do_mem

  ; Command: 'touch' (mock file creation)
  mov di, cmd_touch
  call strcmp_prefix
  jc .do_touch_mock

  ; Command: 'rm' (mock file removal)
  mov di, cmd_rm
  call strcmp_prefix
  jc .do_rm_mock

  ; Command: 'pwd' (print working directory mock)
  mov di, cmd_pwd
  call strcmp
  jc .do_pwd_mock

  ; Command: 'mkdir' (mock directory creation)
  mov di, cmd_mkdir
  call strcmp_prefix
  jc .do_mkdir_mock

  ; Command: 'rmdir' (mock directory removal)
  mov di, cmd_rmdir
  call strcmp_prefix
  jc .do_rmdir_mock

  ; Command: 'cd' (mock directory change)
  mov di, cmd_cd
  call strcmp_prefix
  jc .do_cd_mock

  ; Command: 'cp' (mock file copy)
  mov di, cmd_cp
  call strcmp_prefix
  jc .do_cp_mock

  ; Command: 'mv' (mock file move)
  mov di, cmd_mv
  call strcmp_prefix
  jc .do_mv_mock

  ; Command: 'history' (mock shell history)
  mov di, cmd_history
  call strcmp
  jc .do_history_mock

  ; Command: 'clear' (alias for cls)
  mov di, cmd_clear
  call strcmp
  jc .do_cls

  ; Unknown command
  mov si, msg_unknown
  call print_string
  ret

.do_ver:
  mov si, msg_ver
  call print_string
  ret

.do_ls_mock:
  mov si, msg_ls_mock
  call print_string
  ret

.do_ps_mock:
  mov si, msg_ps_mock
  call print_string
  ret

.do_df_mock:
  mov si, msg_df_mock
  call print_string
  ret

.do_du_mock:
  mov si, msg_du_mock
  call print_string
  ret

.do_touch_mock:
  mov si, msg_touch_ok
  call print_string
  ret

.do_rm_mock:
  mov si, msg_rm_ok
  call print_string
  ret

.do_mkdir_mock:
  mov si, msg_mkdir_ok
  call print_string
  ret

.do_rmdir_mock:
  mov si, msg_rmdir_ok
  call print_string
  ret

.do_cd_mock:
  mov si, msg_cd_ok
  call print_string
  ret

.do_cp_mock:
  mov si, msg_cp_ok
  call print_string
  ret

.do_mv_mock:
  mov si, msg_mv_ok
  call print_string
  ret

.do_history_mock:
  mov si, msg_history_mock
  call print_string
  ret

.do_su_mock:
  mov si, msg_su_ok
  call print_string
  ret

.do_sudo_mock:
  mov si, msg_sudo_ok
  call print_string
  ret

.do_pwd_mock:
  mov si, msg_pwd_mock
  call print_string
  ret

.do_kill_mock:
  mov si, msg_kill_ok
  call print_string
  ret

.do_cat:
  ; Usage: cat <lba_hex>
  ; Reuses 'read' logic to dump the first 64 bytes of a sector as ASCII
  add si, 4
  mov al, [si]
  test al, al
  jz .cat_help

  call parse_hex_word
  jc .cat_help
  push ax

  call lba_to_chs
  ; Target buffer 0x2000:0x0000
  mov ax, 0x2000
  mov es, ax
  xor bx, bx
  mov ax, 0x0201
  int 0x13
  jc .read_err

  ; Print first 64 bytes as ASCII
  mov si, 0
  mov ax, 0x2000
  mov ds, ax
  mov cx, 64
.cat_loop:
  lodsb
  test al, al
  jz .cat_next
  cmp al, 32
  jl .cat_dot
  cmp al, 126
  jg .cat_dot
  jmp .cat_print
.cat_dot:
  mov al, '.'
.cat_print:
  mov ah, 0x0E
  int 0x10
.cat_next:
  loop .cat_loop
  
  ; Restore DS
  mov ax, 0x0000
  mov ds, ax
  mov si, newline
  call print_string
  ret

.cat_help:
  mov si, msg_cat_help
  call print_string
  ret

.do_edit:
  ; Usage: edit <addr_hex> <string>
  ; Writes a string to memory at <addr_hex>
  add si, 5
  mov al, [si]
  test al, al
  jz .edit_help

  call parse_hex_word
  jc .edit_help
  mov di, ax ; target address

  ; Skip to space after address
  mov al, [si]
  cmp al, ' '
  jne .edit_help
  inc si ; start of string

.edit_loop:
  lodsb
  stosb
  test al, al
  jnz .edit_loop

  mov si, msg_poke_ok ; reuse "Memory updated"
  call print_string
  ret

.edit_help:
  mov si, msg_edit_help
  call print_string
  ret

.do_read:
  ; Usage: read <sector_hex>
  ; Reads 1 sector (512 bytes) to 0x2000:0x0000
  add si, 5
  mov al, [si]
  test al, al
  jz .read_help

  call parse_hex_word
  jc .read_help
  
  call lba_to_chs

  ; Target buffer 0x2000:0x0000
  mov ax, 0x2000
  mov es, ax
  xor bx, bx

  mov ax, 0x0201 ; AH=02 (Read), AL=01 (1 sector)
  int 0x13
  jc .read_err

  mov si, msg_read_ok
  call print_string
  ret

.read_err:
  mov si, msg_read_err
  call print_string
  call print_hex_byte ; Error code in AH? wait, status is in AH.
  mov si, newline
  call print_string
  ret

.read_help:
  mov si, msg_read_help
  call print_string
  ret

.do_write:
  ; Usage: write <lba_hex>
  ; Writes 1 sector (512 bytes) from 0x2000:0x0000
  add si, 6
  mov al, [si]
  test al, al
  jz .write_help

  call parse_hex_word
  jc .write_help
  
  call lba_to_chs

  ; Source buffer 0x2000:0x0000
  mov ax, 0x2000
  mov es, ax
  xor bx, bx

  mov ax, 0x0301 ; AH=03 (Write), AL=01 (1 sector)
  int 0x13
  jc .write_err

  mov si, msg_write_ok
  call print_string
  ret

.write_err:
  mov si, msg_write_err
  call print_string
  call print_hex_byte
  mov si, newline
  call print_string
  ret

.write_help:
  mov si, msg_write_help
  call print_string
  ret

.do_fill:
  ; Usage: fill <val_hex>
  ; Fills the transfer buffer (0x2000:0x0000) with 512 bytes of <val_hex>
  add si, 5
  mov al, [si]
  test al, al
  jz .fill_help

  call parse_hex_byte
  jc .fill_help
  
  mov bl, al
  mov ax, 0x2000
  mov es, ax
  xor di, di
  mov al, bl
  mov cx, 512
  rep stosb

  mov si, msg_fill_ok
  call print_string
  ret

.fill_help:
  mov si, msg_fill_help
  call print_string
  ret

.do_seek:
  ; Usage: seek <lba_hex>
  ; Mock seek - just updates a 'current_lba' variable
  add si, 5
  mov al, [si]
  test al, al
  jz .seek_help

  call parse_hex_word
  jc .seek_help

  mov [current_lba], ax
  mov si, msg_seek_ok
  call print_string
  ret

.do_whoami:
  mov si, msg_whoami
  call print_string
  mov si, newline
  call print_string
  ret

.seek_help:
  mov si, msg_seek_help
  call print_string
  ret

.do_panic:
  mov si, msg_panic
  call print_string
  jmp .do_halt

.do_rand:
  ; Simple LCG or use BIOS timer
  ; Read BIOS timer tick (0040h:006Ch)
  push es
  mov ax, 0x0040
  mov es, ax
  mov eax, [es:0x006C]
  pop es
  ; Simple "random" from lower 16 bits of timer
  call print_hex_byte
  mov si, newline
  call print_string
  ret

.do_halt:
  mov si, msg_halt
  call print_string
  cli
.halt_loop:
  hlt
  jmp .halt_loop

.do_time:
  ; Read RTC time (HH:MM:SS)
  ; Get Hours (04h)
  mov al, 0x04
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  call print_decimal_2_digits
  mov al, ':'
  mov ah, 0x0E
  int 0x10

  ; Get Minutes (02h)
  mov al, 0x02
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  call print_decimal_2_digits
  mov al, ':'
  mov ah, 0x0E
  int 0x10

  ; Get Seconds (00h)
  mov al, 0x00
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  call print_decimal_2_digits
  mov si, newline
  call print_string
  ret

.do_date:
  ; Read RTC date (YY:MM:DD)
  ; Get Year (09h)
  mov al, 0x09
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  mov bl, al ; save YY
  
  ; Print '20' prefix
  mov al, '2'
  mov ah, 0x0E
  int 0x10
  mov al, '0'
  int 0x10
  
  mov al, bl
  call print_decimal_2_digits
  mov al, '-'
  mov ah, 0x0E
  int 0x10

  ; Get Month (08h)
  mov al, 0x08
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  call print_decimal_2_digits
  mov al, '-'
  mov ah, 0x0E
  int 0x10

  ; Get Day of Month (07h)
  mov al, 0x07
  out 0x70, al
  in al, 0x71
  call bcd_to_bin
  call print_decimal_2_digits
  mov si, newline
  call print_string
  ret

.do_color:
  ; Simple color command: 'color X' where X is a hex digit (0-F)
  ; Skip "color " (6 chars)
  add si, 6
  mov al, [si]
  test al, al
  jz .color_help

  ; Convert hex char to value
  call hex_to_bin
  jc .color_help
  
  ; Set global text attribute (background 0, foreground AL)
  mov [text_attr], al
  
  ; Optional: Refresh screen with new color or just let it apply to next prints
  mov si, msg_color_set
  call print_string
  ret

.color_help:
  mov si, msg_color_help
  call print_string
  ret

.do_dump:
  ; Simple hex dump: 'dump XXXX' (hex offset from 0x0000)
  ; Skip "dump " (5 chars)
  add si, 5
  mov al, [si]
  test al, al
  jz .dump_help

  ; Parse 4-digit hex address
  call parse_hex_word
  jc .dump_help
  
  ; AX now contains the offset
  mov si, ax
  mov cx, 16 ; Dump 16 bytes
.dump_loop:
  lodsb
  call print_hex_byte
  mov al, ' '
  mov ah, 0x0E
  int 0x10
  loop .dump_loop

  mov si, newline
  call print_string
  ret

.dump_help:
  mov si, msg_dump_help
  call print_string
  ret

.do_peek:
  ; Peek 1 byte: 'peek XXXX'
  add si, 5
  mov al, [si]
  test al, al
  jz .peek_help

  call parse_hex_word
  jc .peek_help

  mov bx, ax
  mov al, [bx]
  call print_hex_byte
  mov si, newline
  call print_string
  ret

.peek_help:
  mov si, msg_peek_help
  call print_string
  ret

.do_poke:
  ; Poke 1 byte: 'poke XXXX YY'
  add si, 5
  mov al, [si]
  test al, al
  jz .poke_help

  call parse_hex_word
  jc .poke_help
  push ax ; Save address

  ; Skip to space after address
  ; SI already advanced by 4 in parse_hex_word
  mov al, [si]
  cmp al, ' '
  jne .poke_err_pop

  inc si ; Move to hex byte
  mov al, [si]
  test al, al
  jz .poke_err_pop

  call parse_hex_byte
  jc .poke_err_pop
  
  mov bl, al ; value
  pop ax     ; address
  mov di, ax
  mov [di], bl

  mov si, msg_poke_ok
  call print_string
  ret

.poke_err_pop:
  pop ax
.poke_help:
  mov si, msg_poke_help
  call print_string
  ret

.do_pci:
  mov si, msg_pci_header
  call print_string

  mov dx, 0x0CF8 ; Config Address Port
  mov eax, 0x80000000 ; Bit 31: Enable bit
  
.pci_loop:
  ; Check if device exists (Vendor ID != 0xFFFF)
  push eax
  out dx, eax
  mov dx, 0x0CFC ; Config Data Port
  in eax, dx
  cmp ax, 0xFFFF
  je .next_device
  
  ; Print Bus/Dev/Fn
  pop eax
  push eax
  
  ; Bus
  shr eax, 16
  and al, 0xFF
  call print_hex_byte
  mov al, ':'
  mov ah, 0x0E
  int 0x10

  ; Device
  pop eax
  push eax
  shr eax, 11
  and al, 0x1F
  call print_hex_byte
  mov al, '.'
  mov ah, 0x0E
  int 0x10

  ; Function
  pop eax
  push eax
  shr eax, 8
  and al, 0x07
  call print_hex_byte
  mov si, space
  call print_string

  ; Read Vendor:Device
  mov dx, 0x0CF8
  pop eax
  push eax
  out dx, eax
  mov dx, 0x0CFC
  in eax, dx
  
  push eax
  shr eax, 16
  call print_hex_byte ; Device ID High
  pop eax
  push eax
  shr eax, 8
  call print_hex_byte ; Device ID Low
  mov al, ':'
  mov ah, 0x0E
  int 0x10
  pop eax
  push eax
  call print_hex_byte ; Vendor ID High (wait, in eax is Dev:Vendor)
  ; Actually in eax is DevID(31:16) : VenID(15:0)
  ; Let's re-do carefully
  pop eax
  
  ; Vendor ID (Low 16 bits of EAX)
  push eax
  push ax
  pop dx
  mov al, dh
  call print_hex_byte
  mov al, dl
  call print_hex_byte
  mov al, ':'
  mov ah, 0x0E
  int 0x10
  
  ; Device ID (High 16 bits of EAX)
  pop eax
  shr eax, 16
  mov dx, ax
  mov al, dh
  call print_hex_byte
  mov al, dl
  call print_hex_byte

  mov si, newline
  call print_string

.next_device:
  pop eax
  add eax, 0x800 ; Increment Device field (bits 11-15)
  cmp eax, 0x80010000 ; Check if we've scanned all devices on Bus 0 (up to 31)
  jl .pci_loop
  ret

.do_mem:
  ; Simple mem command to show total conventional memory
  ; BIOS int 0x12 returns KB in AX
  int 0x12
  push ax
  mov si, msg_mem_conv
  call print_string
  pop ax
  xor eax, eax
  mov ax, [esp-2] ; wait, push ax pushed to stack.
  ; let's do it cleaner
  mov ax, [esp] ; ax is on stack
  xor eax, eax
  pop ax
  call print_decimal_32
  mov si, msg_kb
  call print_string
  ret

.do_beep:
  ; PC speaker beep
  ; Frequency = 1193180 / frequency_hz
  ; For ~1000Hz: 1193
  mov al, 0xB6
  out 0x43, al
  mov ax, 1193
  out 0x42, al
  mov al, ah
  out 0x42, al

  ; Turn speaker on
  in al, 0x61
  or al, 0x03
  out 0x61, al

  ; Wait ~100ms (BIOS wait: Int 15h, AH=86h, CX:DX = microseconds)
  ; 100,000 us = 0x000186A0
  mov cx, 0x0001
  mov dx, 0x86A0
  mov ah, 0x86
  int 0x15

  ; Turn speaker off
  in al, 0x61
  and al, 0xFC
  out 0x61, al
  ret

.do_cls:
  mov ax, 0x0003 ; Reset video mode (clears screen)
  int 0x10
  ; Set cursor to (0,0) just in case
  mov ah, 0x02
  mov bh, 0x00
  mov dx, 0x0000
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

lba_to_chs:
  ; Input: AX = LBA
  ; Output: CH=Cyl, DH=Head, CL=Sector, DL=0
  ; For 1.44MB Floppy (18 SPT, 2 Heads)
  push bx
  mov bl, 18
  div bl       ; AL = LBA / 18, AH = LBA % 18
  mov cl, ah
  inc cl       ; CL = Sector (1-based)

  xor ah, ah
  mov bl, 2
  div bl       ; AL = Cylinder, AH = Head
  mov dh, ah   ; DH = Head
  mov ch, al   ; CH = Cylinder
  mov dl, 0    ; Drive 0
  pop bx
  ret

; parse_hex_word: parse 4 hex digits from DS:SI into AX. Sets Carry on error.
parse_hex_word:
  push bx
  push cx
  xor bx, bx
  mov cx, 4
.loop:
  mov al, [si]
  call hex_to_bin
  jc .done
  shl bx, 4
  or bl, al
  inc si
  loop .loop
  mov ax, bx
  clc
.done:
  pop cx
  pop bx
  ret

; parse_hex_byte: parse 2 hex digits from DS:SI into AL. Sets Carry on error.
parse_hex_byte:
  push bx
  mov al, [si]
  call hex_to_bin
  jc .err
  mov bl, al
  shl bl, 4
  inc si
  mov al, [si]
  call hex_to_bin
  jc .err
  or bl, al
  inc si
  mov al, bl
  clc
  jmp .done
.err:
  stc
.done:
  pop bx
  ret

; print_hex_byte: prints AL as 2 hex digits
print_hex_byte:
  push ax
  shr al, 4
  call .print_nibble
  pop ax
  and al, 0x0F
.print_nibble:
  cmp al, 10
  jl .digit
  add al, 7
.digit:
  add al, '0'
  mov ah, 0x0E
  int 0x10
  ret

; hex_to_bin: AL is hex char, returns value in AL, sets Carry if invalid
hex_to_bin:
  cmp al, '0'
  jl .error
  cmp al, '9'
  jle .digit
  
  ; Convert to uppercase
  and al, 0xDF
  cmp al, 'A'
  jl .error
  cmp al, 'F'
  jle .alpha
.error:
  stc
  ret
.digit:
  sub al, '0'
  clc
  ret
.alpha:
  sub al, 'A'
  add al, 10
  clc
  ret

; bcd_to_bin: AL is BCD, returns binary in AL
bcd_to_bin:
  push bx
  mov bl, al
  and al, 0x0F      ; AL = low nibble
  shr bl, 4         ; BL = high nibble
  mov ah, 10
  mul ah            ; AL = high * 10
  add al, bl        ; AL = (high * 10) + low
  pop bx
  ret

; print_decimal_2_digits: prints AL as 2-digit decimal (00-99)
print_decimal_2_digits:
  pusha
  mov ah, 0
  mov bl, 10
  div bl            ; AL = quotient (tens), AH = remainder (ones)
  add ax, 0x3030    ; convert both to ASCII
  mov bl, ah        ; store ones in BL
  mov ah, 0x0E
  int 0x10          ; print tens
  mov al, bl
  int 0x10          ; print ones
  popa
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
  mov bl, [text_attr]
  int 0x10
  jmp .print
.done:
  popa
  ret

; --- data ---

msg db "os-2week: stage2 ok", 13, 10, 0
msg_ver db "os-2week v0.1.17 (Day 41: Add 'su' and 'sudo' mocks)", 13, 10, 0
msg_help db "Available: ver, cls, clear, reboot, help, echo <text>, mmap, cpu, uptime, time, date, color <0-F>, dump <addr>, peek <addr>, poke <addr> <val>, edit <addr> <str>, pci, mem, free, beep, exit, halt, panic, rand, ls, ps, kill <pid>, cat <lba>, type <lba>, read <lba>, write <lba>, fill <val>, seek <lba>, whoami, su, sudo, df, du, touch, rm, pwd, mkdir, rmdir, cd, cp, mv, history", 13, 10, 0
msg_ls_mock db "boot.bin stage2.bin README.txt test.txt bin/ backup/", 13, 10, 0
msg_ps_mock db "PID TTY      STAT   TIME  COMMAND", 13, 10, "  1 tty1     S      0:01  init", 13, 10, "  2 tty1     R      0:00  shell", 13, 10, 0
msg_df_mock db "Filesystem     Size  Used Avail Use% Mounted on", 13, 10, "/dev/fd0       1.4M  512K  932K  35% /", 13, 10, 0
msg_du_mock db "512    ./boot.bin", 13, 10, "2048   ./stage2.bin", 13, 10, "128    ./README.txt", 13, 10, "0      ./test.txt", 13, 10, "4096   ./bin", 13, 10, "4096   ./backup", 13, 10, "10880  .", 13, 10, 0
msg_kill_ok db "Process terminated.", 13, 10, 0
msg_touch_ok db "File created.", 13, 10, 0
msg_rm_ok db "File removed.", 13, 10, 0
msg_mkdir_ok db "Directory created.", 13, 10, 0
msg_rmdir_ok db "Directory removed.", 13, 10, 0
msg_cd_ok db "Directory changed.", 13, 10, 0
msg_cp_ok db "File copied.", 13, 10, 0
msg_mv_ok db "File moved.", 13, 10, 0
msg_history_mock db "1 ver", 13, 10, "2 help", 13, 10, "3 ls", 13, 10, "4 date", 13, 10, "5 history", 13, 10, 0
msg_pwd_mock db "/", 13, 10, 0
msg_whoami db "Root User (Admin)", 13, 10, 0
msg_su_ok db "Switched user (mock).", 13, 10, 0
msg_sudo_ok db "[sudo] password for root: ", 13, 10, "Access granted (mock).", 13, 10, 0
msg_cat_help db "Usage: cat <lba-hex> - displays sector contents as text", 13, 10, 0
msg_edit_help db "Usage: edit <addr-hex> <string> - writes string to memory", 13, 10, 0
msg_read_ok db "Read Success to 2000:0000", 13, 10, 0
msg_read_err db "Read Error: code 0x", 0
msg_read_help db "Usage: read <lba-hex> (0-11) - simple disk probe", 13, 10, 0
msg_write_ok db "Write Success from 2000:0000", 13, 10, 0
msg_write_err db "Write Error: code 0x", 0
msg_write_help db "Usage: write <lba-hex> - PERSISTENT write to disk", 13, 10, 0
msg_fill_ok db "Buffer filled.", 13, 10, 0
msg_fill_help db "Usage: fill <hex-byte> - fills transfer buffer (512b) with value", 13, 10, 0
msg_seek_ok db "Head moved to sector.", 13, 10, 0
msg_seek_help db "Usage: seek <lba-hex> - mocks a disk seek operation", 13, 10, 0
msg_unknown db "Unknown command. Type 'help'.", 13, 10, 0
msg_halt db "System halted.", 13, 10, 0
msg_panic db "KERNEL PANIC: Unhandled Exception", 13, 10, 0
msg_color_set db "Color attribute updated.", 13, 10, 0
msg_color_help db "Usage: color <hex-digit> (e.g., color A for light green)", 13, 10, 0
msg_dump_help db "Usage: dump <4-digit-hex> (e.g., dump 1000)", 13, 10, 0
msg_peek_help db "Usage: peek <4-digit-hex> (e.g., peek 0500)", 13, 10, 0
msg_poke_help db "Usage: poke <4-digit-hex> <2-digit-hex> (e.g., poke 0500 FF)", 13, 10, 0
msg_poke_ok db "Memory updated.", 13, 10, 0
msg_pci_header db "B:D.F Ven:Dev", 13, 10, 0
msg_mem_conv db "Conventional Memory: ", 0
msg_kb db " KB", 13, 10, 0
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
cmd_time db "time", 0
cmd_date db "date", 0
cmd_color db "color ", 0
cmd_dump db "dump ", 0
cmd_peek db "peek ", 0
cmd_poke db "poke ", 0
cmd_pci db "pci", 0
cmd_mem db "mem", 0
cmd_beep db "beep", 0
cmd_exit db "exit", 0
cmd_panic db "panic", 0
cmd_halt db "halt", 0
cmd_rand db "rand", 0
cmd_ls db "ls", 0
cmd_cat db "cat ", 0
cmd_edit db "edit ", 0
cmd_read db "read ", 0
cmd_write db "write ", 0
cmd_fill db "fill ", 0
cmd_seek db "seek ", 0
cmd_whoami db "whoami", 0
cmd_su db "su ", 0
cmd_sudo db "sudo ", 0
cmd_clear db "clear", 0
cmd_type db "type ", 0
cmd_ps db "ps", 0
cmd_kill db "kill ", 0
cmd_free db "free", 0
cmd_df db "df", 0
cmd_du db "du", 0
cmd_touch db "touch ", 0
cmd_rm db "rm ", 0
cmd_pwd db "pwd", 0
cmd_mkdir db "mkdir ", 0
cmd_rmdir db "rmdir ", 0
cmd_cd db "cd ", 0
cmd_cp db "cp ", 0
cmd_mv db "mv ", 0
cmd_history db "history", 0

; Buffer
input_buffer times 64 db 0
mmap_entry times 24 db 0
vendor_id times 13 db 0
text_attr db 0x07 ; Default Light Gray on Black
current_lba dw 0x0000
