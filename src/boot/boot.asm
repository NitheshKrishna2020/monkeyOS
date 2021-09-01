org 0x7c00
bits 16

CODE_SEG equ gdt_code - gdt_start   ; offset of code_seg 0x8h
DATA_SEG equ gdt_data - gdt_start   ; offset of data_seg

jmp 0:start

start:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

; basic routine to switch to protected mode
.load_protected:
    cli
    lgdt[gdt_descriptor]    ; lgdt find the size and offset
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax            ; finish switching protected mode
    jmp CODE_SEG:load32     ; CODE_SEG is the cs in procted mode


; ------ GDT ------
; gdt_null
; The first segment is null segment always set to 0, reserved by Intel
gdt_start:
    dd 0x0
    dd 0x0

; offset 0x8 because gdt_null takes 64 bits -> 0x8
; code_segment
gdt_code:           ; CS should point to this
    dw 0xffff       ; limits 0-15
    dw 0            ; base address 0-15
    db 0            ; base 16-23
    db 0x9a         ; access byte
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

; offset 0x10 because gdt_code takes 64 bits -> 0x8 + 0x8 = 0x10
; data_segment
gdt_data:           ; DS, SS, ES, FS, GS
    dw 0xffff       ; limits 0-15
    dw 0            ; base address 0-15
    db 0            ; base 16-23
    db 0x92         ; access byte
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; size of the descriptor
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1          ; starting sector we want to load, 0 is the boot sector
    mov ecx, 100        ; total number sector we want to load
    mov edi, 0x0100000  ; the address we want to load them into RAM
    call ata_lba_read   ; call the dirve and load 100 sectors to memory at 0x0100000
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax        ; backup the LBA
    ; send the highest 8 bits of the lba to hard disk controller
    shr eax, 24         ; right shift eax 24 bits, then eax contains the 8 highest bit of LBA
    or eax, 0xE0        ; select master drive
    mov dx, 0x1F6       ; the port expects the hightest 8 bits
    out dx, al          
    ; Finish sending the highest 8 bits of the lba

    ; send the total sectors to the hard disk controller
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; finished sending the total sectors to read

    ; send more bits of the lba
    mov eax, ebx ; restroe the backup lba
    mov dx, 0x1F3
    out dx, al
    ; finish sending more bit of 
    
    ; sending more
    mov dx, 0x1F4
    mov eax, ebx ; restroe the backup lba
    shr eax, 8
    out dx, al
    ; finish sending more bit of lba

    ; send more uper 16 bits
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; finish sending uper 16 bit of lba

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

; Read all sectors into memory
.next_sector:
    push ecx

; checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again
; need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw      ; reading a word from port 0x1F0, and store to edi
    pop ecx       ; cx auto decrement
    loop .next_sector
    ;End of reading sectors into memory
    ret

times 510 - ($ - $$) db 0
dw 0xaa55
