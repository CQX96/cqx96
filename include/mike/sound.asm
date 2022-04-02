; SOUND.ASM
; For the CQX96 Kernel


; Basically includes the same code as includes/bios/sound/beeps.asm.
; lol.







os_speaker_tone:
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






os_speaker_off:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret




