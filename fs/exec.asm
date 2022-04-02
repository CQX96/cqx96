; EXEC.ASM
; For the CQX96 Kernel







program_file:         ; ax = filename
	push ax
	mov bx, 0
	mov cx, 40960
	call os_load_file
	jc could_not_load
	pop ax
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	call 40960
	
	jmp commandline
	
could_not_load:
	pop ax
	mov si, ax
	call printstring
	mov si, errormsg_exec
	call printstring
	call newline
	
	jmp commandline
	

errormsg_exec db ": File not found, so cannot load!"	