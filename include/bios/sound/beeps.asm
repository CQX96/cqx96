; BEEPS.ASM
; For the CQX96 Kernel

beep_start: 	; ax=freq
	pusha

	mov cx, ax

	mov al, 182
	out 43h, al
	mov ax, cx
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h
	or al, 03h
	out 61h, al

	popa
	ret
	
beep_stop:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret