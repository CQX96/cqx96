; INTERR.ASM
; For the CQX96 Kernel

; Interrupt handler things for CQX96


divide_by_zero:
	mov si, divzero
%ifndef IGNORE_PANICS
	jmp panic
%endif
	jmp $


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

printstring_i:			; INT 96H, AH = 3
	 call printstring
	 iret
commandline_i:			; INT 96H, AH = 0
	 call commandline
	 iret
getinput_i:			; INT 96H, AH = 2
	 call getinput
	 iret

int96h:
	cmp ah, 00h
	je commandline_i
	cmp ah, 01h
	je not_implemented
	cmp ah, 02h
	je getinput_i
	iret

divzero db "Divide by zero detected",0
