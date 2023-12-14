; DISK.ASM
; For the CQX96 Kernel










os_get_file_list:
	pusha

	mov word [.file_list_tmp], ax

	mov eax, 0			

	call disk_reset_floppy		

	mov ax, 19			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, si

	mov ah, 2			
	mov al, 14			

	pusha				


.read_root_dir:
	popa
	pusha

	stc
	int 13h				
	call disk_reset_floppy		
	jnc .show_dir_init		

	call disk_reset_floppy		
	jnc .read_root_dir
	jmp .done			

.show_dir_init:
	popa

	mov ax, 0
	mov si, disk_buff		

	mov word di, [.file_list_tmp]	


.start_entry:
	mov al, [si+11]			
	cmp al, 0Fh			
	je .skip

	test al, 18h			
	jnz .skip			

	mov al, [si]
	cmp al, 229			
	je .skip

	cmp al, 0			
	je .done


	mov cx, 1			
	mov dx, si
	
.testdirentry:
	inc si
	mov al, [si]			
	cmp al, ' '			
	jl .nxtdirentry
	cmp al, '~'
	ja .nxtdirentry
	cmp cx, 8
	je .checker
    jmp .skipchecker
.checker:
	cmp al, 'U'
	je .nxtdirentry
.skipchecker:
	inc cx
	cmp cx, 11			
	je .gotfilename
	jmp .testdirentry


.gotfilename:
	mov si, dx
	mov cx, 0
.loopy:
	mov byte al, [si]
	cmp al, ' '
	je .ignore_space
	mov byte [di], al
	inc si
	inc di
	inc cx
	cmp cx, 8
	je .add_dot
	cmp cx, 11
	je .done_copy
	jmp .loopy

.ignore_space:
	inc si
	inc cx
	cmp cx, 8
	je .add_dot
	jmp .loopy

.add_dot:
	mov byte [di], '.'
	inc di
	jmp .loopy

.done_copy:
	mov byte [di], ','		
	inc di

.nxtdirentry:
	mov si, dx			

.skip:
	add si, 32			
	jmp .start_entry


.done:
	dec di
	mov byte [di], 0		

	popa
	ret


	.file_list_tmp		dw 0







os_load_file:
	call os_string_uppercase
	call int_filename_convert

	mov [.filename_loc], ax		
	mov [.load_position], cx	

	mov eax, 0			

	call disk_reset_floppy		
	jnc .floppy_ok			

	mov si, .err_msg_floppy_reset	
%ifndef IGNORE_PANICS
	jmp panic
%endif
	ret


.floppy_ok:				
	mov ax, 19			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, si

	mov ah, 2			
	mov al, 14			

	pusha				


.read_root_dir:
	popa
	pusha

	stc				
	int 13h				
	jnc .search_root_dir		

	call disk_reset_floppy		
	jnc .read_root_dir

	popa
	jmp .root_problem		

.search_root_dir:
	popa

	mov cx, word 224		
	mov bx, -32			

.next_root_entry:
	add bx, 32			
	mov di, disk_buff		
	add di, bx

	mov al, [di]			

	cmp al, 0			
	je .root_problem

	cmp al, 229			
	je .next_root_entry		

	mov al, [di+11]			

	cmp al, 0Fh			
	je .next_root_entry

	test al, 18h			
	jnz .next_root_entry

	mov byte [di+11], 0		

	mov ax, di			
	call os_string_uppercase

	mov si, [.filename_loc]		

	call os_string_compare		
	jc .found_file_to_load

	loop .next_root_entry

.root_problem:
	mov bx, 0			
	stc				
	ret


.found_file_to_load:			
	mov ax, [di+28]			
	mov word [.file_size], ax

	cmp ax, 0			
	je .end				

	mov ax, [di+26]			
	mov word [.cluster], ax

	mov ax, 1			
	call disk_convert_l2hts

	mov di, disk_buff		
	mov bx, di

	mov ah, 2			
	mov al, 9			

	pusha

.read_fat:
	popa				
	pusha

	stc
	int 13h
	jnc .read_fat_ok

	call disk_reset_floppy
	jnc .read_fat

	popa
	jmp .root_problem


.read_fat_ok:
	popa


.load_file_sector:
	mov ax, word [.cluster]		
	add ax, 31

	call disk_convert_l2hts		

	mov bx, [.load_position]


	mov ah, 02			
	mov al, 01

	stc
	int 13h
	jnc .calculate_next_cluster	

	call disk_reset_floppy		
	jnc .load_file_sector

	mov si, .err_msg_floppy_reset	
%ifndef IGNORE_PANICS
	jmp panic
%endif
	ret


