org 0x7c00
bits 16
jmp 0:start 

start:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    jmp $

times 510 - ($ - $$) db 0
dw 0xaa55
