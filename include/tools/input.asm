; INPUT.ASM
; For the CQX96 kernel





waitkey:
	mov ah, 0x11
	int 0x16
	jnz .key_pressed
	hlt
	jmp waitkey
	
.key_pressed:
	mov ah, 0x10
	int 0x16
	ret

getinput:
	pusha
	mov bh, 0
	mov ah, 3
	int 10h
	mov word [.tmp2], dx
	popa
	pusha
	cmp bx, 0
	je .done

	mov di, ax
	dec bx
	mov cx, bx
	jmp .get_char
.get_chare:
	pop ax
.get_char:
	call waitkey
	cmp al, 8
	je .backspace
	
	cmp al, 9
	je .tab

	cmp al, 13
	je .end_string

	jcxz .get_char

	cmp al, ' '
	jb .get_char

	cmp al, 126
	ja .get_char

	call .add_char

	dec cx
	jmp .get_char
	
.tab:
	mov si, inputca
.tab_loop:
	lodsb
	cmp al, 0
	je .get_char
	call .add_char
	jmp .tab_loop

.end_string:
	mov al, 0
	stosb

.done:
	popa
	ret


.backspace:							; This used to not work for a while, but it works now. (Not at the time of writing this, but in release 1.0 :-)
	mov bh, 0
	mov ah, 3
	int 10h
	push ax
	mov ax, word [.tmp2]
	cmp dl, al
	je .get_chare
	pop ax

	inc cx

	call .reverse_cursor
	mov al, ' '
	call .add_char
	call .reverse_cursor

	jmp .get_char

.reverse_cursor:
	dec di
	
	mov bh, 0
	mov ah, 3
	int 10h

	dec dl
	mov bh, 0
	mov ah, 2
	int 10h
	
	ret
	
.back_line:
	dec dh
	mov dl, 79
	mov bh, 0
	mov ah, 2
	int 10h
	ret

.add_char:
	call curpos
	cmp dl, 79
	je .get_char
	stosb
	mov ah, 0x0E
	mov bh, 0
	push bp
	int 0x10
	pop bp
	ret

.tmp dw 0
.tmp2 dw 0

curpos:
	pusha

	mov bh, 0
	mov ah, 3
	int 10h

	mov [.tmp], dx
	popa
	mov dx, [.tmp]
	ret
	.tmp dw 0
	
	
getpassword:
	pusha
	mov bh, 0
	mov ah, 3
	int 10h
	mov word [.tmp2], dx
	popa
	pusha
	cmp bx, 0
	je .done

	mov di, ax
	dec bx
	mov cx, bx
	jmp .get_char
.get_chare:
	pop ax
.get_char:
	call waitkey
	cmp al, 8
	je .backspace

	cmp al, 13
	je .end_string

	jcxz .get_char

	cmp al, ' '
	jb .get_char

	cmp al, 126
	ja .get_char

	call .add_char

	dec cx
	jmp .get_char

.end_string:
	mov al, 0
	stosb

.done:
	popa
	ret


.backspace:
	mov bh, 0
	mov ah, 3
	int 10h
	push ax
	mov ax, word [.tmp2]
	cmp dl, al
	je .get_chare
	pop ax

	inc cx

	call .reverse_cursor
	mov al, ' '
	stosb
	mov ah, 0x0E
	mov bh, 0
	push bp
	int 0x10
	pop bp
	call .reverse_cursor

	jmp .get_char

.reverse_cursor:
	dec di
	
	mov bh, 0
	mov ah, 3
	int 10h

	dec dl
	mov bh, 0
	mov ah, 2
	int 10h
	
	ret
	
.back_line:
	dec dh
	mov dl, 79
	mov bh, 0
	mov ah, 2
	int 10h
	ret

.add_char:
	stosb
	mov ah, 0x0E
	mov bh, 0
	push ax
	mov al, '*'
	push bp
	int 0x10
	pop bp
	pop ax
	ret

.tmp dw 0
.tmp2 dw 0
