; PANIC.ASM
; For the CQX96 Kernel

; PANIC.ASM may only be ran if a fatal kernel error occurs.

%ifndef IGNORE_PANICS       ; Only enable IGNORE_PANICS when debugging

; PANIC
; SI = Panic reason message
panic:
    push si             ; Push the message to the stack
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