.calculate_next_cluster:
	mov ax, [.cluster]
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				
	mov si, disk_buff		
	add si, ax
	mov ax, word [ds:si]

	or dx, dx			

	jz .even			
					

.odd:
	shr ax, 4			
	jmp .calculate_cluster_cont	

.even:
	and ax, 0FFFh			

.calculate_cluster_cont:
	mov word [.cluster], ax		

	cmp ax, 0FF8h
	jae .end

	add word [.load_position], 512
	jmp .load_file_sector		


.end:
	mov bx, [.file_size]		
	clc				
	ret


	.bootd		db 0 		
	.cluster	dw 0 		
	.pointer	dw 0 		

	.filename_loc	dw 0		
	.load_position	dw 0		
	.file_size	dw 0		

	.string_buff	times 12 db 0	

	.err_msg_floppy_reset	db 'Disk failed to reset', 0







os_write_file:
	pusha

	mov si, ax
	call os_string_length
	cmp ax, 0
	je near .failure
	mov ax, si

	call os_string_uppercase
	call int_filename_convert	
	jc near .failure

	mov word [.filesize], cx
	mov word [.location], bx
	mov word [.filename], ax

	call os_file_exists		
	jnc near .failure


	
	pusha

	mov di, .free_clusters
	mov cx, 128
.clean_free_loop:
	mov word [di], 0
	inc di
	inc di
	loop .clean_free_loop

	popa


	

	mov ax, cx
	mov dx, 0
	mov bx, 512			
	div bx
	cmp dx, 0
	jg .add_a_bit			
	jmp .carry_on

.add_a_bit:
	add ax, 1
.carry_on:

	mov word [.clusters_needed], ax

	mov word ax, [.filename]	

	call os_create_file		
	jc near .failure		

	mov word bx, [.filesize]
	cmp bx, 0
	je near .finished

	call disk_read_fat		
	mov si, disk_buff + 3		

	mov bx, 2			
	mov word cx, [.clusters_needed]
	mov dx, 0			

.find_free_cluster:
	lodsw				
	and ax, 0FFFh			
	jz .found_free_even		

.more_odd:
	inc bx				
	dec si				

	lodsw				
	shr ax, 4			
	or ax, ax			
	jz .found_free_odd

.more_even:
	inc bx				
	jmp .find_free_cluster


.found_free_even:
	push si
	mov si, .free_clusters		
	add si, dx
	mov word [si], bx
	pop si

	dec cx				
	cmp cx, 0
	je .finished_list

	inc dx				
	inc dx
	jmp .more_odd

.found_free_odd:
	push si
	mov si, .free_clusters		
	add si, dx
	mov word [si], bx
	pop si

	dec cx
	cmp cx, 0
	je .finished_list

	inc dx				
	inc dx
	jmp .more_even



.finished_list:

	
	
	

	mov cx, 0			
	mov word [.count], 1		

.chain_loop:
	mov word ax, [.count]		
	cmp word ax, [.clusters_needed]
	je .last_cluster

	mov di, .free_clusters

	add di, cx
	mov word bx, [di]		

	mov ax, bx			
	mov dx, 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				
	mov si, disk_buff
	add si, ax			
	mov ax, word [ds:si]

	or dx, dx			
	jz .even

.odd:
	and ax, 000Fh			
	mov di, .free_clusters
	add di, cx			
	mov word bx, [di+2]		
	shl bx, 4			
	add ax, bx

	mov word [ds:si], ax		

	inc word [.count]
	inc cx				
	inc cx

	jmp .chain_loop

.even:
	and ax, 0F000h			
	mov di, .free_clusters
	add di, cx			
	mov word bx, [di+2]		

	add ax, bx

	mov word [ds:si], ax		

	inc word [.count]
	inc cx				
	inc cx

	jmp .chain_loop



.last_cluster:
	mov di, .free_clusters
	add di, cx
	mov word bx, [di]		

	mov ax, bx

	mov dx, 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				
	mov si, disk_buff
	add si, ax			
	mov ax, word [ds:si]

	or dx, dx			
	jz .even_last

.odd_last:
	and ax, 000Fh			
	add ax, 0FF80h
	jmp .finito

.even_last:
	and ax, 0F000h			
	add ax, 0FF8h


.finito:
	mov word [ds:si], ax

	call disk_write_fat		


	

	mov cx, 0

.save_loop:
	mov di, .free_clusters
	add di, cx
	mov word ax, [di]

	cmp ax, 0
	je near .write_root_entry

	pusha

	add ax, 31

	call disk_convert_l2hts

	mov word bx, [.location]

	mov ah, 3
	mov al, 1
	stc
	int 13h

	popa

	add word [.location], 512
	inc cx
	inc cx
	jmp .save_loop


