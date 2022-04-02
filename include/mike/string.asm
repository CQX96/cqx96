; STRING.ASM
; For the CQX96 Kernel













os_string_reverse:
	pusha

	cmp byte [si], 0		
	je .end

	mov ax, si
	call os_string_length

	mov di, si
	add di, ax
	dec di				

.loop:
	mov byte al, [si]		
	mov byte bl, [di]

	mov byte [si], bl
	mov byte [di], al

	inc si				
	dec di

	cmp di, si			
	ja .loop

.end:
	popa
	ret







os_find_char_in_string:
	pusha

	mov cx, 1			
					
					

.more:
	cmp byte [si], al
	je .done
	cmp byte [si], 0
	je .notfound
	inc si
	inc cx
	jmp .more

.done:
	mov [.tmp], cx
	popa
	mov ax, [.tmp]
	ret

.notfound:
	popa
	mov ax, 0
	ret


	.tmp	dw 0






os_string_charchange:
	pusha

	mov cl, al

.loop:
	mov byte al, [si]
	cmp al, 0
	je .finish
	cmp al, cl
	jne .nochange

	mov byte [si], bl

.nochange:
	inc si
	jmp .loop

.finish:
	popa
	ret






os_string_uppercase:
	pusha

	mov si, ax			

.more:
	cmp byte [si], 0		
	je .done			

	cmp byte [si], 'a'		
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 20h		

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret






os_string_lowercase:
	pusha

	mov si, ax			

.more:
	cmp byte [si], 0		
	je .done			

	cmp byte [si], 'A'		
	jb .noatoz
	cmp byte [si], 'Z'
	ja .noatoz

	add byte [si], 20h		

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret






os_string_copy:
	pusha

.more:
	mov al, [si]			
	mov [di], al
	inc si
	inc di
	cmp byte al, 0			
	jne .more

.done:
	popa
	ret







os_string_truncate:
	pusha

	add si, ax
	mov byte [si], 0

	popa
	ret






os_string_join:
	pusha

	mov si, ax			
	mov di, cx
	call os_string_copy

	call os_string_length		

	add cx, ax			

	mov si, bx			
	mov di, cx
	call os_string_copy

	popa
	ret






os_string_chomp:
	pusha

	mov dx, ax			

	mov di, ax			
	mov cx, 0			

.keepcounting:				
	cmp byte [di], ' '
	jne .counted
	inc cx
	inc di
	jmp .keepcounting

.counted:
	cmp cx, 0			
	je .finished_copy

	mov si, di			
	mov di, dx			

.keep_copying:
	mov al, [si]			
	mov [di], al			
	cmp al, 0
	je .finished_copy
	inc si
	inc di
	jmp .keep_copying

.finished_copy:
	mov ax, dx			

	call os_string_length
	cmp ax, 0			
	je .done

	mov si, dx
	add si, ax			

.more:
	dec si
	cmp byte [si], ' '
	jne .done
	mov byte [si], 0		
	jmp .more			

.done:
	popa
	ret






os_string_strip:
	pusha

	mov di, si

	mov bl, al			
.nextchar:
	lodsb
	stosb
	cmp al, 0			
	je .finish			
	cmp al, bl			
	jne .nextchar			

.skip:					
	dec di				
	jmp .nextchar

.finish:
	popa
	ret






os_string_compare:
	pusha

.more:
	mov al, [si]			
	mov bl, [di]

	cmp al, bl			
	jne .not_same

	cmp al, 0			
	je .terminated

	inc si
	inc di
	jmp .more


.not_same:				
	popa				
	clc				
	ret


.terminated:				
	popa
	stc				
	ret







os_string_strincmp:
	pusha

.more:
	mov al, [si]			
	mov bl, [di]

	cmp al, bl			
	jne .not_same

	cmp al, 0			
	je .terminated

	inc si
	inc di

	dec cl				
	cmp cl, 0			
	je .terminated

	jmp .more


.not_same:				
	popa				
	clc				
	ret


.terminated:				
	popa
	stc				
	ret







os_string_parse:
	push si

	mov ax, si			

	mov bx, 0			
	mov cx, 0
	mov dx, 0

	push ax				

.loop1:
	lodsb				
	cmp al, 0			
	je .finish
	cmp al, ' '			
	jne .loop1
	dec si
	mov byte [si], 0		

	inc si				
	mov bx, si

.loop2:					
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loop3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	pop ax

	pop si
	ret







os_string_to_int:
	pusha

	mov ax, si			
	call os_string_length

	add si, ax			
	dec si

	mov cx, ax			

	mov bx, 0			
	mov ax, 0


	
	
	
	

	mov word [.multiplier], 1	

.loop:
	mov ax, 0
	mov byte al, [si]		
	sub al, 48			

	mul word [.multiplier]		

	add bx, ax			

	push ax				
	mov word ax, [.multiplier]
	mov dx, 10
	mul dx
	mov word [.multiplier], ax
	pop ax

	dec cx				
	cmp cx, 0
	je .finish
	dec si				
	jmp .loop

.finish:
	mov word [.tmp], bx
	popa
	mov word ax, [.tmp]

	ret


	.multiplier	dw 0
	.tmp		dw 0







os_int_to_string:
	pusha

	mov cx, 0
	mov bx, 10			
	mov di, .t			

.push:
	mov dx, 0
	div bx				
	inc cx				
	push dx				
	test ax, ax			
	jnz .push			
.pop:
	pop dx				
	add dl, '0'			
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		

	popa
	mov ax, .t			
	ret


	.t times 7 db 0







os_sint_to_string:
	pusha

	mov cx, 0
	mov bx, 10			
	mov di, .t			

	test ax, ax			
	js .neg				
	jmp .push			
.neg:
	neg ax				
	mov byte [.t], '-'		
	inc di				
