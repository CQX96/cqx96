; MAIN.ASM
; For the CQX96 Kernel

; It is the kernel.

jmp cqx                   ;0000h   [bootloader]
jmp printstring           ;0003h
jmp commandline           ;0006h
jmp newline               ;0009h
jmp os_create_file        ;000Ch
jmp os_remove_file        ;000Fh
jmp getinput              ;0012h
jmp os_write_file         ;0015h
jmp os_load_file          ;0018h
jmp os_string_chomp       ;001Bh
jmp os_int_to_string      ;001Eh
jmp os_load_file          ;0021h
jmp os_string_copy        ;0024h
jmp os_string_tokenize    ;0027h
jmp os_string_length      ;002Ah
jmp os_print_2hex         ;002Dh
jmp os_print_4hex         ;0030h
jmp os_string_compare     ;0033h
jmp os_string_to_int      ;0036h
jmp os_get_file_size      ;0039h
jmp program_file          ;003Ch
jmp login		  ;003Fh [for logout command(?)]
jmp get_username	  ;0042h
jmp os_string_uppercase   ;0045h
disk_buff	equ	24576
cqx:
	cli
	mov ax, 0
	mov ss, ax
	mov sp, 0FFFFh
	sti

	cld

	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	cmp dl, 0
	je no_change
	mov [bootdev], dl
	push es
	mov ah, 8
	int 13h
	pop es
	and cx, 3Fh
	mov [SecsPerTrack], cx
	movzx dx, dh
	add dx, 1
	mov [Sides], dx
	
no_change:
	mov ax, sysload_dmn
	call load_daemon
	mov ax, filesys_dmn
	call load_daemon
	mov ax, login_dmn
	call load_daemon
	call newline
	mov si, reachedlogin
	call printstring
	call newline
	mov cl, 9
	call wait_ticks_again
	
	mov ah,06h	; Clear screen.
	mov al,00h
	mov bh,07h
	mov ch,00d
	mov cl,00d
	mov dh,24d
	mov dl,79d
	int 10h
	
	mov ah,02h	; move cursor Instruction.
	mov bh,00h
	mov dh,1d
	mov dl,0d
	int 10h
	
	mov si, space
	call printstring	
	call newline
	mov si, welcome
	call printstring
login:	
	call newline
	mov si, loginprompt
	call printstring
	mov ax, loggedinuser
	mov bx, 8
	call getinput
	mov ax, loggedinuser
	mov si, ax
	mov di, slash
	call stringcompare
	jc slashuser
	mov ax, loggedinuser
	mov bx, usrext
	mov cx, usrfile
	call os_string_join
	mov ax, usrfile
	mov bx, 0
	mov cx, 32768
	call os_load_file
	jc .nosuchuser
	call newline
	mov si, passprompt
	call printstring
	mov ax, input
	mov bx, 32
	call getinput
	mov ax, input
	call os_string_chomp
	mov si, ax
	mov di, 32768
	call stringcompare
	jc commandline
	jmp .incorrect
	
.incorrect:
	call newline
	mov si, incorrectpass
	call printstring
	jmp login
	
.nosuchuser:
	call newline
	mov si, nosuchuser
	call printstring
	jmp login
	
slashuser:
	mov byte [isslash], 1
	jmp slasher
	
commandline:	
	mov ax, shellname
	mov bx, 0
	mov cx, 28200
	call os_load_file
	jc shellfail

	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	jmp 28200

get_username:
	mov si, loggedinuser
	ret
	
slasher:
	cmp byte [isslash], 0
	je commandline
	call newline
	mov si, openbracket
	call printstring
	mov ax, loggedinuser
	call os_string_uppercase
	mov si, ax
	call printstring
	mov si, closebracket
	call printstring
	mov si, delim
	call printstring
	mov ax, input
	mov bx, 64
	call getinput
	mov ax, input
	call os_string_chomp
	mov si, ax
	call split
	mov si, ax
	mov di, adduser_cmd
	call stringcompare
	jc cmd_adduser
	
	call newline
	mov si, slasherror
	call printstring
	
	jmp slasher

