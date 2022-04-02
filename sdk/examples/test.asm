bits 16
%include "cqx.inc"
org 40960
start:
mov ax, input
mov bx, 64
call getinput
mov ax, input
call stripspaces
mov si, ax
call printstring
ret
input times 64 db 0