.write_root_entry:

	
	

	call disk_read_root_dir

	mov word ax, [.filename]
	call disk_get_root_entry

	mov word ax, [.free_clusters]	

	mov word [di+26], ax		

	mov word cx, [.filesize]
	mov word [di+28], cx

	mov byte [di+30], 0		
	mov byte [di+31], 0

	call disk_write_root_dir

.finished:
	popa
	clc
	ret

.failure:
	popa
	stc				
	ret


	.filesize	dw 0
	.cluster	dw 0
	.count		dw 0
	.location	dw 0

	.clusters_needed	dw 0

	.filename	dw 0

	.free_clusters	times 128 dw 0






os_file_exists:
	call os_string_uppercase
	call int_filename_convert	

	push ax
	call os_string_length
	cmp ax, 0
	je .failure
	pop ax

	push ax
	call disk_read_root_dir

	pop ax				

	mov di, disk_buff

	call disk_get_root_entry	

	ret

.failure:
	pop ax
	stc
	ret






os_create_file:
	clc

	call os_string_uppercase
	call int_filename_convert	
	pusha

	push ax				

	call os_file_exists		
	jnc .exists_error


	

	mov di, disk_buff		


	mov cx, 224			
.next_entry:
	mov byte al, [di]
	cmp al, 0			
	je .found_free_entry
	cmp al, 0E5h			
	je .found_free_entry
	add di, 32			
	loop .next_entry

.exists_error:				
	pop ax				

	popa
	stc				
	ret


.found_free_entry:
	pop si				
	mov cx, 11
	rep movsb			


	sub di, 11			


	mov byte [di+11], 0		
	mov byte [di+12], 0		
	mov byte [di+13], 0		
	mov byte [di+14], 0C6h		
	mov byte [di+15], 07Eh		
	mov byte [di+16], 0		
	mov byte [di+17], 0		
	mov byte [di+18], 0		
	mov byte [di+19], 0		
	mov byte [di+20], 0		
	mov byte [di+21], 0		
	mov byte [di+22], 0C6h		
	mov byte [di+23], 07Eh		
	mov byte [di+24], 0		
	mov byte [di+25], 0		
	mov byte [di+26], 0		
	mov byte [di+27], 0		
	mov byte [di+28], 0		
	mov byte [di+29], 0		
	mov byte [di+30], 0		
	mov byte [di+31], 0		

	call disk_write_root_dir
	jc .failure

	popa
	clc				
	ret

.failure:
	popa
	stc
	ret






os_remove_file:
	pusha
	call os_string_uppercase
	call int_filename_convert	
	push ax				

	clc

	call disk_read_root_dir		

	mov di, disk_buff		

	pop ax				

	call disk_get_root_entry	
	jc .failure			


	mov ax, word [es:di+26]		
	mov word [.cluster], ax		

	mov byte [di], 0E5h		

	inc di

	mov cx, 0			
.clean_loop:
	mov byte [di], 0
	inc di
	inc cx
	cmp cx, 31			
	jl .clean_loop

	call disk_write_root_dir	


	call disk_read_fat		
	mov di, disk_buff		


.more_clusters:
	mov word ax, [.cluster]		

	cmp ax, 0			
	je .nothing_to_do

	mov bx, 3			
	mul bx
	mov bx, 2
	div bx				
	mov si, disk_buff		
	add si, ax
	mov ax, word [ds:si]

	or dx, dx			

	jz .even			
					
.odd:
	push ax
	and ax, 000Fh			
	mov word [ds:si], ax
	pop ax

	shr ax, 4			
	jmp .calculate_cluster_cont	

.even:
	push ax
	and ax, 0F000h			
	mov word [ds:si], ax
	pop ax

	and ax, 0FFFh			

.calculate_cluster_cont:
	mov word [.cluster], ax		

	cmp ax, 0FF8h			
	jae .end

	jmp .more_clusters		

.end:
	call disk_write_fat
	jc .failure

.nothing_to_do:
	popa
	clc
	ret

.failure:
	popa
	stc
	ret


	.cluster dw 0







os_rename_file:
	push bx
	push ax

	clc

	call disk_read_root_dir		

	mov di, disk_buff		

	pop ax				

	call os_string_uppercase
	call int_filename_convert

	call disk_get_root_entry	
	jc .fail_read			

	pop bx				

	mov ax, bx

	call os_string_uppercase
	call int_filename_convert

	mov si, ax

	mov cx, 11			
	rep movsb

	call disk_write_root_dir	
	jc .fail_write

	clc
	ret

.fail_read:
	pop ax
	stc
	ret

.fail_write:
	stc
	ret