adduser_cmd db "adduser", 0
newusername db "New username: ", 0
newpassword db "New password: ", 0
nonewslash  db "You cannot create another SLASH user.", 0
critical db "Critical error.", 0

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
	jmp slasher
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

load_daemon:     ; in=ax=daemon name, out=ax=success(0)||fail(1)
	push ax
	call newline
    mov si, successms
	call printstring
	pop ax
    mov si, ax
	call printstring
	
	call os_seed_random             ; "Fake" loading. Why? so that the user can actually
	                                ; read the text.
	mov ax, 3
	mov bx, 12
	call os_get_random
	mov [rngo], cx
	mov cl, [rngo]
	call wait_ticks_again
	
	mov ax, 0
	
	ret

shellfail:
	mov si, noshellfound
	jmp panic
	
fail:
	mov ax, input
	mov bx, prg_extension
	mov cx, input
	call os_string_join
	mov ax, input
	mov bx, 0
	mov cx, 40960
	call os_load_file
	jc actual_fail
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0
	call 40960
	jmp commandline
	
actual_fail:
	mov si, badcmd
	call newline
	call printstring
	jmp commandline
	
program_file:
	mov bx, 0
	mov cx, 40960
	call os_load_file
	jc fail

	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	call 40960
	
	jmp commandline
	
printcharacter:	
	mov ah, 0x0e	
	mov bh, 0x00	
	mov bl, 0x07	
	int 0x10	
	ret	
	
printstring:
next_character:	
	mov al, [si]	
	inc si		
	or al, al	
	jz exit_function 
	call printcharacter 
	jmp next_character	
	
exit_function:	
	ret
	
newline:
	pusha
	mov ah, 0x0e
	mov al, 0x0a
	int 10h
	mov al, 0x0d
	int 10h
	popa
	ret

; =============MikeOS=============

os_print_1hex:
	pusha

	and ax, 0Fh
	call os_print_digit

	popa
	ret

os_print_2hex:
	pusha

	push ax
	shr ax, 4
	call os_print_1hex

	pop ax
	call os_print_1hex

	popa
	ret

os_print_4hex:
	pusha

	push ax
	mov al, ah
	call os_print_2hex

	pop ax	
	call os_print_2hex

	popa
	ret

os_print_digit:
	pusha

	cmp ax, 9
	jle .digit_format

	add ax, 'A'-'9'-1

.digit_format:
	add ax, '0'

	mov ah, 0Eh
	int 10h

	popa
	ret
; ================================

reachedlogin  db "[SUCCESS!] Reached target: Login", 0
sysload_dmn   db "Starting system daemon",0
filesys_dmn   db "Starting filesystem daemon",0
login_dmn     db "Starting login-data daemon",0
%include "../include/tools/input.asm"
fn            db '            ',0
%include "../include/tools/string.asm"
%include "../include/mike/disk.asm"
%include "../include/mike/keyboard.asm"
%include "../include/mike/math.asm"
%include "../include/mike/ports.asm"
%include "../include/mike/sound.asm"
slash         db '/',0
loggedinuser  times 10 db 0
%include "../include/mike/string.asm"
isslash       db 0
welcome       db 'Welcome to CQX96!', 0
badcmd        db 'Unknown command or filename.', 0
delim         db ':', 0
prg_extension db '.PRG', 0
incorrectpass db 'Incorrect password,',0
noshellfound  db 'No shell found!',0
nosuchuser    db 'That is not a user on this system!',0
space         db ' ', 0
loginprompt   db 'CQX96 username (Log in as / if you are a new user): ',13,10,0
slasherror    db 'The SLASH user may only create another user (adduser command).',0
passprompt    db 'Password: ',0
successms     db '[SUCCESS!] ',0
failms        db '[FAIL!] ',0
openbracket   db "[",0
closebracket  db "]",0
rngo          db 0
noting        db 0
ver           equ "0.04"
shellname     db "MAIN.SHL", 0
input 		  times 64 db 0
usrfile 	  times 13 db 0
usrext		  db ".USR", 0
%include "../fs/handler/urand.asm"
%include "../fs/handler/null.asm"
%include "../fs/handler/sbeep.asm"
%include "../kernel/panic.asm"
%include "../kernel/includes/ini.asm"
