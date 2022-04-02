	bits 16				; tell nasm it is a 16-bit application
	%include "cqx.inc"	; include the SDK
	org 40960			; tell nasm the code starts at 40960
start:
	mov si, hello		; move the string hello (containing Hello, World) to SI
	call newline		; print a new line
	call printstring	; print the string in SI
	ret					; end of program
	hello db "Hello, World!"