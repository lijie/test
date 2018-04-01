	section .text
	
;;; accepts an exit code and terminates current process
exit:
	mov rax, 60
	syscall
	ret

;;; accepts an pointer to a string and return its length
string_length:	
	xor rax, rax
.loop:
	cmp byte [rdi + rax], 0
	je .end
	inc rax
	jmp .loop
.end:
	ret

;;; accepts an pointer to a null-terminated string and prints it to stdout
print_string:
	push rdi
	call string_length
	pop rsi

	mov rdx, rax		; get str length and save it to rdx
	
	mov rax, 1		; syscall no.
	mov rdi, 1		; stdout
	syscall
	ret

print_char:
	push rdi
	mov rdi, rsp
	call print_string
	pop rdi
	ret

print_newline:
	mov rdi, 10
	jmp print_char

print_uint:
	mov rax, rdi
	mov rdi, rsp
	push 0
	sub rsp, 16		; alloc buffer, 24 * 8
	dec rdi			; rdi -> last byte of buffer
	mov r8, 10
.loop:
	xor rdx, rdx		; rdx must be clean
	div r8
	or dl, 0x30		; add 0x30 to ascii
	dec rdi			; leave last byte null-terminated
	mov [rdi], dl
	test rax, rax
	jnz .loop
	
	call print_string	; rdi -> first byte of string
	add rsp, 24		; release buffer
	ret

print_int:
	test rdi, rdi
	jns print_uint		; test SF flag
	push rdi
	mov rdi, '-'
	call print_char
	pop rdi
	neg rdi			; rdi = -rdi
	call print_uint

read_char:
	mov rax, 0
	mov rdi, 0
	push 0
	mov rsi, rsp
	mov rdx, 1
	syscall
	pop rax
	ret

read_word:
	push r14
	push r15
	xor r14, r14		; use r14 as buffer offset
	mov r15, rsi		; r15 save buffer length

.A:
	push rdi
	call read_char
	pop rdi
	cmp al, ' '
	je .A
	cmp al, 13,		; ignore ' ', 13, 10, 9
	je .A
	cmp al, 10,
	je .A
	cmp al, 9
	je .A
	test al, al		; if read_char retunrs 0, end
	jz .C
	
	mov byte [rdi + r14], al ; save char to buffer
	inc r14

	cmp r14, r15
	jne .A

.C:
	mov rax, rdi
	mov rdx, r14
	pop r15
	pop r14
	ret

parse_uint:
	mov r8, 10
	xor rcx, rcx
	xor rax, rax

.loop:
	movzx r9, byte[rdi + rcx]
	inc rcx
	
	cmp r9b, '0'
	jb .end
	cmp r9b, '9'
	ja .end

	xor rdx, rdx
	mul r8
	and r9, 0x0f
	add rax, r9
	jmp .loop
.end:	
	mov rdx, rcx
	ret

parse_int:
	mov al, byte[rdi]
	cmp al, '-'
	je .signed
	jmp parse_uint
.signed:
	inc rdi
	call parse_uint
	neg rax
	test rdx, rdx
	jz .error
	inc rdx
	ret
.error:
	xor rax, rax
	ret

string_equals:
	mov al, byte[rdi]
	cmp al, byte[rsi]
	jne .no

	inc rdi
	inc rsi
	test al, al
	jnz string_equals
	mov rax, 1
	ret
.no:
	xor rax, rax
	ret
	

string_copy:
	push rsi
.loop:
	mov al, byte[rdi]
	test al, al
	jz .end
	mov byte[rsi], al
	inc rdi
	inc rsi
	dec rdx
	test rdx, rdx
	jnz .loop
.end:
	pop rax
	ret
