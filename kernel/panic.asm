; PANIC.ASM
; For the CQX96 Kernel

; PANIC.ASM may only be ran if a fatal kernel error occurs.

%ifndef IGNORE_PANICS       ; Only enable IGNORE_PANICS when debugging

; PANIC
; SI = Panic reason message
panic:
    push si             ; Push the message to the stack

	mov ah,06h	; Clear screen to red
	mov al,00h
	mov bh,04fh
	mov ch,00d
	mov cl,00d
	mov dh,24d
	mov dl,79d
	int 10h
	
    ; Print panic message
    mov si, panicstr1
    call printstring
    pop si              ; Pop the message so we can use it
    call printstring
    mov si, panicstr2
    call printstring
jmp $

panicstr1 db 13,10,"Kernel Panic: ", 0
panicstr2 db 13,10,"System halted.", 0

%endif
