sbeep_activate:
	mov ax, 550
	call os_speaker_tone
	mov cl, 5
	call wait_ticks_again
	call os_speaker_off
	jmp sbeep_activate
sbeep_once:
	mov ax, 550
	call os_speaker_tone
	mov cl, 5
	call wait_ticks_again
	call os_speaker_off
	jmp commandline
	
wait_ticks_again:
	mov ch,0
.0:
	push cx
.1:
	mov ah,0x00
	int 0x1a
	cmp dx,[bp+0x00]
	je .1
	mov [bp+0x00],dx
	pop cx
	loop .0
	ret