; STRING.ASM... AGAIN.
; For the CQX96 Kernel




; Calculate length of string
os_string_length:
	pusha

	mov bx, ax

	mov cx, 0

.more:
	cmp byte [bx], 0
	je .done
	inc bx
	inc cx
	jmp .more


.done:
	mov word [.tmp_counter], cx
	popa
	mov ax, [.tmp_counter]
	ret
	.tmp_counter	dw 0
	
ucase:				; CONVERT STRING TO UPPERCASE
	pusha
	mov si, ax

.more:
	cmp byte [si], 'a'
	jb .noaz
	cmp byte [si], 'z'
	ja .noaz
	sub byte [si], 20h
	inc si
	jmp .more

.noaz:
	inc si
	jmp .more

.done:
	popa
	ret

split:
	push si
	mov ax, si

	mov bx, 0
	mov cx, 0
	mov dx, 0

	push ax

.loops1:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loops1
	dec si
	mov byte [si], 0

	inc si
	mov bx, si

.loops2:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loops2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loops3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loops3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	pop ax

	pop si
	ret

stringcompare:
	pusha

.more:
	mov al, [si]
	mov bl, [di]

	cmp al, bl	
	jne .not_same

	cmp al, 0
	je .terminated

	inc si
	inc di
	jmp .more

.not_same:
	popa	
	clc
	ret

.terminated:
	popa
	stc
	ret
