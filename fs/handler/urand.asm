urand_activate:
	call os_seed_random
	mov ax, 2
	mov bx, 128
	call os_get_random
	mov si, cx
	call printstring
	jmp urand_activate
urand_once:
	call os_seed_random
	mov ax, 2
	mov bx, 128
	call os_get_random
	mov si, cx
	call printstring
	jmp commandline