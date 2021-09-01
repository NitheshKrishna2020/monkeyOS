org 0x7c00
bits 16
jmp 0:start 

CODE_SEG equ gdt_code - gdt_start   ; offset of codeseg 0x8h
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
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    jmp $

times 510 - ($ - $$) db 0
dw 0xaa55
