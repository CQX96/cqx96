; MATH.ASM
; For the CQX96 Kernel










os_seed_random:
	push bx
	push ax

	mov bx, 0
	mov al, 0x02			
	out 0x70, al
	in al, 0x71

	mov bl, al
	shl bx, 8
	mov al, 0			
	out 0x70, al
	in al, 0x71
	mov bl, al

	mov word [os_random_seed], bx	
					
	pop ax
	pop bx
	ret


	os_random_seed	dw 0







os_get_random:
	push dx
	push bx
	push ax

	sub bx, ax			
	call .generate_random
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx

	pop ax
	pop bx
	pop dx
	add cx, ax			
	ret


.generate_random:
	push dx
	push bx

	mov ax, [os_random_seed]
	mov dx, 0x7383			
	mul dx				
	mov [os_random_seed], ax

	pop bx
 	pop dx
	ret






os_bcd_to_int:
	pusha

	mov bl, al			

	and ax, 0Fh			
	mov cx, ax			

	shr bl, 4			
	mov al, 10
	mul bl				

	add ax, cx			
	mov [.tmp], ax

	popa
	mov ax, [.tmp]			
	ret


	.tmp	dw 0






os_long_int_negate:
	neg ax
	adc dx, 0
	neg dx
	ret




