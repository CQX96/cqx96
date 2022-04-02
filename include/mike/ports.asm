; PORTS.ASM
; For the CQX96 Kernel










os_port_byte_out:
	pusha

	out dx, al

	popa
	ret







os_port_byte_in:
	pusha

	in al, dx
	mov word [.tmp], ax

	popa
	mov ax, [.tmp]
	ret


	.tmp dw 0






os_serial_port_enable:
	pusha

	mov dx, 0			
	cmp ax, 1
	je .slow_mode

	mov ah, 0
	mov al, 11100011b		
	jmp .finish

.slow_mode:
	mov ah, 0
	mov al, 10000011b		

.finish:
	int 14h

	popa
	ret






os_send_via_serial:
	pusha

	mov ah, 01h
	mov dx, 0			

	int 14h

	mov [.tmp], ax

	popa

	mov ax, [.tmp]

	ret


	.tmp dw 0






os_get_via_serial:
	pusha

	mov ah, 02h
	mov dx, 0			

	int 14h

	mov [.tmp], ax

	popa

	mov ax, [.tmp]

	ret


	.tmp dw 0




