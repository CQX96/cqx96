	BITS 16
	%INCLUDE "cqx.inc"
	ORG 40960

start:

    mov ah,06h
    mov al, 00h
    xor cx, cx
    mov dx,184fh
    mov bh,4eh
    int 10h

    mov ah, 3
    int 10h
    mov ah, 02h
    mov dh, 0
    mov dl, 0
    mov bh, 0
    int 10h
	
	mov si, filenamemsg
	call printstring
	
	mov ax, filename
	mov bx, 12
	call getinput
	
	mov ah, 0x00
	mov al, 0x03
	int 10h
	
	mov ax, filename
	mov bx, 0
	mov cx, buffer
    call 0018h

    mov dx, buffer
    add dx, ax
    mov bx, dx
    mov byte [bx], '$'

    mov si, buffer
    call printstring

    mov ah, 3
    int 10h
    mov ah, 02h
    mov dh, 0		         ; set cursor at beginning again
    mov dl, 0
    mov bh, 0
    int 10h

    mov si, buffer         ; user inputs
    input:
    mov ah, 0
    int 16h
    
    cmp ah, 4Dh           ; right Arrow key (key code)
    je right

    cmp ah, 4Bh           ; left Arrow key (key code)
    je left

    cmp al, 8             ; backspace key (ascii)
    je erase

    cmp al, 27            ; escape key (ascii)
    je exit

    cmp al, 9             ; tab key (ascii)
    je tab

    mov [si], al          ; anything else, write in buffer
    inc si
    mov byte [edit], 1

    mov ah,0ah            ; print character in buffer
	mov cx,1
	mov bh,0
	int 10h

	add dl, 1
	mov ah, 2
	mov bh, 0
	int 10h

	jmp input

right:
    inc si
    mov ah, 3       
    int 10h

    mov ah, 2           ; move cursor right one space
    add dl, 1
    int 10h

    jmp input

left:
	cmp dl, 0
	je dont1
	
    dec si
    mov ah, 3  
    int 10h

    mov ah, 2           ; move cursor left one space
    sub dl, 1
    int 10h

    jmp input
	
dont:
	jmp input
	
dont1:
	cmp dh, 0
	je dont
	
    dec si
    mov ah, 3  
    int 10h

    mov ah, 2           ; move cursor left one space
    sub dl, 1
    int 10h

    jmp input
tab:
    mov ah, 3
    int 10h

    mov ah, 2           ; move cursor right four spaces
    add dl, 4
    int 10h

    inc si
    inc si
    inc si
    inc si

    jmp input

erase:
	cmp dl, 0
	je dont
	
	mov ah,02h
	sub dl, 1
	mov bh,0
	int 10h

	mov ah,0ah
	mov al,WS
	mov cx,1
	int 10h
    
    dec si
    mov al, WS
    mov [si], al
    mov byte [edit], 1
	jmp input

exit:

    cmp byte [edit], 0
	je close

    mov ax, filename
    call removefile

    mov ax, filename
	mov word cx, 2000
	mov bx, buffer
	call writefile

close:
	ret

WS  equ  20h
filename db 'document.txt', 0	
handle dw 0
buffer db 2000 DUP(?)
filenamemsg db "Enter file name: "
edit dw 0