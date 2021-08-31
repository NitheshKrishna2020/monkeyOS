org 0  ; offset 0
bits 16
jmp 0x7c0:start ; BIOS will load bootloader to 0x7c00

handle_int_zero:
    mov si, message
    call print_message
    iret

; start label will be address 0x7c0:start
start:
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov word[ss:0x00], handle_int_zero
    mov word[ss:0x02], 0x7c0

    mov ax, 0x00
    div ax
    jmp $

; print_message label will be address 0x7c0:print_message
print_message:
    lodsb
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
    db 'I changed divided by zero exception!', 0

times 510 - ($ - $$) db 0
dw 0xaa55