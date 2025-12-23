;@DESC A simple number guessing game
;@NAME Guesser

; GUESSER.ASM
; For the CQX96 Kernel

	BITS 16
	%INCLUDE "cqx.inc"
	ORG 40960
start:
	pusha
	call newline
	call os_seed_random
	mov ax, 1
	mov bx, 100
	call os_get_random
	mov ax, cx
	call 001Eh
	mov cx, ax
	xor dx, dx
	jmp continue
	
correct:
	call newline
	mov si, correcto
	call printstring
	mov ax, dx
	call 001Eh
	mov si, ax
	call printstring
	mov si, secondtm
	call printstring
	popa
	ret

continue:
	call newline
	inc dx
    mov si, guessm
	call printstring
	mov ax, input
	mov bx, 4
	call getinput
	mov si, cx
	mov di, input
	call stringcompare
	jc correct
	call newline
	mov si, incorrect
	call printstring
	jmp continue
	
os_seed_random:
	push bx
	push ax
	mov bx, 0
	mov al, 0x02			
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl bx, 8
	mov al, 0			
	out 0x70, al
	in al, 0x71
	mov bl, al
	mov word [os_random_seed], bx				
	pop ax
	pop bx
	ret
	os_random_seed	dw 0

os_get_random:
	push dx
	push bx
	push ax
	sub bx, ax			
	call .generate_random
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx
	pop ax
	pop bx
	pop dx
	add cx, ax			
	ret

.generate_random:
	push dx
	push bx
	mov ax, [os_random_seed]
	mov dx, 0x7383			
	mul dx				
	mov [os_random_seed], ax
	pop bx
 	pop dx
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
   
guessm    db "Guess my number between 1 and 100!", 0
guess     db 0
correcto  db "That's correct! You guessed it in ", 0
secondtm  db " tries", 0
incorrect db "That's not correct!", 0
input     times 3 db 0
tries     db 0