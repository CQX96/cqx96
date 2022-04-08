graphics_init:
    push ax
    xor ah, ah
    mov ax, 13h  
    int 10h
    call txti
    pop ax
    ret

graphics_uninit:
    push ax
    xor ah, ah
    mov ax, 03h  
    int 10h
    pop ax
    ret

%include "../kernel/includes/graphics/lib.asm"
