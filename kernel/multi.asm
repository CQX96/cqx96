; Simple program to switch between two programs

; MULTI_ADDRESS equ 0xBFFF        ; Funny address to store the program in memory
; LOAD_ADDRESS equ 40960          ; Address to load the program to

; oldaddr dw 0
; oldoldaddr dw commandline   ; Location of the old program, this is the shell by default

; screenmem: times 2048 db 0										; This was a pain to implement...
; screenmemold: times 2048 db 0

multi_switch:
  ret         ; Does not work yet, but it will be used to switch between programs
              ; This needs to be looked at later





;   pusha
;   mov ax,0xb800
;   mov es,ax

;   mov si, MULTI_ADDRESS				; I am very happy that I got this to work
;   mov di, MULTI_ADDRESS+2001h
;   mov cx, 2000h
;   call os_string_copy_nal
  
;   mov si, LOAD_ADDRESS
;   mov di, MULTI_ADDRESS
;   mov cx, 2000h
;   call os_string_copy_nal
  
;   mov si, MULTI_ADDRESS+2001h
;   mov di, LOAD_ADDRESS
;   mov cx, 2000h
;   call os_string_copy_nal
  
; ;
; ;	switch video memory
; ;
;   xor bx, bx

;   mov si, screenmemold
;   mov di, screenmem
;   mov cx, 2048
;   call os_string_copy_nal

;   mov si, es:bx
;   mov di, screenmemold
;   mov cx, 2048
;   call os_string_copy_nal
  
;   mov si, screenmem
;   mov di, es:bx
;   mov cx, 2048
;   call os_string_copy_nal

;   ; Reset the segment registers
; 	mov ax, 2000h
; 	mov ds, ax
; 	mov es, ax
; 	mov fs, ax
; 	mov gs, ax

;   pop ax							; POP ax from the stack (the stack contains the address of old program)
;   mov bx, word [oldoldaddr]		; Swap some values
;   mov word [oldaddr], bx
;   mov word [oldoldaddr], ax
;   popa
;   jmp word [oldaddr]				; Jump to the new program
  
  

; ; os_string_copy_nal -- Copy one string into another until cx is zero
; ; IN/OUT: cx = amount, SI = source, DI = destination (programmer needs to check for sufficient room)
; os_string_copy_nal:
;   pusha
; .more:
;   dec cx
;   mov al, [si]                         ; Transfer contents (at least one byte terminator)
;   mov [di], al
;   inc si
;   inc di
;   cmp cx, 0                             ; If source string is empty, quit out
;   jne .more
; .done:
;   popa
;   ret