.push:
	mov dx, 0
	div bx				
	inc cx				
	push dx				
	test ax, ax			
	jnz .push			
.pop:
	pop dx				
	add dl, '0'			
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		

	popa
	mov ax, .t			
	ret


	.t times 7 db 0







os_long_int_to_string:
	pusha

	mov si, di			

	mov word [di], 0		

	cmp bx, 37			
	ja .done

	cmp bx, 0			
	je .done

.conversion_loop:
	mov cx, 0			
					

	xchg ax, cx			
	xchg ax, dx
	div bx				

	xchg ax, cx			
	div bx				
	xchg cx, dx			

.save_digit:
	cmp cx, 9			
	jle .convert_digit

	add cx, 'A'-'9'-1

.convert_digit:
	add cx, '0'			

	push ax				
	push bx
	mov ax, si
	call os_string_length		
	mov di, si
	add di, ax			
	inc ax				

.move_string_up:
	mov bl, [di]			
	mov [di+1], bl
	dec di
	dec ax
	jnz .move_string_up

	pop bx
	pop ax
	mov [si], cl			

.test_end:
	mov cx, dx			
	or cx, ax			
	jnz .conversion_loop

.done:
	popa
	ret






os_set_time_fmt:
	pusha
	cmp al, 0
	je .store
	mov al, 0FFh
.store:

	popa
	ret






os_get_time_string:
	pusha

	mov di, bx			

	clc				
	mov ah, 2			
	int 1Ah
	jnc .read

	clc
	mov ah, 2			
	int 1Ah

.read:
	mov al, ch			
	call os_bcd_to_int
	mov dx, ax			

	mov al,	ch			
	shr al, 4			
	and ch, 0Fh			

	jz .twelve_hr

	call .add_digit			
	mov al, ch
	call .add_digit
	jmp short .minutes

.twelve_hr:
	cmp dx, 0			
	je .midnight

	cmp dx, 10			
	jl .twelve_st1

	cmp dx, 12			
	jle .twelve_st2

	mov ax, dx			
	sub ax, 12
	mov bl, 10
	div bl
	mov ch, ah

	cmp al, 0			
	je .twelve_st1

	jmp short .twelve_st2		

.midnight:
	mov al, 1
	mov ch, 2

.twelve_st2:
	call .add_digit			
.twelve_st1:
	mov al, ch
	call .add_digit

	mov al, ':'			
	stosb

.minutes:
	mov al, cl			
	shr al, 4			
	and cl, 0Fh			
	call .add_digit
	mov al, cl
	call .add_digit

	mov al, ' '			
	stosb

	mov si, .hours_string		

	jnz .copy

	mov si, .pm_string		
	cmp dx, 12			
	jg .copy

	mov si, .am_string		

.copy:
	lodsb				
	stosb
	cmp al, 0
	jne .copy

	popa
	ret


.add_digit:
	add al, '0'			
	stosb				
	ret


	.hours_string	db 'hours', 0
	.am_string 	db 'AM', 0
	.pm_string 	db 'PM', 0








.try_fmt1:
	cmp bl, 1			
	jne .do_fmt0

	mov ah, dl			
	call .add_1or2digits

	mov al, bh
	cmp bh, 0
	jne .fmt1_day

	mov al, ' '			

.fmt1_day:
	stosb				

	mov ah,	dh			
	cmp bh, 0			
	jne .fmt1_month

	call .add_month			
	mov ax, ', '
	stosw
	jmp short .fmt1_century

.fmt1_month:
	call .add_1or2digits		
	mov al, bh
	stosb

.fmt1_century:
	mov ah,	ch			
	cmp ah, 0
	je .fmt1_year

	call .add_1or2digits		

.fmt1_year:
	mov ah, cl			
	call .add_2digits		

	jmp .done

.do_fmt0:				
	mov ah,	dh			
	cmp bh, 0			
	jne .fmt0_month

	call .add_month			
	mov al, ' '
	stosb
	jmp short .fmt0_day

.fmt0_month:
	call .add_1or2digits		
	mov al, bh
	stosb

.fmt0_day:
	mov ah, dl			
	call .add_1or2digits

	mov al, bh
	cmp bh, 0			
	jne .fmt0_day2

	mov al, ','			
	stosb
	mov al, ' '

.fmt0_day2:
	stosb

.fmt0_century:
	mov ah,	ch			
	cmp ah, 0
	je .fmt0_year

	call .add_1or2digits		

.fmt0_year:
	mov ah, cl			
	call .add_2digits		


.done:
	mov ax, 0			
	stosw

	popa
	ret


.add_1or2digits:
	test ah, 0F0h
	jz .only_one
	call .add_2digits
	jmp short .two_done
.only_one:
	mov al, ah
	and al, 0Fh
	call .add_digit
.two_done:
	ret

.add_2digits:
	mov al, ah			
	shr al, 4
	call .add_digit
	mov al, ah
	and al, 0Fh
	call .add_digit
	ret


.add_month:
	push bx
	push cx
	mov al, ah			
	call os_bcd_to_int
	dec al				
	mov bl, 4			
	mul bl
	mov si, .months
	add si, ax
	mov cx, 4
	rep movsb
	cmp byte [di-1], ' '		
	jne .done_month			
	dec di
.done_month:
	pop cx
	pop bx
	ret


	.months db 'Jan.Feb.Mar.Apr.May JuneJulyAug.SeptOct.Nov.Dec.'







os_string_tokenize:
	push si

.next_char:
	cmp byte [si], al
	je .return_token
	cmp byte [si], 0
	jz .no_more
	inc si
	jmp .next_char

.return_token:
	mov byte [si], 0
	inc si
	mov di, si
	pop si
	ret

.no_more:
	mov di, 0
	pop si
	ret