os_get_file_size:
	pusha

	call os_string_uppercase
	call int_filename_convert

	clc

	push ax

	call disk_read_root_dir
	jc .failure

	pop ax

	mov di, disk_buff

	call disk_get_root_entry
	jc .failure

	mov word bx, [di+28]

	mov word [.tmp], bx

	popa

	mov word bx, [.tmp]

	ret

.failure:
	popa
	stc
	ret


	.tmp	dw 0










int_filename_convert:
	pusha

	mov si, ax

	call os_string_length
	cmp ax, 14			
	jg .failure			

	cmp ax, 0
	je .failure			

	mov dx, ax			

	mov di, .dest_string

	mov cx, 0
.copy_loop:
	lodsb
	cmp al, '.'
	je .extension_found
	stosb
	inc cx
	cmp cx, dx
	jg .failure			
	jmp .copy_loop

.extension_found:
	cmp cx, 0
	je .failure			

	cmp cx, 8
	je .do_extension		

	
	

.add_spaces:
	mov byte [di], ' '
	inc di
	inc cx
	cmp cx, 8
	jl .add_spaces

	
.do_extension:
	lodsb				
	cmp al, 0
	je .failure
	stosb
	lodsb
	cmp al, 0
	je .failure
	stosb
	lodsb
	cmp al, 0
	je .failure
	stosb

	mov byte [di], 0		

	popa
	mov ax, .dest_string
	clc				
	ret


.failure:
	popa
	stc				
	ret


	.dest_string	times 13 db 0







disk_get_root_entry:
	pusha

	mov word [.filename], ax

	mov cx, 224			
	mov ax, 0			

.to_next_root_entry:
	xchg cx, dx			

	mov word si, [.filename]	
	mov cx, 11
	rep cmpsb
	je .found_file			

	add ax, 32			

	mov di, disk_buff		
	add di, ax

	xchg dx, cx			
	loop .to_next_root_entry

	popa

	stc				
	ret


.found_file:
	sub di, 11			

	mov word [.tmp], di		

	popa

	mov word di, [.tmp]

	clc
	ret


	.filename	dw 0
	.tmp		dw 0






disk_read_fat:
	pusha

	mov ax, 1			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, 2000h
	mov es, bx
	mov bx, si

	mov ah, 2			
	mov al, 9			

	pusha				


.read_fat_loop:
	popa
	pusha

	stc				
	int 13h				

	jnc .fat_done
	call disk_reset_floppy		
	jnc .read_fat_loop		

	popa
	jmp .read_failure		

.fat_done:
	popa				

	popa				
	clc
	ret

.read_failure:
	popa
	stc				
	ret






disk_write_fat:
	pusha

	mov ax, 1			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, ds
	mov es, bx
	mov bx, si

	mov ah, 3			
	mov al, 9			

	stc				
	int 13h				

	jc .write_failure		

	popa				
	clc
	ret

.write_failure:
	popa
	stc				
	ret






disk_read_root_dir:
	pusha

	mov ax, 19			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, ds
	mov es, bx
	mov bx, si

	mov ah, 2			
	mov al, 14			

	pusha				


.read_root_dir_loop:
	popa
	pusha

	stc				
	int 13h				

	jnc .root_dir_finished
	call disk_reset_floppy		
	jnc .read_root_dir_loop		

	popa
	jmp .read_failure		


.root_dir_finished:
	popa				

	popa				
	clc				
	ret

.read_failure:
	popa
	stc				
	ret






disk_write_root_dir:
	pusha

	mov ax, 19			
	call disk_convert_l2hts

	mov si, disk_buff		
	mov bx, ds
	mov es, bx
	mov bx, si

	mov ah, 3			
	mov al, 14			

	stc				
	int 13h				
	jc .write_failure

	popa				
	clc
	ret

.write_failure:
	popa
	stc				
	ret





disk_reset_floppy:
	push ax
	push dx
	mov ax, 0

	mov dl, [bootdev]

	stc
	int 13h
	pop dx
	pop ax
	ret


change_device:		; note: AX = New device ID
	mov si, ax
	call os_string_to_int
	mov [bootdev], ax
	ret
	
get_device:		; out: SI = device ID/Number
	mov si, [bootdev]
	ret


disk_convert_l2hts:
	push bx
	push ax

	mov bx, ax			

	mov dx, 0			
	div word [SecsPerTrack]		
	add dl, 01h			
	mov cl, dl			
	mov ax, bx

	mov dx, 0			
	div word [SecsPerTrack]		
	mov dx, 0
	div word [Sides]		
	mov dh, dl			
	mov ch, al			

	pop ax
	pop bx


	mov dl, [bootdev]		


	ret


	Sides dw 2
	SecsPerTrack dw 18

	bootdev db 0			






