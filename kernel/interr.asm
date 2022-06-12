; INTERR.ASM
; For the CQX96 Kernel

; Interrupt handler things for CQX96




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
