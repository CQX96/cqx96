; CMD.ASM
; For the CQX96 Kernel
	
cmd_adduser:
	call newline
	mov si, newusername
	call printstring
	
	mov ax, input
	mov bx, 64
	call getinput
	
	mov ax, input
	
	cmp ax, slash
	je .error

	mov ax, input
	mov bx, usrext
	mov cx, usrfile
	call os_string_join
	
	call newline
	mov si, newpassword
	call printstring
	
	mov ax, input
	mov bx, 64
	call getinput
	
	mov ax, input
	call os_string_length
	push ax
	mov dx, input
%ifdef MD5_HASH
	pop cx
	mov si, input
	mov di, md5buffer
	call compute_md5
	
	mov ax, usrfile
	mov bx, md5buffer
	mov cx, 16
	call os_write_file
%else
	mov ax, usrfile
	mov bx, dx
	mov word cx, 32
	call os_write_file
%endif
	jmp commandline
	
.actual_fail:
	call newline
	mov si, critical
	call printstring
	jmp commandline
	
.error:
	call newline
	mov si, nonewslash
	call printstring
	jmp commandline
	
filesize dw 0000h
adduser_cmd db "adduser", 0
userfile times 32 db 0
no_ext db "No filename(s) specified.", 0
removed db "Removed!", 0
critical db "Critical error.", 0
newusername db "New username: ", 0
newpassword db "New password: ", 0
version db "0.04", 0
nonewslash db "You cannot create another SLASH user.", 0
created db "Created!", 0
usrfile times 13 db 0
usrext db ".USR", 0
input times 64 db 0
bootbackup db 0
