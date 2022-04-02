; CMD.ASM
; For the CQX96 Kernel
	
cmd_ver:
	pusha
        call newline
 	mov si, version
	call printstring
	popa
	jmp commandline

cmd_rem:
	pusha
	cmp bx, 0
	je .error
	mov ax, bx
	call os_remove_file
	call newline
	mov si, removed
	call printstring
	popa
	jmp commandline

.error:
	mov si, no_ext
	call newline
	call printstring
	jmp commandline
	
cmd_display:
	cmp bx, 0
	je .interprete
	mov si, bx
	call newline
	call printstring
	
	cmp cx, 0
	je .quit
	
	mov si, space
	call printstring
	
	mov si, cx
	call printstring
	
	cmp dx, 0
	je .quit
	
	mov si, space
	call printstring
	
	mov si, dx
	call printstring
	
	jmp commandline
	
.interprete:
	call newline
	mov ax, input
	mov bx, 64
	call getinput
	mov si, input
	mov di, quit_cmd
	call stringcompare
	jc .quit
	call newline
	call printstring
	jmp .interprete
	
.quit:
	jmp commandline
	
cmd_quit:
	jmp commandline
	
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
	
	mov ax, usrfile
	mov bx, dx
	mov word cx, 32
	call os_write_file
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
	
cmd_make:
	cmp bx, 0
	je .fail
	mov ax, bx
	call os_create_file
	jmp .quit
	
.fail:
	mov si, no_ext
	call newline
	call printstring
	jmp .quit	
	
.quit:
	jmp commandline
	
cmd_dir:
	mov si, bx
	mov di, urand_cmd
	call stringcompare
	jc urand_activate
	mov di, urand1_cmd
	call stringcompare
	jc urand_once
	mov di, null_cmd
	call stringcompare
	jc null_activate
	mov di, null1_cmd
	call stringcompare
	jc null_once
	mov di, sbeep_cmd
	call stringcompare
	jc sbeep_activate
	mov di, sbeep1_cmd
	call stringcompare
	jc sbeep_once
	
	call newline
	mov cx,	0
	mov ax, dirlist
	call os_get_file_list

	mov si, dirlist

.set_column:

	mov ah, 0Eh	
.next_char:
	lodsb

	cmp al, ','
	je .next_filename

	cmp al, 0
	je .done

	int 10h
	jmp .next_char

.next_filename:
	call newline
	inc cx

	mov ax, cx
	and ax, 03h

	jmp .set_column

.done:
	jmp commandline

filesize dw 0000h
display_cmd db "display", 0
make_cmd db "make", 0
dir_cmd db "dir", 0
rem_cmd db "rem", 0
ver_cmd db "ver", 0
quit_cmd db "quit", 0
adduser_cmd db "adduser", 0
dirlist	times 1024 db 0
userfile times 32 db 0
no_ext db "No filename specified.", 0
removed db "Removed!", 0
critical db "Critical error.", 0
newusername db "New username: ", 0
newpassword db "New password: ", 0
urand_cmd db "./urand", 0
urand1_cmd db "./urand.1", 0
null_cmd db "./null", 0
null1_cmd db "./null.1", 0
sbeep_cmd db "./sbeep", 0
sbeep1_cmd db "./sbeep.1", 0
version db "0.03", 0
nonewslash db "You cannot create another SLASH user.", 0
created db "Created!", 0
usrfile times 13 db 0
usrext db ".USR", 0
input times 64 db 0