null_activate:
	mov si, nullchar
	call printstring
	jmp null_activate
null_once:
	mov si, nullchar
	call printstring
	jmp commandline
	
nullchar db 0