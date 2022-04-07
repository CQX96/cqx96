panic:
push si
mov si, panicstr1
call printstring
pop si
call printstring
mov si, panicstr2
call printstring
jmp $

panicstr1 db 13,10,"Kernel Panic: ", 0
panicstr2 db 13,10,"System halted.", 0
