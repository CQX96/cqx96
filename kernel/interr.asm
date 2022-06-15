; INTERR.ASM
; For the CQX96 Kernel

; Interrupt handler things for CQX96


divide_by_zero:
	mov si, divzero
	jmp panic


kernel_new_interrupt:
	pusha
	cli
	mov dx, es			; Store original ES
	xor ax, ax			; Clear AX for new ES value
	mov es, ax
	mov al, cl			; Move supplied int into AL
	mov bl, 4			; Multiply by four to get position
	mul bl
	mov bx, ax
	mov [es:bx], si
	add bx, 2
	mov ax, 0x2000
	mov [es:bx], ax
	mov es, dx			; Finally, restore data segment
	sti
	popa
	ret

printstring_i:			; INT 96H, AH = 0
	 call printstring
	 iret
commandline_i:			; INT 96H, AH = 1
	 call commandline
	 iret
newline_i:			; INT 96H, AH = 2
	 call newline
	 iret

int96h:
	cmp ah, 00h
	je printstring_i
	cmp ah, 01h
	je commandline_i
	cmp ah, 02h
	je newline_i
	iret

divzero db "Divide by zero detected",0
