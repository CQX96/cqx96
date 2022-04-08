 
 ;https://stackoverflow.com/questions/48648548/graphics-mode-in-assembly-8086
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;GFX mode 13h print library ver:1.0
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;txti       init font adress
 ;char       cx=color,al=ASCII,scr:di<=al ;cl=ch => no background
 ;printerg   scr:di <= ds:si ,cx=color cl=ch => no background
 ;graphprint scr:di text after call ,cx=color ...
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 txti:   pusha           ;init font adress
     push es
     mov ax,1130h    ; VGA BIOS - font info
     mov bh,3        ; font 8 x 8 pixels
     int 10h         ; ES:BP returns font address
     mov [cs:fonts],es   ;get font adr
     mov [cs:fonto],bp
     pop es
     popa
     ret
 fonts   dw 0        ; font address for printing ...
 fonto   dw 0
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 char:   pusha       ;cx=color,al=ASCII,scr:di<=al ;cl=ch => no background
     push    ds
     push    es
     push    word 0A000h
     pop es
     sub     ah,ah
     shl     ax,3
     mov     ds,[cs:fonts]
     mov     si,[cs:fonto]
     add     si,ax
     mov     dh,8
 .char0: mov     dl,8
     lodsb
     mov     ah,al
 .char1: mov     al,cl
     rcl     ah,1
     jc  .char2
     mov     al,ch
 .char2: cmp     cl,ch
     jz  .char3
     mov     [es:di],al
 .char3: inc     di
     dec     dl
     jnz     .char1
     add     di,320-8
     dec     dh
     jnz     .char0
     pop es
     pop     ds
     popa
     ret
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 printerg:  pusha       ;scr:di <= ds:si ,cx=color cl=ch => no background
 .l0:    lodsb
     or  al,al
     jz  .esc
     call    char
     add     di,8
     jmp     short .l0
 .esc:   popa
     ret
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 graphprint: mov [cs:.dat],si    ;scr:di text after call ,cx=color ...
     pop si
     push    ax
     push    di
     push    ds
     push    cs
     pop ds
 .l0:    lodsb
     or  al,al
     jz  .esc
     call    char
     add     di,8
     jmp     short .l0
 .esc:   pop ds
     pop di
     pop ax
     push    si
     add di,9*320
     mov si,[cs:.dat]
     ret
 .dat:   dw  0
