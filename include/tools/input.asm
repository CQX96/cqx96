; INPUT.ASM
; For the CQX96 Kernel





waitkey:
	mov eax, 0
	mov ah, 10h                           ; BIOS call to wait for key
	int 16h
	cmp byte [logged], 0			; Check if we are logged in before switching screens
	je .end
	cmp ah, 105
	je multi_switch
.end:
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
