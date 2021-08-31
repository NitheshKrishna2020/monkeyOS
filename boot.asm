org 0  ; offset 0
bits 16

start:
    cli
    mov ax, 0x7c0
    mov ds, ax
    sti
    mov bx, message     
    call print_message
    jmp $

print_message:
    mov al, [bx]
    cmp al, 0
    je .done
    call print_char
    inc bx
    jmp print_message

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message:
    db 'Hello From My Kernel!', 0

times 510 - ($ - $$) db 0
dw 0xaa55