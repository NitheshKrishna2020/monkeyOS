org 0
bits 16
jmp 0x7c0:start 


start:
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti
    ; ------ Prepare for reading disk ------
    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, second_sector
    int 0x13
    jc error_handler        ; if something wrong jmp to error_handler

    mov si, second_sector   ; add the second sector to si register
    call print_message
    jmp $

error_handler:
    mov si, message
    call print_message
    jmp $

print_message:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp print_message

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message:
    db 'Failed to load sector', 0

times 510 - ($ - $$) db 0
dw 0xaa55

second_sector: